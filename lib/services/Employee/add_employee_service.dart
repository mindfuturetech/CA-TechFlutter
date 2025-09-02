import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/employee.dart';
import '../app_config.dart'; // Update path as needed

class EmployeeService {
  // Private constructor for singleton pattern
  EmployeeService._();
  static final EmployeeService _instance = EmployeeService._();
  static EmployeeService get instance => _instance;

  // HTTP client for connection reuse
  static final http.Client _client = http.Client();

  // Get JWT token from cookie stored in shared preferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('auth_cookie');

    if (cookie != null && cookie.startsWith('token=')) {
      // Extract token from cookie format: "token=actual_jwt_token"
      return cookie.substring(6); // Remove 'token=' prefix
    }

    return null;
  }

  // Get full cookie for HTTP requests
  static Future<String?> _getCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_cookie');
  }

  // Get headers with authorization
  static Future<Map<String, String>> _getHeaders() async {
    final cookie = await _getCookie();
    final token = await _getToken();

    print('🔑 Retrieved cookie: $cookie'); // Debug print
    print('🔑 Retrieved token: $token'); // Debug print

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Use Cookie header for HTTP-only cookies
      if (cookie != null) 'Cookie': cookie,
      // Also include Authorization header if your backend expects it
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _getToken();
    final cookie = await _getCookie();

    print('🔍 Auth check - Token: $token');
    print('🔍 Auth check - Cookie: $cookie');

    return token != null && token.isNotEmpty;
  }

  // Fetch all employees
  static Future<EmployeeApiResponse<List<dynamic>>> fetchEmployees() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/employee/employee-list');
      final headers = await _getHeaders();

      print('📋 Fetch employees - Headers: $headers');
      print('📋 Fetch employees - URL: $url');

      final response = await _client.get(url, headers: headers);

      print('📋 Fetch employees - Status: ${response.statusCode}');
      print('📋 Fetch employees - Body: ${response.body}');

      return _handleResponse<List<dynamic>>(
        response,
        successMessage: 'Employees fetched successfully',
        errorMessage: 'Failed to fetch employees',
        dataExtractor: (responseData) => responseData['employeeList'] ?? [],
      );
    } catch (e) {
      print('📋 Fetch employees - Error: $e');
      return EmployeeApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Create employees
  static Future<EmployeeApiResponse<Map<String, dynamic>>> createEmployees(
      List<Map<String, String>> employees
      ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/employee/create-employee');
      final headers = await _getHeaders();

      print('➕ Create employees - Headers: $headers');
      print('➕ Create employees - URL: $url');
      print('➕ Create employees - Body: ${jsonEncode(employees)}');

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(employees),
      );

      print('➕ Create employees - Status: ${response.statusCode}');
      print('➕ Create employees - Response: ${response.body}');

      return _handleResponse<Map<String, dynamic>>(
        response,
        successMessage: 'Employees created successfully',
        errorMessage: 'Failed to create employees',
        dataExtractor: (responseData) => responseData,
      );
    } catch (e) {
      print('➕ Create employees - Error: $e');
      return EmployeeApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get employee count (helper method)
  static Future<int> getEmployeeCount() async {
    try {
      print('🔢 Getting employee count...');
      final result = await fetchEmployees();
      if (result.success && result.data != null) {
        final count = result.data!.length;
        print('🔢 Employee count: $count');
        return count;
      }
      print('🔢 Employee count failed, returning 0');
      return 0;
    } catch (e) {
      print('🔢 Employee count error: $e');
      return 0;
    }
  }

  /// Generic response handler
  static EmployeeApiResponse<T> _handleResponse<T>(
      http.Response response, {
        required String successMessage,
        required String errorMessage,
        T Function(Map<String, dynamic>)? dataExtractor,
      }) {
    try {
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        T? data;
        if (dataExtractor != null) {
          data = dataExtractor(responseData);
        } else {
          data = responseData as T?;
        }

        return EmployeeApiResponse.success(
          data: data,
          message: responseData['message'] ?? successMessage,
        );
      } else {
        return EmployeeApiResponse.error(
          responseData['message'] ?? errorMessage,
          statusCode: response.statusCode,
          duplicates: responseData['duplicates'], // For handling duplicate errors
        );
      }
    } catch (e) {
      print('🚨 Response parsing error: $e');
      return EmployeeApiResponse.error('Failed to parse response: ${e.toString()}');
    }
  }
  //list emplyee api

  static Future<List<Employee>> fetchallEmployees() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/employee/employee-list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final employeeList = data['employeeList'] as List;
        return employeeList.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch employees: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching employees: $e');
      throw Exception('Error fetching employees: $e');
    }
  }

  static Future<Employee> updateEmployee(String empId, Map<String, dynamic> editedData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/employee/update-employee'),
        headers: headers,
        body: json.encode({
          'empId': empId,
          'editedData': editedData,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Employee.fromJson(data['updatedRecord']);
      } else {
        throw Exception('Failed to update employee: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating employee: $e');
      throw Exception('Error updating employee: $e');
    }
  }

  static Future<void> deleteEmployee(String empId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/employee/delete-employee/$empId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete employee: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting employee: $e');
      throw Exception('Error deleting employee: $e');
    }
  }

  /// Clean up resources
  static void dispose() {
    _client.close();
  }
}

/// Employee-specific ApiResponse to handle employee-specific errors
class EmployeeApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;
  final List<dynamic>? duplicates; // For handling duplicate employee errors

  EmployeeApiResponse._({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
    this.duplicates,
  });

  factory EmployeeApiResponse.success({
    T? data,
    required String message,
  }) {
    return EmployeeApiResponse._(
      success: true,
      data: data,
      message: message,
    );
  }

  factory EmployeeApiResponse.error(
      String message, {
        int? statusCode,
        List<dynamic>? duplicates,
      }) {
    return EmployeeApiResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
      duplicates: duplicates,
    );
  }

  @override
  String toString() {
    return 'EmployeeApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}