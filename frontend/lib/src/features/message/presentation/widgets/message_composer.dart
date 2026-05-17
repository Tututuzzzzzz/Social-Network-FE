import 'package:flutter/material.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/core/testing/test_keys.dart';

class MessageComposer extends StatelessWidget {
  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    required this.onTakePhoto,
    required this.isSending,
    required this.accentColor,
    required this.fillColor,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.hintColor,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onTakePhoto;
  final bool isSending;
  final Color accentColor;
  final Color fillColor;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color hintColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: isSending ? null : onPickImage,
            icon: const Icon(Icons.image_outlined),
            tooltip: context.l10n.mediaLibrary,
            color: iconColor,
          ),
          IconButton(
            onPressed: isSending ? null : onTakePhoto,
            icon: const Icon(Icons.photo_camera_outlined),
            tooltip: context.l10n.cameraLabel,
            color: iconColor,
          ),
          Expanded(
            child: Container(
              height: 42,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                key: TestKeys.messageInputField,
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: context.l10n.typeMessageHint,
                  hintStyle: TextStyle(color: hintColor),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.emoji_emotions_outlined),
            color: iconColor,
          ),
          SizedBox(
            height: 42,
            width: 42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                key: TestKeys.messageSendButton,
                onPressed: isSending ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
