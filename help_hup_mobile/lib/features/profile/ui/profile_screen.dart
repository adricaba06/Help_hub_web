import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../../applications/ui/applications_list_screen.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/ui/login_screen.dart';
import '../../favourites/ui/list_favourite_screen.dart';
import '../../opportunities/ui/opportunities_list_screen.dart';
import '../../organization/organization_list/ui/organization_list_manager_view.dart';
import '../bloc/profile_bloc.dart';
import '../../profile_edit/ui/profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>().add(ProfileRequested());
    }
  }

  Future<void> _openLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );

    if (!mounted) return;

    if (context.read<AuthBloc>().state is AuthAuthenticated) {
      context.read<ProfileBloc>().add(ProfileRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isManager = authState is AuthAuthenticated &&
        (authState.user.role.trim().toUpperCase() == 'MANAGER' ||
            authState.user.role.trim().toUpperCase() == 'ROLE_MANAGER');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Center(
                child: Text(
                  'Perfil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF18181B),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isAuthenticated ? _buildAuthenticatedContent() : _buildGuestContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: isManager ? 1 : 3,
        onTap: (index) {
          if (index == 0) {
            if (isManager) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OrganizationListManagerView()),
              );
              return;
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OpportunitiesListScreen()),
            );
          } else if (!isManager && index == 2) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ListFavouriteScreen()),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          } else if (!isManager && index == 1) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ApplicationsListScreen()),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildGuestContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 44,
                color: Color(0xFF10B77F),
              ),
              const SizedBox(height: 14),
              const Text(
                'Inicia sesión para ver tu perfil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Necesitas autenticarte para consultar tus datos personales.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF52525B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B77F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedContent() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF10B77F),
            ),
          );
        }

        if (state is ProfileError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 56,
                    color: Color(0xFFA1A1AA),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF52525B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(ProfileRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B77F),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = (state as ProfileLoaded).user;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE6E6E6),
                  child: Icon(
                    Icons.person,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1C),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9F0E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role,
                    style: const TextStyle(
                      color: Color(0xFF10B77F),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F3EC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Color(0xFF10B77F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EMAIL',
                              style: TextStyle(
                                color: Color(0xFF10B77F),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: Color(0xFF262626),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  label: 'Editar Perfil',
                  icon: Icons.edit,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileEditScreen(user: user),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  label: 'Cambiar contraseña',
                  icon: Icons.edit,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  label: 'Cerrar sesión',
                  icon: Icons.logout,
                  backgroundColor: const Color(0xFFB42318),
                  onTap: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor = const Color(0xFF10B77F),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
