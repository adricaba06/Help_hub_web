import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/features/auth/bloc/auth_bloc.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final role = state is AuthAuthenticated
            ? state.user.role.trim().toUpperCase()
            : '';
        final isOrganizationRole =
            role == 'MANAGER' ||
            role == 'ROLE_MANAGER' ||
            role == 'ADMIN' ||
            role == 'ROLE_ADMIN';
        final effectiveIndex = isOrganizationRole
            ? (currentIndex == 1 || currentIndex == 3 ? 1 : 0)
            : currentIndex;
        final items = isOrganizationRole
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.apartment_outlined),
                  activeIcon: Icon(Icons.apartment),
                  label: 'Organizaciones',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Explorar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.description_outlined),
                  activeIcon: Icon(Icons.description),
                  label: 'Solicitudes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favoritos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ];

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: effectiveIndex,
          onTap: onTap,
          selectedItemColor: const Color(0xFF10B77F),
          unselectedItemColor: const Color(0xFFA1A1AA),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: items,
        );
      },
    );
  }
}
