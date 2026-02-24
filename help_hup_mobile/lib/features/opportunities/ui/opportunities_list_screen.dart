import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../../../widgets/opportunity_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../favourites/ui/list_favourite_screen.dart';
import '../bloc/opportunity_bloc.dart';

class OpportunitiesListScreen extends StatefulWidget {
  const OpportunitiesListScreen({super.key});

  @override
  State<OpportunitiesListScreen> createState() =>
      _OpportunitiesListScreenState();
}

class _OpportunitiesListScreenState extends State<OpportunitiesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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

  void _onBottomNavTap(int index) {
    if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ListFavouriteScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cargar datos la primera vez que se muestra la pantalla
    _loadDataIfNeeded();
    
    return Scaffold(
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
                  IconButton(
                    icon: const Icon(Icons.logout_outlined, color: Color(0xFF52525B)),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    tooltip: 'Cerrar sesión',
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
                                return OpportunityCard(
                                  opportunity: state.opportunities[index],
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
