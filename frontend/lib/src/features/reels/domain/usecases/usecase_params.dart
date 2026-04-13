import 'package:equatable/equatable.dart';

class ReelsQueryParams extends Equatable {
  final int page;

  const ReelsQueryParams({this.page = 1});

  @override
  List<Object?> get props => [page];
}
