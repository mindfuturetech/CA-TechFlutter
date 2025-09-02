class AuthValidators {
  static String sanitizeLoginInput(String input) {
    return input.trim().toUpperCase();
  }

  static bool isValidUserId(String userId) {
    // Matches the backend validation: CA/CS/CL followed by 1-999
    final regex = RegExp(r'^(CA|CS|CL)(0[1-9]|[1-9][0-9]|[1-9][0-9][0-9])$');
    return regex.hasMatch(userId);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  static String? validateUserId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your User ID';
    }

    final sanitized = sanitizeLoginInput(value);
    if (!isValidUserId(sanitized)) {
      return 'Enter a valid User ID (e.g., CA01, CS123, CL999)';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (!isValidPassword(value)) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }
}
