import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/favorite_opportunity_service.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../../../widgets/opportunity_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/ui/login_screen.dart';
import '../../applications/ui/applications_list_screen.dart';
import '../bloc/bloc_bloc.dart';
import '../../opportunities/ui/opportunities_list_screen.dart';
import '../../profile/ui/profile_screen.dart';

class ListFavouriteScreen extends StatefulWidget {
  const ListFavouriteScreen({super.key});

  @override
  State<ListFavouriteScreen> createState() => _ListFavouriteScreenState();
}

class _ListFavouriteScreenState extends State<ListFavouriteScreen> {
  final FavoriteOpportunityService _favoriteService = FavoriteOpportunityService();
  late final FavoritesBloc _favoritesBloc;
  Set<int> _favoriteUpdatingIds = <int>{};

  @override
  void initState() {
    super.initState();
    _favoritesBloc = FavoritesBloc(FavoriteOpportunityService())
      ..add(FavoritesRequested());
  }

  @override
  void dispose() {
    _favoritesBloc.close();
    super.dispose();
  }

  void _reload() {
    _favoritesBloc.add(FavoritesRequested());
  }

  bool _isUserRole(AuthState authState) {
    if (authState is! AuthAuthenticated) return false;
    return authState.user.role.trim().toUpperCase() == 'USER';
  }

  Future<void> _removeFavorite(int opportunityId) async {
    if (_favoriteUpdatingIds.contains(opportunityId)) return;

    setState(() {
      _favoriteUpdatingIds = {..._favoriteUpdatingIds, opportunityId};
    });

    try {
      await _favoriteService.removeFavorite(opportunityId);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _favoriteUpdatingIds = {..._favoriteUpdatingIds}..remove(opportunityId);
        });
      }
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OpportunitiesListScreen()),
      );
    } else if (index == 1) {
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
    return BlocProvider.value(
      value: _favoritesBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mis favoritos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B77F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    if (state is FavoritesLoading || state is FavoritesInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF10B77F),
                        ),
                      );
                    }

                    if (state is FavoritesError) {
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
                                onPressed: _reload,
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

                    final favorites = (state as FavoritesLoaded).opportunities;

                    if (favorites.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: Color(0xFFA1A1AA),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No tienes oportunidades favoritas',
                              style: TextStyle(
                                color: Color(0xFF52525B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final authState = context.read<AuthBloc>().state;
                        final showFavoriteButton = _isUserRole(authState);
                        final opportunity = favorites[index];
                        return OpportunityCard(
                          opportunity: opportunity,
                          showFavoriteButton: showFavoriteButton,
                          isFavorite: true,
                          isFavoriteLoading: _favoriteUpdatingIds.contains(opportunity.id),
                          onFavoriteTap: showFavoriteButton
                              ? () => _removeFavorite(opportunity.id)
                              : null,
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
          currentIndex: 2,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }
}
