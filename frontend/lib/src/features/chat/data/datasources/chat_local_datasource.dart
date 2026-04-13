import '../models/chat_model.dart';

abstract class ChatLocalDataSource {
  Future<List<ChatModel>> fetchItems();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  @override
  Future<List<ChatModel>> fetchItems() async {
    // Placeholder cache layer. Remote source currently provides seeded UI data.
    return const [];
  }
}
