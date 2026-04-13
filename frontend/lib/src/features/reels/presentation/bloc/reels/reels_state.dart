part of 'reels_bloc.dart';

sealed class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object?> get props => [];
}

class ReelsInitialState extends ReelsState {
  const ReelsInitialState();
}

class ReelsLoadingState extends ReelsState {
  const ReelsLoadingState();
}

class ReelsSuccessState extends ReelsState {
  final List<ReelsEntity> items;

  const ReelsSuccessState(this.items);

  @override
  List<Object?> get props => [items];
}

class ReelsFailureState extends ReelsState {
  final String message;

  const ReelsFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
