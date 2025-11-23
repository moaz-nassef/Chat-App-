import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // begin: Alignment.topCenter,
              // end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF3E5F5), // Light purple
                Color(0xFFE1BEE7),
                Color(0xFFCE93D8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // ✅ الصور الخلفية تحت (أول حاجة في الـ Stack)
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/main_top.png',
                  width: 150, // ✅ العرض
                  height: 150, // ✅ الارتفاع
                  fit: BoxFit.contain,
                ),
              ),

              // ✅ زرار الرجوع
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF6A1B9A),
                    size: 30,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    padding: EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    shadowColor: Color(0xFF9C27B0).withOpacity(0.3),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/main_bottom.png',
                  width: 120, // ✅ العرض
                  height: 120, // ✅ الارتفاع
                  fit: BoxFit.contain,
                ),
              ),

              // ✅ المحتوى الرئيسي فوق
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),

                        // Welcome text
                        Text(
                          "مرحباً بك",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF8E24AA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 30),

                        // SVG Icon with shadow
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF9C27B0).withOpacity(0.3),
                                blurRadius: 30,
                                offset: Offset(0, 15),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/chat.svg',
                            height: 300,
                          ),
                        ),

                        SizedBox(height: 40),

                        // ✅ LOGIN Button
                        _buildAnimatedButton(
                          context: context,
                          text: 'تسجيل الدخول',
                          textEn: 'LOGIN',
                          isPrimary: true,
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          delay: 200,
                        ),

                        SizedBox(height: 20), // ✅ المسافة بين الأزرار
                        // ✅ SIGNUP Button
                        _buildAnimatedButton(
                          context: context,
                          text: 'إنشاء حساب',
                          textEn: 'SIGNUP',
                          isPrimary: false,
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          delay: 400,
                        ),

                        Spacer( 
                          
                        ),

                        // Optional: Skip button
                        TextButton(
                          onPressed: () {
                            // Skip to main screen
                          },
                          child: Text(
                            'Skip for now',
                            style: TextStyle(
                              color: Color(0xFF7B1FA2),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Button Builder - عشان نقلل التكرار
  Widget _buildAnimatedButton({
    required BuildContext context,
    required String text,
    required String textEn,
    required bool isPrimary,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color:
                  isPrimary
                      ? Color(0xFF9C27B0).withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isPrimary
                    ? Color(0xFF9C27B0) // Purple
                    : Colors.white,
            foregroundColor: isPrimary ? Colors.white : Color(0xFF9C27B0),
            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: isPrimary ? Colors.transparent : Color(0xFF9C27B0),
                width: 2,
              ),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Text(
                textEn,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
