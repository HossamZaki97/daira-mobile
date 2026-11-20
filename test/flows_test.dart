import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('signed out: welcome → sign in → home with the payment to make', (tester) async {
    final app = await TestHarness.start(tester);
    expect(find.text('Your circles, clearly'), findsOneWidget);

    await tapText(tester, 'Sign in', last: false);
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Mona@Example.invalid ');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret-123');
    await tapText(tester, 'Sign in');

    expect(app.auth.logins, ['mona@example.invalid']);
    expect(find.text('Hi Mona'), findsOneWidget);
    expect(find.textContaining('Pay your installment', findRichText: true), findsOneWidget);
  });

  testWidgets('member reports a payment after confirming', (tester) async {
    final app = await TestHarness.start(tester, signedIn: true);
    app.go(R.circle('c1'));
    await TestHarness.settle(tester);

    expect(find.text('Your installment'), findsOneWidget);
    await tapText(tester, 'I paid', last: false); // the button
    expect(find.text('Did you pay this installment?'), findsOneWidget);
    await tapText(tester, 'I paid'); // the dialog

    expect(app.circles.calls, ['report:o1']);
    expect(find.text('Waiting for the organizer to confirm.'), findsOneWidget);
  });

  testWidgets('organizer: «Not received» needs a reason, then is sent', (tester) async {
    final app = await TestHarness.start(tester, signedIn: true, circle: circleFixture(organizer: true));
    app.go(R.circle('c1'));
    await TestHarness.settle(tester);

    expect(find.text('Installment due'), findsOneWidget); // the due date stands out in the hero
    await revealText(tester, 'Round 1 installments'); // below the hero, actions and tabs
    expect(find.text('Round 1 installments'), findsOneWidget);
    await tapText(tester, 'Not received', last: false);
    expect(find.text('Payment from Ali Hassan did not arrive?'), findsOneWidget);

    await tapText(tester, 'Not received'); // empty reason
    expect(find.text('Fill in this field.'), findsOneWidget);
    expect(app.circles.calls, isEmpty);

    await tester.enterText(find.byType(TextFormField).last, 'No transfer yet');
    await tapText(tester, 'Not received');
    expect(app.circles.calls, ['reject:o2']);
    expect(app.circles.rejectReason, 'No transfer yet');
  });

  testWidgets('organizer: tap who paid, then record from the bar', (tester) async {
    final app = await TestHarness.start(tester, signedIn: true, circle: circleFixture(organizer: true, other: 'pending'));
    app.go(R.circle('c1'));
    await TestHarness.settle(tester);

    // The bar is hidden (and cannot be tapped) until someone is selected.
    expect(find.text('Record payment').hitTestable(), findsNothing);
    await revealText(tester, 'Ali Hassan');
    await tapText(tester, 'Ali Hassan', last: false);
    expect(find.text('Record payment').hitTestable(), findsOneWidget);
    await tapText(tester, 'Record payment'); // the bar
    await tester.tap(find.widgetWithText(ChoiceChip, 'Cash'));
    await TestHarness.settle(tester);
    await tapText(tester, 'Record payment'); // the sheet
    expect(app.circles.calls, ['record:o2:cash']);
  });

  testWidgets('create wizard saves a draft with the typed plan', (tester) async {
    final app = await TestHarness.start(tester, signedIn: true);
    app.go(R.newCircle);
    await TestHarness.settle(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Office circle');
    await tester.enterText(find.byType(TextFormField).at(1), '1,000');
    await tapText(tester, 'Next');
    await tester.tap(find.byType(TextFormField).first);
    await tester.enterText(find.byType(TextFormField).first, 'Sara');
    await tester.pump();
    // A matching contact is suggested; choosing it sends the same person.
    await tapText(tester, 'Sara Ali');
    await tapText(tester, 'Next');
    expect(find.text('Sara Ali'), findsWidgets); // turn order step
    await tapText(tester, 'Next');
    await tapText(tester, 'Save as draft');

    final plan = app.circles.createdPlan!;
    expect(plan['name'], 'Office circle');
    expect(plan['amount'], '1000.00');
    expect(plan['currency'], 'EGP');
    expect(plan['activate'], false);
    expect(plan['members'], [
      {'name': 'Sara Ali', 'shares': 1, 'contact_id': 'k1'},
    ]);
  });
}

/// Scrolls the page until [text] is built and on screen (lists build lazily).
/// The finder must not use `.first`: it is empty until the row is built.
Future<void> revealText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(find.text(text), 200, scrollable: find.byType(Scrollable).first);
  await TestHarness.settle(tester);
}
