import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../widgets/admin_display_formatters.dart';
import '../../../../widgets/admin_empty_state.dart';
import '../../../../widgets/admin_status_pill.dart';
import '../../../post/domain/entities/admin_post.dart';
import '../../../post/domain/entities/admin_post_media.dart';
import '../../domain/entities/admin_report.dart';
import '../bloc/detail/admin_report_detail_cubit.dart';
import '../bloc/detail/admin_report_detail_state.dart';

Future<void> showAdminReportDetailDialog({
  required BuildContext context,
  required AdminReport report,
  AdminPost? initialPost,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return BlocProvider(
        create: (_) => injector<AdminReportDetailCubit>()..load(report.targetId),
        child: Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
            child: AdminReportDetailDialog(
              initialReport: report,
              initialPost: initialPost,
            ),
          ),
        ),
      );
    },
  );
}

class AdminReportDetailDialog extends StatelessWidget {
  final AdminReport initialReport;
  final AdminPost? initialPost;

  const AdminReportDetailDialog({
    super.key,
    required this.initialReport,
    this.initialPost,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReportDetailCubit, AdminReportDetailState>(
      builder: (context, state) {
        final reports = state.reports.isEmpty
            ? [initialReport]
            : _withInitialReport(state.reports, initialReport);
        final post = state.postDetail?.post == null
            ? initialPost
            : _mergePost(
                initialPost: initialPost,
                detailPost: state.postDetail!.post,
              );
        final reportedPost = _ReportedPost.fromReports(reports);

        return Column(
          children: [
            _ReportDetailHeader(report: initialReport, total: reports.length),
            const Divider(height: 1),
            Expanded(
              child: switch (state.status) {
                AdminReportDetailStatus.initial ||
                AdminReportDetailStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                AdminReportDetailStatus.failure => ListView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                  children: [
                    if (post != null)
                      _PostSummaryCard(post: post)
                    else if (reportedPost != null)
                      _ReportedPostCard(post: reportedPost)
                    else
                      _PostLoadWarning(
                        message: state.message ?? 'Backend request failed.',
                      ),
                    const SizedBox(height: 16),
                    _ReportCard(
                      report: initialReport,
                      busy: state.busyReportId == initialReport.id,
                    ),
                  ],
                ),
                AdminReportDetailStatus.ready => reports.isEmpty
                    ? const AdminEmptyState(
                        icon: Icons.flag_outlined,
                        title: 'Không có báo cáo',
                        message:
                            'Backend không trả về báo cáo nào cho bài viết này.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                        itemCount: reports.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            if (post != null) {
                              return _PostSummaryCard(post: post);
                            }
                            if (reportedPost != null) {
                              return _ReportedPostCard(post: reportedPost);
                            }
                            return _PostLoadWarning(
                              message: state.postMessage ??
                                  'Backend không trả về chi tiết bài viết.',
                            );
                          }
                          final report = reports[index - 1];
                          return _ReportCard(
                            report: report,
                            busy: state.busyReportId == report.id,
                          );
                        },
                      ),
              },
            ),
          ],
        );
      },
    );
  }
}

List<AdminReport> _withInitialReport(
  List<AdminReport> reports,
  AdminReport initialReport,
) {
  if (reports.any((report) => report.id == initialReport.id)) {
    return reports;
  }
  return [initialReport, ...reports];
}

AdminPost _mergePost({
  required AdminPost? initialPost,
  required AdminPost detailPost,
}) {
  if (initialPost == null) {
    return detailPost;
  }

  final detailAuthorUnknown =
      detailPost.authorUsername.trim().isEmpty ||
      detailPost.authorUsername.trim().toLowerCase() == 'unknown';
  final detailDisplayUnknown =
      detailPost.authorDisplayName.trim().isEmpty ||
      detailPost.authorDisplayName.trim().toLowerCase() == 'unknown';

  return AdminPost(
    id: _prefer(detailPost.id, initialPost.id),
    authorId: _prefer(detailPost.authorId, initialPost.authorId),
    authorUsername: detailAuthorUnknown
        ? initialPost.authorUsername
        : detailPost.authorUsername,
    authorDisplayName: detailDisplayUnknown
        ? initialPost.authorDisplayName
        : detailPost.authorDisplayName,
    authorAvatarUrl: _preferNullable(
      detailPost.authorAvatarUrl,
      initialPost.authorAvatarUrl,
    ),
    content: _prefer(detailPost.content, initialPost.content),
    likesCount: detailPost.likesCount,
    commentsCount: detailPost.commentsCount,
    likeIds: detailPost.likeIds.isEmpty
        ? initialPost.likeIds
        : detailPost.likeIds,
    media: detailPost.media.isEmpty ? initialPost.media : detailPost.media,
    createdAt: detailPost.createdAt,
    updatedAt: detailPost.updatedAt,
  );
}

String _prefer(String primary, String fallback) {
  return primary.trim().isEmpty ? fallback : primary;
}

String? _preferNullable(String? primary, String? fallback) {
  return primary == null || primary.trim().isEmpty ? fallback : primary;
}

class _ReportDetailHeader extends StatelessWidget {
  final AdminReport report;
  final int total;

