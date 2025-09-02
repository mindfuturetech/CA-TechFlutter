class FormValidation {
  // Validate complete form data (equivalent to your validateForm function)
  static String? validateForm(Map<String, dynamic> formData) {
    final name = formData['name'] ?? '';
    final mobile = formData['mobile'] ?? '';
    final email = formData['email'] ?? '';
    final pan = formData['pan'] ?? '';
    final gst = formData['gst'] ?? '';
    final shopAct = formData['shopAct'] ?? '';
    final address = formData['address'] ?? '';

    // Name validation: Only alphabets, max length
    final nameRegex = RegExp(r'^[a-zA-Z\s]{2,50}$');
    if (!nameRegex.hasMatch(name)) {
      return "Invalid name";
    }

    // Mobile validation: 10-digit numeric check
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    if (!mobileRegex.hasMatch(mobile)) {
      return "Invalid mobile number";
    }

    // Email validation: Valid email pattern
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return "Invalid email";
    }

    // PAN validation: 10-character alphanumeric (e.g., ABCDE1234F)
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    if (!panRegex.hasMatch(pan)) {
      return "Invalid PAN";
    }

    // GST validation: 15-character format (only if provided)
    if (gst.isNotEmpty) {
      final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
      if (!gstRegex.hasMatch(gst)) {
        return "Invalid GST";
      }
    }

    // Shop Act validation: Basic length validation (only if provided)
    if (shopAct.isNotEmpty && (shopAct.length < 5 || shopAct.length > 20)) {
      return "Invalid Shop Act License";
    }

    // Address validation: Max length
    if (address.length < 10 || address.length > 300) {
      return "Invalid address";
    }

    return null; // No errors
  }

  // Individual field validators
  static String? validateName(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter your name';
    final nameRegex = RegExp(r'^[a-zA-Z\s]{2,50}$');
    if (!nameRegex.hasMatch(value!)) return 'Name should only contain letters and spaces';
    return null;
  }

  static String? validateMobile(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter mobile number';
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    if (!mobileRegex.hasMatch(value!)) return 'Enter valid 10-digit mobile number';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter email address';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value!)) return 'Enter valid email address';
    return null;
  }

  static String? validatePAN(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter PAN number';
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    if (!panRegex.hasMatch(value!)) return 'Enter valid PAN (e.g., ABCDE1234F)';
    return null;
  }

  static String? validateGST(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter GST number';
    final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gstRegex.hasMatch(value!)) return 'Enter valid GST number';
    return null;
  }

  static String? validateShopAct(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter Shop Act License';
    if (value!.length < 5 || value.length > 20) return 'Shop Act License should be 5-20 characters';
    return null;
  }

  static String? validateAddress(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter address';
    if (value!.length < 10 || value.length > 300) return 'Address should be 10-300 characters';
    return null;
  }

  static String? validateCompanyName(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter company name';
    if (value!.length < 2 || value.length > 100) return 'Company name should be 2-100 characters';
    return null;
  }
}