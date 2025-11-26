import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:to_do_list/main.dart'; // Update with your actual path

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Pass isLoggedIn: false (or true) — required now
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Your existing test logic (if you still have a counter somewhere)
    // Or just verify the app launches
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}