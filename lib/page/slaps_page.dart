import 'package:chatbotbnn/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
                child: SvgPicture.asset('resources/bg.svg', fit: BoxFit.cover),
              ),

              // Logo ở góc trên bên phải
              Positioned(
                top: 50, // Khoảng cách từ trên xuống
                left: 20, // Khoảng cách từ phải vào
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: SvgPicture.asset(
                    'resources/logo_1.svg',
                    width: 50, // Kích thước logo
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Logo ở góc trên bên phải
              Positioned(
                top: 300, // Khoảng cách từ dưới lên
                left: 20, // Khoảng cách từ trái vào
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Căn chỉnh văn bản về bên trái
                  children: [
                    Text(
                      'SmartChat:',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    Text('Kinh doanh vượt trội',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                    Text('24/7 với trợ lý AI',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                    // Text('Cao cấp, thực tế, thông minh, đơn giản',
                    //     style: GoogleFonts.inter(
                    //         color: Colors.white,
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
