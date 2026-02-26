import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/models/application_response.dart';
import '../../../core/services/application_service.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/ui/login_screen.dart';
import '../../favourites/ui/list_favourite_screen.dart';
import '../../opportunities/ui/opportunities_list_screen.dart';
import '../../profile/ui/profile_screen.dart';
import '../bloc/application_bloc.dart';

enum _ApplicationsTab { all, pending, resolved }

class ApplicationsListScreen extends StatefulWidget {
  const ApplicationsListScreen({super.key});

  @override
  State<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends State<ApplicationsListScreen> {
  late final ApplicationsBloc _applicationsBloc;
  _ApplicationsTab _selectedTab = _ApplicationsTab.all;

  @override
  void initState() {
    super.initState();
    _applicationsBloc = ApplicationsBloc(ApplicationService());
    _loadCurrentTab();
  }

  @override
  void dispose() {
    _applicationsBloc.close();
    super.dispose();
  }

  void _loadCurrentTab() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    if (authState.user.role.trim().toUpperCase() != 'USER') return;

    _applicationsBloc.add(
      ApplicationsRequested(
        userId: authState.user.id,
        status: _statusForTab(_selectedTab),
      ),
    );
  }

  String? _statusForTab(_ApplicationsTab tab) {
    switch (tab) {
      case _ApplicationsTab.all:
        return null;
      case _ApplicationsTab.pending:
        return 'PENDING';
      case _ApplicationsTab.resolved:
        return null;
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OpportunitiesListScreen()),
      );
    } else if (index == 2) {
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
    } else if (index == 3) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isUser = isAuthenticated &&
        authState.user.role.trim().toUpperCase() == 'USER';

    return BlocProvider.value(
      value: _applicationsBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabs(),
              Expanded(
                child: !isAuthenticated
                    ? _buildGuestState()
                    : !isUser
                        ? _buildNotAllowedState()
                        : _buildApplicationsList(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 1,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: const Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            child: Text(
              'Mis Solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF10221C),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Todas',
              tab: _ApplicationsTab.all,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'Pendientes',
              tab: _ApplicationsTab.pending,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'Resueltas',
              tab: _ApplicationsTab.resolved,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required _ApplicationsTab tab,
  }) {
    final isSelected = _selectedTab == tab;

    return GestureDetector(
      onTap: () {
        if (_selectedTab == tab) return;
        setState(() {
          _selectedTab = tab;
        });
        _loadCurrentTab();
      },
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF10B77F) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF10B77F) : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsList() {
    return BlocBuilder<ApplicationsBloc, ApplicationsState>(
      builder: (context, state) {
        if (state is ApplicationsInitial || state is ApplicationsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF10B77F)),
          );
        }

        if (state is ApplicationsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                    style: const TextStyle(color: Color(0xFF52525B)),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _loadCurrentTab,
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

        final loaded = state as ApplicationsLoaded;
        final applications = _filterBySelectedTab(loaded.applications);

        if (applications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 56,
                  color: Color(0xFFA1A1AA),
                ),
                SizedBox(height: 12),
                Text(
                  'No hay solicitudes para este filtro',
                  style: TextStyle(color: Color(0xFF52525B)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemBuilder: (context, index) {
            return _ApplicationCard(application: applications[index]);
          },
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemCount: applications.length,
        );
      },
    );
  }

  List<ApplicationResponse> _filterBySelectedTab(
    List<ApplicationResponse> applications,
  ) {
    if (_selectedTab != _ApplicationsTab.resolved) return applications;
    return applications.where((item) => _isResolvedStatus(item.status)).toList();
  }

  bool _isResolvedStatus(String status) {
    final normalized = status.trim().toUpperCase();
    return normalized == 'ACCEPTED' ||
        normalized == 'REJECTED' ||
        normalized == 'APPROVED' ||
        normalized == 'DECLINED';
  }

  Widget _buildGuestState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 54,
              color: Color(0xFF10B77F),
            ),
            const SizedBox(height: 12),
            const Text(
              'Inicia sesion para ver tus solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF10221C),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B77F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Iniciar sesion'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAllowedState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Esta seccion solo esta disponible para usuarios voluntarios.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF52525B),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});

  final ApplicationResponse application;

  @override
  Widget build(BuildContext context) {
    final visual = _statusVisual(application.status);
    final dateText = application.applicationDate == null
        ? 'Sin fecha'
        : DateFormat('dd MMM', 'es').format(application.applicationDate!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1F10B77F)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.volunteer_activism_outlined,
                  color: Color(0xFF10B77F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            application.opportunityTitle,
                            style: const TextStyle(
                              color: Color(0xFF10221C),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: visual.background,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            visual.label,
                            style: TextStyle(
                              color: visual.foreground,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Solicitud enviada: $dateText',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _statusMessage(application.status),
                      style: TextStyle(
                        color: visual.foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (application.status.trim().toUpperCase() != 'PENDING')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Detalle de solicitud proximamente.'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: visual.buttonBackground,
                  foregroundColor: visual.buttonForeground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _buttonLabel(application.status),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _statusMessage(String status) {
    final normalized = status.trim().toUpperCase();
    if (normalized == 'PENDING') {
      return 'La organizacion esta revisando tu perfil.';
    }
    if (normalized == 'ACCEPTED' || normalized == 'APPROVED') {
      return 'Tu participacion ha sido confirmada.';
    }
    if (normalized == 'REJECTED' || normalized == 'DECLINED') {
      return 'Lo sentimos, no ha sido posible aceptar la solicitud.';
    }
    return 'Estado actualizado por la organizacion.';
  }

  String _buttonLabel(String status) {
    final normalized = status.trim().toUpperCase();
    if (normalized == 'ACCEPTED' || normalized == 'APPROVED') {
      return 'Ver detalles';
    }
    return 'Cerrado';
  }

  _StatusVisual _statusVisual(String status) {
    final normalized = status.trim().toUpperCase();
    if (normalized == 'PENDING') {
      return const _StatusVisual(
        label: 'PENDIENTE',
        background: Color(0xFFFEF3C7),
        foreground: Color(0xFFD97706),
        buttonBackground: Color(0xFFF3F4F6),
        buttonForeground: Color(0xFF10221C),
      );
    }
    if (normalized == 'ACCEPTED' || normalized == 'APPROVED') {
      return const _StatusVisual(
        label: 'ACEPTADA',
        background: Color(0x1910B77F),
        foreground: Color(0xFF10B77F),
        buttonBackground: Color(0xFF10B77F),
        buttonForeground: Colors.white,
      );
    }
    if (normalized == 'REJECTED' || normalized == 'DECLINED') {
      return const _StatusVisual(
        label: 'RECHAZADA',
        background: Color(0xFFFEF2F2),
        foreground: Color(0xFFEF4444),
        buttonBackground: Color(0xFFF9FAFB),
        buttonForeground: Color(0xFF9CA3AF),
      );
    }
    return const _StatusVisual(
      label: 'ESTADO',
      background: Color(0xFFE5E7EB),
      foreground: Color(0xFF4B5563),
      buttonBackground: Color(0xFFF3F4F6),
      buttonForeground: Color(0xFF10221C),
    );
  }
}

class _StatusVisual {
  final String label;
  final Color background;
  final Color foreground;
  final Color buttonBackground;
  final Color buttonForeground;

  const _StatusVisual({
    required this.label,
    required this.background,
    required this.foreground,
    required this.buttonBackground,
    required this.buttonForeground,
  });
}
