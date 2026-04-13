part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeFetchedEvent extends HomeEvent {
  final int page;

  const HomeFetchedEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}
