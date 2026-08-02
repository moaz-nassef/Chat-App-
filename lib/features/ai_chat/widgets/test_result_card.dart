import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Animated outcome of the "Test connection" button:
/// green card (reply + latency) on success, red card on failure.
/// Appears/disappears with a size + fade transition.
class TestResultCard extends StatelessWidget {
  const TestResultCard({super.key, this.reply, this.latencyMs, this.error});

  final String? reply;
  final int? latencyMs;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (error != null) {
      return _ResultContainer(
        key: const ValueKey('error'),
        color: AppColors.error,
        icon: Icons.error_outline,
        title: 'فشل الاتصال',
        body: error!,
      );
    }
    if (reply != null) {
      return _ResultContainer(
        key: const ValueKey('success'),
        color: AppColors.success,
        icon: Icons.check_circle_outline,
        title:
            latencyMs != null
                ? 'الاتصال ناجح (${latencyMs}ms)'
                : 'الاتصال ناجح',
        body: 'رد الموديل: $reply',
      );
    }
    return const SizedBox.shrink(key: ValueKey('none'));
  }
}

class _ResultContainer extends StatelessWidget {
  const _ResultContainer({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
