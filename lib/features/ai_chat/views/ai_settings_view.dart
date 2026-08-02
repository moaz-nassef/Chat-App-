import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di_container.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../cubit/ai_settings_cubit.dart';
import '../cubit/ai_settings_state.dart';
import '../data/ai_settings.dart';
import '../widgets/provider_picker.dart';
import '../widgets/settings_field.dart';
import '../widgets/test_result_card.dart';

/// AI provider settings: pick a provider, paste the API key, tune the
/// base URL / model, test the connection live, then save.
/// Opened from the AI chat app-bar gear icon.
class AiSettingsView extends StatelessWidget {
  const AiSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AiSettingsCubit>()..load(),
      child: const _AiSettingsBody(),
    );
  }
}

class _AiSettingsBody extends StatefulWidget {
  const _AiSettingsBody();

  @override
  State<_AiSettingsBody> createState() => _AiSettingsBodyState();
}

class _AiSettingsBodyState extends State<_AiSettingsBody>
    with SingleTickerProviderStateMixin {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();

  bool _obscureKey = true;

  /// Staggered entrance animation for the sections.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  /// (Re)fills the form when loading finishes or the provider changes:
  /// saved credentials if present, otherwise the preset defaults.
  void _fillForm(AiSettingsState state) {
    final preset = AiProviderPreset.of(state.selectedProvider);
    final saved = state.selectedSaved;
    _apiKeyController.text = saved.apiKey;
    _baseUrlController.text =
        saved.baseUrl.isEmpty ? preset.defaultBaseUrl : saved.baseUrl;
    _modelController.text =
        saved.model.isEmpty ? preset.defaultModel : saved.model;
  }

  Future<void> _pasteKey() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (text.isEmpty) {
      AppSnackBar.error(context, 'الحافظة فارغة');
      return;
    }
    _apiKeyController.text = text;
    context.read<AiSettingsCubit>().invalidateTest();
  }

  Future<void> _save() async {
    final cubit = context.read<AiSettingsCubit>();
    if (cubit.state.useCustom && _apiKeyController.text.trim().isEmpty) {
      AppSnackBar.error(context, 'أدخل مفتاح API أو عطّل المزود المخصص');
      return;
    }
    final ok = await cubit.save(
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text,
      model: _modelController.text,
    );
    if (!mounted) return;
    if (ok) {
      AppSnackBar.success(context, 'تم حفظ الإعدادات بنجاح');
    } else {
      AppSnackBar.error(context, 'تعذر حفظ الإعدادات');
    }
  }

  /// Section [index] wrapped in its staggered fade+slide.
  Widget _animated(int index, Widget child) {
    final start = (index * 0.12).clamp(0.0, 0.6);
    final animation = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, start + 0.4, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FA),
      appBar: AppBar(title: const Text('إعدادات الذكاء الاصطناعي')),
      body: BlocConsumer<AiSettingsCubit, AiSettingsState>(
        listenWhen:
            (previous, current) =>
                previous.isLoading != current.isLoading ||
                previous.selectedProvider != current.selectedProvider,
        listener: (context, state) => _fillForm(state),
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final preset = AiProviderPreset.of(state.selectedProvider);
          final cubit = context.read<AiSettingsCubit>();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // ── 0 · Header ──────────────────────────────────────
              _animated(0, const _Header()),
              const SizedBox(height: 20),

              // ── 1 · Enable switch ───────────────────────────────
              _animated(1, _buildSwitchCard(state, cubit)),
              const SizedBox(height: 20),

              // ── 2 · Provider picker ─────────────────────────────
              _animated(
                2,
                _Section(
                  title: 'مزود الخدمة',
                  child: ProviderPicker(
                    selected: state.selectedProvider,
                    savedProviders: state.savedProviders,
                    onSelect: cubit.selectProvider,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── 3 · Credentials ─────────────────────────────────
              _animated(
                3,
                _Section(
                  title: 'بيانات الاتصال',
                  child: Column(
                    children: [
                      SettingsField(
                        controller: _apiKeyController,
                        label: 'API Key',
                        hint: preset.keyHint,
                        icon: Icons.key_rounded,
                        obscureText: _obscureKey,
                        textDirection: TextDirection.ltr,
                        onChanged: (_) => cubit.invalidateTest(),
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'لصق من الحافظة',
                              icon: const Icon(
                                Icons.content_paste_rounded,
                                size: 20,
                              ),
                              onPressed: _pasteKey,
                            ),
                            IconButton(
                              tooltip: _obscureKey ? 'إظهار' : 'إخفاء',
                              icon: Icon(
                                _obscureKey
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscureKey = !_obscureKey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SettingsField(
                        controller: _baseUrlController,
                        label: 'Base URL',
                        hint:
                            preset.defaultBaseUrl.isEmpty
                                ? 'https://api.example.com/v1'
                                : preset.defaultBaseUrl,
                        icon: Icons.link_rounded,
                        keyboardType: TextInputType.url,
                        textDirection: TextDirection.ltr,
                        onChanged: (_) => cubit.invalidateTest(),
                      ),
                      const SizedBox(height: 14),
                      SettingsField(
                        controller: _modelController,
                        label: 'الموديل',
                        hint:
                            preset.defaultModel.isEmpty
                                ? 'اسم الموديل'
                                : preset.defaultModel,
                        icon: Icons.psychology_outlined,
                        textDirection: TextDirection.ltr,
                        onChanged: (_) => cubit.invalidateTest(),
                      ),
                      if (preset.suggestedModels.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final model in preset.suggestedModels)
                                ActionChip(
                                  label: Text(
                                    model,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: preset.color.withValues(
                                    alpha: 0.08,
                                  ),
                                  side: BorderSide(
                                    color: preset.color.withValues(alpha: 0.3),
                                  ),
                                  onPressed: () {
                                    _modelController.text = model;
                                    cubit.invalidateTest();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── 4 · Test + result ───────────────────────────────
              _animated(
                4,
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed:
                            state.isTesting
                                ? null
                                : () => cubit.test(
                                  apiKey: _apiKeyController.text,
                                  baseUrl: _baseUrlController.text,
                                  model: _modelController.text,
                                ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: preset.color,
                          side: BorderSide(color: preset.color, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon:
                            state.isTesting
                                ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: preset.color,
                                  ),
                                )
                                : const Icon(Icons.bolt_rounded),
                        label: Text(
                          state.isTesting
                              ? 'جارٍ اختبار الاتصال...'
                              : 'اختبار الاتصال',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TestResultCard(
                      reply: state.testReply,
                      latencyMs: state.testLatencyMs,
                      error: state.testError,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── 5 · Save ────────────────────────────────────────
              _animated(
                5,
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: state.isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child:
                        state.isSaving
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Text(
                              'حفظ الإعدادات',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwitchCard(AiSettingsState state, AiSettingsCubit cubit) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              state.useCustom
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.grey.shade300,
        ),
      ),
      child: SwitchListTile(
        value: state.useCustom,
        onChanged: cubit.setUseCustom,
        title: const Text(
          'استخدام مزود مخصص',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          state.useCustom
              ? 'سيتم استخدام الإعدادات أدناه للردود'
              : 'الوضع الحالي: المساعد المدمج (Firebase AI)',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        activeThumbColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Gradient header with the robot icon.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.aiBlue, AppColors.primaryLight],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Icon(Icons.smart_toy, color: Colors.white, size: 28),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مزود الذكاء الاصطناعي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'اختر المزود، الصق المفتاح، اختبر ثم احفظ',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled white card grouping a section of the form.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 4, left: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ],
    );
  }
}
