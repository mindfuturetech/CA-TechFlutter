// session_manager.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

class SessionManager {
  static SessionManager? _instance;
  static SessionManager get instance => _instance ??= SessionManager._();

  SessionManager._();

  Timer? _inactivityTimer;
  Timer? _backgroundTimer;
  DateTime? _backgroundTime;
  VoidCallback? _onSessionExpired;
  bool _isSessionActive = false;

  // Session timeout duration (1 minute)
  static const Duration _sessionTimeout = Duration(minutes: 1);
  static const Duration _backgroundTimeout = Duration(minutes: 1);

  /// Start a new session with expiration callback
  static Future<void> startSession(VoidCallback onSessionExpired) async {
    instance._onSessionExpired = onSessionExpired;
    instance._isSessionActive = true;
    instance._resetInactivityTimer();
    print('Session started with callback');
  }

  /// End the current session
  static void endSession() {
    instance._clearTimers();
    instance._isSessionActive = false;
    instance._onSessionExpired = null;
    print('Session ended');
  }

  /// Check if session is currently active
  static bool get isSessionActive => instance._isSessionActive;

  /// Reset the inactivity timer (call this on user interaction)
  static void resetTimer() {
    if (instance._isSessionActive) {
      instance._resetInactivityTimer();
      print('Session timer reset due to user activity');
    }
  }

  /// Handle app lifecycle changes
  static void handleAppLifecycleChange(AppLifecycleState state) {
    print('App lifecycle changed to: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        instance._handleAppResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        instance._handleAppPaused();
        break;
      case AppLifecycleState.detached:
        instance._handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        instance._handleAppPaused();
        break;
    }
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_sessionTimeout, () {
      _expireSession('Inactivity timeout - no user interaction for ${_sessionTimeout.inMinutes} minute(s)');
    });
    print('Inactivity timer reset - will expire in ${_sessionTimeout.inMinutes} minute(s)');
  }

  void _handleAppPaused() {
    if (!_isSessionActive) return;

    _backgroundTime = DateTime.now();
    _inactivityTimer?.cancel();

    // Start background timer
    _backgroundTimer = Timer(_backgroundTimeout, () {
      _expireSession('Background timeout - app was minimized for ${_backgroundTimeout.inMinutes} minute(s)');
    });

    print('App went to background at ${_backgroundTime} - background timer started');
  }

  void _handleAppResumed() {
    if (!_isSessionActive) return;

    _backgroundTimer?.cancel();

    if (_backgroundTime != null) {
      final backgroundDuration = DateTime.now().difference(_backgroundTime!);
      print('App resumed after ${backgroundDuration.inSeconds} seconds in background');

      if (backgroundDuration >= _backgroundTimeout) {
        _expireSession('App was in background for ${backgroundDuration.inMinutes} minute(s), exceeding limit of ${_backgroundTimeout.inMinutes} minute(s)');
        return;
      }
    }

    // Reset inactivity timer when app resumes
    _resetInactivityTimer();
    print('App resumed - session continues with reset timer');
  }

  void _handleAppDetached() {
    if (_isSessionActive) {
      _expireSession('App was detached/closed');
    }
  }

  void _expireSession(String reason) {
    if (!_isSessionActive) {
      print('Session expiry called but session already inactive');
      return;
    }

    print('Session expired: $reason');
    _clearTimers();
    _isSessionActive = false;

    final callback = _onSessionExpired;
    _onSessionExpired = null;

    // Call the callback if it exists
    if (callback != null) {
      print('Calling session expiry callback');
      callback();
    } else {
      print('No session expiry callback registered');
    }
  }

  void _clearTimers() {
    _inactivityTimer?.cancel();
    _backgroundTimer?.cancel();
    _inactivityTimer = null;
    _backgroundTimer = null;
    _backgroundTime = null;
    print('All session timers cleared');
  }
}