class Validators {
  Validators._();
  static final _email = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email wajib diisi';
    if (!_email.hasMatch(s)) return 'Format email belum benar';
    return null;
  }

  static String? passwordRequired(String? v) =>
      (v ?? '').isEmpty ? 'Password wajib diisi' : null;

  static String? passwordNew(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Password wajib diisi';
    if (s.length < 8) return 'Minimal 8 karakter';
    return null;
  }

  static String? name(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Nama wajib diisi';
    if (s.length < 2) return 'Nama terlalu pendek';
    return null;
  }

  static String? confirm(String? v, String original) {
    if ((v ?? '').isEmpty) return 'Ulangi password-mu';
    if (v != original) return 'Password belum sama';
    return null;
  }
}
