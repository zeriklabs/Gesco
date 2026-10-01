import 'package:flutter_test/flutter_test.dart';
import 'package:gesco/core/utils/validators.dart';

void main() {
  group('Validators.boleta', () {
    test('acepta una boleta de 10 dígitos', () {
      expect(Validators.boleta('2023670000'), isNull);
    });

    test('acepta preboleta de nuevo ingreso', () {
      // El proyecto base exigía exactamente 10 caracteres, así que rechazaba
      // PE-12345678 (11) — el mismo ejemplo que daba su diálogo de ayuda.
      expect(Validators.boleta('PE-12345678'), isNull);
      expect(Validators.boleta('PE12345678'), isNull);
      expect(Validators.boleta('pe-12345678'), isNull);
    });

    test('exige algo', () {
      expect(Validators.boleta(''), isNotNull);
      expect(Validators.boleta(null), isNotNull);
    });

    test('dice cuántos dígitos faltan', () {
      expect(Validators.boleta('20236'), contains('llevas 5'));
    });

    test('corrige el formato de la preboleta', () {
      expect(Validators.boleta('PE-123'), contains('PE-12345678'));
    });

    test('normalizarBoleta agrega el guion y sube a mayúsculas', () {
      expect(Validators.normalizarBoleta('pe12345678'), 'PE-12345678');
      expect(Validators.normalizarBoleta(' 2023670000 '), '2023670000');
    });

    test('esPreboleta distingue los dos casos', () {
      expect(Validators.esPreboleta('PE-12345678'), isTrue);
      expect(Validators.esPreboleta('2023670000'), isFalse);
    });
  });

  group('Validators.telefono', () {
    test('acepta 10 dígitos con o sin guiones', () {
      expect(Validators.telefono('4929237969'), isNull);
      expect(Validators.telefono('492-923-7969'), isNull);
      expect(Validators.telefono('492 923 7969'), isNull);
    });

    test('dice cuántos dígitos lleva', () {
      expect(Validators.telefono('492-123-850'), contains('llevas 9'));
    });

    test('permite vacío cuando es opcional', () {
      expect(Validators.telefono('', obligatorio: false), isNull);
      expect(Validators.telefono('', obligatorio: true), isNotNull);
    });
  });

  group('Validators.contrasena', () {
    test('acepta una que cumple las tres reglas', () {
      expect(Validators.contrasena('Politecnico1'), isNull);
    });

    test('pide 8 caracteres', () {
      expect(Validators.contrasena('Ab1'), contains('8 caracteres'));
    });

    test('pide mayúscula', () {
      expect(Validators.contrasena('politecnico1'), contains('mayúscula'));
    });

    test('pide número', () {
      expect(Validators.contrasena('Politecnico'), contains('número'));
    });

    test('confirmar compara contra la original', () {
      expect(Validators.confirmarContrasena('abc', 'abc'), isNull);
      expect(Validators.confirmarContrasena('abc', 'abd'), isNotNull);
    });
  });

  group('Validators.correo', () {
    test('acepta correos normales', () {
      expect(Validators.correo('alguien@gmail.com'), isNull);
      expect(Validators.correo('a.b+c@ipn.mx'), isNull);
    });

    test('rechaza lo que no lo es', () {
      expect(Validators.correo('alguien'), isNotNull);
      expect(Validators.correo('alguien@'), isNotNull);
      expect(Validators.correo('alguien@dominio'), isNotNull);
    });
  });

  group('Validators.promedio', () {
    test('acepta el rango del SAES', () {
      expect(Validators.promedio('8.47'), isNull);
      expect(Validators.promedio('10'), isNull);
      expect(Validators.promedio('8,47'), isNull); // con coma también
    });

    test('rechaza fuera de rango', () {
      expect(Validators.promedio('11'), contains('0 a 10'));
      expect(Validators.promedio('-1'), contains('0 a 10'));
    });

    test('rechaza lo que no es número', () {
      expect(Validators.promedio('ocho'), isNotNull);
    });
  });

  group('Validators.codigoPostal', () {
    test('pide exactamente 5 dígitos', () {
      expect(Validators.codigoPostal('98718'), isNull);
      expect(Validators.codigoPostal('9871'), isNotNull);
      expect(Validators.codigoPostal('987180'), isNotNull);
    });
  });
}
