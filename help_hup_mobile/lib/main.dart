import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/config/bloc_observer.dart';
import 'core/services/auth_service.dart';
import 'core/services/opportunity_service.dart';
import 'core/services/profile_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/opportunities/bloc/opportunity_bloc.dart';
import 'features/opportunities/ui/opportunities_list_screen.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'widgets/splash_screen.dart';

void main() async {
  // Ensure Flutter engine is initialized before any plugin calls
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-warm SharedPreferences so the first frame has no async wait
  await SharedPreferences.getInstance();
  // Initialize date formatting for Spanish locale
  await initializeDateFormatting('es', null);
  // Configure BLoC observer for global logging
  Bloc.observer = AppBlocObserver();
  runApp(const HelpHubApp());
}

class HelpHubApp extends StatelessWidget {
  const HelpHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthService(), StorageService())),
        BlocProvider(create: (_) => OpportunityBloc(OpportunityService())),
        BlocProvider(create: (_) => ProfileBloc(ProfileService())),
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        return const OpportunitiesListScreen();
      },
    );
  }
}
