// utils/validators.dart
class Validators {
  // Sanitize User ID input - remove non-alphanumeric characters and convert to uppercase
  static String sanitizeUserId(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
  }

  // Validate User ID format - CA/CS/CL followed by numbers
  static bool isValidUserId(String id) {
    final regex = RegExp(r'^(CA|CS|CL)(0[1-9]|[1-9][0-9]|[1-9][0-9][0-9])$');
    return regex.hasMatch(id);
  }

  // Validate email format
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  // Validate mobile number (Indian format)
  static bool isValidMobile(String mobile) {
    final regex = RegExp(r'^[6-9]\d{9}$');
    return regex.hasMatch(mobile);
  }

  // Validate PAN number format
  static bool isValidPAN(String pan) {
    final regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return regex.hasMatch(pan.toUpperCase());
  }

  // Validate GST number format
  static bool isValidGST(String gst) {
    final regex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    return regex.hasMatch(gst.toUpperCase());
  }

  // Get user ID pattern hint based on business type
  static String getUserIdHint(String businessType) {
    switch (businessType) {
      case 'CA':
        return 'CA followed by numbers (e.g., CA123)';
      case 'CS':
        return 'CS followed by numbers (e.g., CS456)';
      case 'CL':
        return 'CL followed by numbers (e.g., CL789)';
      default:
        return 'Enter valid User ID';
    }
  }

  // Get business type full name
  static String getBusinessTypeFullName(String businessType) {
    switch (businessType) {
      case 'CA':
        return 'Chartered Accountant';
      case 'CS':
        return 'Company Secretary';
      case 'CL':
        return 'Cost & Works Accountant';
      default:
        return businessType;
    }
  }
}