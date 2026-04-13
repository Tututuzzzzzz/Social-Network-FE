import 'package:flutter/material.dart';

class HomeFilterTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const HomeFilterTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Padding(
              padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 8),
              child: ChoiceChip(
                label: Text(tabs[i]),
                selected: i == selectedIndex,
                onSelected: (_) => onChanged(i),
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }
}
