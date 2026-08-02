import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_settings.dart';

/// Persists [AiConfig] locally on the device (SharedPreferences).
///
/// API keys NEVER leave the device — they are not written to Firestore
/// (the `users` collection is readable by every signed-in user).
class AiSettingsStore {
  AiSettingsStore(this._prefs);

  static const String _key = 'ai_settings_v1';

  final SharedPreferences _prefs;

  /// In-memory cache so [AiRepo] can read settings synchronously.
  AiConfig _cache = AiConfig.empty;

  /// The last loaded/saved config (valid after [load] ran once).
  AiConfig get current => _cache;

  /// Loads from disk into the cache. Call once at app start.
  Future<AiConfig> load() async {
    final raw = _prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cache = AiConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('AiSettingsStore: corrupted payload, resetting ($e)');
        _cache = AiConfig.empty;
      }
    }
    return _cache;
  }

  Future<void> save(AiConfig config) async {
    _cache = config;
    await _prefs.setString(_key, jsonEncode(config.toJson()));
  }

  Future<void> clear() async {
    _cache = AiConfig.empty;
    await _prefs.remove(_key);
  }
}
