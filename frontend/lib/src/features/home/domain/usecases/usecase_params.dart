import 'package:equatable/equatable.dart';

class HomeQueryParams extends Equatable {
  final int page;

  const HomeQueryParams({this.page = 1});

  @override
  List<Object?> get props => [page];
}
