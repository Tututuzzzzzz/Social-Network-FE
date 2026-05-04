import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/utils/url_normalizer.dart';
import '../../domain/entities/story_group_entity.dart';
import '../../domain/entities/story_item_entity.dart';
import '../widgets/story_progress_bar.dart';
import '../widgets/story_user_header.dart';

class StoryViewScreen extends StatefulWidget {
  final List<StoryGroupEntity> storyGroups;
  final int initialGroupIndex;

  const StoryViewScreen({
    super.key,
    required this.storyGroups,
    this.initialGroupIndex = 0,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with SingleTickerProviderStateMixin {
  late PageController _groupPageController;
  late AnimationController _progressController;
  
  int _currentGroupIndex = 0;
  int _currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _groupPageController = PageController(initialPage: _currentGroupIndex);
    
    _progressController = AnimationController(vsync: this);
    
    _loadStory();
  }

  void _loadStory({bool animateToPage = true}) {
    _progressController.stop();
    _progressController.reset();

    final currentStory = widget.storyGroups[_currentGroupIndex].stories[_currentStoryIndex];
    _progressController.duration = currentStory.duration;
    
    _progressController.forward().whenComplete(() {
      _nextStory();
    });

    if (animateToPage && _groupPageController.hasClients) {
       _groupPageController.animateToPage(
        _currentGroupIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStory() {
    if (_currentStoryIndex < widget.storyGroups[_currentGroupIndex].stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _loadStory(animateToPage: false);
    } else {
      // Move to next group
      if (_currentGroupIndex < widget.storyGroups.length - 1) {
        setState(() {
          _currentGroupIndex++;
          _currentStoryIndex = 0;
        });
        _loadStory();
      } else {
        // End of all stories
        Navigator.of(context).pop();
      }
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _loadStory(animateToPage: false);
    } else {
      // Move to previous group
      if (_currentGroupIndex > 0) {
        setState(() {
          _currentGroupIndex--;
          _currentStoryIndex = widget.storyGroups[_currentGroupIndex].stories.length - 1;
        });
        _loadStory();
      }
    }
  }

  @override
  void dispose() {
    _groupPageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGroup = widget.storyGroups[_currentGroupIndex];
    final currentStory = currentGroup.stories[_currentStoryIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) => _progressController.stop(),
        onLongPressEnd: (_) => _progressController.forward(),
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Background Image
            Center(
              child: Image.network(
                currentStory.url.normalizeClientUrl(),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
              ),
            ),
            
            // UI Overlays
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Progress Bars
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return StoryProgressBar(
                        totalCount: currentGroup.stories.length,
                        currentIndex: _currentStoryIndex,
                        progress: _progressController.value,
                      );
                    },
                  ),
                  
                  // User Info
                  StoryUserHeader(
                    username: currentGroup.username,
                    avatarUrl: currentGroup.avatarUrl,
                    onClose: () => Navigator.of(context).pop(),
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
