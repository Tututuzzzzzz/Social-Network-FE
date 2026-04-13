import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<List<ProfileModel>> fetchItems();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  @override
  Future<List<ProfileModel>> fetchItems() async {
    return const [];
  }
}
