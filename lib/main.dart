import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/test_result_filter_provider.dart';
import 'providers/beta_engagement_provider.dart';
import 'providers/launch_readiness_provider.dart';
import 'package:vccm/screens/auth/login_screen.dart';
import 'package:vccm/screens/auth/register_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TestResultFilterProvider()),
        ChangeNotifierProvider(create: (_) => BetaEngagementProvider()),
        ChangeNotifierProvider(create: (_) => LaunchReadinessProvider()),
      ],
      child: MaterialApp(
        title: 'VCCM',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.isLoading) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return userProvider.isAuthenticated
                      ? const DashboardScreen()
                      : const LoginScreen();
                },
              ),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/home': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
