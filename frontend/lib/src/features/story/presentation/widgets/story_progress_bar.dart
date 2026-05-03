import 'package:flutter/material.dart';

class StoryProgressBar extends StatelessWidget {
  final int totalCount;
  final int currentIndex;
  final double progress;

  const StoryProgressBar({
    super.key,
    required this.totalCount,
    required this.currentIndex,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalCount, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: LinearProgressIndicator(
              value: index < currentIndex
                  ? 1.0
                  : (index == currentIndex ? progress : 0.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 2,
            ),
          ),
        );
      }),
    );
  }
}
