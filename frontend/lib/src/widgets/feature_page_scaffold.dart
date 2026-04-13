import 'package:flutter/material.dart';

class FeaturePageScaffold extends StatelessWidget {
  final String title;
  final Widget? body;
  final bool isLoading;
  final bool isEmpty;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final String? errorTitle;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String retryLabel;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry bodyPadding;

  const FeaturePageScaffold({
    super.key,
    required this.title,
    this.body,
    this.isLoading = false,
    this.isEmpty = false,
    this.emptyTitle = 'No data yet',
    this.emptyMessage = 'Add content to start building this screen.',
    this.emptyIcon = Icons.inbox_outlined,
    this.errorTitle,
    this.errorMessage,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.actions,
    this.floatingActionButton,
    this.bodyPadding = const EdgeInsets.all(16),
  });

  Widget _buildBodyContent() {
    if (errorMessage != null) {
      return _ScaffoldStatusView(
        icon: Icons.error_outline,
        title: errorTitle ?? 'Something went wrong',
        message: errorMessage!,
        actionLabel: onRetry != null ? retryLabel : null,
        onActionPressed: onRetry,
      );
    }

    if (isEmpty) {
      return _ScaffoldStatusView(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    if (body != null) {
      return body!;
    }

    return _PrototypeScreenFallback(title: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(padding: bodyPadding, child: _buildBodyContent()),
            ),
            if (isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScaffoldStatusView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const _ScaffoldStatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.blueGrey),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _PrototypeKind { feed, chat, reels, profile }

class _PrototypeScreenFallback extends StatelessWidget {
  final String title;

  const _PrototypeScreenFallback({required this.title});

  @override
  Widget build(BuildContext context) {
    final prototypeKind = _resolveKind(title);

    switch (prototypeKind) {
      case _PrototypeKind.chat:
        return _buildChatPreview(context);
      case _PrototypeKind.reels:
        return _buildReelsPreview(context);
      case _PrototypeKind.profile:
        return _buildProfilePreview(context);
      case _PrototypeKind.feed:
        return _buildFeedPreview(context);
    }
  }

  _PrototypeKind _resolveKind(String value) {
    final normalized = value.toLowerCase();

    if (normalized.contains('reels') ||
        normalized.contains('story') ||
        normalized.contains('shot')) {
      return _PrototypeKind.reels;
    }

    if (normalized.contains('chat') ||
        normalized.contains('message') ||
        normalized.contains('nhom') ||
        normalized.contains('nick')) {
      return _PrototypeKind.chat;
    }

    if (normalized.contains('profile') ||
        normalized.contains('cover') ||
        normalized.contains('chan') ||
        normalized.contains('han che') ||
        normalized.contains('dai dien')) {
      return _PrototypeKind.profile;
    }

    return _PrototypeKind.feed;
  }

  Widget _buildFeedPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        _PreviewCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: const Icon(Icons.person_outline),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text('Share your moment with friends...'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 106,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              return AspectRatio(
                aspectRatio: 0.72,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primary.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Story ${index + 1}',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PreviewCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colorScheme.secondaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mochi user ${index + 1}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const Icon(Icons.more_horiz),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A richer mock based on your Figma flow is now shown here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.9),
                          colorScheme.tertiary.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _PreviewAction(
                        icon: Icons.favorite_border,
                        label: 'Like',
                      ),
                      _PreviewAction(
                        icon: Icons.chat_bubble_outline,
                        label: 'Comment',
                      ),
                      _PreviewAction(icon: Icons.send_outlined, label: 'Share'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: colorScheme.outline),
              const SizedBox(width: 10),
              Text(
                'Search conversation',
                style: TextStyle(color: colorScheme.outline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          12,
          (index) => _PreviewCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: colorScheme.primaryContainer,
                  child: const Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversation ${index + 1}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        index.isEven
                            ? 'Typing a new message...'
                            : 'Last message from Figma-mapped screen',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(index + 1).toString().padLeft(2, '0')}:3${index % 10}',
                  style: TextStyle(color: colorScheme.outline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReelsPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.tertiary.withValues(alpha: 0.8),
                          colorScheme.primary.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 14,
                  right: 14,
                  child: Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 3 ? 4 : 0),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  right: 12,
                  bottom: 16,
                  child: Column(
                    children: [
                      _ReelsAction(icon: Icons.favorite_border, label: '42k'),
                      SizedBox(height: 12),
                      _ReelsAction(
                        icon: Icons.chat_bubble_outline,
                        label: '1.2k',
                      ),
                      SizedBox(height: 12),
                      _ReelsAction(icon: Icons.send_outlined, label: 'Share'),
                    ],
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 76,
                  bottom: 16,
                  child: Text(
                    'Short-form video placeholder upgraded to mimic a reels layout.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.8),
                    colorScheme.secondary.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: -34,
              child: CircleAvatar(
                radius: 36,
                backgroundColor: colorScheme.surface,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  child: const Icon(Icons.person, size: 30),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 44),
        Text('Mochi User', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'This profile preview now follows the Figma structure more closely.',
          style: TextStyle(color: colorScheme.outline),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ProfileMetric(label: 'Posts', value: '128'),
            _ProfileMetric(label: 'Followers', value: '9.4K'),
            _ProfileMetric(label: 'Following', value: '281'),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Edit profile'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Share'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.secondaryContainer,
                    colorScheme.primaryContainer,
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;

  const _PreviewCard({required this.child, this.margin = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _PreviewAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PreviewAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 5), Text(label)],
    );
  }
}

class _ReelsAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ReelsAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label),
      ],
    );
  }
}
