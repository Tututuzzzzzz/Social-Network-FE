import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reels_entity.dart';

abstract class ReelsRepository {
  Future<Either<Failure, List<ReelsEntity>>> fetchItems();
}
