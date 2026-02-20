import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:help_hup_mobile/features/organization/create_organization_form_page/ui/create_organization_form_page_view.dart';
import 'package:help_hup_mobile/features/organization/organization_list/bloc/organization_list_page_bloc.dart';

class OrganizationListManagerView extends StatelessWidget {
  const OrganizationListManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrganizationListPageBloc>(
      create: (_) =>
          OrganizationListPageBloc(OrganizationService())
            ..add(LoadManagerOrganizations()),
      child: const _OrganizationListScreen(),
    );
  }
}

class _OrganizationListScreen extends StatelessWidget {
  const _OrganizationListScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _TopHeader(),
            Expanded(
              child:
                  BlocBuilder<
                    OrganizationListPageBloc,
                    OrganizationListPageState
                  >(
                    builder: (context, state) {
                      if (state is OrganizationListPageLoading ||
                          state is OrganizationListPageInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is OrganizationListPageError) {
                        return _ErrorBlock(
                          error: state.error,
                          onRetry: () {
                            context.read<OrganizationListPageBloc>().add(
                              LoadManagerOrganizations(),
                            );
                          },
                        );
                      }

                      if (state is OrganizationListPageLoaded) {
                        final organizations = state.organizations.content;
                        final uniqueCities = organizations
                            .map((e) => e.city.trim().toLowerCase())
                            .toSet()
                            .length;

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<OrganizationListPageBloc>().add(
                              LoadManagerOrganizations(),
                            );
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            children: [
                              _PanelCard(
                                totalOrgs: state.organizations.totalElements,
                                totalCities: uniqueCities,
                              ),
                              const SizedBox(height: 16),
                              if (organizations.isEmpty) const _EmptyBlock(),
                              ...organizations.map(
                                (org) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _OrganizationCard(org: org),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
            ),
            const _BottomNavMock(),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF10B77F).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1F5F9),
            ),
            child: const Icon(Icons.apartment, color: Color(0xFF334155)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Mis Organizaciones',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CrearOrganizacionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B77F),
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final int totalOrgs;
  final int totalCities;

  const _PanelCard({required this.totalOrgs, required this.totalCities});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0C10B77F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x3310B77F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panel de Control',
            style: TextStyle(
              color: Color(0xFF10B77F),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gestionas $totalOrgs organizaciones activas en $totalCities ciudades diferentes.',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final Organization org;

  const _OrganizationCard({required this.org});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.business, color: Color(0xFF334155)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  org.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        org.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          height: 1.33,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Eliminar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavMock extends StatelessWidget {
  const _BottomNavMock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: const [
          _NavItem(label: 'Explorar', icon: Icons.explore_outlined),
          _NavItem(
            label: 'Solicitudes',
            icon: Icons.description_outlined,
            selected: true,
          ),
          _NavItem(label: 'Favoritos', icon: Icons.favorite_border),
          _NavItem(label: 'Perfil', icon: Icons.person_outline),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _NavItem({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF10B77F) : const Color(0xFF64748B);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected ? const Color(0x1910B77F) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: const Text(
        'No hay organizaciones para mostrar.',
        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBlock({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE11D48)),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
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
}
