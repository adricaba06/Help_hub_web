import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/core/models/opportunity_filter.dart';
import 'package:help_hup_mobile/core/models/opportunity_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:help_hup_mobile/features/organization/organization_opportunities/bloc/organization_opportunities_bloc.dart';
import 'package:intl/intl.dart';

class OrganizationOpportunitiesView extends StatelessWidget {
  final int organizationId;
  final String organizationName;

  const OrganizationOpportunitiesView({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrganizationOpportunitiesBloc(
        organizationService: OrganizationService(),
        organizationId: organizationId,
      )..add(const LoadOrganizationOpportunities()),
      child: _OrganizationOpportunitiesScreen(
        organizationName: organizationName,
      ),
    );
  }
}

class _OrganizationOpportunitiesScreen extends StatefulWidget {
  final String organizationName;

  const _OrganizationOpportunitiesScreen({required this.organizationName});

  @override
  State<_OrganizationOpportunitiesScreen> createState() =>
      _OrganizationOpportunitiesScreenState();
}

class _OrganizationOpportunitiesScreenState
    extends State<_OrganizationOpportunitiesScreen> {
  static const double _loadMoreThreshold = 220;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedCity;
  String? _selectedStatus;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) return;

    final bloc = context.read<OrganizationOpportunitiesBloc>();
    final current = bloc.state;
    if (current is! OrganizationOpportunitiesLoaded) return;
    if (current.isLoadingMore || current.hasReachedEnd) return;

    bloc.add(const LoadMoreOrganizationOpportunities());
  }

  void _ensureScrollableContent(OrganizationOpportunitiesLoaded state) {
    if (state.isLoadingMore || state.hasReachedEnd) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.maxScrollExtent > 0) return;

      context.read<OrganizationOpportunitiesBloc>().add(
        const LoadMoreOrganizationOpportunities(),
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _applyFilters);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : null,
    );

    if (picked == null || !mounted) return;
    setState(() {
      _dateFrom = picked.start;
      _dateTo = picked.end;
    });
  }

  void _applyFilters() {
    final title = _searchController.text.trim();

    context.read<OrganizationOpportunitiesBloc>().add(
      ApplyOrganizationOpportunitiesFilter(
        OpportunityFilter(
          title: title.isEmpty ? null : title,
          city: _selectedCity,
          dateFrom: _dateFrom,
          dateTo: _dateTo,
          status: _selectedStatus,
        ),
      ),
    );
  }

  String _dateRangeLabel() {
    if (_dateFrom != null && _dateTo != null) {
      return '${_dateFrom!.day}/${_dateFrom!.month} - ${_dateTo!.day}/${_dateTo!.month}';
    } else if (_dateFrom != null) {
      return 'Desde ${_dateFrom!.day}/${_dateFrom!.month}';
    } else if (_dateTo != null) {
      return 'Hasta ${_dateTo!.day}/${_dateTo!.month}';
    }
    return 'Fechas';
  }

  Future<void> _showCityFilterDialog() async {
    final current = context.read<OrganizationOpportunitiesBloc>().state;
    final dynamicCities = <String>[];
    if (current is OrganizationOpportunitiesLoaded) {
      dynamicCities.addAll(current.opportunities.map((e) => e.city).toSet());
      dynamicCities.sort();
    }
    final cities = dynamicCities.isNotEmpty
        ? dynamicCities
        : ['Madrid', 'Barcelona', 'Valencia', 'Sevilla'];

    final selectedCity = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar ciudad'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: cities
                .map(
                  (city) => ListTile(
                    title: Text(city),
                    onTap: () => Navigator.of(context).pop(city),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (!mounted || selectedCity == null) return;
    setState(() => _selectedCity = selectedCity);
    _applyFilters();
  }

  Future<void> _showStatusDialog() async {
    final selectedStatus = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              onTap: () => Navigator.of(context).pop(null),
            ),
            ListTile(
              title: const Text('OPEN'),
              onTap: () => Navigator.of(context).pop('OPEN'),
            ),
            ListTile(
              title: const Text('CLOSED'),
              onTap: () => Navigator.of(context).pop('CLOSED'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _selectedStatus = selectedStatus);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Oportunidades',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.organizationName,
                        style: const TextStyle(
                          color: Color(0xFF10B77F),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<OrganizationOpportunitiesBloc>().add(
                        const RefreshOrganizationOpportunities(),
                      );
                    },
                    icon: const Icon(Icons.refresh, color: Color(0xFF52525B)),
                    tooltip: 'Recargar',
                  ),
                ],
              ),
            ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      icon: Icons.location_on,
                      label: _selectedCity ?? 'Ciudad',
                      hasDropdown: true,
                      isActive: _selectedCity != null,
                      onTap: _showCityFilterDialog,
                      onClear: _selectedCity != null
                          ? () {
                              setState(() => _selectedCity = null);
                              _applyFilters();
                            }
                          : null,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      icon: Icons.calendar_today,
                      label: _dateRangeLabel(),
                      hasDropdown: true,
                      isActive: _dateFrom != null || _dateTo != null,
                      onTap: () async {
                        await _pickDateRange();
                        if (mounted) _applyFilters();
                      },
                      onClear: _dateFrom != null || _dateTo != null
                          ? () {
                              setState(() {
                                _dateFrom = null;
                                _dateTo = null;
                              });
                              _applyFilters();
                            }
                          : null,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      icon: Icons.tune,
                      label: _selectedStatus ?? 'Estado',
                      hasDropdown: true,
                      isActive: _selectedStatus != null,
                      onTap: _showStatusDialog,
                      onClear: _selectedStatus != null
                          ? () {
                              setState(() => _selectedStatus = null);
                              _applyFilters();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child:
                  BlocBuilder<
                    OrganizationOpportunitiesBloc,
                    OrganizationOpportunitiesState
                  >(
                    builder: (context, state) {
                      if (state is OrganizationOpportunitiesInitial ||
                          state is OrganizationOpportunitiesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is OrganizationOpportunitiesError) {
                        return _ErrorBlock(
                          message: state.error.replaceFirst('Exception: ', ''),
                          onRetry: () {
                            context.read<OrganizationOpportunitiesBloc>().add(
                              const LoadOrganizationOpportunities(),
                            );
                          },
                        );
                      }

                      if (state is OrganizationOpportunitiesLoaded) {
                        _ensureScrollableContent(state);

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<OrganizationOpportunitiesBloc>().add(
                              const RefreshOrganizationOpportunities(),
                            );
                          },
                          child: CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    0,
                                  ),
                                  child: _StatsCard(total: state.totalElements),
                                ),
                              ),
                              if (state.opportunities.isEmpty)
                                const SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      24,
                                    ),
                                    child: _EmptyBlock(),
                                  ),
                                )
                              else
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    20,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _OpportunityListCard(
                                          opportunity:
                                              state.opportunities[index],
                                        ),
                                      ),
                                      childCount: state.opportunities.length,
                                    ),
                                  ),
                                ),
                              if (state.isLoadingMore)
                                const SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
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
    );
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
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int total;

  const _StatsCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBCEAD7)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF10B77F),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Total de oportunidades: $total',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityListCard extends StatelessWidget {
  final OpportunityResponse opportunity;

  const _OpportunityListCard({required this.opportunity});

  String _formatDateRange() {
    final formatter = DateFormat('d MMM', 'es');
    return '${formatter.format(opportunity.dateFrom)} - ${formatter.format(opportunity.dateTo)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: opportunity.isOpen
                      ? const Color(0x1A10B77F)
                      : const Color(0x1AA1A1AA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  opportunity.isOpen ? 'ABIERTA' : 'CERRADA',
                  style: TextStyle(
                    color: opportunity.isOpen
                        ? const Color(0xFF10B77F)
                        : const Color(0xFF71717A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            opportunity.title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  opportunity.city,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDateRange(),
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const Spacer(),
              Text(
                'Plazas: ${opportunity.seats}',
                style: const TextStyle(
                  color: Color(0xFF10B77F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, color: Color(0xFF94A3B8), size: 28),
            SizedBox(height: 8),
            Text(
              'No hay oportunidades',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
