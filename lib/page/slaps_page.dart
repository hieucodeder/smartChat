import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_chat/page/login_page.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'resources/bg.svg',
                  fit: BoxFit.cover,
                ),
              ),

              // Logo góc trên bên trái
              Positioned(
                top: screenSize.height * 0.05,
                left: screenSize.width * 0.03,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'resources/logo_1.png',
                    width: isTablet ? 220 : 180,
                    height: isTablet ? 80 : 65,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Text ở giữa (khoảng 35% từ trên xuống)
              Positioned(
                top: screenSize.height * 0.35,
                left: screenSize.width * 0.05,
                right: screenSize.width * 0.05,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SmartChat:',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isTablet ? 40 : 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kinh doanh vượt trội',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isTablet ? 40 : 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'với Trợ lý AI',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isTablet ? 40 : 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
