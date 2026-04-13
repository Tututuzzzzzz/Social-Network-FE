import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/home_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<HomeEntity>>> fetchItems();
}
