import 'package:flutter/material.dart';

import 'package:frontend/src/core/l10n/l10n.dart';

class ProfileActionBar extends StatelessWidget {
  const ProfileActionBar({
    super.key,
    required this.isSendingFriendRequest,
    required this.isFriendRequestSent,
    required this.isFriend,
    required this.isOpeningMessage,
    this.onAddFriend,
    this.onMessage,
  });

  final bool isSendingFriendRequest;
  final bool isFriendRequestSent;
  final bool isFriend;
  final bool isOpeningMessage;
  final VoidCallback? onAddFriend;
  final VoidCallback? onMessage;

  static const Color _mint = Color(0xFF25A97A);
  static const Color _mintDark = Color(0xFF137B5B);
  static const Color _messageBlue = Color(0xFF2F6FED);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileActionButton(
            label: isFriend
                ? context.l10n.friends
                : isFriendRequestSent
                ? context.l10n.friendRequestSent
                : context.l10n.addFriendAction,
            icon: isFriend || isFriendRequestSent
                ? Icons.check_rounded
                : Icons.person_add_alt_1_rounded,
            backgroundColor: isFriend || isFriendRequestSent
                ? const Color(0xFFE6F7F0)
                : _mint,
            foregroundColor: isFriend || isFriendRequestSent
                ? _mintDark
                : Colors.white,
            borderColor: isFriend || isFriendRequestSent
                ? const Color(0xFFBFEBD9)
                : _mint,
            isLoading: isSendingFriendRequest,
            onPressed: isFriend || isFriendRequestSent ? null : onAddFriend,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileActionButton(
            label: context.l10n.messageAction,
            icon: Icons.chat_bubble_rounded,
            backgroundColor: Colors.white.withValues(alpha: 0.96),
            foregroundColor: _messageBlue,
            borderColor: const Color(0xFFD8E5FF),
            isLoading: isOpeningMessage,
            onPressed: onMessage,
            shadowColor: _messageBlue.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.isLoading,
    this.onPressed,
    this.shadowColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color:
                    shadowColor ??
                    const Color(0xFF1D5848).withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          foregroundColor,
                        ),
                      ),
                    )
                  : Row(
                      key: ValueKey(label),
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: foregroundColor, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foregroundColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
