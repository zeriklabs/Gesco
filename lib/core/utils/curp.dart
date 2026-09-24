/// Lo que se puede deducir de un CURP.
///
/// El GESCO actual pide por separado el RFC, la fecha de nacimiento y el estado
/// de nacimiento, aunque los tres ya vienen dentro del CURP. Pedirlos a mano
/// solo abre la puerta a que no coincidan.
class CurpData {
  const CurpData({
    required this.rfc,
    required this.fechaNacimiento,
    required this.estadoNacimiento,
    required this.esHombre,
  });

  /// Los primeros 10 caracteres del CURP.
  ///
  /// Ojo: es el RFC **sin homoclave**. Los tres caracteres finales los asigna
  /// el SAT y no se pueden derivar. Si la solicitud necesita el RFC completo,
  /// el alumno tiene que completarlo.
  final String rfc;

  final DateTime fechaNacimiento;

  /// Nombre del estado, en mayúsculas, como lo espera el formato impreso.
  final String estadoNacimiento;

  final bool esHombre;

  int edadAl(DateTime fecha) {
    var edad = fecha.year - fechaNacimiento.year;
    final cumpleAunNoLlega = fecha.month < fechaNacimiento.month ||
        (fecha.month == fechaNacimiento.month && fecha.day < fechaNacimiento.day);
    if (cumpleAunNoLlega) edad--;
    return edad;
  }
}

abstract final class Curp {
  static final _formato = RegExp(
    r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]\d$',
  );

  /// Tabla del dígito verificador. El orden importa: la Ñ va después de la N.
  static const _alfabeto = '0123456789ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';

  static const _entidades = <String, String>{
    'AS': 'AGUASCALIENTES',
    'BC': 'BAJA CALIFORNIA',
    'BS': 'BAJA CALIFORNIA SUR',
    'CC': 'CAMPECHE',
    'CL': 'COAHUILA',
    'CM': 'COLIMA',
    'CS': 'CHIAPAS',
    'CH': 'CHIHUAHUA',
    'DF': 'CIUDAD DE MÉXICO',
    'DG': 'DURANGO',
    'GT': 'GUANAJUATO',
    'GR': 'GUERRERO',
    'HG': 'HIDALGO',
    'JC': 'JALISCO',
    'MC': 'MÉXICO',
    'MN': 'MICHOACÁN',
    'MS': 'MORELOS',
    'NT': 'NAYARIT',
    'NL': 'NUEVO LEÓN',
    'OC': 'OAXACA',
    'PL': 'PUEBLA',
    'QT': 'QUERÉTARO',
    'QR': 'QUINTANA ROO',
    'SP': 'SAN LUIS POTOSÍ',
    'SL': 'SINALOA',
    'SR': 'SONORA',
    'TC': 'TABASCO',
    'TS': 'TAMAULIPAS',
    'TL': 'TLAXCALA',
    'VZ': 'VERACRUZ',
    'YN': 'YUCATÁN',
    'ZS': 'ZACATECAS',
    'NE': 'NACIDO EN EL EXTRANJERO',
  };

  static String normalizar(String valor) =>
      valor.trim().toUpperCase().replaceAll(RegExp(r'\s'), '');

  /// `true` si la estructura y el dígito verificador cuadran.
  static bool esValido(String valor) {
    final curp = normalizar(valor);
    if (curp.length != 18 || !_formato.hasMatch(curp)) return false;
    if (!_entidades.containsKey(curp.substring(11, 13))) return false;
    if (_parseFecha(curp) == null) return false;
    return _digitoVerificador(curp) == curp[17];
  }

  /// Devuelve los datos derivados, o `null` si el CURP no es válido.
  static CurpData? analizar(String valor) {
    final curp = normalizar(valor);
    if (!esValido(curp)) return null;

    return CurpData(
      rfc: curp.substring(0, 10),
      fechaNacimiento: _parseFecha(curp)!,
      estadoNacimiento: _entidades[curp.substring(11, 13)]!,
      esHombre: curp[10] == 'H',
    );
  }

  /// El siglo no está en el CURP: se infiere del carácter 17.
  ///
  /// Hasta 1999 ese carácter era un dígito; a partir del 2000 es una letra.
  /// Es la convención oficial del RENAPO, no una heurística nuestra.
  static DateTime? _parseFecha(String curp) {
    final yy = int.tryParse(curp.substring(4, 6));
    final mm = int.tryParse(curp.substring(6, 8));
    final dd = int.tryParse(curp.substring(8, 10));
    if (yy == null || mm == null || dd == null) return null;
    if (mm < 1 || mm > 12 || dd < 1 || dd > 31) return null;

    final naceEnLos2000 = RegExp(r'[A-Z]').hasMatch(curp[16]);
    final anio = (naceEnLos2000 ? 2000 : 1900) + yy;

    final fecha = DateTime(anio, mm, dd);
    // Atrapa 31 de febrero y compañía: DateTime los recorre al mes siguiente.
    if (fecha.month != mm || fecha.day != dd) return null;
    return fecha;
  }

  static String _digitoVerificador(String curp) {
    var suma = 0;
    for (var i = 0; i < 17; i++) {
      final valor = _alfabeto.indexOf(curp[i]);
      if (valor < 0) return '';
      suma += valor * (18 - i);
    }
    return ((10 - (suma % 10)) % 10).toString();
  }
}
