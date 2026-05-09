import 'package:equatable/equatable.dart';

class Friend extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;

  const Friend({required this.id, required this.name, this.avatarUrl});

  @override
  List<Object?> get props => [id, name, avatarUrl];
}
