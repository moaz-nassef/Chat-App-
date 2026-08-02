import 'package:flutter/material.dart';

import '../data/ai_settings.dart';

/// Grid of animated provider cards. The selected one gets a colored
/// border, a soft glow, a scale bump and an animated check badge.
class ProviderPicker extends StatelessWidget {
  const ProviderPicker({
    super.key,
    required this.selected,
    required this.savedProviders,
    required this.onSelect,
  });

  final AiProvider selected;

  /// Providers that already have a saved API key get a small dot marker.
  final Map<AiProvider, AiProviderConfig> savedProviders;
  final ValueChanged<AiProvider> onSelect;

  @override
  Widget build(BuildContext context) {
    final providers = AiProviderPreset.all.values.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: providers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final preset = providers[index];
        final isSelected = preset.provider == selected;
        final hasKey =
            (savedProviders[preset.provider]?.apiKey ?? '').isNotEmpty;
        return _ProviderCard(
          preset: preset,
          isSelected: isSelected,
          hasKey: hasKey,
          onTap: () => onSelect(preset.provider),
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.preset,
    required this.isSelected,
    required this.hasKey,
    required this.onTap,
  });

  final AiProviderPreset preset;
  final bool isSelected;
  final bool hasKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? preset.color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isSelected
                        ? preset.color.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.04),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: preset.color.withValues(alpha: 0.12),
                      child: Text(
                        preset.name[0],
                        style: TextStyle(
                          color: preset.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      preset.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? preset.color : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              // "key saved" marker
              if (hasKey && !isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: preset.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              // animated check badge
              Positioned(
                top: 4,
                right: 4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                  child:
                      isSelected
                          ? Container(
                            key: const ValueKey('check'),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: preset.color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
