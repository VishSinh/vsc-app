/// Utility class for common validation patterns
class ValidationPatterns {
  /// Regular expression for validating email addresses
  static final RegExp emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  /// Regular expression for validating phone numbers (10 digits)
  static final RegExp phonePattern = RegExp(r'^[0-9]{10}$');

  /// Regular expression for validating Indian phone numbers with optional country code
  static final RegExp indianPhonePattern = RegExp(r'^(\+91[\-\s]?)?[0]?(91)?[6789]\d{9}$');

  /// Regular expression for validating passwords
  /// Requires at least 8 characters, including at least one uppercase letter,
  /// one lowercase letter, one number, and one special character
  static final RegExp strongPasswordPattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  /// Regular expression for validating URLs
  static final RegExp urlPattern = RegExp(r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');

  /// Regular expression for validating PAN card numbers (India)
  static final RegExp panCardPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

  /// Regular expression for validating GST numbers (India)
  static final RegExp gstNumberPattern = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');

  /// Regular expression for validating Aadhaar numbers (India)
  static final RegExp aadhaarNumberPattern = RegExp(r'^[2-9]{1}[0-9]{11}$');

  /// Regular expression for validating PIN codes (India)
  static final RegExp pinCodePattern = RegExp(r'^[1-9][0-9]{5}$');

  /// Regular expression for validating alphanumeric text
  static final RegExp alphanumericPattern = RegExp(r'^[a-zA-Z0-9]+$');

  /// Regular expression for validating numeric text
  static final RegExp numericPattern = RegExp(r'^[0-9]+$');

  /// Regular expression for validating decimal numbers
  static final RegExp decimalPattern = RegExp(r'^\d+(\.\d+)?$');

  /// Regular expression for validating alphabetic text
  static final RegExp alphabeticPattern = RegExp(r'^[a-zA-Z]+$');

  /// Validate an email address
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return emailPattern.hasMatch(email);
  }

  /// Validate a phone number
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    return phonePattern.hasMatch(phone);
  }

  /// Validate an Indian phone number
  static bool isValidIndianPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    return indianPhonePattern.hasMatch(phone);
  }

  /// Validate a strong password
  static bool isValidStrongPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    return strongPasswordPattern.hasMatch(password);
  }

  /// Validate a URL
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return urlPattern.hasMatch(url);
  }

  /// Validate a PAN card number (India)
  static bool isValidPanCard(String? panCard) {
    if (panCard == null || panCard.isEmpty) return false;
    return panCardPattern.hasMatch(panCard);
  }

  /// Validate a GST number (India)
  static bool isValidGstNumber(String? gstNumber) {
    if (gstNumber == null || gstNumber.isEmpty) return false;
    return gstNumberPattern.hasMatch(gstNumber);
  }

  /// Validate an Aadhaar number (India)
  static bool isValidAadhaarNumber(String? aadhaarNumber) {
    if (aadhaarNumber == null || aadhaarNumber.isEmpty) return false;
    return aadhaarNumberPattern.hasMatch(aadhaarNumber);
  }

  /// Validate a PIN code (India)
  static bool isValidPinCode(String? pinCode) {
    if (pinCode == null || pinCode.isEmpty) return false;
    return pinCodePattern.hasMatch(pinCode);
  }

  /// Validate alphanumeric text
  static bool isAlphanumeric(String? text) {
    if (text == null || text.isEmpty) return false;
    return alphanumericPattern.hasMatch(text);
  }

  /// Validate numeric text
  static bool isNumeric(String? text) {
    if (text == null || text.isEmpty) return false;
    return numericPattern.hasMatch(text);
  }

  /// Validate decimal number
  static bool isDecimal(String? text) {
    if (text == null || text.isEmpty) return false;
    return decimalPattern.hasMatch(text);
  }

  /// Validate alphabetic text
  static bool isAlphabetic(String? text) {
    if (text == null || text.isEmpty) return false;
    return alphabeticPattern.hasMatch(text);
  }
}
