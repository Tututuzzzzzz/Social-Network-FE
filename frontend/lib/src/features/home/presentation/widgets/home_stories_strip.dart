import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_route_path.dart';

class HomeStoryItem {
  final String id;
  final String name;
  final bool hasUnread;

  const HomeStoryItem({
    required this.id,
    required this.name,
    required this.hasUnread,
  });
}

class HomeStoriesStrip extends StatelessWidget {
  final List<HomeStoryItem> items;
  final ValueChanged<int>? onTapStory;

  const HomeStoriesStrip({super.key, required this.items, this.onTapStory});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final borderColor = item.hasUnread
              ? const Color(0xFF4A9BFF)
              : Colors.grey.shade300;

          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (onTapStory != null) {
                onTapStory!(index);
              }
              context.pushNamed(
                AppRoutes.otherProfile.name,
                pathParameters: {'userId': item.id},
              );
            },
            child: SizedBox(
              width: 74,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      child: Text(item.name.substring(0, 1).toUpperCase()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
