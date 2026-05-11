import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/core/l10n/l10n.dart';

import '../../../../routes/app_route_path.dart';
import '../../../chat/domain/entities/chat_entity.dart';

class ConversationManagementPage extends StatefulWidget {
  final ChatEntity thread;

  const ConversationManagementPage({super.key, required this.thread});

  @override
  State<ConversationManagementPage> createState() =>
      _ConversationManagementPageState();
}

class _ConversationManagementPageState
    extends State<ConversationManagementPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final surfaceContainer = onSurface.withValues(alpha: 0.1);
    final isGroup = widget.thread.isGroup;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'block') {
                // handle block
              } else if (value == 'delete') {
                // handle delete
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'block',
                child: Text(context.l10n.blockAction),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(context.l10n.deleteConversationAction),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: surfaceContainer,
              backgroundImage: widget.thread.avatarUrl.isNotEmpty
                  ? NetworkImage(widget.thread.avatarUrl)
                  : null,
              child: widget.thread.avatarUrl.isEmpty
                  ? Text(
                      widget.thread.senderName.trim().isNotEmpty
                          ? widget.thread.senderName.trim().substring(0, 1).toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 40,
                        color: onSurface,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              widget.thread.senderName.trim().isNotEmpty
                  ? widget.thread.senderName.trim()
                  : context.l10n.userDefaultName,
              style: TextStyle(
                color: onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),
            // 4 Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildActionButton(Icons.call, context.l10n.audioCallAction, context)),
                  Expanded(child: _buildActionButton(Icons.videocam, context.l10n.videoCallAction, context)),
                  Expanded(
                    child: isGroup
                        ? _buildActionButton(
                            Icons.group,
                            context.l10n.memberList,
                            context,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.featureInDevelopment,
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildActionButton(
                            Icons.person,
                            context.l10n.viewProfileChatAction,
                            context,
                            onTap: () {
                              if (widget.thread.recipientId.isNotEmpty) {
                                context.pushNamed(
                                  AppRoutes.otherProfile.name,
                                  pathParameters: {
                                    'userId': widget.thread.recipientId,
                                  },
                                );
                              }
                            },
                          ),
                  ),
                  Expanded(child: _buildActionButton(Icons.notifications, context.l10n.muteNotificationsAction, context)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Tùy chỉnh Section
            _buildSectionHeader(context.l10n.customizationSection, context),
            _buildCustomMenuItem(
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: context.l10n.themeAction,
              context: context,
            ),
            const SizedBox(height: 20),
            // Hành động khác Section
            _buildSectionHeader(context.l10n.otherActionsSection, context),
            _buildMenuItem(
                Icons.image, context.l10n.viewMediaFilesLinks,
                iconColor: onSurface, context: context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, BuildContext context, {VoidCallback? onTap}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surfaceContainer = onSurface.withValues(alpha: 0.1);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: onSurface, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title,
      {required Color iconColor, required BuildContext context}) {
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(icon, color: iconColor, size: 28),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
      ),
      onTap: () {},
    );
  }

  Widget _buildCustomMenuItem(
      {required Widget leading,
      required String title,
      required BuildContext context}) {
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Align(
          alignment: Alignment.centerLeft,
          child: leading,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
      ),
      onTap: () {},
    );
  }
}
