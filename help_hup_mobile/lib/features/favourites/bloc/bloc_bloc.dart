import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/opportunity_response.dart';
import '../../../core/services/favorite_opportunity_service.dart';

part 'bloc_event.dart';
part 'bloc_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoriteOpportunityService favoriteOpportunityService;

  FavoritesBloc(this.favoriteOpportunityService) : super(FavoritesInitial()) {
    on<FavoritesRequested>(_onFavoritesRequested);
  }

  Future<void> _onFavoritesRequested(
    FavoritesRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());

    try {
      final favorites = await favoriteOpportunityService.getMyFavorites();
      emit(FavoritesLoaded(opportunities: favorites));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(FavoritesError(message: message));
    }
  }
}
