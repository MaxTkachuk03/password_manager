import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MasterPasswordService {
  static final MasterPasswordService _instance = MasterPasswordService._internal();
  factory MasterPasswordService() => _instance;
  MasterPasswordService._internal();

  static const String _masterPasswordKey = 'master_password';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Get master password
  Future<String?> getMasterPassword() async {
    try {
      return await _storage.read(key: _masterPasswordKey);
    } catch (e) {
      return null;
    }
  }

  /// Set master password
  Future<void> setMasterPassword(String password) async {
    await _storage.write(key: _masterPasswordKey, value: password);
  }

  /// Check if master password is set
  Future<bool> hasMasterPassword() async {
    final password = await getMasterPassword();
    return password != null && password.isNotEmpty;
  }

  /// Clear master password
  Future<void> clearMasterPassword() async {
    await _storage.delete(key: _masterPasswordKey);
  }

  /// Verify master password
  Future<bool> verifyMasterPassword(String password) async {
    final storedPassword = await getMasterPassword();
    return storedPassword == password;
  }
}

