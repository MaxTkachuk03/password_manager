import 'package:flutter/material.dart';
import '../../../core/security/app_lock_service.dart';
import '../../../core/widgets/password_dialog.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final AppLockService _lockService = AppLockService();
  bool _isUnlocking = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _tryBiometricUnlock();
  }

  Future<void> _checkBiometric() async {
    final available = await _lockService.isBiometricAvailable();
    setState(() {
      _biometricAvailable = available;
    });
  }

  Future<void> _tryBiometricUnlock() async {
    if (_biometricAvailable) {
      final unlocked = await _lockService.unlockApp(useBiometric: true);
      if (unlocked && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _unlockWithPassword() async {
    if (_isUnlocking) return;
    
    setState(() {
      _isUnlocking = true;
    });

    final password = await PasswordDialog.show(
      context,
      title: 'Розблокування',
      hint: 'Введіть пароль для розблокування',
    );

    if (password != null) {
      final unlocked = await _lockService.unlockApp(password: password);
      if (unlocked && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Невірний пароль'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isUnlocking = false;
      });
    }
  }

  Future<void> _unlockWithBiometric() async {
    if (_isUnlocking) return;
    
    setState(() {
      _isUnlocking = true;
    });

    final unlocked = await _lockService.unlockApp(useBiometric: true);
    if (unlocked && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      setState(() {
        _isUnlocking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Застосунок заблоковано',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Введіть пароль або використайте біометрію для розблокування',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (_biometricAvailable) ...[
                    ElevatedButton.icon(
                      onPressed: _isUnlocking ? null : _unlockWithBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Розблокувати біометрією'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton.icon(
                    onPressed: _isUnlocking ? null : _unlockWithPassword,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Розблокувати паролем'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

