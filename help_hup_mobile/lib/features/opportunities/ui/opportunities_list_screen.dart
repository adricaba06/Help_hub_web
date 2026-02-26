import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/features/opportunities/provider/opportunity_detail_provider.dart';
import 'package:help_hup_mobile/features/opportunities/ui/opportunity_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/services/favorite_opportunity_service.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../../../widgets/opportunity_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/ui/login_screen.dart';
import '../../applications/ui/applications_list_screen.dart';
import '../../favourites/ui/list_favourite_screen.dart';
import '../../profile/ui/profile_screen.dart';
import '../bloc/opportunity_bloc.dart';

class OpportunitiesListScreen extends StatefulWidget {
  const OpportunitiesListScreen({super.key});

  @override
  State<OpportunitiesListScreen> createState() =>
      _OpportunitiesListScreenState();
}

class _OpportunitiesListScreenState extends State<OpportunitiesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FavoriteOpportunityService _favoriteService = FavoriteOpportunityService();
  Timer? _debounce;
  bool _hasLoadedData = false;
  Set<int> _favoriteIds = <int>{};
  Set<int> _favoriteUpdatingIds = <int>{};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoritesForUser();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadDataIfNeeded() {
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      // Cargar con un pequeño delay para asegurar que el token esté listo
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<OpportunityBloc>().add(OpportunitySearchRequested(''));
        }
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context
          .read<OpportunityBloc>()
          .add(OpportunitySearchRequested(_searchController.text.trim()));
    });
  }

  bool _isUserRole(AuthState authState) {
    if (authState is! AuthAuthenticated) return false;
    return authState.user.role.trim().toUpperCase() == 'USER';
  }

  Future<void> _loadFavoritesForUser() async {
    final authState = context.read<AuthBloc>().state;
    if (!_isUserRole(authState)) {
      if (!mounted) return;
      setState(() {
        _favoriteIds = <int>{};
        _favoriteUpdatingIds = <int>{};
      });
      return;
    }

    try {
      final favoriteIds = await _favoriteService.getMyFavoriteIds();
      if (!mounted) return;
      setState(() {
        _favoriteIds = favoriteIds;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _favoriteIds = <int>{};
      });
    }
  }

  Future<void> _toggleFavorite(int opportunityId) async {
    if (_favoriteUpdatingIds.contains(opportunityId)) return;

    final isCurrentlyFavorite = _favoriteIds.contains(opportunityId);
    setState(() {
      _favoriteUpdatingIds = {..._favoriteUpdatingIds, opportunityId};
      if (isCurrentlyFavorite) {
        _favoriteIds = {..._favoriteIds}..remove(opportunityId);
      } else {
        _favoriteIds = {..._favoriteIds, opportunityId};
      }
    });

    try {
      if (isCurrentlyFavorite) {
        await _favoriteService.removeFavorite(opportunityId);
      } else {
        await _favoriteService.addFavorite(opportunityId);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (isCurrentlyFavorite) {
          _favoriteIds = {..._favoriteIds, opportunityId};
        } else {
          _favoriteIds = {..._favoriteIds}..remove(opportunityId);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _favoriteUpdatingIds = {..._favoriteUpdatingIds}
            ..remove(opportunityId);
        });
      }
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 1) {
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
        Navigator.of(context).push(
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
    // Cargar datos la primera vez que se muestra la pantalla
    _loadDataIfNeeded();
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (_isUserRole(authState)) {
          _loadFavoritesForUser();
          return;
        }
        setState(() {
          _favoriteIds = <int>{};
          _favoriteUpdatingIds = <int>{};
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),
        body: SafeArea(
        child: Column(
          children: [
            // Header con HelpHub
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HelpHub',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B77F),
                      letterSpacing: -0.5,
                    ),
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      if (authState is AuthAuthenticated) {
                        return const SizedBox(width: 40);
                      }

                      return TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF10B77F),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.login, size: 18),
                            Positioned(
                              right: -2,
                              top: -1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD92D20),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        label: const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar oportunidades...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF52525B),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Chips de filtros
            BlocBuilder<OpportunityBloc, OpportunityState>(
              builder: (context, state) {
                String? selectedCity;
                DateTime? filterDateFrom;
                DateTime? filterDateTo;

                if (state is OpportunityLoaded) {
                  selectedCity = state.selectedCity;
                  filterDateFrom = state.filterDateFrom;
                  filterDateTo = state.filterDateTo;
                } else if (state is OpportunityError) {
                  selectedCity = state.selectedCity;
                  filterDateFrom = state.filterDateFrom;
                  filterDateTo = state.filterDateTo;
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          icon: Icons.location_on,
                          label: selectedCity ?? 'Ciudad',
                          hasDropdown: true,
                          isActive: selectedCity != null,
                          onTap: _showCityFilterDialog,
                          onClear: selectedCity != null 
                              ? () => context.read<OpportunityBloc>().add(OpportunityCityFilterChanged(null))
                              : null,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          icon: Icons.calendar_today,
                          label: _getDateRangeLabel(filterDateFrom, filterDateTo),
                          hasDropdown: true,
                          isActive: filterDateFrom != null || filterDateTo != null,
                          onTap: _showDateRangeDialog,
                          onClear: filterDateFrom != null || filterDateTo != null
                              ? () => context.read<OpportunityBloc>().add(OpportunityDateRangeChanged(null, null))
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Lista de oportunidades
            Expanded(
              child: BlocBuilder<OpportunityBloc, OpportunityState>(
                builder: (context, state) {
                  if (state is OpportunityLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF10B77F),
                      ),
                    );
                  }

                  if (state is OpportunityError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Color(0xFFA1A1AA),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF52525B),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<OpportunityBloc>().add(
                                    OpportunitySearchRequested(_searchController.text.trim()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B77F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is OpportunityLoaded) {
                    if (state.opportunities.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Color(0xFFA1A1AA),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No hay oportunidades disponibles'
                                  : 'No se encontraron oportunidades',
                              style: const TextStyle(
                                color: Color(0xFF52525B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return CustomScrollView(
                      slivers: [
                        // Lista de oportunidades
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final opportunity = state.opportunities[index];
                                final canFavorite = _isUserRole(
                                  context.read<AuthBloc>().state,
                                ) && opportunity.isOpen;
                                
                                return InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChangeNotifierProvider(
                                          create: (_) =>
                                              OpportunityDetailProvider(),
                                          child: OpportunityDetailScreen(
                                            opportunityId: opportunity.id,
                                          ),
                                      ),
                                    ),
                                  );
                                },
                                child: OpportunityCard(
                                  opportunity: opportunity,
                                  showFavoriteButton: canFavorite,
                                    isFavorite: _favoriteIds.contains(
                                      opportunity.id,
                                    ),
                                    isFavoriteLoading:
                                        _favoriteUpdatingIds.contains(
                                          opportunity.id,
                                        ),
                                  onFavoriteTap: canFavorite
                                      ? () => _toggleFavorite(opportunity.id)
                                      : null,
                                  ),
                              );
                              
                              },
                              childCount: state.opportunities.length,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Estado inicial
                  return const Center(
                    child: Text(
                      'Bienvenido a HelpHub',
                      style: TextStyle(
                        color: Color(0xFF52525B),
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 0,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  String _getDateRangeLabel(DateTime? filterDateFrom, DateTime? filterDateTo) {
    if (filterDateFrom != null && filterDateTo != null) {
      final from = '${filterDateFrom.day}/${filterDateFrom.month}';
      final to = '${filterDateTo.day}/${filterDateTo.month}';
      return '$from - $to';
    } else if (filterDateFrom != null) {
      return 'Desde ${filterDateFrom.day}/${filterDateFrom.month}';
    } else if (filterDateTo != null) {
      return 'Hasta ${filterDateTo.day}/${filterDateTo.month}';
    }
    return 'Fechas';
  }

  Future<void> _showCityFilterDialog() async {
    final cities = ['Madrid', 'Barcelona', 'Valencia', 'Sevilla'];
    
    final selectedCity = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar ciudad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: cities.map((city) {
                return ListTile(
                  title: Text(city),
                  onTap: () => Navigator.of(context).pop(city),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (selectedCity != null && mounted) {
      context.read<OpportunityBloc>().add(OpportunityCityFilterChanged(selectedCity));
    }
  }

  Future<void> _showDateRangeDialog() async {
    final bloc = context.read<OpportunityBloc>();
    final currentState = bloc.state;
    
    DateTime? currentDateFrom;
    DateTime? currentDateTo;
    
    if (currentState is OpportunityLoaded) {
      currentDateFrom = currentState.filterDateFrom;
      currentDateTo = currentState.filterDateTo;
    } else if (currentState is OpportunityError) {
      currentDateFrom = currentState.filterDateFrom;
      currentDateTo = currentState.filterDateTo;
    }
    
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: currentDateFrom != null && currentDateTo != null
          ? DateTimeRange(
              start: currentDateFrom,
              end: currentDateTo,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B77F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF52525B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      context.read<OpportunityBloc>().add(OpportunityDateRangeChanged(picked.start, picked.end));
    }
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool hasDropdown,
    bool isActive = false,
    VoidCallback? onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF10B77F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasDropdown && !isActive) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.white,
              ),
            ],
            if (isActive && onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


