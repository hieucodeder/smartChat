import 'package:chatbotbnn/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlapsPage extends StatefulWidget {
  const SlapsPage({super.key});

  @override
  State<SlapsPage> createState() => _SlapsPageState();
}

class _SlapsPageState extends State<SlapsPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().whenComplete(() {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset('resources/bgr1.png', fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Image.asset('resources/bgr2.png', fit: BoxFit.cover),
              ),
              // Các logo hiển thị bên dưới
              Positioned(
                bottom: 10, // Điều chỉnh vị trí logo
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Image.asset('resources/login.png'),
                    Image.asset('resources/login1.png'),
                    Image.asset('resources/login2.png'),
                  ],
                ),
              ),
              // Ảnh chính hiển thị trên cùng
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'resources/Smartchat-1.png',
                    width: double.infinity, // Để nhỏ lại, tránh che logo
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
