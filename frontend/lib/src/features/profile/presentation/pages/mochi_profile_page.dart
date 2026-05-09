import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/cache/secure_local_storage.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/failure_converter.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/update_avatar_usecase.dart';
import '../../domain/usecases/usecase_params.dart';
import '../bloc/profile/profile_bloc.dart';
import '../widgets/profile_empty_state.dart';
import '../widgets/profile_avatar_upload_sheet.dart';
import '../widgets/profile_avatar_viewer.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_photos_tab.dart';
import '../widgets/profile_posts_tab.dart';
import '../widgets/profile_sliver_tab_bar.dart';

class MochiProfilePage extends StatefulWidget {
  const MochiProfilePage({super.key, this.userId});

  final String? userId;

  @override
  State<MochiProfilePage> createState() => _MochiProfilePageState();
}

class _MochiProfilePageState extends State<MochiProfilePage> {
  String _currentUserId = '';
  String _targetUserId = '';
  bool _isResolvingUser = true;
  bool _isUpdatingAvatar = false;

  bool get _isOwnProfile =>
      _targetUserId.isNotEmpty && _targetUserId == _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveAndLoadProfile();
    });
  }

  @override
  void didUpdateWidget(covariant MochiProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _resolveAndLoadProfile();
    }
  }

  Future<void> _resolveAndLoadProfile() async {
    if (!mounted) return;

    setState(() {
      _isResolvingUser = true;
    });

    final storage = getIt<SecureLocalStorage>();
    final currentUserId = (await storage.load(key: 'user_id')).trim();
    final routeUserId = widget.userId?.trim() ?? '';
    final targetUserId = routeUserId.isNotEmpty ? routeUserId : currentUserId;

    if (!mounted) return;

    setState(() {
      _currentUserId = currentUserId;
      _targetUserId = targetUserId;
      _isResolvingUser = false;
    });

    if (targetUserId.isNotEmpty) {
      context.read<ProfileBloc>().add(
        ProfileGetEvent(ProfileParams(userId: targetUserId)),
      );
    }
  }

  Future<void> _refreshProfile() async {
    if (_targetUserId.isEmpty) return;

    context.read<ProfileBloc>().add(
      ProfileGetEvent(ProfileParams(userId: _targetUserId)),
    );
  }

  void _openEditProfile() {
    context.push(AppRoutes.editProfile.path);
  }

  Future<void> _openAvatarViewer(ProfileEntity profile) {
    final displayName = _resolveDisplayName(profile);

    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return ProfileAvatarViewer(
          displayName: displayName,
          avatarUrl: profile.avatarUrl,
          canUpdateAvatar: _isOwnProfile,
          onChangeAvatar: _isOwnProfile
              ? () {
                  Navigator.of(dialogContext).pop();
                  _openAvatarUploadSheet();
                }
              : null,
        );
      },
    );
  }

  Future<void> _openAvatarUploadSheet() async {
    final draft = await showProfileAvatarUploadSheet(context);
    if (!mounted || draft == null) {
      return;
    }

    await _updateAvatar(draft);
  }

  Future<void> _updateAvatar(ProfileAvatarUploadDraft draft) async {
    if (_isUpdatingAvatar) {
      return;
    }

    setState(() => _isUpdatingAvatar = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );

    final useCase = getIt<UpdateAvatarUseCase>();
    final result = await useCase.call(
      UpdateAvatarParams(avatarBytes: draft.bytes, fileName: draft.fileName),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _isUpdatingAvatar = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.updateAvatarFailed} ${mapFailureToMessage(failure)}',
            ),
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.updateAvatarSuccess)),
        );
        _refreshProfile();
      },
    );
  }

  String _resolveDisplayName(ProfileEntity profile) {
    final displayName = profile.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = profile.username?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }

    return 'Người dùng';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: const Color(0xFF31B991),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hồ Sơ Cá Nhân',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_isOwnProfile)
            IconButton(
              tooltip: 'Chỉnh sửa hồ sơ',
              onPressed: _openEditProfile,
              icon: const Icon(Icons.settings_rounded),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isResolvingUser) {
      return const _ProfileLoadingView();
    }

    if (_targetUserId.isEmpty) {
      return const ProfileEmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Chưa có phiên đăng nhập',
        message: 'Vui lòng đăng nhập lại để xem hồ sơ cá nhân.',
      );
    }

    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) {
        if (current is! ProfileLoadedState) {
          return false;
        }
        final previousMessage = previous is ProfileLoadedState
            ? previous.actionErrorMessage
            : null;
        return current.actionErrorMessage != null &&
            current.actionErrorMessage != previousMessage;
      },
      listener: (context, state) {
        if (state is! ProfileLoadedState) {
          return;
        }
        final message = state.actionErrorMessage;
        if (message == null) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        if (state is ProfileLoadingState || state is ProfileInitialState) {
          return const _ProfileLoadingView();
        }

        if (state is ProfileFailureState) {
          return _ProfileErrorView(
            message: state.message,
            onRetry: _refreshProfile,
          );
        }

        if (state is ProfileLoadedState) {
          final postsCount = state.profile.postsCount > state.posts.length
              ? state.profile.postsCount
              : state.posts.length;

          return DefaultTabController(
            length: 2,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: ProfileHeader(
                      profile: state.profile,
                      postsCount: postsCount,
                      onAvatarTap: () => _openAvatarViewer(state.profile),
                    ),
                  ),
                  const ProfileSliverTabBar(),
                ],
                body: TabBarView(
                  children: [
                    ProfilePostsTab(
                      posts: state.posts,
                      currentUserId: _currentUserId,
                      postsErrorMessage: state.postsErrorMessage,
                      onRefresh: _refreshProfile,
                    ),
                    ProfilePhotosTab(
                      posts: state.posts,
                      onRefresh: _refreshProfile,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const _ProfileLoadingView();
      },
    );
  }
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.6),
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Không tải được hồ sơ',
              message: message,
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25A97A),
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
