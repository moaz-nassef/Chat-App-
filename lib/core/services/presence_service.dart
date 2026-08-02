import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/auth/data/auth_repo.dart';

/// Keeps the user's online/offline status in sync with BOTH:
/// 1. the auth session — login, logout, and **restored sessions on cold
///    start** (the case that previously left users offline forever);
/// 2. the app lifecycle — foreground ↔ background.
///
/// Best-effort: failures are logged inside [AuthRepo.setOnlineStatus].
class PresenceService with WidgetsBindingObserver {
  PresenceService(this._authRepo);

  final AuthRepo _authRepo;
  StreamSubscription<bool>? _authSub;

  /// Tracks foreground state so an auth event arriving while the app is
  /// backgrounded doesn't flip the user back online.
  bool _inForeground = true;

  void start() {
    WidgetsBinding.instance.addObserver(this);

    // Fires on cold start (restored session), login and logout.
    _authSub = _authRepo.signedInChanges.listen((signedIn) {
      if (signedIn && _inForeground) {
        _authRepo.setOnlineStatus(true);
      }
      // Logout needs no write here: AuthDataSource.signOut() sets
      // `online: false` before the auth token is destroyed.
    });

    // The session may already be restored before the first stream event.
    if (_authRepo.currentUid != null) {
      _authRepo.setOnlineStatus(true);
    }
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_authRepo.currentUid == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _inForeground = true;
        _authRepo.setOnlineStatus(true);
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _inForeground = false;
        _authRepo.setOnlineStatus(false);
      case AppLifecycleState.inactive:
      // Transient state (notification shade, system dialogs, calls).
      // Ignored on purpose — going offline here makes the status flicker.
    }
  }
}
