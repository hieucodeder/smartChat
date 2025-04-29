import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_chat/model/body_login.dart';
import 'package:smart_chat/page/app_screen.dart';
import 'package:smart_chat/page/forgot_password_page.dart';
import 'package:smart_chat/page/register_page.dart';
import 'package:smart_chat/service/login_service.dart';
import 'package:smart_chat/service/user_singin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _loginService = LoginService();

  bool _isLoading = false; // Trạng thái đang tải

  // @override
  // void initState() {
  //   super.initState();
  //   checkFirebaseConnection();
  // }

  // Future<void> checkFirebaseConnection() async {
  //   try {
  //     // Khởi tạo GoogleSignIn
  //     final GoogleSignIn googleSignIn = GoogleSignIn();

  //     // Bắt đầu quá trình đăng nhập với Google
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  //     if (googleUser == null) {
  //       // Người dùng hủy bỏ đăng nhập
  //       print("Đăng nhập Google bị hủy bỏ.");
  //       return;
  //     }

  //     // Lấy mã xác thực từ Google
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     // Tạo thông tin đăng nhập Firebase từ Google
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // Đăng nhập vào Firebase với thông tin xác thực từ Google
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     // Kiểm tra thông tin người dùng đã đăng nhập
  //     print('Firebase Auth connected: ${userCredential.user}');
  //   } catch (e) {
  //     print('Error connecting to Firebase Auth: $e');
  //   }
  // }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang xử lý dữ liệu...')),
      );

      final String username = _usernameController.text.trim();
      final String password = _passwordController.text.trim();

      // Create BodyLogin object from username and password
      final BodyLogin loginData =
          BodyLogin(username: username, password: password);

      try {
        Map<String, dynamic>? response = await _loginService.login(loginData);

        if (response != null) {
          // Successful login
          showLoginSnackbar(context);
        } else {
          setState(() {});
          showLoginErrorSnackbar(context); // Show error if login fails
        }
      } catch (error) {
        setState(() {});
        showLoginErrorSnackbar(context); // Show error if there's an exception
      }
    } else {
      // If form validation fails
      showValidationErrorSnackbar(context, 'Vui lòng điền đầy đủ thông tin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        resizeToAvoidBottomInset: true,
        body: Container(
            constraints: const BoxConstraints.expand(),
            child: Form(
              key: _formKey,
              child: Stack(fit: StackFit.expand, children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Stack(
                          fit: StackFit.expand,
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        SvgPicture.asset(
                                          'resources/bg1.svg',
                                          fit: BoxFit.cover,
                                          height: 60,
                                          width: 100,
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFFFEDDA),
                                                Color(0xFFF28411), // Red-orange
                                                Color(0xFFF16C18),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: Colors.white.withOpacity(
                                              0.6), // White overlay
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 80),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'resources/Smartchat-1.png',
                      width: 300,
                      height: 150,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  constraints: const BoxConstraints.expand(),
                  margin: const EdgeInsets.fromLTRB(0, 130, 0, 0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 90),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFF16C18), // Màu cam đậm
                              Color(0xFFF04A23), // Màu đỏ cam
                              Color(0xFFF18F0D), // Màu cam sáng
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'Đăng nhập',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                              color: Colors.white, // Bắt buộc để hiện gradient
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập tài khoản';
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(color: Colors.black),
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          237, 250, 248, 248),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide
                                            .none, // Loại bỏ viền mặc định
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide
                                            .none, // Viền khi không focus
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:
                                            BorderSide.none, // Viền khi focus
                                      ),
                                      hintText: 'Tài khoản',
                                      hintStyle: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: const Color(0xFF064265),
                                          fontWeight: FontWeight.w300),
                                      prefixIcon: const Icon(
                                        Icons.account_box_outlined,
                                        size: 23,
                                        color: Color(0xFF064265),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Vui lòng nhập mật khẩu';
                                              }
                                              return null;
                                            },
                                            style: const TextStyle(
                                                color: Colors.black),
                                            controller: _passwordController,
                                            obscureText: !_isPasswordVisible,
                                            decoration: InputDecoration(
                                              hintText: 'Mật khẩu',
                                              hintStyle: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  color:
                                                      const Color(0xFF064265),
                                                  fontWeight: FontWeight.w300),
                                              filled: true,
                                              fillColor: const Color.fromARGB(
                                                  237, 250, 248, 248),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide
                                                    .none, // Loại bỏ viền mặc định
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide
                                                    .none, // Viền khi không focus
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide
                                                    .none, // Viền khi focus
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.lock_outline,
                                                size: 23,
                                                color: Color(0xFF064265),
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _isPasswordVisible
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color: const Color.fromARGB(
                                                      236, 85, 80, 80),
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _isPasswordVisible =
                                                        !_isPasswordVisible;
                                                  });
                                                },
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: _login,
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF18F0D),
                                    Color(0xFFF16C18),
                                    Color(0xFFF04A23),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                                borderRadius: BorderRadius.circular(10)),
                            height: 50,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                'Đăng nhập',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Quên mật khẩu?',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: const Color(0xFF565656),
                                    fontWeight: FontWeight.w400 // Màu xám
                                    )),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordPage()));
                              },
                              child: Text(
                                ' Bấm vào đây',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Container(
                              height: 20, // Chiều cao của Divider
                              width: 1, // Độ dày của Divider
                              color: Colors.black,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage()),
                                );
                              },
                              child: Text('Đăng ký',
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        const Divider(
                          color: Color(0xFFFF18F0D),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        GestureDetector(
                          onTap: () async {
                            // Gọi phương thức đăng nhập với Google từ dịch vụ
                            try {
                              // Hiển thị vòng xoay loading ngay khi bắt đầu đăng nhập
                              showDialog(
                                context: context,
                                barrierDismissible:
                                    false, // Ngăn người dùng tắt dialog bằng cách chạm ra ngoài
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              final user =
                                  await UserSinginService.loginWithGoogle();

                              if (user != null && mounted) {
                                // Tự động chuyển trang sau 2 giây
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) {
                                    Navigator.pop(
                                        context); // Đóng dialog loading thành công
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AppScreen()),
                                    );
                                  }
                                });
                              }
                            } on FirebaseAuthException catch (error) {
                              // Đóng dialog loading nếu có lỗi
                              if (mounted) Navigator.pop(context);

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Lỗi'),
                                  content:
                                      Text('Lỗi đăng nhập: ${error.message}'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } catch (e) {
                              // Đóng dialog loading nếu có lỗi
                              if (mounted) Navigator.pop(context);

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Lỗi'),
                                  content:
                                      const Text('Có lỗi xảy ra khi đăng nhập'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            height: 50,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'resources/google.svg',
                                  fit: BoxFit.cover,
                                  width: 10,
                                  height: 22,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Đăng nhập với Google',
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            )));
  }
}

void showLoginErrorSnackbar(BuildContext context) {
  final snackBar = SnackBar(
    backgroundColor: Colors.white,
    content: Text(
      'Sai tài khoản hoặc mật khẩu.',
      style: GoogleFonts.inter(color: Colors.black),
    ),
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: 'Đóng',
      textColor: Colors.black,
      onPressed: () {},
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showLoginSnackbar(BuildContext context) {
  var snackBar = SnackBar(
    backgroundColor: Colors.white,
    content: Text(
      'Đăng nhập thành công. Đang chuyển hướng....',
      style: GoogleFonts.inter(color: Colors.black),
    ),
    duration: const Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  Future.delayed(const Duration(seconds: 1), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AppScreen()),
    );
  });
}

// Thông báo check thông tin tài khoản, mật khẩu
void showValidationErrorSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    backgroundColor: Colors.white,
    content: Text(
      message,
      style: GoogleFonts.inter(color: Colors.black),
    ),
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: 'Đóng',
      textColor: Colors.black,
      onPressed: () {},
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
