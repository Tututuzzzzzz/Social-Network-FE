import '../models/home_model.dart';

abstract class HomeLocalDataSource {
  Future<List<HomeModel>> fetchItems();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<HomeModel>> fetchItems() async {
    // Placeholder cache layer. Remote source currently provides seeded UI data.
    return const [];
  }
}
