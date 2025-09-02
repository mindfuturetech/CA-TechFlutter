import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



class AuthUtils {

  /// Get the current authentication token from cookie
  static Future<String?> getCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('auth_cookie');

    if (cookie != null && cookie.startsWith('token=')) {
      // Extract token from cookie format: "token=actual_jwt_token"
      return cookie.substring(6); // Remove 'token=' prefix
    }

    return null;
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getCurrentToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    // Optional: Add JWT token expiration check
    if (await _isTokenExpired(token)) {
      await clearAuthData();
      return false;
    }

    return true;
  }

  /// Check if JWT token is expired
  static Future<bool> _isTokenExpired(String token) async {
    try {
      // Basic JWT structure check
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload (base64)
      final payload = parts[1];
      // Add padding if needed
      final normalizedPayload = payload.padRight(
          (payload.length + 3) & ~3,
          '='
      );

      final payloadMap = Map<String, dynamic>.from(
          json.decode(utf8.decode(base64.decode(normalizedPayload)))
      );

      final exp = payloadMap['exp'];
      if (exp == null) return false;

      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expDate);

    } catch (e) {
      print('Error checking token expiration: $e');
      return true; // Treat as expired if we can't parse
    }
  }

  /// Get the full authentication cookie
  static Future<String?> getAuthCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_cookie');
  }

  /// Clear all authentication data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_cookie');
    await prefs.remove('auth_token'); // Remove legacy token if exists
  }

  /// Debug method to print all preferences
  static Future<void> debugPrintAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    print('=== All SharedPreferences ===');
    for (final key in keys) {
      final value = prefs.get(key);
      print('$key: $value');
    }
    print('===========================');
  }

  /// Sanitize login input
  static String sanitizeLoginInput(String input) {
    return input.trim().toUpperCase();
  }
}