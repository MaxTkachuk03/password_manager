import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:password_manager/features/home/bloc/home_bloc.dart';
import 'package:password_manager/features/login/presentation/login_page.dart';
import 'package:password_manager/core/theme/app_theme.dart';
import 'package:password_manager/core/security/app_lock_service.dart';

class AppThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  AppThemeNotifier() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      notifyListeners();
    } catch (e) {
      // If there's an error, keep default value (false)
      _isDarkMode = false;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
    notifyListeners();
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final AppThemeNotifier _themeNotifier = AppThemeNotifier();
  final AppLockService _lockService = AppLockService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lockService.initialize();
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeNotifier.dispose();
    _lockService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _lockService.updateActiveTime();
    } else if (state == AppLifecycleState.resumed) {
      _checkLockStatus();
    }
  }

  Future<void> _checkLockStatus() async {
    if (_lockService.isLocked) {
      // When app is locked, logout user and show login page
      // Reset lock service state
      _lockService.updateActiveTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeNotifier,
      builder: (context, _) {
        return MultiBlocProvider(
          providers: [BlocProvider(create: (context) => HomeBloc())],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SecureVault',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: LoginPage(themeNotifier: _themeNotifier),
          ),
        );
      },
    );
  }
}
