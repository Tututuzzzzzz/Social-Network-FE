import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_admin_user_detail_usecase.dart';
import 'admin_user_detail_state.dart';

class AdminUserDetailCubit extends Cubit<AdminUserDetailState> {
  final GetAdminUserDetailUseCase _getDetail;

  AdminUserDetailCubit(this._getDetail)
    : super(const AdminUserDetailState.initial());

  Future<void> load(String userId) async {
    emit(state.copyWith(status: AdminUserDetailStatus.loading));

    try {
      final detail = await _getDetail(userId);
      emit(state.copyWith(status: AdminUserDetailStatus.ready, detail: detail));
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminUserDetailStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
