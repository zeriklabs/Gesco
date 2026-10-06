import 'package:flutter_test/flutter_test.dart';
import 'package:gesco/core/data/codigos_postales.dart';

void main() {
  group('CodigosPostales.buscar', () {
    test('encuentra el CP 98000 en Zacatecas', () {
      final info = CodigosPostales.buscar('98000');
      expect(info, isNotNull);
      expect(info!.estado, equals('ZACATECAS'));
      expect(info.municipio, equals('ZACATECAS'));
      expect(info.colonias, contains('ZACATECAS CENTRO'));
    });

    test('encuentra el CP 01000 en Álvaro Obregón', () {
      final info = CodigosPostales.buscar('01000');
      expect(info, isNotNull);
      expect(info!.estado, equals('CIUDAD DE MÉXICO'));
      expect(info.municipio, equals('ÁLVARO OBREGÓN'));
      expect(info.colonias, contains('SAN ÁNGEL'));
    });

    test('devuelve null para CP inexistente o inválido', () {
      expect(CodigosPostales.buscar('00000'), isNull);
      expect(CodigosPostales.buscar('999999'), isNull);
      expect(CodigosPostales.buscar(null), isNull);
    });
  });
}
