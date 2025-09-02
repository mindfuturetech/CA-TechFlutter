// Fixed ApiService with consistent token storage
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/user.dart';
import '../app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Private constructor for singleton pattern
  ApiService._();
  static final ApiService _instance = ApiService._();
  static ApiService get instance => _instance;

  // HTTP client for connection reuse
  static final http.Client _client = http.Client();

  // Common headers
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Register a new user
  static Future<ApiResponse<Map<String, dynamic>>> registerUser(
      Map<String, dynamic> userData) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/pendingUsers'),
        headers: _defaultHeaders,
        body: json.encode(userData),
      );

      return _handleResponse<Map<String, dynamic>>(
        response,
        successMessage: 'Registration successful',
        errorMessage: 'Registration failed',
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get stored authentication token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('auth_cookie');

    if (cookie != null && cookie.startsWith('token=')) {
      // Extract token from cookie format
      return cookie.substring(6); // Remove 'token=' prefix
    }

    return null;
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Get headers with authentication
  static Future<Map<String, String>> _getAuthHeaders() async {
    final cookie = (await SharedPreferences.getInstance()).getString('auth_cookie');

    return {
      ..._defaultHeaders,
      if (cookie != null) 'Cookie': cookie,
    };
  }

  /// Fetch secure data with authentication
  static Future<http.Response> fetchSecureData() async {
    final headers = await _getAuthHeaders();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/secure/data'),
      headers: headers,
    );

    return response;
  }

  /// Authenticate user - FIXED VERSION
  static Future<Map<String, dynamic>> authenticateUser(String userId, String password) async {
    try {
      print('Attempting login for user: $userId');

      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      print('Login response headers: ${response.headers}');

      final responseData = json.decode(response.body);

      // if (response.statusCode == 200) {
      //   // Extract token from set-cookie header
      //   final setCookieHeader = response.headers['set-cookie'];
      //   if (setCookieHeader != null && setCookieHeader.contains('token=')) {
      //     final cookie = setCookieHeader.split(';')[0]; // 'token=...'
      //     final prefs = await SharedPreferences.getInstance();
      //
      //     // Store both formats for compatibility
      //     await prefs.setString('auth_cookie', cookie);
      //
      //     // Extract just the token part and store it as auth_token too
      //     final tokenValue = cookie.substring(6); // Remove 'token=' prefix
      //     await prefs.setString('auth_token', tokenValue);
      //
      //     print('✅ Cookie saved: $cookie');
      //     print('✅ Token saved: $tokenValue');
      //   } else {
      //     print('❌ No token cookie received from server');
      //   }
      //
      //   return {
      //     'success': true,
      //     'user': User.fromJson(responseData['user']),
      //     'message': responseData['message'],
      //   };
      // }
      if (response.statusCode == 200) {
        // Extract token from set-cookie header
        final setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null && setCookieHeader.contains('token=')) {
          final cookie = setCookieHeader.split(';')[0]; // 'token=...'
          final prefs = await SharedPreferences.getInstance();

          // Store both formats
          await prefs.setString('auth_cookie', cookie);

          // Extract just the token part and store
          final tokenValue = cookie.substring(6); // Remove 'token=' prefix
          await prefs.setString('auth_token', tokenValue);

          // ✅ Store user data also
          final userJson = json.encode(responseData['user']);
          await prefs.setString('user', userJson);

          print('✅ User saved: $userJson');
        }

        return {
          'success': true,
          'user': User.fromJson(responseData['user']),
          'message': responseData['message'],
        };
      }

      else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('❌ Authentication error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  /// Validate a verification link
  static Future<ApiResponse<Map<String, dynamic>>> validateLink(
      String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/link-status/$token'),
        headers: _defaultHeaders,
      );

      return _handleResponse<Map<String, dynamic>>(
        response,
        successMessage: 'Link validation successful',
        errorMessage: 'Link validation failed',
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Perform user action (approve/reject)
  static Future<ApiResponse<Map<String, dynamic>>> userAction(
      String action, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/user-action'),
        headers: _defaultHeaders,
        body: json.encode({
          'action': action,
          'token': token,
        }),
      );

      return _handleResponse<Map<String, dynamic>>(
        response,
        successMessage: 'Action completed successfully',
        errorMessage: 'Action failed',
      );
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Logout user
  static Future<bool> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('auth_cookie');

    if (cookie == null) return false;

    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': cookie,
        },
      );

      if (response.statusCode == 200) {
        // Clear all authentication data
        await prefs.remove('auth_cookie');
        await prefs.remove('auth_token');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Logout error: $e');
      // Clear tokens anyway on error
      await prefs.remove('auth_cookie');
      await prefs.remove('auth_token');
      return false;
    }
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }


  /// Generic response handler
  static ApiResponse<T> _handleResponse<T>(
      http.Response response, {
        required String successMessage,
        required String errorMessage,
      }) {
    try {
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          data: responseData,
          message: successMessage,
        );
      } else {
        return ApiResponse.error(
          responseData['message'] ?? errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: ${e.toString()}');
    }
  }
  // static Future<Map<String, dynamic>> handleLogout() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('auth_token'); // Use the correct key
  //
  //
  //     if (token == null) {
  //       throw Exception('No token found');
  //     }
  //
  //     final response = await http.post(
  //       Uri.parse('${ApiConfig.baseUrl}/logout'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //         'Cookie': 'token=$token', // If you're using cookies
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       // Clear local storage
  //       await prefs.remove('token');
  //       await prefs.remove('user');
  //       await prefs.setBool('isAuthenticated', false);
  //
  //       return {
  //         'success': true,
  //         'message': data['message'] ?? 'Logged out successfully'
  //       };
  //     } else {
  //       final errorData = json.decode(response.body);
  //       throw Exception(errorData['message'] ?? 'Logout failed');
  //     }
  //   } catch (error) {
  //     return {
  //       'success': false,
  //       'message': error.toString().replaceAll('Exception: ', '')
  //     };
  //   }
  // }
  static Future<Map<String, dynamic>> handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token'); // correct key
      final cookie = prefs.getString('auth_cookie');

      if (token == null && cookie == null) {
        throw Exception('No authentication found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/logout'), // match backend route
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          if (cookie != null) 'Cookie': cookie,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ✅ Clear correct keys
        await prefs.remove('auth_cookie');
        await prefs.remove('auth_token');
        await prefs.remove('user');
        await prefs.setBool('isAuthenticated', false);

        return {
          'success': true,
          'message': data['message'] ?? 'Logged out successfully'
        };
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Logout failed');
      }
    } catch (error) {
      return {
        'success': false,
        'message': error.toString().replaceAll('Exception: ', '')
      };
    }
  }


  /// Clean up resources
  static void dispose() {
    _client.close();
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;

  ApiResponse._({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
  });

  factory ApiResponse.success({
    T? data,
    required String message,
  }) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {
    int? statusCode,
  }) {
    return ApiResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}