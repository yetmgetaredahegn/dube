import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dube/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Test', () {
    testWidgets('Register, Add Customer, Add Transaction, and Verify',
        (WidgetTester tester) async {
      // 1. Launch App
      app.main();
      await tester.pumpAndSettle();

      // 2. Navigate to Register (assuming we start at Login)
      final registerLink = find.text('Register');
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // 3. Fill Registration Form
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Shop');
      await tester.enterText(find.byType(TextFormField).at(1), '0911223344');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@dube.com');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      
      // Scroll to find button if needed
      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Wait for Firebase

      // 4. Verify Dashboard
      expect(find.text('Dashboard'), findsOneWidget);

      // 5. Navigate to Customers Tab
      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();

      // 6. Add Customer
      await tester.tap(find.text('Add Customer'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), '0900112233');
      await tester.enterText(find.byType(TextFormField).at(2), '5000');
      await tester.tap(find.text('Add Customer'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 7. Open Customer Detail
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // 8. Add Credit Transaction
      await tester.tap(find.text('Add Transaction'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '150.50');
      await tester.enterText(find.byType(TextFormField).at(1), 'Bread and milk');
      await tester.tap(find.text('Add Credit'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 9. Verify Balance in Detail
      expect(find.text('ETB 150.50'), findsWidgets);
      expect(find.text('Bread and milk'), findsOneWidget);

      // 10. Go back to Dashboard and verify totals
      await tester.tap(find.byIcon(Icons.dashboard_outlined));
      await tester.pumpAndSettle();
      expect(find.text('ETB 150.50'), findsWidgets);
    });
  });
}
