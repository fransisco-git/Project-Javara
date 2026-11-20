import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  const AuthUser({required this.name, required this.email});
  final String name;
  final String email;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// ⚠️ SIMULASI LOKAL — hanya untuk demo / tugas, BUKAN keamanan sungguhan.
/// Akun disimpan di perangkat dengan hash SHA-256 + salt statis.
/// Untuk produksi, ganti isi kelas ini dengan Firebase Auth / backend sendiri;
/// layar tidak perlu diubah karena hanya memanggil method di bawah.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Kode verifikasi demo. Tidak ada email yang benar-benar dikirim.
  static const demoCode = '12345';
  static const codeLength =
      5; // desain menulis "5 digit"; ubah di sini jika ternyata 4

  static const _kAccounts = 'auth_accounts';
  static const _kSession = 'auth_session_email';
  static const _salt = 'javara-demo-salt';

  String _normalize(String email) => email.trim().toLowerCase();
  String _hash(String password) =>
      sha256.convert(utf8.encode('$_salt:$password')).toString();

  Map<String, dynamic> _readAccounts(SharedPreferences p) {
    final raw = p.getString(_kAccounts);
    if (raw == null || raw.isEmpty) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    final email = p.getString(_kSession);
    return email != null && _readAccounts(p).containsKey(email);
  }

  Future<AuthUser?> currentUser() async {
    final p = await SharedPreferences.getInstance();
    final email = p.getString(_kSession);
    if (email == null) return null;
    final acct = _readAccounts(p)[email];
    if (acct == null) return null;
    final name =
        (Map<String, dynamic>.from(acct as Map)['name'] ?? '') as String;
    return AuthUser(name: name, email: email);
  }

  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final p = await SharedPreferences.getInstance();
    final accounts = _readAccounts(p);
    final key = _normalize(email);
    if (accounts.containsKey(key)) {
      throw const AuthException('Email ini sudah terdaftar. Coba Log In saja.');
    }
    accounts[key] = {'name': name.trim(), 'hash': _hash(password)};
    await p.setString(_kAccounts, jsonEncode(accounts));
    await p.setString(_kSession, key);
    return AuthUser(name: name.trim(), email: key);
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final p = await SharedPreferences.getInstance();
    final key = _normalize(email);
    final acct = _readAccounts(p)[key];
    if (acct == null) {
      throw const AuthException('Akun belum terdaftar. Yuk Sign Up dulu.');
    }
    final data = Map<String, dynamic>.from(acct as Map);
    if (data['hash'] != _hash(password)) {
      throw const AuthException('Email atau password salah.');
    }
    await p.setString(_kSession, key);
    return AuthUser(name: (data['name'] ?? '') as String, email: key);
  }

  Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSession);
  }

  // ---- Alur Lupa Password (simulasi) ----

  Future<void> requestReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    // Produksi: panggil backend. Jangan bocorkan apakah email terdaftar atau tidak.
  }

  Future<void> verifyCode(String email, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (code != demoCode) {
      throw const AuthException('Kode belum cocok. Cek lagi kode di emailmu.');
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final p = await SharedPreferences.getInstance();
    final accounts = _readAccounts(p);
    final key = _normalize(email);
    final acct = accounts[key];
    if (acct == null) {
      throw const AuthException('Akun dengan email ini tidak ditemukan.');
    }
    final data = Map<String, dynamic>.from(acct as Map);
    data['hash'] = _hash(newPassword);
    accounts[key] = data;
    await p.setString(_kAccounts, jsonEncode(accounts));
  }
}
