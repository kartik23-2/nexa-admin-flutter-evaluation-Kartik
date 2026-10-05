import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/firebase_service.dart';
import 'state/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const NexaAdminApp());
}

class NexaAdminApp extends StatelessWidget {
  const NexaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'NEXA Admin Lite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: AppRoutes.navigatorKey,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.dashboard: (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
