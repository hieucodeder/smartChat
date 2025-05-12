import 'package:smart_chat/model/body_forget_password.dart';
import 'package:smart_chat/model/respone_forgetpassword.dart';
import 'package:smart_chat/page/login_page.dart';
import 'package:smart_chat/provider/navigation_provider.dart';
import 'package:smart_chat/provider/provider_color.dart';
import 'package:smart_chat/service/forget_password_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_chat/service/get_by_id_service.dart';

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

  void showChangePasswordDialog(BuildContext context) {
    final selectedColors =
        Provider.of<Providercolor>(context, listen: false).selectedColor;
    final textStyles = GoogleFonts.inter(fontSize: 16, color: Colors.white);

    // Biến trạng thái
    bool isOldPasswordVisible = false;
    bool isNewPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Đổi mật khẩu",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: !isOldPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Nhập mật khẩu cũ",
                      hintStyle: textStyles,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isOldPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF064265),
                        ),
                        onPressed: () {
                          setState(() {
                            isOldPasswordVisible = !isOldPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newPasswordController,
                    obscureText: !isNewPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Nhập mật khẩu mới",
                      hintStyle: textStyles,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF064265),
                          size: 23,
                        ),
                        onPressed: () {
                          setState(() {
                            isNewPasswordVisible = !isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Xác nhận mật khẩu mới",
                      hintStyle: textStyles,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF064265),
                          size: 23,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                      border: Border.all(width: 1, color: selectedColors)),
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Hủy',
                        style: GoogleFonts.inter(
                            color: selectedColors == Colors.white
                                ? const Color(0xfffef6622)
                                : selectedColors),
                      )),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColors == Colors.white
                        ? const Color(0xfffef6622)
                        : selectedColors,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide.none,
                    ),
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();

                    String oldPassword = oldPasswordController.text.trim();
                    String newPassword = newPasswordController.text.trim();
                    String confirmPassword =
                        confirmPasswordController.text.trim();

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
                            content:
                                Text("Mật khẩu mới phải có ít nhất 6 ký tự")),
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
    final response = await fetchGetById();

    // Nếu response null, thông báo lỗi
    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải thông tin người dùng')),
      );
      return;
    }

    // Dữ liệu từ API
    String userName = response.username ?? '';
    String fullName = response.fullName ?? '';
    String email = response.email ?? '';
    String phoneNumber = response.phoneNumber ?? "";
    String address = response.address ?? "";
    String pictureUrl = response.picture ?? "";

    // Gán vào controller
    TextEditingController usernameController =
        TextEditingController(text: userName);
    TextEditingController fullNameController =
        TextEditingController(text: fullName);
    TextEditingController emailController = TextEditingController(text: email);
    TextEditingController phoneNumberController =
        TextEditingController(text: phoneNumber);
    TextEditingController addressController =
        TextEditingController(text: address);
    TextEditingController pictureController =
        TextEditingController(text: pictureUrl);

    final selectedColors =
        Provider.of<Providercolor>(context, listen: false).selectedColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sửa người dùng',
            style: GoogleFonts.inter(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview ảnh động từ URL controller
                    if (pictureController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(pictureController.text),
                          backgroundColor: Colors.grey[200],
                          onBackgroundImageError: (_, __) {
                            setState(() {
                              pictureController.text = '';
                            });
                          },
                        ),
                      ),
                    buildTextField("Tài khoản", usernameController),
                    buildTextField("Họ và tên", fullNameController),
                    buildTextField("Email", emailController),
                    buildTextField("Điện thoại", phoneNumberController),
                    buildTextField("Địa chỉ", addressController),
                  ],
                ),
              );
            },
          ),
          actions: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
                border: Border.all(width: 1, color: selectedColors),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Hủy',
                  style: GoogleFonts.inter(
                    color: selectedColors == Colors.white
                        ? const Color(0xfffef6622)
                        : selectedColors,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedColors == Colors.white
                    ? const Color(0xfffef6622)
                    : selectedColors,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide.none,
                ),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('username', usernameController.text);
                await prefs.setString('full_name', fullNameController.text);
                await prefs.setString('email', emailController.text);
                await prefs.setString(
                    'phone_number', phoneNumberController.text);
                await prefs.setString('address', addressController.text);
                await prefs.setString('picture', pictureController.text);
                Navigator.pop(context);
              },
              child: Text(
                'Lưu',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
              ),
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
          hintStyle: GoogleFonts.inter(fontSize: 16, color: Colors.black),
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
                      ? const Color(0xfffef6622)
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
                  Icons.lock,
                  size: 23,
                  color: selectedColor == Colors.white
                      ? const Color(0xfffef6622)
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
                      ? const Color(0xfffef6622)
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
                      ? const Color(0xfffef6622)
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
                      ? const Color(0xfffef6622)
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
                              ? const Color(0xfffef6622)
                              : selectedColor),
                    )),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor == Colors.white
                      ? const Color(0xfffef6622)
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
                    Provider.of<NavigationProvider>(context, listen: false)
                        .setCurrentIndex(1);

                    // Quay về LoginPage, xóa mọi trang trước đó
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
