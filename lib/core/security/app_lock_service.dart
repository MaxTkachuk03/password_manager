import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  static final AppLockService _instance = AppLockService._internal();
  factory AppLockService() => _instance;
  AppLockService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  DateTime? _lastActiveTime;
  Timer? _lockTimer;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  /// Initialize app lock service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final autoLockMinutes = prefs.getInt('auto_lock_minutes') ?? 5;
    
    if (autoLockMinutes > 0) {
      _startLockTimer(autoLockMinutes);
    }
    
    _lastActiveTime = DateTime.now();
  }

  /// Update last active time
  void updateActiveTime() {
    _lastActiveTime = DateTime.now();
  }

  /// Start lock timer
  void _startLockTimer(int minutes) {
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      if (_lastActiveTime != null) {
        final inactiveDuration = DateTime.now().difference(_lastActiveTime!);
        if (inactiveDuration.inMinutes >= minutes) {
          await lockApp();
        }
      }
    });
  }

  /// Lock the app
  Future<void> lockApp() async {
    _isLocked = true;
    _lockTimer?.cancel();
  }

  /// Unlock the app with password or biometric
  Future<bool> unlockApp({
    String? password,
    bool useBiometric = false,
  }) async {
    if (useBiometric) {
      try {
        final isAvailable = await _localAuth.canCheckBiometrics ||
            await _localAuth.isDeviceSupported();
        
        if (isAvailable) {
          final didAuthenticate = await _localAuth.authenticate(
            localizedReason: 'Розблокуйте застосунок для доступу до паролів',
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),
          );
          
          if (didAuthenticate) {
            _isLocked = false;
            updateActiveTime();
            final prefs = await SharedPreferences.getInstance();
            final autoLockMinutes = prefs.getInt('auto_lock_minutes') ?? 5;
            if (autoLockMinutes > 0) {
              _startLockTimer(autoLockMinutes);
            }
            return true;
          }
        }
      } catch (e) {
        // Biometric authentication failed
        return false;
      }
    }
    
    // Password-based unlock
    if (password != null) {
      final prefs = await SharedPreferences.getInstance();
      final storedPassword = prefs.getString('app_lock_password');
      
      if (storedPassword == null || storedPassword == password) {
        _isLocked = false;
        updateActiveTime();
        final autoLockMinutes = prefs.getInt('auto_lock_minutes') ?? 5;
        if (autoLockMinutes > 0) {
          _startLockTimer(autoLockMinutes);
        }
        return true;
      }
    }
    
    return false;
  }

  /// Set app lock password
  Future<void> setLockPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lock_password', password);
  }

  /// Check if biometric is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _lockTimer?.cancel();
  }
}

