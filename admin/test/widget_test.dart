import 'package:admin/src/app.dart';
import 'package:admin/src/core/theme/admin_theme.dart';
import 'package:admin/src/features/admin/domain/entities/admin_dashboard_snapshot.dart';
import 'package:admin/src/features/admin/presentation/widgets/overview/admin_overview_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AdminApp is constructible', (tester) async {
    expect(const AdminApp(), isA<AdminApp>());
  });

  testWidgets('overview metrics fit at compact desktop width', (tester) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AdminTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1220,
              child: AdminOverviewSection(
                snapshot: AdminDashboardSnapshot.empty,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
