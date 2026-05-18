import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../chat/domain/entities/chat_entity.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_route_path.dart';
import '../../domain/entities/message_media_upload_file.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';
import '../widgets/message_chat_room_app_bar.dart';
import '../widgets/message_composer.dart';
import '../widgets/message_history_list.dart';

part 'message_chat_room_actions.dart';

class MessageChatRoomPage extends StatefulWidget {
  final ChatEntity thread;

  const MessageChatRoomPage({super.key, required this.thread});

  @override
  State<MessageChatRoomPage> createState() => _MessageChatRoomPageState();
}

class _MessageChatRoomPageState extends State<MessageChatRoomPage>
    with MessageChatRoomActions {
  static const int _historyPageLimit = 30;

  final TextEditingController _composerController = TextEditingController();
  final ScrollController _historyScrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  double _previousMaxScrollExtentBeforeOlderLoad = 0.0;
  MessageChatRoomState? _previousChatState;
  bool _showScrollToLatestButton = false;

  @override
  ScrollController get historyScrollController => _historyScrollController;

  @override
  TextEditingController get composerController => _composerController;

  @override
  ImagePicker get imagePicker => _imagePicker;

  @override
  double get previousMaxScrollExtentBeforeOlderLoad =>
      _previousMaxScrollExtentBeforeOlderLoad;

  @override
  set previousMaxScrollExtentBeforeOlderLoad(double value) {
    _previousMaxScrollExtentBeforeOlderLoad = value;
  }

  @override
  int get historyPageLimit => _historyPageLimit;

  @override
  MessageChatRoomState? get previousChatState => _previousChatState;

  @override
  set previousChatState(MessageChatRoomState? value) {
    _previousChatState = value;
  }

  @override
  bool get showScrollToLatestButton => _showScrollToLatestButton;

  @override
  set showScrollToLatestButton(bool value) {
    _showScrollToLatestButton = value;
  }

  @override
  void initState() {
    super.initState();
    _historyScrollController.addListener(onHistoryScroll);
    context.read<MessageBloc>().add(
      MessageChatRoomStarted(thread: widget.thread, limit: _historyPageLimit),
    );
  }

  @override
  void dispose() {
    _historyScrollController
      ..removeListener(onHistoryScroll)
      ..dispose();
    _composerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threadName = widget.thread.senderName.trim().isEmpty
        ? context.l10n.conversationTitle
        : widget.thread.senderName.trim();
    final currentState = context.watch<MessageBloc>().state;
    final chatState = currentState is MessageChatRoomState
        ? currentState
        : _previousChatState;
    final threadAvatarUrl = resolvePeerAvatarUrl(chatState);
    final colors = AppColors.of(context);

    return PopScope<ChatEntity>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        closeWithResult();
      },
      child: Scaffold(
        backgroundColor: colors.scaffold,
        appBar: MessageChatRoomAppBar(
          title: threadName,
          avatarUrl: threadAvatarUrl,
          accentColor: colors.primary,
          foregroundColor: colors.appBarForeground,
          avatarBackgroundColor: colors.sheetSurface,
          onBack: closeWithResult,
          onManage: () {
            context.pushNamed(
              AppRoutes.chatConversationManage.name,
              pathParameters: {'threadId': widget.thread.id},
              extra: widget.thread,
            );
          },
        ),
        body: BlocConsumer<MessageBloc, MessageState>(
          listener: (context, state) {
            if (state is! MessageChatRoomState) {
              return;
            }

            final previous = _previousChatState;
            final previousErrorVersion = previous?.errorVersion ?? -1;
            final previousScrollToLatestVersion =
                previous?.scrollToLatestVersion ?? -1;
            final previousRestoreScrollVersion =
                previous?.restoreScrollVersion ?? -1;
            final previousMessages = previous?.messages ?? const [];
            final hasNewMessage =
                state.messages.length > previousMessages.length;
            final latestMessage = state.messages.isNotEmpty
                ? state.messages.last
                : null;
            final previousLatestId = previousMessages.isNotEmpty
                ? previousMessages.last.id
                : '';
            final latestMessageIsNew =
                latestMessage != null && latestMessage.id != previousLatestId;
            final shouldRespondToNewMessage =
                hasNewMessage && latestMessageIsNew;

            if (state.errorMessage != null &&
                state.errorVersion != previousErrorVersion) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }

            if (state.scrollToLatestVersion != previousScrollToLatestVersion) {
              if (state.scrollToLatestVersion > 0) {
                scrollToLatestAfterHydration();
              }
            }

            if (state.restoreScrollVersion != previousRestoreScrollVersion) {
              if (state.restoreScrollVersion > 0) {
                restoreScrollAfterOlderLoaded();
              }
            }

            if ((previous?.isSending ?? false) &&
                !state.isSending &&
                state.errorVersion == previousErrorVersion) {
              _composerController.clear();
            }

            if (shouldRespondToNewMessage) {
              final shouldAutoScroll =
                  isNearLatestMessage || (latestMessage?.fromMe ?? false);
              if (shouldAutoScroll) {
                animateToLatestMessage();
              } else if (!_showScrollToLatestButton) {
                setState(() {
                  _showScrollToLatestButton = true;
                });
              }
            }

            _previousChatState = state;
          },
          builder: (blocContext, state) {
            final chatState = state is MessageChatRoomState
                ? state
                : MessageChatRoomState.initial();
            final isSending = chatState.isSending;

            return SafeArea(
              child: Column(
                children: [
                  if (chatState.isBootstrappingHistory)
                    const LinearProgressIndicator(minHeight: 2),
                  if (chatState.isLoadingOlderHistory)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        MessageHistoryList(
                          controller: _historyScrollController,
                          messages: chatState.messages,
                          accentColor: colors.accent,
                          peerBubbleColor: colors.inputFill,
                          isGroupChat: widget.thread.isGroup,
                          currentUserId: chatState.currentUserId,
                          onReaction: (messageId, emoji, isRemove) {
                            if (isRemove) {
                              blocContext.read<MessageBloc>().add(
                                MessageRemoveReactionRequested(
                                  messageId: messageId,
                                  emoji: emoji,
                                ),
                              );
                            } else {
                              blocContext.read<MessageBloc>().add(
                                MessageAddReactionRequested(
                                  messageId: messageId,
                                  emoji: emoji,
                                ),
                              );
                            }
                          },
                          onDelete: (messageId) {
                            blocContext.read<MessageBloc>().add(
                              MessageDeleteRequested(
                                conversationId: widget.thread.id,
                                messageId: messageId,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 12,
                          child: Center(
                            child: _ScrollToLatestButton(
                              isVisible: _showScrollToLatestButton,
                              accentColor: colors.accent,
                              onPressed: animateToLatestMessage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  MessageComposer(
                    controller: _composerController,
                    onSend: () => onSendPressed(blocContext),
                    onPickImage: () => onPickMediaPressed(ImageSource.gallery),
                    onTakePhoto: () => onPickMediaPressed(ImageSource.camera),
                    isSending: isSending,
                    accentColor: colors.accent,
                    fillColor: colors.inputFill,
                    backgroundColor: colors.scaffold,
                    iconColor: colors.textSecondary,
                    textColor: colors.textPrimary,
                    hintColor: colors.textSecondary,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScrollToLatestButton extends StatelessWidget {
  const _ScrollToLatestButton({
    required this.isVisible,
    required this.accentColor,
    required this.onPressed,
  });

  final bool isVisible;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isVisible ? 1 : 0.86,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        child: IgnorePointer(
          ignoring: !isVisible,
          child: Material(
            color: accentColor,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
