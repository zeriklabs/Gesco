import 'package:flutter_test/flutter_test.dart';
import 'package:gesco/core/utils/curp.dart';

/// CURP sintéticos: están construidos para que cuadre el dígito verificador,
/// pero no corresponden a ninguna persona. No metas CURP reales aquí — el
/// repositorio es público.
const curpZacatecas = 'PEGA900215HZSRRL08';
const curpCdmx2005 = 'LOMA050330MDFPRSA1';
const curpJalisco = 'ROVE991112HJCDRD58';

void main() {
  group('Curp.esValido', () {
    test('acepta CURP bien formados', () {
      expect(Curp.esValido(curpZacatecas), isTrue);
      expect(Curp.esValido(curpCdmx2005), isTrue);
      expect(Curp.esValido(curpJalisco), isTrue);
    });

    test('normaliza minúsculas y espacios', () {
      expect(Curp.esValido('  ${curpZacatecas.toLowerCase()} '), isTrue);
    });

    test('rechaza longitud incorrecta', () {
      expect(Curp.esValido('PEGA900215HZSRRL0'), isFalse);
      expect(Curp.esValido('PEGA900215HZSRRL089'), isFalse);
      expect(Curp.esValido(''), isFalse);
    });

    test('rechaza un dígito verificador que no cuadra', () {
      // Mismo CURP con el último dígito cambiado.
      expect(Curp.esValido('PEGA900215HZSRRL09'), isFalse);
    });

    test('rechaza entidades que no existen', () {
      expect(Curp.esValido('PEGA900215HXXRRL08'), isFalse);
    });

    test('rechaza fechas imposibles', () {
      expect(Curp.esValido('PEGA900231HZSRRL08'), isFalse); // 31 de febrero
      expect(Curp.esValido('PEGA901315HZSRRL08'), isFalse); // mes 13
    });
  });

  group('Curp.analizar', () {
    test('saca el RFC de los primeros 10 caracteres', () {
      expect(Curp.analizar(curpZacatecas)!.rfc, 'PEGA900215');
    });

    test('saca el estado de nacimiento', () {
      expect(Curp.analizar(curpZacatecas)!.estadoNacimiento, 'ZACATECAS');
      expect(Curp.analizar(curpCdmx2005)!.estadoNacimiento, 'CIUDAD DE MÉXICO');
      expect(Curp.analizar(curpJalisco)!.estadoNacimiento, 'JALISCO');
    });

    test('resuelve el siglo con el carácter 17', () {
      // Homoclave numérica: nacido en los 1900.
      expect(Curp.analizar(curpZacatecas)!.fechaNacimiento, DateTime(1990, 2, 15));
      // Homoclave alfabética: nacido en los 2000.
      expect(Curp.analizar(curpCdmx2005)!.fechaNacimiento, DateTime(2005, 3, 30));
    });

    test('saca el sexo', () {
      expect(Curp.analizar(curpZacatecas)!.esHombre, isTrue);
      expect(Curp.analizar(curpCdmx2005)!.esHombre, isFalse);
    });

    test('devuelve null cuando el CURP no sirve', () {
      expect(Curp.analizar('no es un curp'), isNull);
    });
  });

  group('CurpData.edadAl', () {
    final datos = Curp.analizar(curpZacatecas)!; // 15 de febrero de 1990

    test('cuenta los años cumplidos', () {
      expect(datos.edadAl(DateTime(2026, 9, 24)), 36);
    });

    test('no cuenta el cumpleaños que todavía no llega', () {
      expect(datos.edadAl(DateTime(2026, 2, 14)), 35);
      expect(datos.edadAl(DateTime(2026, 2, 15)), 36);
    });
  });
}
