// file: lib/page/register_page.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smart_chat/page/login_page.dart';
import 'package:smart_chat/service/singnup_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _userNameController = TextEditingController();

  final _signupService = SignupService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _onRegisterTap() async {
    // 1) Validate form
    if (!_formKey.currentState!.validate()) return;

    // 2) Check password match
    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu và xác nhận không khớp')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3) Call service
    final result = await _signupService.signup(
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      fullName: _fullNameController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmController.text,
      phoneNumber: _phoneController.text.trim(),
      picture: "",
      userName: _userNameController.text.trim(),
    );

    if (kDebugMode) print('Signup result: $result');

    setState(() => _isLoading = false);

    // 4) Handle result
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại')),
      );
      return;
    }

    final message = (result['message'] as String?) ?? 'Đăng ký thành công';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '$message. Vui lòng kiểm tra email để kích hoạt tài khoản.')),
    );

    // 5) Navigate to login
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          _buildBackground(),
          Form(
            key: _formKey,
            child: _buildForm(),
          ),
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset('resources/bg1.svg', fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFEDDA),
                  Color(0xFFF28411),
                  Color(0xFFF16C18)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.6)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFAF8F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(5),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
      child: Column(
        children: [
          Image.asset('resources/Smartchat-1.png', width: 300, height: 150),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          // Họ và tên
          TextFormField(
            controller: _fullNameController,
            decoration: inputDecoration.copyWith(
              hintText: 'Họ tên',
              prefixIcon:
                  const Icon(Icons.person_2_outlined, color: Color(0xFF064265)),
            ),
            validator: (v) => v!.isEmpty ? 'Vui lòng nhập Họ tên' : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Username
              SizedBox(
                height: 46,
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextFormField(
                  controller: _userNameController,
                  decoration: inputDecoration.copyWith(
                    hintText: 'Tài khoản',
                    prefixIcon: const Icon(Icons.account_box_outlined,
                        color: Color(0xFF064265)),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Vui lòng nhập Tài khoản' : null,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              SizedBox(
                height: 46,
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextFormField(
                  controller: _addressController,
                  decoration: inputDecoration.copyWith(
                    hintText: 'Địa chỉ',
                    prefixIcon: const Icon(Icons.home_outlined,
                        color: Color(0xFF064265)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập Địa chỉ' : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 46,
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextFormField(
                  controller: _emailController,
                  decoration: inputDecoration.copyWith(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFF064265)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập Email' : null,
                ),
              ),
              const SizedBox(width: 5),
              // Điện thoại
              SizedBox(
                height: 46,
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextFormField(
                  controller: _phoneController,
                  decoration: inputDecoration.copyWith(
                    hintText: 'Điện thoại',
                    prefixIcon: const Icon(Icons.phone_enabled_outlined,
                        color: Color(0xFF064265)),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Vui lòng nhập Số điện thoại' : null,
                ),
              ),
            ],
          ),
          // Email

          const SizedBox(height: 20),

          Row(
            children: [
              // Mật khẩu
              SizedBox(
                height: 46,
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: inputDecoration.copyWith(
                    hintText: 'Mật khẩu',
                    prefixIcon:
                        const Icon(Icons.password, color: Color(0xFF064265)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF064265),
                      ),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Vui lòng nhập Mật khẩu' : null,
                ),
              ),
              const SizedBox(width: 5),

              // Xác nhận mật khẩu
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                height: 46,
                child: TextFormField(
                  controller: _passwordConfirmController,
                  obscureText: !_isPasswordVisible,
                  decoration: inputDecoration.copyWith(
                    hintText: 'Xác nhận mật khẩu',
                    prefixIcon: const Icon(Icons.password_outlined,
                        color: Color(0xFF064265)),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Vui lòng xác nhận Mật khẩu' : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Nút Đăng ký
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _onRegisterTap,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF18F0D),
                      Color(0xFFF16C18),
                      Color(0xFFF04A23)
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: const Center(
                  child: Text('Đăng ký',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Đã có tài khoản',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      color: const Color(0xFF565656),
                      fontWeight: FontWeight.w400 // Màu xám
                      )),
              Container(
                height: 20, // Chiều cao của Divider
                width: 1, // Độ dày của Divider
                color: const Color(0xFF565656),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                child: Text(
                  'Đăng nhập',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
