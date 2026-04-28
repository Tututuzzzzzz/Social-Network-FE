import 'package:flutter/material.dart';
// Keep this widget lightweight and dependency-free; integrate usecases via DI where needed.

/// A small reusable button widget to send/cancel friend request or show friend status.
/// This is a stub: integrate with repository/usecases and Post UI.
class FriendActionButton extends StatefulWidget {
  final String targetUserId;
  final bool isFriend;
  final bool isPending;

  const FriendActionButton({
    super.key,
    required this.targetUserId,
    this.isFriend = false,
    this.isPending = false,
  });

  @override
  State<FriendActionButton> createState() => _FriendActionButtonState();
}

class _FriendActionButtonState extends State<FriendActionButton> {
  bool _loading = false;
  late bool _isFriend;
  late bool _isPending;

  @override
  void initState() {
    super.initState();
    _isFriend = widget.isFriend;
    _isPending = widget.isPending;
  }

  Future<void> _sendRequest() async {
    setState(() => _loading = true);
    try {
      // TODO: call FriendRepository or Usecase to send request.
      // Example: GetIt.I<SendFriendRequestUsecase>().call(widget.targetUserId);
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _isPending = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFriend) {
      return const Text('Friends', style: TextStyle(color: Colors.grey));
    }

    if (_loading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_isPending) {
      return TextButton(onPressed: null, child: const Text('Pending'));
    }

    return ElevatedButton(onPressed: _sendRequest, child: const Text('Add'));
  }
}
