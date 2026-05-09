import 'package:flutter/material.dart';

class PostDetailMediaCarousel extends StatefulWidget {
  const PostDetailMediaCarousel({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<PostDetailMediaCarousel> createState() =>
      _PostDetailMediaCarouselState();
}

class _PostDetailMediaCarouselState extends State<PostDetailMediaCarousel> {
  static const double _mediaAspectRatio = 4 / 5;

  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant PostDetailMediaCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrls.length == oldWidget.imageUrls.length) return;
    if (_currentIndex < widget.imageUrls.length) return;

    _currentIndex = 0;
    if (widget.imageUrls.isNotEmpty && _pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: _mediaAspectRatio,
        child: Container(
          color: const Color(0xFFF1F1F1),
          child: const Center(
            child: Icon(Icons.image_outlined, size: 48, color: Colors.black26),
          ),
        ),
      );
    }

    if (widget.imageUrls.length == 1) {
      return AspectRatio(
        aspectRatio: _mediaAspectRatio,
        child: SizedBox.expand(
          child: _buildNetworkImage(widget.imageUrls.first),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _mediaAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (_, index) {
              return _buildNetworkImage(widget.imageUrls[index]);
            },
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                final isActive = index == _currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 8 : 6,
                  height: isActive ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return Container(
      color: Colors.black,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                color: const Color(0xFFF1F1F1),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF1F1F1),
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: Colors.black26,
            ),
          ),
        ),
      ),
    );
  }
}
