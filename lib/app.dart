import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/chat/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/firestore_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'utils/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                      AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.light,
      darkTheme:                  AppTheme.dark,
      themeMode:                  ThemeMode.system,
      routes:                     AppRoutes.routes,
      home:                       const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper>
    with WidgetsBindingObserver {

  final _firestoreService = FirestoreService();
  String? _currentUid;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthState();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (_currentUid != null) {
      _firestoreService.updateOnlineStatus(_currentUid!, false);
    }
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentUid == null) return;

    switch (state) {
      case AppLifecycleState.resumed:

        _firestoreService.updateOnlineStatus(_currentUid!, true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:

        _firestoreService.updateOnlineStatus(_currentUid!, false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {

        _currentUid = auth.currentUser?.uid;

        switch (auth.status) {
          case AuthStatus.authenticated:

            if (_currentUid != null) {
              _firestoreService.updateOnlineStatus(
                  _currentUid!, true);
            }
            return const HomeScreen();

          case AuthStatus.unauthenticated:
          case AuthStatus.error:

            if (_currentUid != null) {
              _firestoreService.updateOnlineStatus(
                  _currentUid!, false);
            }
            return const LoginScreen();

          default:
            return const Scaffold(
              backgroundColor: AppColors.backgroundDark,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              ),
            );
        }
      },
    );
  }
}