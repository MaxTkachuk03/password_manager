import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';

class EncryptionService {
  static const int _nonceLength = 12; // 96 bits for GCM nonce

  /// Derive encryption key from password using PBKDF2
  static Key _deriveKey(String password, String salt) {
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);
    
    // Use PBKDF2 to derive key
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(saltBytes, 100000, 32));
    
    final secretKey = pbkdf2.process(passwordBytes);
    
    return Key(Uint8List.fromList(secretKey));
  }

  /// Generate salt for key derivation
  static String _generateSalt() {
    final random = IV.fromSecureRandom(16);
    return base64.encode(random.bytes);
  }

  /// Encrypt data with password using AES256-GCM
  static String encrypt(String plainText, String password) {
    try {
      // Generate salt
      final salt = _generateSalt();
      
      // Derive key from password
      final key = _deriveKey(password, salt);
      
      // Generate nonce for GCM
      final nonce = IV.fromSecureRandom(_nonceLength);
      
      // Create encrypter with AES-GCM mode
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      
      // Encrypt data
      final encrypted = encrypter.encrypt(plainText, iv: nonce);
      
      // Combine salt, nonce, and encrypted data
      // GCM mode includes authentication tag in the encrypted data
      final encryptedData = {
        'salt': salt,
        'nonce': base64.encode(nonce.bytes),
        'data': encrypted.base64,
      };
      
      return base64.encode(utf8.encode(jsonEncode(encryptedData)));
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Decrypt data with password using AES256-GCM
  static String decrypt(String encryptedText, String password) {
    try {
      // Decode base64
      final decoded = utf8.decode(base64.decode(encryptedText));
      final encryptedData = jsonDecode(decoded) as Map<String, dynamic>;
      
      // Extract salt, nonce, and encrypted data
      final salt = encryptedData['salt'] as String;
      final nonceBase64 = encryptedData['nonce'] as String;
      final dataBase64 = encryptedData['data'] as String;
      
      // Derive key from password
      final key = _deriveKey(password, salt);
      
      // Create nonce
      final nonce = IV(base64.decode(nonceBase64));
      
      // Create encrypter with AES-GCM mode
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      
      // Decrypt data (GCM mode includes authentication tag in encrypted data)
      final encrypted = Encrypted(base64.decode(dataBase64));
      final decrypted = encrypter.decrypt(encrypted, iv: nonce);
      
      return decrypted;
    } catch (e) {
      throw EncryptionException('Failed to decrypt data. Wrong password or corrupted file.');
    }
  }

  /// Check if string is encrypted (contains encrypted structure)
  static bool isEncrypted(String text) {
    try {
      final decoded = utf8.decode(base64.decode(text));
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      return data.containsKey('salt') && 
             data.containsKey('nonce') && 
             data.containsKey('data');
    } catch (e) {
      return false;
    }
  }
}

class EncryptionException implements Exception {
  final String message;
  
  const EncryptionException(this.message);
  
  @override
  String toString() => 'EncryptionException: $message';
}

