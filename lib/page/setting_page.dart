import 'package:chatbotbnn/model/body_forget_password.dart';
import 'package:chatbotbnn/model/respone_forgetpassword.dart';
import 'package:chatbotbnn/page/login_page.dart';
import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:chatbotbnn/service/forget_password_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final styleText = GoogleFonts.inter(
      fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500);
  final List<Map<String, dynamic>> languages = [
    {'locale': const Locale('vi'), 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'locale': const Locale('en'), 'name': 'English', 'flag': '🇺🇸'},
  ];
  Locale? selectedLocale;
  @override
  void initState() {
    super.initState();
    selectedLocale = languages.first['locale']; // Đặt mặc định
  }

  Widget _buildColorSelector(BuildContext context) {
    final colors = [
      Colors.white, // Màu trắng
      const Color(0xFF284973),
      const Color(0xff48433d),
    ];

    return Consumer<Providercolor>(
      builder: (context, providerColor, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: colors.map((color) {
            final isSelected = providerColor.selectedColor == color;

            return GestureDetector(
              onTap: () => providerColor.changeColor(color),
              child: Container(
                margin: const EdgeInsets.all(6),
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: color.withOpacity(0.5), blurRadius: 8)
                        ]
                      : [],
                ),
                child: Center(
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.black, size: 18)
                      : const SizedBox(height: 23),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  void showChangePasswordDialog(BuildContext context) {
    final selectedColors =
        Provider.of<Providercolor>(context, listen: false).selectedColor;
    final textStyles = GoogleFonts.inter(fontSize: 16, color: Colors.black);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Đổi mật khẩu",
            style: GoogleFonts.inter(fontSize: 20, color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(
                  labelText: "Nhập mật khẩu cũ",
                  hintStyle: textStyles,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOldPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                      size: 23,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureOldPassword,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: "Nhập mật khẩu mới",
                  hintStyle: textStyles,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                      size: 23,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureNewPassword,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu mới",
                  hintStyle: textStyles,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                      size: 23,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Hủy",
                selectionColor: selectedColors,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Đóng bàn phím nếu đang mở
                FocusScope.of(context).unfocus();

                String oldPassword = oldPasswordController.text.trim();
                String newPassword = newPasswordController.text.trim();
                String confirmPassword = confirmPasswordController.text.trim();

                if (oldPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Vui lòng nhập đầy đủ thông tin")),
                  );
                  return;
                }

                if (newPassword.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Mật khẩu mới phải có ít nhất 6 ký tự")),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Mật khẩu mới không trùng khớp")),
                  );
                  return;
                }

                // Gọi hàm xử lý đổi mật khẩu
                handleForgetPassword(context);
              },
              child: Text(
                "Lưu",
                style: textStyles,
              ),
            ),
          ],
        );
      },
    );
  }

  void handleForgetPassword(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');
    String? userName = prefs.getString('username');

    BodyForgetPassword requestBody = BodyForgetPassword(
      passwordHash: oldPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
      newConfirmPassword: confirmPasswordController.text.trim(),
      username: userName,
      userId: userId,
    );

    ResponeForgetpassword response = await forgetPassword(requestBody);

    if (response.results == true) {
      print("Thành công: ${response.message}");

      // Xóa dữ liệu phiên đăng nhập
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false);
    } else {
      print("Thất bại: ${response.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${response.message}")),
      );
    }
  }

  Future<void> showUserInfoDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy dữ liệu từ SharedPreferences
    String? userName = prefs.getString('username') ?? "";
    String? fullName = prefs.getString('full_name') ?? "";
    String? email = prefs.getString('email') ?? "";

    // Gán dữ liệu vào TextEditingController
    TextEditingController usernameController = TextEditingController(
      text: userName,
    );
    TextEditingController fullNameController =
        TextEditingController(text: fullName);
    TextEditingController emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sửa người dùng',
            style: GoogleFonts.inter(fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTextField("Tài khoản", usernameController),
              buildTextField("Họ và tên", fullNameController),
              buildTextField("Email", emailController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Đóng',
                style: GoogleFonts.inter(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Lưu thông tin vào SharedPreferences
                await prefs.setString('username', usernameController.text);
                await prefs.setString('full_name', fullNameController.text);
                await prefs.setString('email', emailController.text);

                Navigator.pop(context);
              },
              child: Text('Lưu', style: GoogleFonts.inter(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_box,
                  size: 23,
                  color: selectedColor == Colors.white
                      ? const Color(0xFFFef6622)
                      : selectedColor,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    showUserInfoDialog(context);
                  },
                  child: Text('Tài khoản của bạn', style: styleText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.search,
                  size: 23,
                  color: selectedColor == Colors.white
                      ? const Color(0xFFFef6622)
                      : selectedColor,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    showChangePasswordDialog(context);
                  },
                  child: Text('Đổi mật khẩu', style: styleText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.color_lens,
                  size: 23,
                  color: selectedColor == Colors.white
                      ? const Color(0xFFFef6622)
                      : selectedColor,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {},
                  child: Text('Màu sắc:', style: styleText),
                ),
                _buildColorSelector(context),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.black),
            Row(
              children: [
                Icon(
                  Icons.logout_outlined,
                  size: 23,
                  color: selectedColor == Colors.white
                      ? const Color(0xFFFef6622)
                      : selectedColor,
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                    onPressed: () {
                      _showAlertDialog(context);
                    },
                    child: Text('Đăng xuất', style: styleText))
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final selectedColor =
              Provider.of<Providercolor>(context).selectedColor;
          return AlertDialog(
            title: Container(
                // margin: const EdgeInssets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent),
                child: Center(
                  child: Text(
                    'Thông báo!',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black),
                  ),
                )),
            content: Text(
              'Bạn có muốn đăng xuất tài khoản không?',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: selectedColor == Colors.white
                      ? const Color(0xFFFef6622)
                      : selectedColor),
            ),
            actions: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                    border: Border.all(
                        width: 1,
                        color:
                            Provider.of<Providercolor>(context).selectedColor)),
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.inter(
                          color: selectedColor == Colors.white
                              ? const Color(0xFFFef6622)
                              : selectedColor),
                    )),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor == Colors.white
                      ? const Color(0xFFFef6622)
                      : selectedColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide.none,
                  ),
                ),
                onPressed: () async {
                  try {
                    // Thực hiện đăng xuất bằng cách xóa token
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token'); // Xóa token hiện tại
// Thêm vào trước khi xóa token
                    await FirebaseAuth.instance.signOut();
// Thêm vào trước khi xóa token
                    await GoogleSignIn().signOut();
                    // Chuyển đến trang đăng nhập và xóa hết lịch sử navigation
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false,
                    );

                    // (Tùy chọn) Thêm thông báo đăng xuất thành công
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đăng xuất thành công'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    print('Lỗi khi đăng xuất: $e');
                    // (Tùy chọn) Thông báo lỗi nếu cần
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Có lỗi xảy ra khi đăng xuất'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text(
                  'Xác nhận',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              )
            ],
          );
        });
  }
}
