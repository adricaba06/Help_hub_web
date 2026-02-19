import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/opportunities/provider/opportunity_provider.dart';
import 'features/opportunities/ui/opportunities_list_screen.dart';

void main() async {
  // Ensure Flutter engine is initialized before any plugin calls
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-warm SharedPreferences so the first frame has no async wait
  await SharedPreferences.getInstance();
  // Initialize date formatting for Spanish locale
  await initializeDateFormatting('es', null);
  runApp(const HelpHubApp());
}

class HelpHubApp extends StatelessWidget {
  const HelpHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OpportunityProvider()),
      ],
      child: MaterialApp(
        title: 'HelpHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF10B77F),
            primary: const Color(0xFF10B77F),
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: const _AuthWrapper(),
      ),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const _SplashScreen();
          case AuthStatus.authenticated:
            return const OpportunitiesListScreen();
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F8F7),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFF10B77F),
              child: Icon(Icons.volunteer_activism, color: Colors.white, size: 48),
            ),
            SizedBox(height: 20),
            Text(
              'HelpHub',
              style: TextStyle(
                color: Color(0xFF18181B),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tu ayuda importa',
              style: TextStyle(color: Color(0xFF52525B), fontSize: 15),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Color(0xFF10B77F),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
