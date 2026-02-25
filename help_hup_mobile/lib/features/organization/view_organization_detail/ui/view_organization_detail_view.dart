import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:help_hup_mobile/core/services/storage_service.dart';
import 'package:help_hup_mobile/features/favourites/ui/list_favourite_screen.dart';
import 'package:help_hup_mobile/features/organization/edit_organization_form_page/ui/edit_organization_form_page.dart';
import 'package:help_hup_mobile/features/organization/organization_list/ui/organization_list_manager_view.dart';
import 'package:help_hup_mobile/features/organization/organization_opportunities/ui/organization_opportunities_view.dart';
import 'package:help_hup_mobile/features/organization/view_organization_detail/bloc/view_organization_detail_bloc.dart';
import 'package:help_hup_mobile/features/opportunities/ui/opportunities_list_screen.dart';
import 'package:help_hup_mobile/widgets/app_bottom_nav_bar.dart';

class ViewOrganizationDetailView extends StatelessWidget {
  final int organizationId;

  const ViewOrganizationDetailView({super.key, required this.organizationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ViewOrganizationDetailBloc(OrganizationService())
            ..add(LoadOrganizationDetail(organizationId: organizationId)),
      child: _ViewOrganizationDetailScreen(organizationId: organizationId),
    );
  }
}

class _ViewOrganizationDetailScreen extends StatelessWidget {
  final int organizationId;

  const _ViewOrganizationDetailScreen({required this.organizationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const TopNavigationBarIosStyle(),
            Expanded(
              child: BlocBuilder<ViewOrganizationDetailBloc, ViewOrganizationDetailState>(
                builder: (context, state) {
                  if (state is ViewOrganizationDetailInitial ||
                      state is ViewOrganizationDetailLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ViewOrganizationDetailError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.error,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                context.read<ViewOrganizationDetailBloc>().add(
                                  LoadOrganizationDetail(
                                    organizationId: organizationId,
                                  ),
                                );
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is ViewOrganizationDetailLoaded) {
                    final org = state.organization;
                    final organizationService = OrganizationService();
                    final orgDescription =
                        (org.description != null &&
                            org.description!.trim().isNotEmpty)
                        ? org.description!
                        : 'Esta organizacion no tiene descripcion publicada.';
                    final coverUrl = organizationService.buildImageUrl(
                      org.coverFieldId,
                    );
                    final logoUrl = organizationService.buildImageUrl(
                      org.logoFieldId,
                    );
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 290,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 256,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      coverUrl == null
                                          ? Image.network(
                                              'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=1200&q=60',
                                              fit: BoxFit.cover,
                                            )
                                          : _AuthorizedNetworkImage(
                                              url: coverUrl,
                                              fit: BoxFit.cover,
                                              placeholder: Container(
                                                color: const Color(0xFFE2E8F0),
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                ),
                                              ),
                                            ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withValues(
                                                alpha: 0.4,
                                              ),
                                              Colors.black.withValues(alpha: 0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 24,
                                  bottom: 0,
                                  child: Container(
                                    width: 96,
                                    height: 96,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        width: 2,
                                        color: const Color(0x3310B77F),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: logoUrl == null
                                          ? Container(
                                              color: const Color(0xFFF1F5F9),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.business,
                                                color: Color(0xFF334155),
                                              ),
                                            )
                                          : _AuthorizedNetworkImage(
                                              url: logoUrl,
                                              fit: BoxFit.cover,
                                              placeholder: Container(
                                                color: const Color(0xFFF1F5F9),
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.business,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  org.name,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.75,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Color(0xFF10B77F),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      org.city,
                                      style: const TextStyle(
                                        color: Color(0xFF10B77F),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 1.43,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1,
                                        color: Color(0x0C10B77F),
                                      ),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      _StatItem(
                                        label: 'Oportunities',
                                        value: '24',
                                      ),
                                      SizedBox(width: 24),
                                      _StatItem(
                                        label: 'VOLUNTARIOS',
                                        value: '1.2k',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Manager',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    height: 1.56,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0x0C10B77F),
                                    ),
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
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 2,
                                            color: const Color(0x3310B77F),
                                          ),
                                          image: const DecorationImage(
                                            image: NetworkImage(
                                              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=160&q=60',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              org.manager?.name ??
                                                  'Carlos Rodriguez',
                                              style: const TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Informacion',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    height: 1.56,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  orgDescription.trim().isNotEmpty
                                      ? orgDescription
                                      : 'Esta organizacion no tiene descripcion publicada.',
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    height: 1.63,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              OrganizationOpportunitiesView(
                                                organizationId: org.id,
                                                organizationName: org.name,
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B77F),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(56),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Ver Oportunidades',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        height: 1.56,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final updated =
                                          await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditOrganizationScreen(
                                                    organization: org,
                                                  ),
                                            ),
                                          );
                                      if (updated == true && context.mounted) {
                                        context
                                            .read<ViewOrganizationDetailBloc>()
                                            .add(
                                              LoadOrganizationDetail(
                                                organizationId: organizationId,
                                              ),
                                            );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(56),
                                      side: const BorderSide(
                                        width: 2,
                                        color: Color(0xFFE2E8F0),
                                      ),
                                      foregroundColor: const Color(0xFF475569),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Editar Organizacion',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        height: 1.56,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OpportunitiesListScreen()),
      );
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrganizationListManagerView()),
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ListFavouriteScreen()),
      );
    }
  }
}

class TopNavigationBarIosStyle extends StatelessWidget {
  const TopNavigationBarIosStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 12),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        shape: const RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0x1910B77F)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.chevron_left, color: Color(0xFF1E293B)),
          ),
          const Text(
            'Perfil',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.56,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            height: 1.33,
          ),
        ),
      ],
    );
  }
}

class _AuthorizedNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Widget placeholder;

  const _AuthorizedNetworkImage({
    required this.url,
    required this.fit,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
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
          return placeholder;
        }

        return Image.network(
          url,
          fit: fit,
          headers: <String, String>{'Authorization': 'Bearer $token'},
          errorBuilder: (context, error, stackTrace) => placeholder,
        );
      },
    );
  }
}
