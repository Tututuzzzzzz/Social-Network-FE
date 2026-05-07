import 'dart:async';

class SessionExpirationNotifier {
  final _controller = StreamController<void>.broadcast();
  bool _hasPendingNotification = false;

  Stream<void> get stream => _controller.stream;

  void notifyExpired() {
    if (_hasPendingNotification || _controller.isClosed) {
      return;
    }

    _hasPendingNotification = true;
    _controller.add(null);
  }

  void reset() {
    _hasPendingNotification = false;
  }

  Future<void> dispose() {
    return _controller.close();
  }
}
