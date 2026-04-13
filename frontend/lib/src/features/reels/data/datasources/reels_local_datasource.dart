import '../models/reels_model.dart';

abstract class ReelsLocalDataSource {
  Future<List<ReelsModel>> fetchItems();
}

class ReelsLocalDataSourceImpl implements ReelsLocalDataSource {
  @override
  Future<List<ReelsModel>> fetchItems() async {
    return const [];
  }
}
