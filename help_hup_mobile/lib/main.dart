import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/features/organization/organization_list/ui/organization_list_manager_view.dart';
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

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(AuthService(), StorageService());
  }

  @override
  void dispose() {
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
          return const _SplashScreen();
        }

        if (state is AuthAuthenticated) {
          final role = state.user.role.trim().toLowerCase();

          if (role == 'manager') {
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
//  - - - - -- -- -  - - - - - - - - - - - - - --

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
              child: Icon(
                Icons.volunteer_activism,
                color: Colors.white,
                size: 48,
              ),
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
