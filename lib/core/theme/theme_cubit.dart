import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the app-wide [ThemeMode] (نهاري / ليلي / حسب النظام) and
/// persists the choice locally so it survives restarts.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _load();
  }

  static const String _key = 'theme_mode_v1';

  final SharedPreferences _prefs;

  void _load() {
    final saved = _prefs.getString(_key);
    final mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
    if (!isClosed) emit(mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(_key, mode.name);
  }

  /// Cycles light → dark → light (used by the app-bar toggle).
  Future<void> toggle() =>
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
