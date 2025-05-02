import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vccm/screens/auth/login_screen.dart';

// Mock UserProvider that does not call Firebase
class MockUserProvider extends ChangeNotifier {
  // Add any properties/methods needed for the UI to build
}

void main() {
  testWidgets('LoginScreen has a login button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<MockUserProvider>(
        create: (_) => MockUserProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    final loginButton = find.byType(ElevatedButton);
    expect(loginButton, findsOneWidget);
  });
}
