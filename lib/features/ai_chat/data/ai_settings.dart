import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Which wire protocol the provider speaks.
enum AiTransport { openAiCompatible, geminiNative, anthropicNative }

/// Supported AI providers.
enum AiProvider { gemini, openRouter, openai, anthropic, deepseek, xai, custom }

/// Static preset (defaults + branding) for one [AiProvider].
class AiProviderPreset {
  const AiProviderPreset({
    required this.provider,
    required this.name,
    required this.keyHint,
    required this.defaultBaseUrl,
    required this.defaultModel,
    required this.suggestedModels,
    required this.transport,
    required this.color,
  });

  final AiProvider provider;
  final String name;

  /// Shown as the API-key field hint (e.g. `sk-or-...`).
  final String keyHint;
  final String defaultBaseUrl;
  final String defaultModel;
  final List<String> suggestedModels;
  final AiTransport transport;
  final Color color;

  static const Map<AiProvider, AiProviderPreset> all = {
    AiProvider.gemini: AiProviderPreset(
      provider: AiProvider.gemini,
      name: 'Gemini',
      keyHint: 'AIza... أو مفتاح Google AI Studio',
      defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      defaultModel: 'gemini-2.5-flash-lite',
      suggestedModels: [
        'gemini-2.5-flash-lite',
        'gemini-2.5-flash',
        'gemini-2.5-pro',
      ],
      transport: AiTransport.geminiNative,
      color: AppColors.aiBlue,
    ),
    AiProvider.openRouter: AiProviderPreset(
      provider: AiProvider.openRouter,
      name: 'OpenRouter',
      keyHint: 'sk-or-...',
      defaultBaseUrl: 'https://openrouter.ai/api/v1',
      defaultModel: 'nvidia/nemotron-3-ultra-550b-a55b:free',
      suggestedModels: [
        'nvidia/nemotron-3-ultra-550b-a55b:free',
        'meta-llama/llama-3.3-70b-instruct:free',
        'deepseek/deepseek-r1:free',
        'google/gemini-2.0-flash-exp:free',
      ],
      transport: AiTransport.openAiCompatible,
      color: Color(0xFF6366F1),
    ),
    AiProvider.openai: AiProviderPreset(
      provider: AiProvider.openai,
      name: 'OpenAI',
      keyHint: 'sk-...',
      defaultBaseUrl: 'https://api.openai.com/v1',
      defaultModel: 'gpt-4o-mini',
      suggestedModels: ['gpt-4o-mini', 'gpt-4o', 'gpt-4.1-mini'],
      transport: AiTransport.openAiCompatible,
      color: Color(0xFF10A37F),
    ),
    AiProvider.anthropic: AiProviderPreset(
      provider: AiProvider.anthropic,
      name: 'Claude',
      keyHint: 'sk-ant-...',
      defaultBaseUrl: 'https://api.anthropic.com/v1',
      defaultModel: 'claude-3-5-haiku-latest',
      suggestedModels: [
        'claude-3-5-haiku-latest',
        'claude-sonnet-4-5',
        'claude-opus-4-1',
      ],
      transport: AiTransport.anthropicNative,
      color: Color(0xFFD97757),
    ),
    AiProvider.deepseek: AiProviderPreset(
      provider: AiProvider.deepseek,
      name: 'DeepSeek',
      keyHint: 'sk-...',
      defaultBaseUrl: 'https://api.deepseek.com/v1',
      defaultModel: 'deepseek-chat',
      suggestedModels: ['deepseek-chat', 'deepseek-reasoner'],
      transport: AiTransport.openAiCompatible,
      color: Color(0xFF4D6BFE),
    ),
    AiProvider.xai: AiProviderPreset(
      provider: AiProvider.xai,
      name: 'Grok',
      keyHint: 'xai-...',
      defaultBaseUrl: 'https://api.x.ai/v1',
      defaultModel: 'grok-3-mini',
      suggestedModels: ['grok-3-mini', 'grok-3', 'grok-2-latest'],
      transport: AiTransport.openAiCompatible,
      color: Color(0xFF111111),
    ),
    AiProvider.custom: AiProviderPreset(
      provider: AiProvider.custom,
      name: 'Custom',
      keyHint: 'مفتاح أي مزود متوافق مع OpenAI',
      defaultBaseUrl: '',
      defaultModel: '',
      suggestedModels: [],
      transport: AiTransport.openAiCompatible,
      color: AppColors.primary,
    ),
  };

