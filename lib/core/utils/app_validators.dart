class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    // Removes spaces and checks for 10-15 digits (accommodating country codes like +91)
    final cleanPhone = value.trim().replaceAll(' ', '');
    final phoneRegex = RegExp(r"^\+?[0-9]{10,15}$");
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required.';
    }
    if (value.length != 6) {
      return 'OTP must be exactly 6 digits.';
    }
    return null;
  }
}