import 'package:equatable/equatable.dart';

class SearchEntity extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String bio;

  const SearchEntity({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
  });

  @override
  List<Object?> get props => [id, username, displayName, avatarUrl, bio];
}

class SearchResponseEntity extends Equatable {
  final List<SearchEntity> data;
  final PaginationEntity pagination;

  const SearchResponseEntity({
    required this.data,
    required this.pagination,
  });

  @override
  List<Object?> get props => [data, pagination];
}

class PaginationEntity extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  const PaginationEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [page, limit, total, totalPages, hasMore];
}

class SearchHistoryEntry extends Equatable {
  final String label;
  final String? userId;
  final String? avatarUrl;
  final bool isUser;

  const SearchHistoryEntry({
    required this.label,
    this.userId,
    this.avatarUrl,
    this.isUser = false,
  });

  factory SearchHistoryEntry.query(String label) {
    return SearchHistoryEntry(label: label, isUser: false);
  }

  factory SearchHistoryEntry.user({
    required String label,
    required String userId,
    String? avatarUrl,
  }) {
    return SearchHistoryEntry(
      label: label,
      userId: userId,
      avatarUrl: avatarUrl,
      isUser: true,
    );
  }

  factory SearchHistoryEntry.fromMap(Map<String, dynamic> map) {
    final label = (map['label'] ?? map['query'] ?? '').toString();
    final userId = map['userId']?.toString();
    final avatarUrl = map['avatarUrl']?.toString();
    final isUser = map['isUser'] == true || (userId?.trim().isNotEmpty ?? false);

    return SearchHistoryEntry(
      label: label,
      userId: userId,
      avatarUrl: avatarUrl,
      isUser: isUser,
    );
  }

  Map<String, dynamic> toMap() => {
    'label': label,
    'userId': userId,
    'avatarUrl': avatarUrl,
    'isUser': isUser,
  };

  @override
  List<Object?> get props => [label, userId, avatarUrl, isUser];
}
