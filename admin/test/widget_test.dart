import 'package:admin/src/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AdminApp is constructible', (tester) async {
    expect(const AdminApp(), isA<AdminApp>());
  });
}
