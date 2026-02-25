import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:help_hup_mobile/features/favourites/ui/list_favourite_screen.dart';
import 'package:help_hup_mobile/features/opportunities/ui/opportunities_list_screen.dart';
import 'package:help_hup_mobile/features/organization/organization_list/ui/organization_list_manager_view.dart';
import 'package:help_hup_mobile/widgets/app_bottom_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const SizedBox.shrink();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0x1A10B77F),
                      child: Icon(Icons.person, color: Color(0xFF10B77F)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.user.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            state.user.email,
                            style: const TextStyle(color: Color(0xFF52525B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(
                    Icons.logout_outlined,
                    color: Color(0xFFB91C1C),
                  ),
                  title: const Text(
                    'Cerrar sesion',
                    style: TextStyle(color: Color(0xFFB91C1C)),
                  ),
                  onTap: () => _confirmLogout(context),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OpportunitiesListScreen()),
      );
      return;
    }

    if (index == 1) {
      final authState = context.read<AuthBloc>().state;
      final isManager =
          authState is AuthAuthenticated &&
          authState.user.role.trim().toLowerCase() == 'manager';

      if (isManager) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrganizationListManagerView()),
        );
      }
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ListFavouriteScreen()),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesion'),
          content: const Text('Quieres cerrar la sesion actual?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Cerrar sesion',
                style: TextStyle(color: Color(0xFFB91C1C)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }
}
