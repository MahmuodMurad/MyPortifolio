import 'package:flutter_test/flutter_test.dart';
import 'package:my_portifolio/app/app.dart';
import 'package:my_portifolio/features/splash/ui/splash_screen.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PortfolioApp());

    // Verify splash screen content
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