  const _ReportDetailHeader({required this.report, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 14, 18),
      child: Row(
        children: [
          const Icon(Icons.flag_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chi tiết báo cáo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '$total báo cáo cho bài viết này',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Đóng',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _ReportedPost {
  final String authorName;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String? content;
  final List<String> mediaUrls;

  const _ReportedPost({
    required this.authorName,
    this.authorUsername,
    this.authorAvatarUrl,
    this.content,
    this.mediaUrls = const [],
  });

  static _ReportedPost? fromReports(List<AdminReport> reports) {
    for (final report in reports) {
      final authorName = report.targetAuthorName?.trim() ?? '';
      if (authorName.isNotEmpty) {
        return _ReportedPost(
          authorName: authorName,
          authorUsername: report.targetAuthorUsername,
          authorAvatarUrl: report.targetAuthorAvatarUrl,
          content: report.targetContent,
          mediaUrls: report.targetMediaUrls,
        );
      }
    }
    return null;
  }
}

class _PostLoadWarning extends StatelessWidget {
  final String message;

  const _PostLoadWarning({required this.message});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E0D5)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF7F5EF),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.article_outlined, color: Color(0xFF0F766E)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chưa tải được thông tin bài viết',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
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

class _ReportedPostCard extends StatelessWidget {
  final _ReportedPost post;

  const _ReportedPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _resolveNetworkUrl(post.authorAvatarUrl);
    final username = post.authorUsername?.trim() ?? '';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E0D5)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF7F5EF),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bài viết bị báo cáo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: avatarUrl == null
                      ? null
                      : NetworkImage(avatarUrl),
                  child: avatarUrl == null ? Text(initialFor(post.authorName)) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      if (username.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '@$username',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ReportLine(
              label: 'Nội dung',
              value: _contentText(post.content ?? ''),
            ),
            if (post.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 14),
              _UrlMediaPreview(urls: post.mediaUrls),
            ],
          ],
        ),
      ),
    );
  }
}

class _PostSummaryCard extends StatelessWidget {
  final AdminPost post;

  const _PostSummaryCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _resolveNetworkUrl(post.authorAvatarUrl);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E0D5)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF7F5EF),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bài viết bị báo cáo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: avatarUrl == null
                      ? null
                      : NetworkImage(avatarUrl),
                  child: avatarUrl == null
                      ? Text(initialFor(post.authorDisplayName))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorDisplayName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${post.authorUsername}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ReportLine(label: 'Nội dung', value: _contentText(post.content)),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoChip(
                  icon: Icons.favorite_border,
                  label: '${post.likesCount} lượt thích',
                ),
                _InfoChip(
                  icon: Icons.mode_comment_outlined,
                  label: '${post.commentsCount} bình luận',
                ),
                _InfoChip(
                  icon: Icons.image_outlined,
                  label: '${post.mediaCount} tệp đính kèm',
                ),
                _InfoChip(
                  icon: Icons.schedule_outlined,
                  label: formatAdminDate(post.createdAt),
                ),
              ],
            ),
            if (post.media.isNotEmpty) ...[
              const SizedBox(height: 14),
              _PostMediaPreview(media: post.media),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final AdminReport report;
  final bool busy;

  const _ReportCard({required this.report, required this.busy});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E0D5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Báo cáo từ ${report.reporterName}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                AdminStatusPill(
                  label: report.status,
                  color: report.isOpen
                      ? const Color(0xFFB42318)
                      : const Color(0xFF0F766E),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ReportLine(label: 'Lý do', value: report.reason),
            _ReportLine(
              label: 'Thời gian tạo',
              value: formatAdminDate(report.createdAt),
            ),
            if (report.isOpen) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () => context
                              .read<AdminReportDetailCubit>()
                              .reviewReport(report.id, 'resolved'),
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Xác nhận vi phạm'),
                  ),
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => context
                              .read<AdminReportDetailCubit>()
                              .reviewReport(report.id, 'dismissed'),
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Bỏ qua báo cáo'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E0D5)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _PostMediaPreview extends StatelessWidget {
  final List<AdminPostMedia> media;

  const _PostMediaPreview({required this.media});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = media[index];
          final url = _resolveMediaUrl(item);
          if (!item.isImage || url == null) {
            return const _MediaFallback();
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 128,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _MediaFallback(),
            ),
          );
        },
      ),
    );
  }
}

class _UrlMediaPreview extends StatelessWidget {
  final List<String> urls;

  const _UrlMediaPreview({required this.urls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final url = _resolveNetworkUrl(urls[index]);
          if (url == null) {
            return const _MediaFallback();
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 128,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _MediaFallback(),
            ),
          );
        },
      ),
    );
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E0D5)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: const SizedBox(
        width: 128,
        height: 96,
        child: Center(child: Icon(Icons.perm_media_outlined)),
      ),
    );
  }
}

class _ReportLine extends StatelessWidget {
  final String label;
  final String value;

  const _ReportLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 3),
          SelectableText(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

String _contentText(String value) {
  final text = value.trim();
  return text.isEmpty ? 'Bài viết không có nội dung chữ.' : text;
}

String? _resolveMediaUrl(AdminPostMedia item) {
  return _resolveNetworkUrl(item.mediaUrl) ?? _resolveNetworkUrl(item.objectKey);
}

String? _resolveNetworkUrl(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return null;
  }
  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw;
  }

  final baseUri = Uri.tryParse(ApiConstants.baseUrl);
  if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
    return raw;
  }

  final normalizedPath = raw.startsWith('/') ? raw : '/$raw';
  return baseUri.replace(path: normalizedPath, query: '').toString();
}
