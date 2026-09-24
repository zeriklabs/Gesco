import 'package:flutter/widgets.dart';

import '../../core/utils/curp.dart';

/// Todo lo que el alumno captura durante el alta.
///
/// Vive en `RegistroScreen` y se le presta a cada paso. Así los datos
/// sobreviven cuando el alumno va y viene entre pasos, y cada pantalla de
/// paso puede ser un widget chico que no sabe nada de las demás.
///
/// Cuando haya backend, esto es lo que se serializa y se manda.
class RegistroDatos {
  // --- Paso 1: cuenta ------------------------------------------------------
  final boleta = TextEditingController();
  final correo = TextEditingController();
  final password = TextEditingController();
  final passwordConfirmar = TextEditingController();
  bool aceptaAviso = false;

  // --- Paso 2: verificación ------------------------------------------------
  final codigo = TextEditingController();

  // --- Paso 3: datos personales -------------------------------------------
  final nombre = TextEditingController();
  final apellidoPaterno = TextEditingController();
  final apellidoMaterno = TextEditingController();
  final curp = TextEditingController();
  String? estadoCivil;
  String? municipioNacimiento;

  final telefonoCelular = TextEditingController();
  final telefonoFijo = TextEditingController();

  final codigoPostal = TextEditingController();
  final colonia = TextEditingController();
  final calle = TextEditingController();
  final numeroExterior = TextEditingController();
  final numeroInterior = TextEditingController();
  String? estado;
  String? municipio;

  // --- Paso 4: tutor -------------------------------------------------------
  final tutorNombre = TextEditingController();
  final tutorApellidoPaterno = TextEditingController();
  final tutorApellidoMaterno = TextEditingController();
  String? tutorParentesco;
  final tutorOcupacion = TextEditingController();
  final tutorTelefonoCelular = TextEditingController();
  final tutorTelefonoFijo = TextEditingController();
  final tutorTelefonoTrabajo = TextEditingController();

  /// Le ahorra al alumno recapturar siete campos. En el GESCO actual hay que
  /// teclear el domicilio del tutor completo aunque sea el mismo.
  bool tutorMismoDomicilio = true;

  final tutorCalle = TextEditingController();
  final tutorNumeroExterior = TextEditingController();
  final tutorNumeroInterior = TextEditingController();
  final tutorColonia = TextEditingController();
  final tutorCodigoPostal = TextEditingController();
  String? tutorEstado;
  String? tutorMunicipio;

  // --- Paso 5: generales ---------------------------------------------------
  bool trabaja = false;
  final horarioTrabajo = TextEditingController();
  final datosTrabajo = TextEditingController();
  bool visibleParaTutor = false;

  // --- Paso 6: escolares ---------------------------------------------------
  String? carrera;
  String? semestre;
  String? grupo;
  String? situacionAcademica;
  bool cuentaConDictamen = false;
  bool provieneDeBaja = false;
  String? tipoCarga;
  final totalCreditos = TextEditingController();
  final nivelesInscritos = TextEditingController();
  final promedioSaes = TextEditingController();

  // --- Derivados del CURP --------------------------------------------------

  /// Lo que se puede sacar del CURP, o `null` si todavía no es válido.
  CurpData? get derivados => Curp.analizar(curp.text);

  String get rfcDerivado => derivados?.rfc ?? '';

  String get fechaNacimientoDerivada {
    final f = derivados?.fechaNacimiento;
    if (f == null) return '';
    final dd = f.day.toString().padLeft(2, '0');
    final mm = f.month.toString().padLeft(2, '0');
    return '$dd-$mm-${f.year}';
  }

  String get estadoNacimientoDerivado => derivados?.estadoNacimiento ?? '';

  String get edadDerivada {
    final d = derivados;
    if (d == null) return '';
    final anios = d.edadAl(DateTime.now());
    return '$anios ${anios == 1 ? 'año' : 'años'}';
  }

  /// Cuántos campos se llenaron solos. Se muestra al alumno: es el argumento
  /// de por qué esto es mejor que capturar todo a mano.
  int get camposAutocompletados {
    var n = 0;
    if (derivados != null) n += 4; // RFC, fecha, edad, estado de nacimiento
    if (municipio != null && codigoPostal.text.length == 5) n += 2;
    if (tutorMismoDomicilio) n += 7;
    return n;
  }

  /// El domicilio del tutor, resuelto: si comparte el del alumno, se copia.
  void sincronizarDomicilioTutor() {
    if (!tutorMismoDomicilio) return;
    tutorCalle.text = calle.text;
    tutorNumeroExterior.text = numeroExterior.text;
    tutorNumeroInterior.text = numeroInterior.text;
    tutorColonia.text = colonia.text;
    tutorCodigoPostal.text = codigoPostal.text;
    tutorEstado = estado;
    tutorMunicipio = municipio;
  }

  String get domicilioResumido {
    final partes = [
      if (calle.text.isNotEmpty) calle.text,
      if (numeroExterior.text.isNotEmpty) numeroExterior.text,
      if (colonia.text.isNotEmpty) colonia.text,
      if (municipio != null) municipio!,
    ];
    return partes.isEmpty ? 'Sin capturar' : partes.join(', ');
  }

  void dispose() {
    for (final c in [
      boleta, correo, password, passwordConfirmar, codigo,
      nombre, apellidoPaterno, apellidoMaterno, curp,
      telefonoCelular, telefonoFijo,
      codigoPostal, colonia, calle, numeroExterior, numeroInterior,
      tutorNombre, tutorApellidoPaterno, tutorApellidoMaterno,
      tutorOcupacion, tutorTelefonoCelular, tutorTelefonoFijo,
      tutorTelefonoTrabajo,
      tutorCalle, tutorNumeroExterior, tutorNumeroInterior, tutorColonia,
      tutorCodigoPostal,
      horarioTrabajo, datosTrabajo,
      totalCreditos, nivelesInscritos, promedioSaes,
    ]) {
      c.dispose();
    }
  }
}
