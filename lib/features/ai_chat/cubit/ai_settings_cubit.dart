import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../data/ai_repo.dart';
import '../data/ai_settings.dart';
import '../data/ai_settings_store.dart';
import 'ai_settings_state.dart';

/// Owns the AI settings screen: loads/persists [AiConfig] and runs
/// live connection tests through [AiRepo].
class AiSettingsCubit extends Cubit<AiSettingsState> {
  AiSettingsCubit(this._store, this._aiRepo) : super(const AiSettingsState());

  final AiSettingsStore _store;
  final AiRepo _aiRepo;

  /// Loads the persisted config once per screen open.
  Future<void> load() async {
    final config = await _store.load();
    if (isClosed) return;
    emit(
      state.copyWith(
        isLoading: false,
        useCustom: config.useCustom,
        selectedProvider: config.selectedProvider,
        savedProviders: config.providers,
        clearTestOutcome: true,
      ),
    );
  }

  /// Switches the selected provider. Its saved credentials (if any) are
  /// surfaced via [AiSettingsState.selectedSaved] — the view fills the
  /// form fields from them.
  void selectProvider(AiProvider provider) {
    if (provider == state.selectedProvider) return;
    emit(state.copyWith(selectedProvider: provider, clearTestOutcome: true));
  }

  void setUseCustom(bool value) {
    emit(state.copyWith(useCustom: value));
  }

  /// Any keystroke in the form invalidates the previous test result.
  void invalidateTest() {
    if (state.hasTestOutcome) {
      emit(state.copyWith(clearTestOutcome: true));
    }
  }

  /// Live-fires a ping through the provider with the CURRENT form values
  /// (not the saved ones) so the user can test before saving.
  Future<void> test({
    required String apiKey,
    required String baseUrl,
    required String model,
  }) async {
    if (state.isTesting) return;
    emit(state.copyWith(isTesting: true, clearTestOutcome: true));

    final preset = AiProviderPreset.of(state.selectedProvider);
    final settings = AiSettings(
      provider: state.selectedProvider,
      apiKey: apiKey.trim(),
      baseUrl: baseUrl.trim().isEmpty ? preset.defaultBaseUrl : baseUrl.trim(),
      model: model.trim().isEmpty ? preset.defaultModel : model.trim(),
    );

    try {
      final result = await _aiRepo.testConnection(settings);
      if (isClosed) return;
      emit(
        state.copyWith(
          isTesting: false,
          testReply: result.reply,
          testLatencyMs: result.latencyMs,
        ),
      );
    } on AiFailure catch (f) {
      if (isClosed) return;
      emit(state.copyWith(isTesting: false, testError: f.message));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isTesting: false, testError: '❌ $e'));
    }
  }

  /// Persists the form. Conversation memory is reset so the next reply
  /// starts fresh with the new provider/model.
  Future<bool> save({
    required String apiKey,
    required String baseUrl,
    required String model,
  }) async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true));

    final provider = state.selectedProvider;
    final config = AiConfig(
      useCustom: state.useCustom,
      selectedProvider: provider,
      providers: {
        ...state.savedProviders,
        provider: AiProviderConfig(
          apiKey: apiKey.trim(),
          baseUrl: baseUrl.trim(),
          model: model.trim(),
        ),
      },
    );

    try {
      await _store.save(config);
      _aiRepo.clearAllSessions();
      if (isClosed) return true;
      emit(state.copyWith(isSaving: false, savedProviders: config.providers));
      return true;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return false;
    }
  }
}
