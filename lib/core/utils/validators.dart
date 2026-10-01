/// Reusable form validators. Every form in the app should use these so error
/// copy stays consistent.
class Validators {
  const Validators._();

  static final RegExp _email = RegExp(
    r'^[\w\.\-\+]+@[\w\-]+(\.[\w\-]+)+$',
  );

  /// E.164-ish phone check that also accepts formatted US numbers.
  static final RegExp _phone = RegExp(r'^\+?[0-9\s\-\(\)]{7,20}$');

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? name(String? value) {
    final empty = required(value, field: 'Full name');
    if (empty != null) return empty;
    if (value!.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, field: 'Email');
    if (empty != null) return empty;
    if (!_email.hasMatch(value!.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    final empty = required(value, field: 'Phone number');
    if (empty != null) return empty;
    if (!_phone.hasMatch(value!.trim())) return 'Enter a valid phone number';
    return null;
  }

  /// Optional phone – only validates when the user typed something.
  static String? optionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return phone(value);
  }

  static String? password(String? value) {
    final empty = required(value, field: 'Password');
    if (empty != null) return empty;
    if (value!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final empty = required(value, field: 'Confirm password');
    if (empty != null) return empty;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Free-text fields (business name, address, …).
  static String? minLength(String? value, int min, {String field = 'This field'}) {
    final empty = required(value, field: field);
    if (empty != null) return empty;
    if (value!.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }
}
