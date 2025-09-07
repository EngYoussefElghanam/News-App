part of 'discover_cubit.dart';

sealed class DiscoverState {}

final class DiscoverInitial extends DiscoverState {}

final class DiscoverLoading extends DiscoverState {}

final class DiscoverLoaded extends DiscoverState {
  final List<Article> articles;

  DiscoverLoaded(this.articles);
}

final class DiscoverError extends DiscoverState {
  final String message;

  DiscoverError(this.message);
}
