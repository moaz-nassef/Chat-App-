import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  // ✅ Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ✅ متغيرات إظهار/إخفاء الباسورد
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool isLoading = false;

  // ✅ Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Animation
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ✅ Function للتسجيل
  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      isLoading = true;
      // TODO: إضافة الـ signup logic هنا
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');

      try {
        var auth = FirebaseAuth.instance;

        UserCredential user = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // تحديث اسم المستخدم
        await user.user!.updateDisplayName(_nameController.text.trim());
        await user.user!.reload();

        print("✔ تم إنشاء الحساب بنجاح!");
        print("User: ${user.user!.email}");
        print("Name: ${user.user!.displayName}");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✔ تم إنشاء الحساب بنجاح")));
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء الحساب بنجاح! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );


        Navigator.pushReplacementNamed(context, "/login");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "❌ خطأ: The password provided is too weak.",
              style: TextStyle(color: Colors.black),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "❌ خطأ: The account already exists for that email.",
              style: TextStyle(color: Colors.black),
            ),
          );
        }
      } catch (e) {
        print(e);
      }
      isLoading = false;
      setState(() {});
    }

    // Navigate to login or home
    // Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7), Color(0xFFCE93D8)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // ✅ الصور الخلفية
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
                // Positioned(
                //   right: 0,
                //   bottom: 0,
                //   child: Image.asset(
                //     'assets/images/login_background.png',
                //     width: 100,
                //     height: 100,
                //     fit: BoxFit.contain,
                //   ),
                // ),
      
                // ✅ المحتوى الرئيسي
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 30),
      
                              // ✅ العنوان
                              Text(
                                "إنشاء حساب جديد",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A1B9A),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF8E24AA),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
      
                              SizedBox(height: 15),
      
                              // // ✅ الأيقونة
                              Container(
                                // padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
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
                                  "assets/icons/signup.svg",
                                  height: 200,
                                ),
                              ),
      
                              // SvgPicture.asset(
                              //   "assets/icons/signup.svg",
                              //   height: 200,
                              // ),
                              SizedBox(height: 15),
      
                              // ✅ Name Field
                              _buildTextField(
                                controller: _nameController,
                                hintText: "الاسم الكامل",
                                hintTextEn: "Full Name",
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'من فضلك أدخل الاسم';
                                  }
                                  if (value.length < 3) {
                                    return 'الاسم قصير جداً';
                                  }
                                  return null;
                                },
                              ),
      
                              SizedBox(height: 18),
      
                              // ✅ Email Field
                              _buildTextField(
                                controller: _emailController,
                                hintText: "البريد الإلكتروني",
                                hintTextEn: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'من فضلك أدخل البريد الإلكتروني';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'البريد الإلكتروني غير صحيح';
                                  }
                                  return null;
                                },
                              ),
      
                              SizedBox(height: 18),
      
                              // ✅ Password Field
                              _buildTextField(
                                controller: _passwordController,
                                hintText: "كلمة المرور",
                                hintTextEn: "Password",
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Color(0xFF9C27B0),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'من فضلك أدخل كلمة المرور';
                                  }
                                  if (value.length < 6) {
                                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
      
                              SizedBox(height: 18),
      
                              // ✅ Confirm Password Field
                              _buildTextField(
                                controller: _confirmPasswordController,
                                hintText: "تأكيد كلمة المرور",
                                hintTextEn: "Confirm Password",
                                icon: Icons.lock_outline,
                                obscureText: _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Color(0xFF9C27B0),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'من فضلك أكد كلمة المرور';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'كلمة المرور غير متطابقة';
                                  }
                                  return null;
                                },
                              ),
      
                              SizedBox(height: 30),
      
                              // ✅ Sign Up Button
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
                                  onPressed: _handleSignup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF9C27B0),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'إنشاء حساب - SIGN UP',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
      
                              SizedBox(height: 20),
      
                              // ✅ Login link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        color: Color(0xFF7B1FA2),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
      
                              SizedBox(height: 20),
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

  // ✅ TextField Builder
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
        color: Colors.white.withValues(alpha: 0.9),
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
