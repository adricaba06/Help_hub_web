import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:help_hup_mobile/core/services/storage_service.dart';
import 'package:help_hup_mobile/features/organization/create_organization_form_page/ui/create_organization_form_page_view.dart';
import 'package:help_hup_mobile/features/organization/delete_organization/bloc/delete_organization_bloc.dart';
import 'package:help_hup_mobile/features/organization/organization_list/bloc/organization_list_page_bloc.dart';
import 'package:help_hup_mobile/features/organization/view_organization_detail/ui/view_organization_detail_view.dart';
import 'package:help_hup_mobile/features/profile/ui/profile_screen.dart';
import 'package:help_hup_mobile/widgets/app_bottom_nav_bar.dart';

class OrganizationListManagerView extends StatelessWidget {
  const OrganizationListManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrganizationListPageBloc>(
          create: (_) => OrganizationListPageBloc(OrganizationService()),
        ),
        BlocProvider<DeleteOrganizationBloc>(
          create: (_) => DeleteOrganizationBloc(OrganizationService()),
        ),
      ],
      child: const _OrganizationListScreen(),
    );
  }
}

class _OrganizationListScreen extends StatefulWidget {
  const _OrganizationListScreen();

  @override
  State<_OrganizationListScreen> createState() => _OrganizationListScreenState();
}

