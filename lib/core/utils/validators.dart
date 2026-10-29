class AppValidators {
  static String? requiredField(String? value, {String message = 'Field ini wajib diisi'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }
    return null;
  }

  static String? numeric(String? value, {String message = 'Hanya boleh berisi angka'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    if (num.tryParse(value.trim()) == null) {
      return message;
    }
    return null;
  }

  static String? minNumber(String? value, num min, {String? message}) {
    final numVal = num.tryParse(value ?? '');
    if (numVal == null || numVal < min) {
      return message ?? 'Nilai minimal adalah $min';
    }
    return null;
  }
}

