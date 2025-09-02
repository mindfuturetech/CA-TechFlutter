// services/partner_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/partner.dart';
import '../app_config.dart';

class PartnerService {
  final String _baseUrl = ApiConfig.baseUrl;
  static final http.Client _client = http.Client();

  // ===== Token & Cookie Retrieval (Same as EmployeeService) =====
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('auth_cookie');

    if (cookie != null && cookie.startsWith('token=')) {
      return cookie.substring(6); // Remove "token=" prefix
    }
    return null;
  }

  static Future<String?> _getCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_cookie');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final cookie = await _getCookie();
    final token = await _getToken();

    print('🔑 PartnerService Cookie: $cookie');
    print('🔑 PartnerService Token: $token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (cookie != null) 'Cookie': cookie,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle API errors consistently
  String _handleApiError(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      return errorData['message'] ?? 'Unknown error occurred';
    } catch (e) {
      return 'Failed to parse error response';
    }
  }

  // ===== API Methods =====

  Future<List<Partner>> getAllPartners() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/partner/partner-list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> partnersJson = data['partnerList'] ?? [];
        return partnersJson.map((json) => Partner.fromJson(json)).toList();
      } else {
        throw Exception(_handleApiError(response));
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error loading partners: $e');
    }
  }

  Future<void> terminatePartner(int partnerId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(
        Uri.parse('$_baseUrl/partner/terminate-partner?id=$partnerId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(_handleApiError(response));
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error terminating partner: $e');
    }
  }

  Future<void> sendPartnerRequest({
    required String businessType,
    required String userId,
    required String email,
  }) async {
    try {
      final headers = await _getHeaders();
      final requestBody = {
        'businessType': businessType,
        'sanitizedUserId': userId,
        'email': email,
      };

      final response = await _client.post(
        Uri.parse('$_baseUrl/partner/partner-request'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception(_handleApiError(response));
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error sending partner request: $e');
    }
  }

  Future<List<Partner>> getPendingRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/partner/pending-requests'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> requestsJson = data['requests'] ?? [];
        return requestsJson.map((json) => Partner.fromJson(json)).toList();
      } else {
        throw Exception(_handleApiError(response));
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error loading pending requests: $e');
    }
  }

  Future<void> removePartner(String partnerId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(
        Uri.parse('$_baseUrl/partner/remove/$partnerId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(_handleApiError(response));
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error removing partner: $e');
    }
  }

  Future<Map<String, dynamic>> validatePartnerLink(String token) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final response = await _client.get(
        Uri.parse('$_baseUrl/partner/link-status/$token'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(_handleApiError(response));
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error validating link: $e');
    }
  }

  Future<void> handlePartnerAction({
    required String action,
    required String token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final response = await _client.post(
        Uri.parse('$_baseUrl/partner/partner-action'),
        headers: headers,
        body: json.encode({'action': action, 'token': token}),
      );

      if (response.statusCode != 200) {
        throw Exception(_handleApiError(response));
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error processing action: $e');
    }
  }

  Future<Map<String, dynamic>> getPartnerStats() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/partner/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(_handleApiError(response));
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error loading statistics: $e');
    }
  }

  static void dispose() {
    _client.close();
  }
}