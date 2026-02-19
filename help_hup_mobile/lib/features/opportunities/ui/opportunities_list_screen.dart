import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/opportunity_provider.dart';
import '../widgets/opportunity_card.dart';

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
          context.read<OpportunityProvider>().searchOpportunities('');
        }
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context
          .read<OpportunityProvider>()
          .searchOpportunities(_searchController.text.trim());
    });
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
                      context.read<AuthProvider>().logout();
                    },
                    tooltip: 'Cerrar sesión',
                  ),
                ],
              ),
            ),
            
            // Campo de búsqueda
            Container(
              color: Colors.white,
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
                  fillColor: const Color(0xFFF6F8F7),
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
            Consumer<OpportunityProvider>(
              builder: (context, provider, _) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          icon: Icons.location_on,
                          label: provider.selectedCity ?? 'Ciudad',
                          hasDropdown: true,
                          isActive: provider.selectedCity != null,
                          onTap: _showCityFilterDialog,
                          onClear: provider.selectedCity != null 
                              ? () => provider.setCity(null) 
                              : null,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          icon: Icons.calendar_today,
                          label: _getDateRangeLabel(provider),
                          hasDropdown: true,
                          isActive: provider.filterDateFrom != null || provider.filterDateTo != null,
                          onTap: _showDateRangeDialog,
                          onClear: provider.filterDateFrom != null || provider.filterDateTo != null
                              ? () => provider.setDateRange(null, null)
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
              child: Consumer<OpportunityProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF10B77F),
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
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
                              provider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF52525B),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                provider.searchOpportunities(
                                    _searchController.text.trim());
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

                  if (provider.opportunities.isEmpty) {
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
                      // Header "Oportunidades destacadas"
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Oportunidades destacadas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF18181B),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Acción para ver todas
                                },
                                child: const Text(
                                  'Ver todas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B77F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Lista de oportunidades
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return OpportunityCard(
                                opportunity: provider.opportunities[index],
                              );
                            },
                            childCount: provider.opportunities.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // Footer estático - sin navegación
        },
      ),
    );
  }

  String _getDateRangeLabel(OpportunityProvider provider) {
    if (provider.filterDateFrom != null && provider.filterDateTo != null) {
      final from = '${provider.filterDateFrom!.day}/${provider.filterDateFrom!.month}';
      final to = '${provider.filterDateTo!.day}/${provider.filterDateTo!.month}';
      return '$from - $to';
    } else if (provider.filterDateFrom != null) {
      return 'Desde ${provider.filterDateFrom!.day}/${provider.filterDateFrom!.month}';
    } else if (provider.filterDateTo != null) {
      return 'Hasta ${provider.filterDateTo!.day}/${provider.filterDateTo!.month}';
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
      context.read<OpportunityProvider>().setCity(selectedCity);
    }
  }

  Future<void> _showDateRangeDialog() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: context.read<OpportunityProvider>().filterDateFrom != null &&
              context.read<OpportunityProvider>().filterDateTo != null
          ? DateTimeRange(
              start: context.read<OpportunityProvider>().filterDateFrom!,
              end: context.read<OpportunityProvider>().filterDateTo!,
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
      context.read<OpportunityProvider>().setDateRange(picked.start, picked.end);
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
          color: isActive ? const Color(0xFF10B77F) : const Color(0xFFE4E4E7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF52525B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF52525B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasDropdown && !isActive) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: isActive ? Colors.white : const Color(0xFF52525B),
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
