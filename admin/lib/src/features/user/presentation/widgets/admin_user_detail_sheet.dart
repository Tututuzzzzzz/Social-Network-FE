import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector.dart';
import '../../../../widgets/admin_display_formatters.dart';
import '../../../../widgets/admin_empty_state.dart';
import '../../../../widgets/admin_image_viewer_dialog.dart';
import '../../../post/domain/entities/admin_post.dart';
import '../../../post/presentation/widgets/admin_post_detail_sheet.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_user_detail.dart';
import '../bloc/detail/admin_user_detail_cubit.dart';
import '../bloc/detail/admin_user_detail_state.dart';
import 'admin_user_identity.dart';

Future<void> showAdminUserDetailSheet({
  required BuildContext context,
  required AdminUser user,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return BlocProvider(
        create: (_) => injector<AdminUserDetailCubit>()..load(user.id),
        child: Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880, maxHeight: 720),
            child: AdminUserDetailSheet(initialUser: user),
          ),
        ),
      );
    },
  );
}

class AdminUserDetailSheet extends StatelessWidget {
  final AdminUser initialUser;

  const AdminUserDetailSheet({super.key, required this.initialUser});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminUserDetailCubit, AdminUserDetailState>(
      builder: (context, state) {
        final detail = state.detail;
        final user = detail?.user ?? initialUser;

        return Column(
          children: [
            _UserDetailHeader(user: user),
            const Divider(height: 1),
            Expanded(
              child: switch (state.status) {
                AdminUserDetailStatus.loading ||
                AdminUserDetailStatus.initial => const Center(
                  child: CircularProgressIndicator(),
                ),
                AdminUserDetailStatus.failure => AdminEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Khong the tai chi tiet nguoi dung',
                  message: state.message ?? 'Backend request failed.',
                ),
                AdminUserDetailStatus.ready =>
                  detail == null
                      ? const AdminEmptyState(
                          icon: Icons.person_outline,
                          title: 'Khong co du lieu',
                          message: 'Backend khong tra ve chi tiet nguoi dung.',
                        )
                      : _UserDetailBody(detail: detail),
              },
            ),
          ],
        );
      },
    );
  }
}

class _UserDetailHeader extends StatelessWidget {
  final AdminUser user;

  const _UserDetailHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 14, 18),
      child: Row(
        children: [
          AdminUserIdentity(user: user),
          const Spacer(),
          IconButton(
            tooltip: 'Dong',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _UserDetailBody extends StatelessWidget {
  final AdminUserDetail detail;

  const _UserDetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final user = detail.user;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      children: [
        _UserProfilePanel(user: user),
        const SizedBox(height: 20),
        Text(
          'Bai viet cua nguoi dung',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        if (detail.posts.isEmpty)
          const AdminEmptyState(
            icon: Icons.article_outlined,
            title: 'Chua co bai viet',
            message: 'Backend tra ve danh sach bai viet rong.',
          )
        else
          ...detail.posts.map((post) => _UserPostRow(post: post)),
      ],
    );
  }
}

class _UserProfilePanel extends StatelessWidget {
  final AdminUser user;

  const _UserProfilePanel({required this.user});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6E0D5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? null
                  : () => showAdminImageViewer(
                      context: context,
                      imageUrl: user.avatarUrl!,
                      title: user.displayName,
                    ),
              child: CircleAvatar(
                radius: 34,
                backgroundImage:
                    user.avatarUrl == null || user.avatarUrl!.isEmpty
                    ? null
                    : NetworkImage(user.avatarUrl!),
                child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                    ? Text(initialFor(user.displayName))
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Wrap(
                runSpacing: 8,
                children: [
                  _InfoLine(label: 'ID', value: user.id),
                  _InfoLine(label: 'Email', value: user.email ?? 'N/A'),
                  _InfoLine(label: 'Phone', value: user.phone ?? 'N/A'),
                  _InfoLine(label: 'Bio', value: user.bio ?? 'N/A'),
                  _InfoLine(label: 'Posts', value: '${user.postsCount}'),
                  _InfoLine(
                    label: 'Friends',
                    value: '${user.friendsCount ?? 0}',
                  ),
                  _InfoLine(
                    label: 'Created',
                    value: formatAdminDate(user.createdAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 2),
          SelectableText(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _UserPostRow extends StatelessWidget {
  final AdminPost post;

  const _UserPostRow({required this.post});

  @override
  Widget build(BuildContext context) {
    final content = post.content.trim().isEmpty ? '(media post)' : post.content;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => showAdminPostDetailSheet(context: context, post: post),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE6E0D5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${post.likesCount} likes - ${post.commentsCount} comments - ${formatAdminDate(post.createdAt)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
