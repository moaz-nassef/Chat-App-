import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  // ✅ Controllers للـ TextFields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ✅ متغير إظهار/إخفاء الباسورد
  bool _obscureText = true;

  // ✅ Form key للـ validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Animation controller
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ✅ Function للـ Login
 void _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    setState(() => isLoading = true);

    try {
      var auth = FirebaseAuth.instance;

      // تسجيل الدخول
      UserCredential user = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print("✔ تم تسجيل الدخول!");
      print("User: ${user.user!.email}");
      print("Name: ${user.user!.displayName}");

      // رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✔ تم تسجيل الدخول بنجاح! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, "/chat");


      // الانتقال إلى صفحة الشات

    } on FirebaseAuthException catch (e) {
      String errorMessage = "";

      if (e.code == 'user-not-found') {
        errorMessage = "❌ هذا الإيميل غير مسجل";
      } else if (e.code == 'wrong-password') {
        errorMessage = "❌ كلمة المرور غير صحيحة";
      } else if (e.code == 'invalid-email') {
        errorMessage = "❌ صيغة الإيميل غير صالحة";
      } else if (e.code == 'user-disabled') {
        errorMessage = "❌ هذا الحساب تم تعطيله";
      } else {
        errorMessage = "❌ خطأ غير متوقع: ${e.message}";
      }

      // عرض رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ حدث خطأ غير متوقع"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall:isLoading,
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.zero,
      
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7), Color(0xFFCE93D8)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // ✅ الصور الخلفية بأحجام أكبر
                Positioned(
                  top: 0,
                  left: 0,
                  child: Image.asset(
                    "assets/images/main_top.png",
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Image.asset(
                    'assets/images/login_bottom.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
      
                // ✅ المحتوى الرئيسي
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 40),
      
                              // ✅ العنوان
                              Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A1B9A),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                "Login Page",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF8E24AA),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
      
                              SizedBox(height: 30),
      
                              // ✅ الأيقونة مع shadow
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(1),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF9C27B0).withOpacity(0.3),
                                      blurRadius: 25,
                                      offset: Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/login.svg",
                                  height: 200,
                                ),
                              ),
      
                              SizedBox(height: 40),
      
                              // ✅ Email Field
                              _buildTextField(
                                controller: _emailController,
                                hintText: "البريد الإلكتروني",
                                hintTextEn: "Your Email",
                                icon: Icons.person,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'من فضلك أدخل البريد الإلكتروني';
                                  }
                                  if (!value.contains('@')) {
                                    return 'البريد الإلكتروني غير صحيح';
                                  }
                                  return null;
                                },
                              ),
      
                              SizedBox(height: 20),
      
                              // ✅ Password Field
                              _buildTextField(
                                controller: _passwordController,
                                hintText: "كلمة المرور",
                                hintTextEn: "Password",
                                icon: Icons.lock,
                                obscureText: _obscureText,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Color(0xFF9C27B0),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'من فضلك أدخل كلمة المرور';
                                  }
                                  if (value.length < 6) {
                                    return 'كلمة المرور قصيرة جداً';
                                  }
                                  return null;
                                },
                              ),
      
                              SizedBox(height: 12),
      
                              // ✅ Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Navigate to forgot password
                                  },
                                  child: Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      color: Color(0xFF7B1FA2),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
      
                              SizedBox(height: 20),
      
                              // ✅ Login Button
                              Container(
                                width: 280,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF9C27B0).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF9C27B0),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'تسجيل الدخول - LOGIN',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
      
                              SizedBox(height: 20),
      
                              // ✅ Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/signup');
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'إنشاء حساب',
                                      style: TextStyle(
                                        color: Color(0xFF7B1FA2),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
      
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ TextField Builder - عشان نقلل التكرار
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String hintTextEn,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF9C27B0), size: 24),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintText: '$hintText - $hintTextEn',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }
}
