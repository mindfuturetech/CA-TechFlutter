class EmployeeValidation {
  // Sanitization methods
  static String sanitizeUsername(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '').trim();
  }

  static String sanitizeMobile(String value) {
    return value.replaceAll(RegExp(r'[^\d+]'), '').trim();
  }

  // Validation methods
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username must be 3-20 alphanumeric characters only';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }

    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    if (!mobileRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  // Validate entire employee list
  static String? validateEmployeeList(List<Map<String, String>> employees) {
    if (employees.isEmpty) {
      return 'Please add at least one employee';
    }

    for (int i = 0; i < employees.length; i++) {
      final emp = employees[i];

      if (emp['username']?.isEmpty ?? true) {
        return 'Employee ${i + 1}: Username is required';
      }

      if (emp['email']?.isEmpty ?? true) {
        return 'Employee ${i + 1}: Email is required';
      }

      if (emp['mobile']?.isEmpty ?? true) {
        return 'Employee ${i + 1}: Mobile is required';
      }

      // Validate individual fields
      String? usernameError = validateUsername(emp['username']);
      if (usernameError != null) {
        return 'Employee ${i + 1}: $usernameError';
      }

      String? emailError = validateEmail(emp['email']);
      if (emailError != null) {
        return 'Employee ${i + 1}: $emailError';
      }

      String? mobileError = validateMobile(emp['mobile']);
      if (mobileError != null) {
        return 'Employee ${i + 1}: $mobileError';
      }
    }

    return null;
  }
}