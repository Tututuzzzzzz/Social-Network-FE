import 'package:equatable/equatable.dart';

class ChatQueryParams extends Equatable {
  final int page;

  const ChatQueryParams({this.page = 1});

  @override
  List<Object?> get props => [page];
}
