import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Shared scaffold for auth screens: gradient background,
/// corner decoration images, and a fade+slide entrance animation
/// for [child].
class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.gradientColors = AppColors.purpleGradient,
    this.showBottomDecoration = true,
  });

  final Widget child;
  final List<Color> gradientColors;
  final bool showBottomDecoration;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.gradientColors,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/main_top.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              if (widget.showBottomDecoration)
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
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(position: _slide, child: widget.child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
