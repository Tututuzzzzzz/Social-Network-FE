import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_admin_post_detail_usecase.dart';
import 'admin_post_detail_state.dart';

class AdminPostDetailCubit extends Cubit<AdminPostDetailState> {
  final GetAdminPostDetailUseCase _getDetail;

  AdminPostDetailCubit(this._getDetail)
    : super(const AdminPostDetailState.initial());

  Future<void> load(String postId) async {
    emit(state.copyWith(status: AdminPostDetailStatus.loading));

    try {
      final detail = await _getDetail(postId);
      emit(state.copyWith(status: AdminPostDetailStatus.ready, detail: detail));
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminPostDetailStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
