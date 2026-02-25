import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/features/organization/organization_list/ui/organization_list_manager_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/config/bloc_observer.dart';
import 'core/services/auth_service.dart';
import 'core/services/opportunity_service.dart';
import 'core/services/profile_service.dart';
import 'core/services/session_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/ui/login_screen.dart';
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

class HelpHubApp extends StatefulWidget {
  const HelpHubApp({super.key});

  @override
  State<HelpHubApp> createState() => _HelpHubAppState();
}

class _HelpHubAppState extends State<HelpHubApp> {
  late final AuthBloc _authBloc;
  late final StreamSubscription<void> _unauthorizedSub;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(AuthService(), StorageService());
    _unauthorizedSub = SessionService.instance.unauthorizedStream.listen((_) {
      _authBloc.add(AuthLogoutRequested());
    });
  }

  @override
  void dispose() {
    _unauthorizedSub.cancel();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider(create: (_) => OpportunityBloc(OpportunityService())),
        BlocProvider(create: (_) => ProfileBloc(ProfileService())),
      ],
      child: MaterialApp(
        title: 'HelpHub',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                previous is AuthAuthenticated &&
                current is AuthUnauthenticated,
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                _navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: child ?? const SizedBox.shrink(),
          );
        },
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

//  - - - - -- -- -  - - - - - - - - - - - - - --
class _AuthWrapper extends StatelessWidget {
  // esto se trata de un envoltorio donde dependiendo del estado y del rol se llevará a una pantalla o otra
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        if (state is AuthAuthenticated) {
          final role = state.user.role.trim().toUpperCase();

          if (role == 'MANAGER' || role == 'ROLE_MANAGER') {
            // manager
            return const OrganizationListManagerView();
          }

          return const OpportunitiesListScreen();
        }

        return const OpportunitiesListScreen();
      },
    );
  }
}
