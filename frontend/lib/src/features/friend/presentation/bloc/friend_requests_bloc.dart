import 'package:flutter/foundation.dart';

import '../../domain/entities/friend_request.dart';
import '../../domain/repositories/friend_repository.dart';

/// Simple ChangeNotifier-based bloc to avoid external dependencies.
class FriendRequestsBloc extends ChangeNotifier {
  final FriendRepository repository;

  FriendRequestsBloc({required this.repository});

  List<FriendRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  List<FriendRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _requests = await repository.getFriendRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> accept(String requestId) async {
    try {
      await repository.acceptFriendRequest(requestId);
      _requests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> reject(String requestId) async {
    try {
      await repository.rejectFriendRequest(requestId);
      _requests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
