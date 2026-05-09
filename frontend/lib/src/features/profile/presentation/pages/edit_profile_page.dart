import 'package:flutter/material.dart';

import '../../../../widgets/feature_page_scaffold.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePageScaffold(
      title: 'Chỉnh sửa hồ sơ',
      emptyIcon: Icons.edit_note_rounded,
      emptyTitle: 'Màn chỉnh sửa hồ sơ',
      emptyMessage: 'Form chỉnh sửa sẽ được nối vào flow cập nhật hồ sơ sau.',
    );
  }
}
