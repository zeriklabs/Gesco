import 'curp.dart';

/// Validaciones compartidas.
///
/// Devuelven `null` cuando el valor es correcto y un mensaje cuando no, que es
/// justo lo que espera `TextFormField.validator`.
///
/// Los mensajes se escriben en segunda persona y dicen **qué hacer**, no solo
/// qué está mal: "Son 10 dígitos" sirve, "Formato inválido" no.
abstract final class Validators {
  /// Boleta de 10 dígitos: 2023670000.
  static final _boleta = RegExp(r'^\d{10}$');

  /// Preboleta de nuevo ingreso: PE-12345678 (11 caracteres con el guion).
  static final _preboleta = RegExp(r'^PE-?\d{8}$');

  static final _correo = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// Acepta boleta **y** preboleta.
  ///
  /// El proyecto base exigía exactamente 10 caracteres, pero el ejemplo de
  /// preboleta del propio diálogo de ayuda (PE-12345678) tiene 11: ese login
  /// rechazaba a todos los de nuevo ingreso.
  static String? boleta(String? valor) {
    final v = valor?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return 'Escribe tu boleta o preboleta';
    if (_boleta.hasMatch(v) || _preboleta.hasMatch(v)) return null;

    if (RegExp(r'^\d+$').hasMatch(v)) {
      return 'La boleta son 10 dígitos; llevas ${v.length}';
    }
    if (v.startsWith('PE')) {
      return 'La preboleta va como PE-12345678';
    }
    return 'Usa tu boleta (10 dígitos) o tu preboleta (PE-12345678)';
  }

  /// Normaliza para guardar: mayúsculas y con guion si es preboleta.
  static String normalizarBoleta(String valor) {
    final v = valor.trim().toUpperCase().replaceAll(' ', '');
    if (RegExp(r'^PE\d{8}$').hasMatch(v)) {
      return 'PE-${v.substring(2)}';
    }
    return v;
  }

  static bool esPreboleta(String valor) =>
      _preboleta.hasMatch(valor.trim().toUpperCase());

  static String? requerido(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  static String? correo(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Escribe tu correo';
    if (!_correo.hasMatch(v)) return 'Revisa el correo: falta el @ o el dominio';
    return null;
  }

  static String? contrasena(String? valor) {
    final v = valor ?? '';
    if (v.isEmpty) return 'Escribe tu contraseña';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-ZÁÉÍÓÚÑ]').hasMatch(v)) return 'Agrega al menos una mayúscula';
    if (!RegExp(r'\d').hasMatch(v)) return 'Agrega al menos un número';
    return null;
  }

  static String? confirmarContrasena(String? valor, String original) {
    if (valor != original) return 'Las contraseñas no coinciden';
    return null;
  }

  /// Teléfono a 10 dígitos, ignorando guiones y espacios.
  static String? telefono(String? valor, {bool obligatorio = true}) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return obligatorio ? 'Escribe el teléfono' : null;
    final digitos = v.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 10) {
      return 'Faltan dígitos: son 10 en total, llevas ${digitos.length}';
    }
    return null;
  }

  static String? curp(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Escribe tu CURP';
    final normalizado = Curp.normalizar(v);
    if (normalizado.length != 18) {
      return 'El CURP son 18 caracteres; llevas ${normalizado.length}';
    }
    if (!Curp.esValido(normalizado)) {
      return 'Ese CURP no es válido. Revísalo contra tu documento';
    }
    return null;
  }

  static String? codigoPostal(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Escribe tu código postal';
    if (!RegExp(r'^\d{5}$').hasMatch(v)) return 'El código postal son 5 dígitos';
    return null;
  }

  /// Promedio del SAES: entre 0 y 10, con hasta dos decimales.
  static String? promedio(String? valor) {
    final v = valor?.trim().replaceAll(',', '.') ?? '';
    if (v.isEmpty) return 'Escribe tu promedio';
    final n = double.tryParse(v);
    if (n == null) return 'Escribe un número, por ejemplo 8.47';
    if (n < 0 || n > 10) return 'El promedio va de 0 a 10';
    return null;
  }

  static String? entero(
    String? valor, {
    String campo = 'Este campo',
    int min = 0,
    int? max,
  }) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return '$campo es obligatorio';
    final n = int.tryParse(v);
    if (n == null) return 'Escribe un número entero';
    if (n < min) return 'No puede ser menor que $min';
    if (max != null && n > max) return 'No puede ser mayor que $max';
    return null;
  }
}
