import '../../domain/entities/search_entity.dart';

class SearchModel {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String bio;

  SearchModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);

    return SearchModel(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      displayName: (map['displayName'] ??
              map['name'] ??
              map['fullName'] ??
              map['username'] ??
              '')
          .toString(),
      avatarUrl: (map['avatarUrl'] ?? map['avatar'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'bio': bio,
  };

  SearchEntity toEntity() => SearchEntity(
        id: id,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
        bio: bio,
      );
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);

    return PaginationModel(
      page: (map['page'] as num?)?.toInt() ?? 1,
      limit: (map['limit'] as num?)?.toInt() ?? 20,
      total: (map['total'] as num?)?.toInt() ?? 0,
      totalPages: (map['totalPages'] as num?)?.toInt() ?? 0,
      hasMore: map['hasMore'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'totalPages': totalPages,
    'hasMore': hasMore,
  };

  PaginationEntity toEntity() => PaginationEntity(
        page: page,
        limit: limit,
        total: total,
        totalPages: totalPages,
        hasMore: hasMore,
      );
}

class SearchResponseModel {
  final List<SearchModel> data;
  final PaginationModel pagination;

  SearchResponseModel({
    required this.data,
    required this.pagination,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    final rawData = map['data'];
    final users = <SearchModel>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          users.add(SearchModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final paginationRaw = map['pagination'];
    final pagination = paginationRaw is Map
        ? PaginationModel.fromJson(Map<String, dynamic>.from(paginationRaw))
        : PaginationModel(
            page: 1,
            limit: 20,
            total: users.length,
            totalPages: users.isEmpty ? 0 : 1,
            hasMore: false,
          );

    return SearchResponseModel(data: users, pagination: pagination);
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'pagination': pagination.toJson(),
  };

  SearchResponseEntity toEntity() => SearchResponseEntity(
        data: data.map((e) => e.toEntity()).toList(),
        pagination: pagination.toEntity(),
      );
}
