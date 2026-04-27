import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../domain/entities/chat_entity.dart';
import 'mochi_dm_styles.dart';

class MochiDmConversationItem extends StatelessWidget {
  final ChatEntity item;
  final int index;
  final String name;
  final String preview;
  final String timeLabel;
  final String initial;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;
  final VoidCallback onHiddenToggle;
  final VoidCallback onDelete;

  const MochiDmConversationItem({
    super.key,
    required this.item,
    required this.index,
    required this.name,
    required this.preview,
    required this.timeLabel,
    required this.initial,
    required this.onTap,
    required this.onPinToggle,
    required this.onHiddenToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor =
        MochiDmStyles.avatarColors[index % MochiDmStyles.avatarColors.length];

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.72,
        children: [
          SlidableAction(
            onPressed: (_) => onPinToggle(),
            backgroundColor: const Color(0xFF4B8EFF),
            foregroundColor: Colors.white,
            icon: item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: item.isPinned ? 'Bo ghim' : 'Ghim',
          ),
          SlidableAction(
            onPressed: (_) => onHiddenToggle(),
            backgroundColor: const Color(0xFF8E8E93),
            foregroundColor: Colors.white,
            icon: item.isHidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            label: item.isHidden ? 'Hien' : 'An',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: const Color(0xFFE84545),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Xoa',
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFDCDDDF),
                    width: 1.1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A2B2F),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: item.unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: const Color(0xFF1A1A1D),
                              height: 1,
                            ),
                          ),
                        ),
                        if (item.isOnline)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1EC85D),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (item.isPinned)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.push_pin,
                              size: 14,
                              color: Color(0xFF4B8EFF),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: item.unreadCount > 0
                            ? const Color(0xFF50525A)
                            : const Color(0xFF7C7E84),
                        fontWeight: item.unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.w400,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: MochiDmStyles.tertiaryText,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                  if (item.unreadCount > 0) ...[
                    const SizedBox(height: 7),
                    Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C8DFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.unreadCount > 99
                            ? '99+'
                            : item.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
