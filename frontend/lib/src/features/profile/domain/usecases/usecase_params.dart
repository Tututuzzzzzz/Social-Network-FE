import 'package:equatable/equatable.dart';

class ProfileQueryParams extends Equatable {
  final int page;

  const ProfileQueryParams({this.page = 1});

  @override
  List<Object?> get props => [page];
}
