import 'package:chatbotbnn/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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
            color: Colors.white,
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
                              color: Colors.white
                                  .withOpacity(0.6), // White overlay
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
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                              Color(0xFFF04A23), // Màu đỏ cam
                              Color(0xFFF16C18), // Màu cam đậm
                              Color(0xFFF18F0D), // Màu cam sáng
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'Tạo tài khoản',
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
                                        return 'Vui lòng nhập Họ tên';
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(color: Colors.black),
                                    // controller: _usernameController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          237, 250, 248, 248),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      hintText: 'Họ tên',
                                      hintStyle: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: const Color(0xFF064265)),
                                      prefixIcon: const Icon(
                                        Icons.account_box_outlined,
                                        size: 24,
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
                                    height: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ShaderMask(
                                            shaderCallback: (bounds) =>
                                                const LinearGradient(
                                              colors: [
                                                Color(0xFFF04A23), // Màu đỏ cam
                                                Color(
                                                    0xFFF16C18), // Màu cam đậm
                                                Color(
                                                    0xFFF18F0D), // Màu cam sáng
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ).createShader(bounds),
                                            child: Text(
                                              'Email',
                                              style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  color:
                                                      const Color(0xFF064265)),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '*',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                color: Colors.red),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Vui lòng nhập email';
                                              }
                                              return null;
                                            },
                                            style: const TextStyle(
                                                color: Colors.black),
                                            controller: _passwordController,
                                            obscureText: !_isPasswordVisible,
                                            decoration: InputDecoration(
                                              hintText: 'Email',
                                              hintStyle: GoogleFonts.inter(
                                                fontSize: 16,
                                                color: const Color(0xFF064265),
                                              ),
                                              filled: true,
                                              fillColor: const Color.fromARGB(
                                                  237, 250, 248, 248),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.email_outlined,
                                                size: 24,
                                                color: Color(0xFF064265),
                                              ),
                                              // suffixIcon: IconButton(
                                              //   icon: Icon(
                                              //     _isPasswordVisible
                                              //         ? Icons
                                              //             .visibility_outlined
                                              //         : Icons
                                              //             .visibility_off_outlined,
                                              //     color: const Color.fromARGB(
                                              //         236, 85, 80, 80),
                                              //     size: 18,
                                              //   ),
                                              //   onPressed: () {
                                              //     setState(() {
                                              //       _isPasswordVisible =
                                              //           !_isPasswordVisible;
                                              //     });
                                              //   },
                                              // ),
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
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Vui lòng nhập mật khẩu';
                                                }
                                                return null;
                                              },
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              // controller: _usernameController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: const Color.fromARGB(
                                                    237, 250, 248, 248),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                hintText: 'Mật khẩu',
                                                hintStyle: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    color: const Color(
                                                        0xFF064265)),
                                                prefixIcon: const Icon(
                                                  Icons.password,
                                                  size: 24,
                                                  color: Color(0xFF064265),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Vui lòng xác nhận mật khẩu';
                                                }
                                                return null;
                                              },
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              // controller: _usernameController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: const Color.fromARGB(
                                                    237, 250, 248, 248),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                hintText: 'Xác nhận mật khẩu',
                                                hintStyle: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    color: const Color(
                                                        0xFF064265)),
                                                prefixIcon: const Icon(
                                                  Icons.password_outlined,
                                                  size: 24,
                                                  color: Color(0xFF064265),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
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
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          // onTap: _login,
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFFF04A23),
                                    Color(0xFFF16C18),
                                    Color(0xFFF18F0D),
                                  ],
                                  center: Alignment.center,
                                  radius: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10)),
                            height: 50,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                'Đăng ký',
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
                            Text('Đã có tài khoản?',
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
                                      builder: (context) => const LoginPage()),
                                );
                              },
                              child: Text(
                                ' Đăng nhập',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
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
                          // onTap: _login,
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
                                  width: 5,
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
      'Sai Họ tên hoặc mật khẩu.',
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
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const AppScreen()),
    // );
  });
}
