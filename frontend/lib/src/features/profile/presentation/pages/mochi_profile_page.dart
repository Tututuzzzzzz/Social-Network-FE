import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/cache/secure_local_storage.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/failure_converter.dart';
import '../../../../routes/app_route_path.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../chat/domain/entities/chat_entity.dart';
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
import '../widgets/profile_settings_sheet.dart';
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

  void _openFriendsList() {
    if (!_isOwnProfile) {
      return;
    }

    context.pushNamed(AppRoutes.profileFriends.name);
  }

  void _sendFriendRequest() {
    if (_isOwnProfile || _targetUserId.isEmpty) {
      return;
    }

    context.read<ProfileBloc>().add(
      ProfileFriendRequestSendEvent(_targetUserId),
    );
  }

  void _openDirectMessage() {
    if (_isOwnProfile || _targetUserId.isEmpty) {
      return;
    }

    context.read<ProfileBloc>().add(
      ProfileDirectMessageOpenEvent(_targetUserId),
    );
  }

  void _openChatRoom(ChatEntity chat) {
    final threadId = chat.id.trim();
    if (threadId.isEmpty) {
      return;
    }

    context.pushNamed(
      AppRoutes.chatMochiChatRoom.name,
      pathParameters: {'threadId': threadId},
      extra: chat,
    );
  }

  Future<void> _openProfileSettings() async {
    final action = await showProfileSettingsSheet(context);
    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case ProfileSettingsAction.editProfile:
        final updated = await context.push<bool>(
          AppRoutes.editProfile.path,
          extra: _currentUserId,
        );
        if (mounted && updated == true) {
          await _refreshProfile();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.profileUpdateSuccess)),
            );
          }
        }
        break;
      case ProfileSettingsAction.logout:
        _logout();
        break;
    }
  }

  void _logout() {
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state is AuthLogoutLoadingState) {
      return;
    }

    authBloc.add(AuthLogoutEvent());
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

    return context.l10n.userDefaultName;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return current is AuthLogoutSuccessState ||
            current is AuthLogoutFailureState;
      },
      listener: (context, state) {
        if (state is AuthLogoutSuccessState) {
          ScaffoldMessenger.of(context).clearSnackBars();
          context.go(AppRoutes.login.path);
          return;
        }

        if (state is AuthLogoutFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message.isEmpty
                    ? context.l10n.logoutFailed
                    : state.message,
              ),
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        return previous is AuthLogoutLoadingState ||
            current is AuthLogoutLoadingState;
      },
      builder: (context, authState) {
        final isLoggingOut = authState is AuthLogoutLoadingState;
        final colors = AppColors.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: colors.scaffold,
              appBar: AppBar(
                systemOverlayStyle: isDark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                backgroundColor: colors.appBar,
                foregroundColor: colors.appBarForeground,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  context.l10n.profilePersonalTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                actions: [
                  if (_isOwnProfile)
                    IconButton(
                      tooltip: context.l10n.profileSettingsTitle,
                      onPressed: isLoggingOut ? null : _openProfileSettings,
                      icon: const Icon(Icons.settings_rounded),
                    ),
                ],
              ),
              body: _buildBody(),
            ),
            if (isLoggingOut)
              Positioned.fill(
                child: ColoredBox(
                  color: colors.scrim,
                  child: const Center(
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isResolvingUser) {
      return const _ProfileLoadingView();
    }

    if (_targetUserId.isEmpty) {
      return ProfileEmptyState(
        icon: Icons.lock_outline_rounded,
        title: context.l10n.noSessionTitle,
        message: context.l10n.noSessionMessage,
      );
    }

    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) {
        if (current is! ProfileLoadedState) {
          return false;
        }
        final previousLoaded = previous is ProfileLoadedState ? previous : null;
        final previousMessage = previous is ProfileLoadedState
            ? previous.actionErrorMessage
            : null;
        final hasNewActionError =
            current.actionErrorMessage != null &&
            current.actionErrorMessage != previousMessage;
        final hasNewFriendRequestSuccess =
            current.friendRequestStatus == ProfileFriendRequestStatus.sent &&
            previousLoaded?.friendRequestStatus !=
                ProfileFriendRequestStatus.sent;
        final hasNewFriendRequestFailure =
            current.friendRequestStatus == ProfileFriendRequestStatus.failure &&
            previousLoaded?.friendRequestStatus !=
                ProfileFriendRequestStatus.failure;
        final hasNewDirectMessageFailure =
            current.directMessageStatus == ProfileDirectMessageStatus.failure &&
            previousLoaded?.directMessageStatus !=
                ProfileDirectMessageStatus.failure;
        final hasNewOpenedChat =
            current.openedChat != null &&
            current.openedChat?.id != previousLoaded?.openedChat?.id;

        return hasNewActionError ||
            hasNewFriendRequestSuccess ||
            hasNewFriendRequestFailure ||
            hasNewDirectMessageFailure ||
            hasNewOpenedChat;
      },
      listener: (context, state) {
        if (state is! ProfileLoadedState) {
          return;
        }
        var shouldClearFeedback = false;

        final message = state.actionErrorMessage;
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          shouldClearFeedback = true;
        }

        if (state.friendRequestStatus == ProfileFriendRequestStatus.sent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.friendRequestSendSuccess)),
          );
          shouldClearFeedback = true;
        }

        if (state.friendRequestStatus == ProfileFriendRequestStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.friendRequestSendError)),
          );
          shouldClearFeedback = true;
        }

        if (state.directMessageStatus == ProfileDirectMessageStatus.failure) {
          final error = state.directMessageErrorMessage ?? '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.cannotOpenChat(error))),
          );
          shouldClearFeedback = true;
        }

        final openedChat = state.openedChat;
        if (openedChat != null) {
          shouldClearFeedback = true;
          _openChatRoom(openedChat);
        }

        if (shouldClearFeedback) {
          context.read<ProfileBloc>().add(ProfileActionFeedbackClearedEvent());
        }
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
                      isOwnProfile: _isOwnProfile,
                      isSendingFriendRequest:
                          state.friendRequestStatus ==
                          ProfileFriendRequestStatus.sending,
                      isFriendRequestSent:
                          state.friendRequestStatus ==
                          ProfileFriendRequestStatus.sent,
                      isFriend:
                          state.friendRequestStatus ==
                          ProfileFriendRequestStatus.friends,
                      isOpeningMessage:
                          state.directMessageStatus ==
                          ProfileDirectMessageStatus.opening,
                      onAvatarTap: () => _openAvatarViewer(state.profile),
                      onFriendsTap: _isOwnProfile ? _openFriendsList : null,
                      onAddFriend: _sendFriendRequest,
                      onMessage: _openDirectMessage,
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
              title: context.l10n.profileLoadFailed,
              message: message,
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25A97A),
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