class _OrganizationListScreenState extends State<_OrganizationListScreen> {
  static const double _loadMoreThreshold = 200;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameFilterController = TextEditingController();
  final TextEditingController _cityFilterController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialOrganizations();
  }

  Future<void> _loadInitialOrganizations() async {
    final user = await StorageService().getUser();
    final role = user?.role.trim().toUpperCase() ?? '';
    final isAdmin = role == 'ADMIN' || role == 'ROLE_ADMIN';
    if (!mounted) return;

    setState(() => _isAdmin = isAdmin);
    context.read<OrganizationListPageBloc>().add(
      LoadOrganizations(size: 8, fetchAll: isAdmin),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) return;

    final bloc = context.read<OrganizationListPageBloc>();
    final state = bloc.state;
    if (state is! OrganizationListPageLoaded) return;
    if (state.isLoadingMore || state.hasReachedEnd) return;

    bloc.add(LoadMoreOrganizations(size: state.pageSize));
  }

  @override
  void dispose() {
    _nameFilterController.dispose();
    _cityFilterController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _applyAdminFilters() {
    final name = _nameFilterController.text.trim();
    final city = _cityFilterController.text.trim();
    context.read<OrganizationListPageBloc>().add(
      LoadOrganizations(
        size: 8,
        fetchAll: true,
        name: name.isEmpty ? null : name,
        city: city.isEmpty ? null : city,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteOrganizationBloc, DeleteOrganizationState>(
      listener: (context, state) {
        if (state is DeleteOrganizationLoaded) {
          context.read<OrganizationListPageBloc>().add(
            RemoveOrganizationFromList(organizationId: state.organizationId),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Organizacion eliminada')),
          );
        }
        if (state is DeleteOrganizationError) {}
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 0,
          onTap: _onBottomNavTap,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _TopHeader(isAdmin: _isAdmin),
              Expanded(
                child:
                    BlocBuilder<
                      OrganizationListPageBloc,
                      OrganizationListPageState
                    >(
                      builder: (context, state) {
                        if (state is OrganizationListPageLoading ||
                            state is OrganizationListPageInitial) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is OrganizationListPageError) {
                          return _ErrorBlock(
                            error: state.error,
                            onRetry: () {
                              context.read<OrganizationListPageBloc>().add(
                                LoadOrganizations(size: 8, fetchAll: _isAdmin),
                              );
                            },
                          );
                        }

                        if (state is OrganizationListPageLoaded) {
                          final organizations = state.organizations;
                          final uniqueCities = organizations
                              .map((e) => e.city.trim().toLowerCase())
                              .toSet()
                              .length;

                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<OrganizationListPageBloc>().add(
                                LoadOrganizations(
                                  size: state.pageSize,
                                  fetchAll: state.fetchAll,
                                  name: state.nameFilter,
                                  city: state.cityFilter,
                                ),
                              );
                            },
                            child: ListView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              children: [
                                _PanelCard(
                                  totalOrgs: state.totalElements,
                                  totalCities: uniqueCities,
                                  isAdmin: state.fetchAll,
                                ),
                                const SizedBox(height: 16),
                                if (state.fetchAll)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _AdminFiltersCard(
                                      nameController: _nameFilterController,
                                      cityController: _cityFilterController,
                                      onApply: _applyAdminFilters,
                                      onClear: () {
                                        _nameFilterController.clear();
                                        _cityFilterController.clear();
                                        _applyAdminFilters();
                                      },
                                    ),
                                  ),
                                if (organizations.isEmpty) const _EmptyBlock(),
                                ...organizations.map(
                                  (org) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _OrganizationCard(
                                      org: org,
                                      canDelete: !state.fetchAll,
                                    ),
                                  ),
                                ),
                                if (!state.hasReachedEnd && !state.isLoadingMore)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      bottom: 16,
                                    ),
                                    child: Center(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          context
                                              .read<OrganizationListPageBloc>()
                                              .add(
                                                LoadMoreOrganizations(
                                                  size: state.pageSize,
                                                ),
                                              );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF10B77F,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.expand_more),
                                        label: const Text(
                                          'Ver mas',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (state.isLoadingMore)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
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
            ],
          ),
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }
}

class _TopHeader extends StatelessWidget {
  final bool isAdmin;

  const _TopHeader({required this.isAdmin});

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
          Expanded(
            child: Text(
              isAdmin ? 'Todas las Organizaciones' : 'Mis Organizaciones',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (!isAdmin)
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
  final bool isAdmin;

  const _PanelCard({
    required this.totalOrgs,
    required this.totalCities,
    required this.isAdmin,
  });

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
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isAdmin
                ? 'Ves $totalOrgs organizaciones registradas en $totalCities ciudades.'
                : 'Gestionas $totalOrgs organizaciones activas en $totalCities ciudades.',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AdminFiltersCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController cityController;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const _AdminFiltersCard({
    required this.nameController,
    required this.cityController,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x3310B77F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              color: Color(0xFF10B77F),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Busca por nombre o ciudad para acotar resultados',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Nombre de organizacion',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.badge_outlined, size: 18),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF10B77F)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: cityController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onApply(),
            decoration: InputDecoration(
              hintText: 'Ciudad',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.location_city_outlined, size: 18),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF10B77F)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B77F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final Organization org;
  final bool canDelete;

  const _OrganizationCard({required this.org, required this.canDelete});

  @override
  Widget build(BuildContext context) {
    final logoUrl = OrganizationService().buildImageUrl(org.logoFieldId);
    final coverUrl = OrganizationService().buildImageUrl(org.coverFieldId);
    final imageUrl = logoUrl ?? coverUrl;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewOrganizationDetailView(organizationId: org.id),
          ),
        );
      },
      child: Container(
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
              child: _OrganizationImage(imageUrl: imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(org.city, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (canDelete)
              TextButton(
                onPressed: () async {
                  final deleteBloc = context.read<DeleteOrganizationBloc>();
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Confirmar eliminacion'),
                        content: Text(
                          'Seguro que quieres eliminar "${org.name}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete == true) {
                    deleteBloc.add(
                      SubmitDeleteOrganization(organizationId: org.id),
                    );
                  }
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _OrganizationImage extends StatelessWidget {
  final String? imageUrl;

  const _OrganizationImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const Icon(Icons.image_outlined, color: Color(0xFF64748B));
    }

    return FutureBuilder<String?>(
      future: StorageService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final token = snapshot.data;
        if (token == null || token.isEmpty) {
          return const Icon(Icons.image_outlined, color: Color(0xFF64748B));
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            headers: <String, String>{'Authorization': 'Bearer $token'},
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_outlined,
                color: Color(0xFF64748B),
              );
            },
          ),
        );
      },
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No hay organizaciones.'));
  }
}

class _ErrorBlock extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBlock({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(error),
        ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}

