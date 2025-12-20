// FiskPulse Widget Tests
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:fisk_pulse/main.dart';

void main() {
  setUpAll(() async {
    // Load test environment
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env.example');
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FiskPulseApp());

    // Verify that the app title is displayed
    expect(find.textContaining('FiskPulse'), findsWidgets);
  });

  testWidgets('Configuration card is displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FiskPulseApp());

    // Verify configuration section exists
    expect(find.text('Configuration'), findsOneWidget);
    expect(find.text('Environment'), findsOneWidget);
    expect(find.text('API URL'), findsOneWidget);
  });
}
