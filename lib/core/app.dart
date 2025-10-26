import 'package:flutter/material.dart';
import 'package:password_manager/features/login/presentation/login_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Manager',
      home: LoginPage(),
      // theme: appThemeData,
      // routerDelegate: _appRouter.delegate(
      //   navigatorObservers: () => [
      //     RouteObserverUtils(),
      //     UxcamNavigationObserver(),
      //     FirebaseNavigatorObserver(
      //       analytics: _analytics,
      //     ),
      //     NavigatorObserver(),
      //   ],
      // ),
      // routeInformationParser: _appRouter.defaultRouteParser(),
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
      // locale: currentLocale,
    );
  }
}
