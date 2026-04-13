import 'package:flutter/material.dart';

class HomeDiscoveryItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const HomeDiscoveryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class HomeDiscoveryGrid extends StatelessWidget {
  final List<HomeDiscoveryItem> items;
  final ValueChanged<int>? onTapItem;

  const HomeDiscoveryGrid({super.key, required this.items, this.onTapItem});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTapItem != null ? () => onTapItem!(index) : null,
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon),
                  const Spacer(),
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