  static AiProviderPreset of(AiProvider provider) => all[provider]!;
}

/// Saved credentials/config for ONE provider.
class AiProviderConfig {
  const AiProviderConfig({
    this.apiKey = '',
    this.baseUrl = '',
    this.model = '',
  });

  final String apiKey;
  final String baseUrl;
  final String model;

  /// Effective base URL (falls back to the preset default when empty).
  String effectiveBaseUrl(AiProvider provider) {
    final trimmed = baseUrl.trim();
    return trimmed.isEmpty
        ? AiProviderPreset.of(provider).defaultBaseUrl
        : trimmed;
  }

  /// Effective model (falls back to the preset default when empty).
  String effectiveModel(AiProvider provider) {
    final trimmed = model.trim();
    return trimmed.isEmpty
        ? AiProviderPreset.of(provider).defaultModel
        : trimmed;
  }

  bool isConfiguredFor(AiProvider provider) =>
      apiKey.trim().isNotEmpty &&
      effectiveBaseUrl(provider).isNotEmpty &&
      effectiveModel(provider).isNotEmpty;

  AiProviderConfig copyWith({String? apiKey, String? baseUrl, String? model}) {
    return AiProviderConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
    );
  }

  Map<String, dynamic> toJson() => {
    'apiKey': apiKey,
    'baseUrl': baseUrl,
    'model': model,
  };

  factory AiProviderConfig.fromJson(Map<String, dynamic> json) {
    return AiProviderConfig(
      apiKey: json['apiKey'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      model: json['model'] as String? ?? '',
    );
  }
}

/// The fully-resolved settings that [AiRepo] actually calls the API with.
class AiSettings {
  const AiSettings({
    required this.provider,
    required this.apiKey,
    required this.baseUrl,
    required this.model,
  });

  final AiProvider provider;
  final String apiKey;
  final String baseUrl;
  final String model;

  AiProviderPreset get preset => AiProviderPreset.of(provider);
}

/// The whole persisted AI configuration: the toggle, the selected
/// provider, and one saved [AiProviderConfig] per provider (so keys are
/// remembered when switching back and forth).
class AiConfig {
  const AiConfig({
    this.useCustom = false,
    this.selectedProvider = AiProvider.gemini,
    this.providers = const {},
  });

  final bool useCustom;
  final AiProvider selectedProvider;
  final Map<AiProvider, AiProviderConfig> providers;

  static const empty = AiConfig();

  /// Config of the currently selected provider (empty when never saved).
  AiProviderConfig get selectedConfig =>
      providers[selectedProvider] ?? const AiProviderConfig();

  /// Resolved settings for the AI pipeline, or null when the custom
  /// provider is disabled / not fully configured.
  AiSettings? get activeSettings {
    if (!useCustom) return null;
    final config = selectedConfig;
    if (!config.isConfiguredFor(selectedProvider)) return null;
    return AiSettings(
      provider: selectedProvider,
      apiKey: config.apiKey.trim(),
      baseUrl: config.effectiveBaseUrl(selectedProvider),
      model: config.effectiveModel(selectedProvider),
    );
  }

  AiConfig copyWith({
    bool? useCustom,
    AiProvider? selectedProvider,
    Map<AiProvider, AiProviderConfig>? providers,
  }) {
    return AiConfig(
      useCustom: useCustom ?? this.useCustom,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      providers: providers ?? this.providers,
    );
  }

  AiConfig withProviderConfig(AiProvider provider, AiProviderConfig config) {
    return copyWith(providers: {...providers, provider: config});
  }

  Map<String, dynamic> toJson() => {
    'useCustom': useCustom,
    'selectedProvider': selectedProvider.name,
    'providers': providers.map(
      (key, value) => MapEntry(key.name, value.toJson()),
    ),
  };

  factory AiConfig.fromJson(Map<String, dynamic> json) {
    final rawProviders = json['providers'];
    final providers = <AiProvider, AiProviderConfig>{};
    if (rawProviders is Map) {
      for (final entry in rawProviders.entries) {
        final provider = AiProvider.values.asNameMap()[entry.key];
        final value = entry.value;
        if (provider != null && value is Map) {
          providers[provider] = AiProviderConfig.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      }
    }
    return AiConfig(
      useCustom: json['useCustom'] as bool? ?? false,
      selectedProvider:
          AiProvider.values.asNameMap()[json['selectedProvider']] ??
          AiProvider.gemini,
      providers: providers,
    );
  }
}
