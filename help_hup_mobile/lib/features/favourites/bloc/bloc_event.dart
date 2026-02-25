part of 'bloc_bloc.dart';

@immutable
sealed class FavoritesEvent {}

final class FavoritesRequested extends FavoritesEvent {}
