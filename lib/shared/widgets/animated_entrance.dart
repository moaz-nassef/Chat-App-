import 'package:flutter/material.dart';

/// Reusable staggered entrance: fades in + slides up once, delayed by
/// [index] so sibling items appear one after another.
///
/// ```dart
/// Column(children: [
///   AnimatedEntrance(index: 0, child: title),
///   AnimatedEntrance(index: 1, child: form),
/// ])
/// ```
class AnimatedEntrance extends StatelessWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 800),
    this.slideOffset = 24,
  });

  final Widget child;

  /// Stagger position — each step delays the entrance a bit more.
  final int index;

  final Duration duration;

  /// How many logical pixels the child slides up from.
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.10).clamp(0.0, 0.6);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
