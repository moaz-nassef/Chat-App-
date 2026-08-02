import 'package:equatable/equatable.dart';

import '../data/ai_settings.dart';

/// Single state object for the AI settings screen (form-friendly).
class AiSettingsState extends Equatable {
  const AiSettingsState({
    this.isLoading = true,
    this.useCustom = false,
    this.selectedProvider = AiProvider.gemini,
    this.savedProviders = const {},
    this.isTesting = false,
    this.testReply,
    this.testLatencyMs,
    this.testError,
    this.isSaving = false,
  });

  /// True while the persisted config is being read from disk.
  final bool isLoading;

  /// Master toggle: custom provider vs. built-in Firebase AI.
  final bool useCustom;
  final AiProvider selectedProvider;

  /// Per-provider saved credentials (keys survive switching).
  final Map<AiProvider, AiProviderConfig> savedProviders;

  final bool isTesting;

  /// Set on the last successful test.
  final String? testReply;
  final int? testLatencyMs;

  /// Set when the last test failed.
  final String? testError;

  final bool isSaving;

  /// The saved config for the selected provider (empty if never saved).
  AiProviderConfig get selectedSaved =>
      savedProviders[selectedProvider] ?? const AiProviderConfig();

  /// True when a test has a visible outcome (success or error).
  bool get hasTestOutcome => testReply != null || testError != null;

  AiSettingsState copyWith({
    bool? isLoading,
    bool? useCustom,
    AiProvider? selectedProvider,
    Map<AiProvider, AiProviderConfig>? savedProviders,
    bool? isTesting,
    String? testReply,
    int? testLatencyMs,
    String? testError,
    bool clearTestOutcome = false,
    bool? isSaving,
  }) {
    return AiSettingsState(
      isLoading: isLoading ?? this.isLoading,
      useCustom: useCustom ?? this.useCustom,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      savedProviders: savedProviders ?? this.savedProviders,
      isTesting: isTesting ?? this.isTesting,
      testReply: clearTestOutcome ? null : (testReply ?? this.testReply),
      testLatencyMs:
          clearTestOutcome ? null : (testLatencyMs ?? this.testLatencyMs),
      testError: clearTestOutcome ? null : (testError ?? this.testError),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    useCustom,
    selectedProvider,
    savedProviders,
    isTesting,
    testReply,
    testLatencyMs,
    testError,
    isSaving,
  ];
}
