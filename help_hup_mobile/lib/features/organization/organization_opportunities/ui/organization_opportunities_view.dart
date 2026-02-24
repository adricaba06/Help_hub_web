import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Oportunidades',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
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
      ),
      body: BlocBuilder<OrganizationOpportunitiesBloc, OrganizationOpportunitiesState>(
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
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrganizationOpportunitiesBloc>().add(
                  const RefreshOrganizationOpportunities(),
                );
              },
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _StatsCard(total: state.totalElements),
                  const SizedBox(height: 16),
                  if (state.opportunities.isEmpty)
                    const _EmptyBlock()
                  else
                    ...state.opportunities.map(
                      (opportunity) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OpportunityListCard(opportunity: opportunity),
                      ),
                    ),
                  if (!state.hasReachedEnd && !state.isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<OrganizationOpportunitiesBloc>().add(
                              const LoadMoreOrganizationOpportunities(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B77F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.expand_more),
                          label: const Text('Ver mas'),
                        ),
                      ),
                    ),
                  if (state.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  opportunity.city,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFF64748B)),
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
            Icon(
              Icons.inbox_outlined,
              color: Color(0xFF94A3B8),
              size: 28,
            ),
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
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
