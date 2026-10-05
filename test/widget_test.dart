import 'package:flutter_test/flutter_test.dart';
import 'package:nexa_admin/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NexaAdminApp());
    expect(find.text('NEXA ADMIN LITE'), findsOneWidget);
  });
}
