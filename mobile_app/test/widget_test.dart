import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart'; // මෙතන mobile_app වෙනුවට ඔබේ project එකේ නම (pubspec.yaml එකේ ඇති නම) හරියට තියෙන්න ඕනේ.

void main() {
  testWidgets('App launch smoke test', (WidgetTester tester) async {
    // 1. අපේ ඇප් එක ලෝඩ් කරන්න
    await tester.pumpWidget(const EFineApp());

    // 2. Splash Screen එකේ "E-Fine SL" කියන නම තියෙනවද බලන්න
    // (අපි Splash Screen එකේ ඒ නම දැම්මා මතක ඇති)
    expect(find.text('E-Fine SL'), findsOneWidget);
  });
}