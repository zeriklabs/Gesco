import 'package:flutter_test/flutter_test.dart';
import 'package:gesco/main.dart';

void main() {
  testWidgets('LoginScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SiGe());

    // Verify that the login screen title and fields are displayed.
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Boleta'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
