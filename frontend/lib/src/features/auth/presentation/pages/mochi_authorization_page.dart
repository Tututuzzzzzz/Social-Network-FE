import 'package:flutter/material.dart';

import '../../../../widgets/feature_page_scaffold.dart';

class MochiAuthorizationPage extends StatelessWidget {
  const MochiAuthorizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePageScaffold(
      title: 'Mochi Authorization',
      isLoading: false,
    );
  }
}
