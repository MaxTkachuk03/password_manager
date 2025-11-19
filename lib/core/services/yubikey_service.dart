import 'package:flutter/services.dart';

/// Platform channel for YubiKey communication
class YubiKeyService {
  static const MethodChannel _channel = MethodChannel('securevault/yubikey');

  /// Check if YubiKey is connected
  static Future<bool> isYubiKeyConnected() async {
    try {
      final bool isConnected = await _channel.invokeMethod('isYubiKeyConnected');
      return isConnected;
    } on PlatformException {
      return false;
    }
  }

  /// Generate TOTP code from YubiKey
  static Future<String?> generateTOTP() async {
    try {
      final String? totpCode = await _channel.invokeMethod('generateTOTP');
      return totpCode;
    } on PlatformException {
      return null;
    }
  }

  /// Perform hardware confirmation with YubiKey
  static Future<bool> performHardwareConfirmation() async {
    try {
      final bool confirmed = await _channel.invokeMethod('performHardwareConfirmation');
      return confirmed;
    } on PlatformException {
      return false;
    }
  }

  /// Get YubiKey information
  static Future<Map<String, dynamic>?> getYubiKeyInfo() async {
    try {
      final Map<String, dynamic>? info = await _channel.invokeMethod('getYubiKeyInfo');
      return info;
    } on PlatformException {
      return null;
    }
  }
}