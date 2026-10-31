
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcial2_acceso_listado/main.dart';

void main() {
  testWidgets('La pantalla Login se muestra correctamente', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Parcial2App(),
      ),
    );

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(
      find.text('¿No tienes cuenta? Regístrate'),
      findsOneWidget,
    );
  });
}
