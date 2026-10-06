import 'package:flutter_test/flutter_test.dart';
import 'package:gesco/core/data/catalogos.dart';

void main() {
  group('Catalogos.municipiosDe', () {
    test('devuelve lista de municipios para un estado válido', () {
      final zacatecas = Catalogos.municipiosDe('ZACATECAS');
      expect(zacatecas, isNotEmpty);
      expect(zacatecas, contains('ZACATECAS'));
      expect(zacatecas, contains('GUADALUPE'));
      expect(zacatecas, contains('FRESNILLO'));
      expect(zacatecas, contains('OTRO'));
    });

    test('devuelve lista vacía para un estado null o inválido', () {
      expect(Catalogos.municipiosDe(null), isEmpty);
      expect(Catalogos.municipiosDe('ESTADO_INEXISTENTE'), isEmpty);
    });

    test('devuelve la misma instancia en llamadas consecutivas', () {
      final primera = Catalogos.municipiosDe('ZACATECAS');
      final segunda = Catalogos.municipiosDe('ZACATECAS');
      expect(identical(primera, segunda), isTrue);
    });
  });
}
