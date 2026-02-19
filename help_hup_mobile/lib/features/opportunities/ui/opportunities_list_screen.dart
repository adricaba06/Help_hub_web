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

  @override
  void initState() {
    super.initState();
    // Cargar todas las oportunidades al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OpportunityProvider>().searchOpportunities('');
    });
    
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header con HelpHub y notificación
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HelpHub',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B77F),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFF52525B)),
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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      icon: Icons.location_on,
                      label: 'Madrid',
                      hasDropdown: true,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      icon: Icons.calendar_today,
                      label: 'Fechas',
                      hasDropdown: true,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      icon: Icons.category,
                      label: 'Categorías',
                      hasDropdown: true,
                    ),
                  ],
                ),
              ),
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

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: provider.opportunities.length,
                    itemBuilder: (context, index) {
                      return OpportunityCard(
                        opportunity: provider.opportunities[index],
                      );
                    },
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

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool hasDropdown,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B77F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );
  }
}
