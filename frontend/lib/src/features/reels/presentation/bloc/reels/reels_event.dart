part of 'reels_bloc.dart';

sealed class ReelsEvent extends Equatable {
  const ReelsEvent();

  @override
  List<Object?> get props => [];
}

class ReelsFetchedEvent extends ReelsEvent {
  final int page;

  const ReelsFetchedEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}
