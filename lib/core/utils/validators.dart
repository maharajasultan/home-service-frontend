class Validators {
  Validators._();

  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi.';
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Email wajib diisi.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) return 'Format email tidak valid.';
    return null;
  }

  /// Menerima 08..., 628..., atau +628... (server menormalkan ke 08...).
  static String? phone(String? value) {
    var digits = (value ?? '').replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return 'Nomor HP wajib diisi.';
    if (digits.startsWith('+62')) {
      digits = '0${digits.substring(3)}';
    } else if (digits.startsWith('62')) {
      digits = '0${digits.substring(2)}';
    }
    if (!RegExp(r'^08[1-9][0-9]{7,11}$').hasMatch(digits)) {
      return 'Nomor HP tidak valid. Contoh: 081234567890.';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Kata sandi wajib diisi.';
    if (text.length < 8) return 'Kata sandi minimal 8 karakter.';
    if (!RegExp(r'[A-Za-z]').hasMatch(text)) return 'Kata sandi harus mengandung huruf.';
    if (!RegExp(r'\d').hasMatch(text)) return 'Kata sandi harus mengandung angka.';
    return null;
  }

  static String? code(String? value) {
    if (!RegExp(r'^\d{6}$').hasMatch((value ?? '').trim())) return 'Kode verifikasi terdiri dari 6 digit angka.';
    return null;
  }
}