import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/cache/hive_local_storage.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../../core/utils/url_normalizer.dart';
import '../../../../routes/app_route_path.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../chat/domain/usecases/create_direct_conversation_usecase.dart';
import '../../../chat/domain/usecases/usecase_params.dart';
import '../../data/models/profile_model.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_user_posts_usecase.dart';
import '../../../friend/domain/usecases/send_friend_request.dart';
import '../../../post/data/models/get_post_model.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../../../post/presentation/bloc/post/post_bloc.dart';
import '../../../post/presentation/pages/post_detail_screen.dart';
import '../../domain/usecases/usecase_params.dart';
import '../bloc/profile/profile_bloc.dart';
import '../widgets/mochi_profile_sections.dart';

class MochiProfilePage extends StatefulWidget {
  final String? userId;
  const MochiProfilePage({super.key, this.userId});

  @override
  State<MochiProfilePage> createState() => _MochiProfilePageState();
}

class _MochiProfilePageState extends State<MochiProfilePage> {
  ProfileEntity? _cachedProfile;
  String _targetUserId = '';
  String _loggedInUserId = '';
  bool _isOtherUser = false;
  List<MochiProfilePostTile> _postTiles = const [];
  Map<String, PostEntity> _postById = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void didUpdateWidget(covariant MochiProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _targetUserId = ''; // Reset to force re-resolution
      _postTiles = const [];
      _postById = {};
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
    }
  }

  Future<void> _loadProfile() async {
    if (!mounted) {
      return;
    }

    if (_targetUserId.trim().isEmpty) {
      _loggedInUserId = await _resolveCurrentUserId();
      _targetUserId = widget.userId ?? _loggedInUserId;
      _isOtherUser = _targetUserId != _loggedInUserId;
    }

    if (!mounted) {
      return;
    }

    if (_targetUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy user_id')),
      );
      return;
    }

    await _loadCachedProfile();
    await _loadCachedUserPosts();
    if (!mounted) return;
    context.read<ProfileBloc>().add(
      ProfileGetEvent(ProfileParams(userId: _targetUserId)),
    );

    unawaited(_loadUserPosts());
  }

  Future<void> _loadCachedProfile() async {
    final localStorage = getIt<HiveLocalStorage>();
    final cached = await localStorage.load(
      key: 'profile_$_targetUserId',
      boxName: 'cache',
    );

    if (!mounted || cached is! Map) {
      return;
    }

    try {
      final model = ProfileModel.fromJson(Map<String, dynamic>.from(cached));
      setState(() {
        _cachedProfile = model;
      });
    } catch (_) {
      // Ignore invalid cache format.
    }
  }

  Future<void> _loadCachedUserPosts() async {
    final localStorage = getIt<HiveLocalStorage>();
    final cached = await localStorage.load(
      key: 'user_posts_${_targetUserId}_1_60',
      boxName: 'cache',
    );

    if (!mounted || cached is! List) {
      return;
    }

    final postMaps = cached
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final posts = postMaps
        .map(PostModel.fromJson)
        .cast<PostEntity>()
        .toList(growable: false);

    final tiles = _buildPostTilesFromPosts(posts);

    setState(() {
      _postById = {for (final post in posts) post.id: post};
      _postTiles = tiles;
    });
  }

  Future<void> _loadUserPosts() async {
    final useCase = getIt<GetUserPostsUseCase>();
    final result = await useCase.call(
      GetUserPostsParams(userId: _targetUserId, page: 1, limit: 60),
    );

    if (!mounted) {
      return;
    }

    result.fold((_) {}, (posts) {
      final tiles = _buildPostTilesFromPosts(posts);

      setState(() {
        _postById = {for (final post in posts) post.id: post};
        _postTiles = tiles;
      });
    });
  }

  List<MochiProfilePostTile> _buildPostTilesFromPosts(
    List<PostEntity> posts,
  ) {
    final tiles = <MochiProfilePostTile>[];

    for (final post in posts) {
      final postImageUrls = post.media
          .where(
            (media) =>
                media.mimeType.toLowerCase().startsWith('image/') ||
                _isLikelyImageUrl(media.mediaUrl ?? media.objectKey),
          )
          .map((media) => (media.mediaUrl ?? media.objectKey).trim())
          .where((raw) => raw.isNotEmpty)
          .toList();

      if (postImageUrls.isEmpty) {
        continue;
      }

      final first = _normalizeMediaUrl(postImageUrls.first);
      if (first.isEmpty) {
        continue;
      }

      tiles.add(
        MochiProfilePostTile(
          postId: post.id,
          imageUrl: first,
          isMulti: postImageUrls.length > 1,
          post: post,
        ),
      );
    }

    return tiles;
  }

  bool _isLikelyImageUrl(String? input) {
    final raw = (input ?? '').trim();
    if (raw.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(raw);
    final path = (uri?.path ?? raw).toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  String _normalizeMediaUrl(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return '';
    }

    final apiUri = Uri.parse(ApiConstants.baseUrl);

    var normalized = raw;
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      final origin =
          '${apiUri.scheme}://${apiUri.host}${apiUri.hasPort ? ':${apiUri.port}' : ''}';
      normalized = raw.startsWith('/') ? '$origin$raw' : '$origin/$raw';
    }

    return normalizeClientNetworkUrl(normalized);
  }

  Future<String> _resolveCurrentUserId() async {
    final secureStorage = getIt<SecureLocalStorage>();
    final storedUserId = await secureStorage.load(key: 'user_id') as String?;
    final secureUserId = (storedUserId ?? '').trim();
    if (secureUserId.isNotEmpty) {
      return secureUserId;
    }

    final localStorage = getIt<HiveLocalStorage>();
    final cachedUser = await localStorage.load(key: 'user', boxName: 'cache');
    if (cachedUser is Map) {
      final map = cachedUser.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final userId = (map['_id'] ?? map['id'] ?? '').toString().trim();
      if (userId.isNotEmpty) {
        await secureStorage.save(key: 'user_id', value: userId);
        return userId;
      }
    }

    final accessToken =
        await secureStorage.load(key: 'access_token') as String?;
    final tokenUserId = _extractUserIdFromAccessToken(accessToken);
    if ((tokenUserId ?? '').isNotEmpty) {
      await secureStorage.save(key: 'user_id', value: tokenUserId);
      return tokenUserId!;
    }

    return '';
  }

  String? _extractUserIdFromAccessToken(String? accessToken) {
    final token = (accessToken ?? '').trim();
    if (token.isEmpty) {
      return null;
    }
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      var payload = parts[1];
      // Base64 padding correction
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> map = json.decode(decoded);

      // Try common claim names that may hold the user id
      final possible =
          map['userId'] ??
          map['id'] ??
          map['sub'] ??
          map['_id'] ??
          map['user'] ??
          map['user_id'];
      if (possible == null) return null;

      if (possible is String && possible.trim().isNotEmpty) {
        return possible.trim();
      }
      if (possible is num) return possible.toString();
      if (possible is Map) {
        final nested = possible['_id'] ?? possible['id'];
        if (nested != null) return nested.toString();
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _refresh() async {
    await _loadProfile();
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _openEditProfile() async {
    final updated = await context.pushNamed<bool>(AppRoutes.editProfile.name);
    if (updated == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _onMessageTap() async {
    final profile = _cachedProfile;
    if (profile == null) {
      return;
    }

    final recipientId = profile.id.trim();
    if (recipientId.isEmpty) {
      return;
    }

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang khởi tạo cuộc trò chuyện...')),
    );

    final useCase = getIt<CreateDirectConversationUseCase>();
    final result = await useCase.call(
      CreateDirectConversationParams(recipientId: recipientId),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể bắt đầu trò chuyện')),
        );
      },
      (chat) {
        context.pushNamed(
          AppRoutes.chatMochiChatRoom.name,
          pathParameters: {'threadId': chat.id},
          extra: chat,
        );
      },
    );
  }

  void _onPostTileTap(MochiProfilePostTile tile) {
    final post = tile.post ?? _postById[tile.postId];
    if (post == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải bài viết...')),
      );
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => BlocProvider<PostBloc>(
              create: (_) => getIt<PostBloc>(),
              child: PostDetailScreen(
                initialPost: post,
                currentUserId:
                    _loggedInUserId.isEmpty ? null : _loggedInUserId,
              ),
            ),
          ),
        )
        .then((value) {
          if (value == true && mounted) {
            _refresh();
          }
        });
  }

  Future<void> _onFollowTap() async {
    final authorId = _targetUserId.trim();

    if (authorId.isEmpty || authorId == _loggedInUserId) {
      return;
    }

    try {
      final useCase = getIt<SendFriendRequest>();
      await useCase(authorId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã gửi yêu cầu theo dõi thành công")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể gửi yêu cầu: $e")),
      );
    }
  }

  Future<void> _openMenu() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D7DD),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('logout'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected != 'logout') {
      return;
    }

    context.read<AuthBloc>().add(AuthLogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLogoutFailureState) {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } catch (_) {
                // Scaffold may not be available
              }
            }

            if (state is AuthLogoutSuccessState) {
              // Không showSnackBar ở đây vì navigate sẽ destroy Scaffold
              context.go(AppRoutes.login.path);
            }
          },
        ),
      ],
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoadedState) {
            _cachedProfile = state.profile;
          }

          if (state is ProfileFailureState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final profile = state is ProfileLoadedState
              ? state.profile
              : _cachedProfile;

          if (profile == null && state is ProfileFailureState) {
            return MochiProfileErrorView(onRetry: _refresh);
          }

          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final previewTiles = profile.posts
              .map(
                (item) => MochiProfilePostTile(
                  postId: item.id,
                  imageUrl: _normalizeMediaUrl(item.mediaUrl),
                ),
              )
              .where((tile) => tile.imageUrl.trim().isNotEmpty)
              .toList();
          final tiles = _postTiles.isNotEmpty
              ? _postTiles
              : (previewTiles.isNotEmpty
                    ? previewTiles
                    : const <MochiProfilePostTile>[]);

          return Material(
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: MochiProfileBody(
                profile: profile,
                postTiles: tiles,
                isOtherUser: _isOtherUser,
                onEditProfile: _openEditProfile,
                onFollow: _onFollowTap,
                onMessage: _onMessageTap,
                onOpenMenu: _openMenu,
                onRefresh: _refresh,
                onPostTap: _onPostTileTap,
              ),
            ),
          );
        },
      ),
    );
  }
}
