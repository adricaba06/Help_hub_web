part of 'bloc_bloc.dart';

@immutable
sealed class FavoritesState {}

final class FavoritesInitial extends FavoritesState {}

final class FavoritesLoading extends FavoritesState {}

final class FavoritesLoaded extends FavoritesState {
	final List<OpportunityResponse> opportunities;

	FavoritesLoaded({required this.opportunities});
}

final class FavoritesError extends FavoritesState {
	final String message;

	FavoritesError({required this.message});
}
