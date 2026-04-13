part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeSuccessState extends HomeState {
  final List<HomeEntity> items;

  const HomeSuccessState(this.items);

  @override
  List<Object?> get props => [items];
}

class HomeFailureState extends HomeState {
  final String message;

  const HomeFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
