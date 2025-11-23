import 'package:flutter/services.dart';
import 'dart:math';

/// Platform channel for YubiKey communication
/// TODO: Replace with real YubiKey integration in Epic 2
class YubiKeyService {
  static const MethodChannel _channel = MethodChannel('securevault/yubikey');
  
  // Mock mode flag - set to true to use stubs instead of platform channel
  static const bool _useMockMode = true;

  /// Check if YubiKey is connected
  /// MOCK: Always returns true for development
  static Future<bool> isYubiKeyConnected() async {
    if (_useMockMode) {
      // Mock: YubiKey is always connected
      return true;
    }
    
    try {
      final bool isConnected = await _channel.invokeMethod('isYubiKeyConnected');
      return isConnected;
    } on PlatformException {
      return false;
    }
  }

  /// Generate TOTP code from YubiKey
  /// MOCK: Generates a random 6-digit code for development
  static Future<String?> generateTOTP() async {
    if (_useMockMode) {
      // Mock: Generate a random 6-digit TOTP code
      final random = Random();
      final code = (100000 + random.nextInt(900000)).toString();
      // Simulate delay
      await Future.delayed(const Duration(milliseconds: 500));
      return code;
    }
    
    try {
      final String? totpCode = await _channel.invokeMethod('generateTOTP');
      return totpCode;
    } on PlatformException {
      return null;
    }
  }

  /// Perform hardware confirmation with YubiKey
  /// MOCK: Always returns true for development
  static Future<bool> performHardwareConfirmation() async {
    if (_useMockMode) {
      // Mock: Hardware confirmation always succeeds
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }
    
    try {
      final bool confirmed = await _channel.invokeMethod('performHardwareConfirmation');
      return confirmed;
    } on PlatformException {
      return false;
    }
  }

  /// Get YubiKey information
  /// MOCK: Returns mock YubiKey info for development
  static Future<Map<String, dynamic>?> getYubiKeyInfo() async {
    if (_useMockMode) {
      // Mock: Return mock YubiKey information
      return {
        'name': 'YubiKey 5 NFC (Mock)',
        'serial': '12345678',
        'version': '5.4.3',
        'model': 'YubiKey 5 NFC',
        'capabilities': ['OTP', 'FIDO2', 'PIV'],
      };
    }
    
    try {
      final Map<String, dynamic>? info = await _channel.invokeMethod('getYubiKeyInfo');
      return info;
    } on PlatformException {
      return null;
    }
  }
}