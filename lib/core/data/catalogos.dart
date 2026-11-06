import 'municipios.dart';

/// Listas de los desplegables.
///
/// Van separadas en dos grupos a propósito:
///
/// - **Confirmadas**: las vi en las capturas del GESCO actual o salen de una
///   norma (las entidades del CURP, por ejemplo).
/// - **Por confirmar**: las armé por deducción. Antes de liberar hay que
///   validarlas con Gestión Escolar, porque si una carrera o un grupo no
///   existe, el trámite se cae en ventanilla y el alumno no se entera hasta
///   que va.
///
/// Cuando haya backend, casi todas deberían venir de la API en vez de estar
/// escritas aquí: los grupos y los periodos cambian cada semestre.
abstract final class Catalogos {
  // === Confirmadas =========================================================

  /// Las 32 entidades más "nacido en el extranjero", igual que el CURP.
  static const estados = <String>[
    'AGUASCALIENTES', 'BAJA CALIFORNIA', 'BAJA CALIFORNIA SUR', 'CAMPECHE',
    'CHIAPAS', 'CHIHUAHUA', 'CIUDAD DE MÉXICO', 'COAHUILA', 'COLIMA',
    'DURANGO', 'GUANAJUATO', 'GUERRERO', 'HIDALGO', 'JALISCO', 'MÉXICO',
    'MICHOACÁN', 'MORELOS', 'NAYARIT', 'NUEVO LEÓN', 'OAXACA', 'PUEBLA',
    'QUERÉTARO', 'QUINTANA ROO', 'SAN LUIS POTOSÍ', 'SINALOA', 'SONORA',
    'TABASCO', 'TAMAULIPAS', 'TLAXCALA', 'VERACRUZ', 'YUCATÁN', 'ZACATECAS',
    'NACIDO EN EL EXTRANJERO',
  ];

  static const estadoCivil = <String>[
    'SOLTERO', 'CASADO', 'UNIÓN LIBRE', 'DIVORCIADO', 'VIUDO',
  ];

  static const parentesco = <String>[
    'MADRE', 'PADRE', 'ABUELO(A)', 'HERMANO(A)', 'TÍO(A)', 'CÓNYUGE', 'OTRO',
  ];

  /// Diez niveles. El GESCO actual los muestra como "8VO".
  static const semestres = <String>[
    '1RO', '2DO', '3RO', '4TO', '5TO', '6TO', '7MO', '8VO', '9NO', '10MO',
  ];

  // === Por confirmar con Gestión Escolar ===================================

  /// Programas académicos ofertados en la UPIIZ - IPN.
  static const carreras = <String>[
    'ING. EN SISTEMAS COMPUTACIONALES',
    'ING. AMBIENTAL',
    'ING. MECATRÓNICA',
    'ING. EN ALIMENTOS',
    'ING. METALÚRGICA',
    'ING. EN INTELIGENCIA ARTIFICIAL',
  ];

  /// Límite máximo de semestres permitidos por programa académico (configurable por el administrador).
  static const _semestresMaximosPorCarrera = <String, int>{
    'ING. EN SISTEMAS COMPUTACIONALES': 10,
    'ING. AMBIENTAL': 10,
    'ING. MECATRÓNICA': 10,
    'ING. EN ALIMENTOS': 10,
    'ING. METALÚRGICA': 10,
    'ING. EN INTELIGENCIA ARTIFICIAL': 10,
  };

  /// Devuelve los semestres máximos permitidos para la carrera especificada.
  static int semestresMaximosDe(String? carrera) {
    if (carrera == null || carrera.isEmpty) return 10;
    return _semestresMaximosPorCarrera[carrera] ?? 10;
  }

  /// Planes de estudio correspondientes a cada carrera (ej. Sistemas 2020, Ambiental 2009).
  static List<String> planesDe(String? carrera) {
    if (carrera == null || carrera.isEmpty) {
      return const ['PLAN 2020', 'PLAN 2009'];
    }
    if (carrera.contains('SISTEMAS')) {
      return const ['SISTEMAS 2020', 'SISTEMAS 2009'];
    }
    if (carrera.contains('AMBIENTAL')) {
      return const ['AMBIENTAL 2009', 'AMBIENTAL 2020'];
    }
    if (carrera.contains('MECATRÓNICA')) {
      return const ['MECATRÓNICA 2020', 'MECATRÓNICA 2009'];
    }
    if (carrera.contains('ALIMENTOS')) {
      return const ['ALIMENTOS 2020', 'ALIMENTOS 2009'];
    }
    if (carrera.contains('METALÚRGICA')) {
      return const ['METALÚRGICA 2020', 'METALÚRGICA 2009'];
    }
    return const ['PLAN 2020', 'PLAN 2009'];
  }

  /// TODO(gescolar): confirmar el catálogo. En las capturas aparecieron
  /// 1CM1, 1MM1, 3CM1, 8CM1 y 9CM1 — el patrón parece ser
  /// <nivel><carrera><turno><número>, pero no está documentado.
  ///
  /// Esto debería venir de la API: los grupos cambian cada periodo.
  static const grupos = <String>[
    '1CM1', '2CM1', '3CM1', '4CM1', '5CM1', '6CM1', '7CM1', '8CM1', '9CM1',
    '1MM1', '2MM1', '3MM1',
  ];

  /// TODO(gescolar): confirmar. De las capturas solo salió "ALUMNO REGULAR".
  static const situacionAcademica = <String>[
    'ALUMNO REGULAR',
    'ALUMNO IRREGULAR',
    'ALUMNO CON DICTAMEN',
    'REINGRESO',
  ];

  static const tipoCarga = <String>[
    'Debajo de la mínima',
    'Mínima',
    'Por encima de la mínima',
    'Debajo de la media',
    'Media',
    'Por encima de la media',
    'Máxima',
  ];

  /// Los tres niveles del plan de estudios del IPN.
  static const niveles = <String>['NIVEL I', 'NIVEL II', 'NIVEL III'];

  /// Cómo va a cursar la unidad que debe.
  ///
  /// TODO(gescolar): confirmar. El campo "estado" del formulario de adeudos
  /// aparece en las capturas, pero no se alcanzaron a ver todas sus opciones.
  static const estadosAdeudo = <String>[
    'NORMAL',
    'RECURSAMIENTO',
    'ETS',
    'SIN CURSAR',
  ];

  /// Periodos escolares para capturar "en qué periodo la reprobé".
  ///
  /// Se generan hacia atrás desde el periodo actual: nadie reprobó algo en un
  /// periodo que todavía no ocurre. Ocho años cubren cualquier caso real,
  /// incluido el de quien va a dictamen por exceder el tiempo reglamentario.
  static List<String> periodosHasta(String actual, {int anios = 8}) {
    final partes = actual.split('/');
    final anio = int.tryParse(partes.first) ?? 27;
    final semestre = int.tryParse(partes.last) ?? 1;

    final lista = <String>[];
    var a = anio;
    var s = semestre;
    for (var i = 0; i < anios * 2; i++) {
      lista.add('${a.toString().padLeft(2, '0')}/$s');
      if (s == 1) {
        s = 2;
        a -= 1;
      } else {
        s = 1;
      }
    }
    return lista;
  }

  /// La documentación soporte de la baja de la escuela.
  ///
  /// En el sistema actual son **once preguntas de sí/no**: veintidós controles
  /// para decir "ninguna". Aquí es una selección múltiple.
  ///
  /// TODO(gescolar): confirmar la lista contra el formato vigente.
  static const motivosBajaEscuela = <String>[
    'Cambio de domicilio',
    'Enfermedad de un hijo',
    'Enfermedad de los padres',
    'Enfermedad de un familiar',
    'Enfermedad propia',
    'Enfermedad del cónyuge',
    'Problemas económicos',
    'Problemas familiares',
    'Trabajo u horario incompatible',
    'Oficio de aceptación de otra unidad o programa académico',
    'Otro',
  ];

  /// Por qué el alumno acude a la Comisión de Situación Escolar.
  ///
  /// TODO(gescolar): el catálogo real está en el desplegable de la solicitud de
  /// dictamen; en las capturas no se alcanzó a leer completo. Estas son las
  /// causas que contempla el reglamento, pero hay que confirmarlas: una causa
  /// mal elegida cambia el dictamen que emite la comisión.
  static const causasCosie = <String>[
    'Agotó las oportunidades para acreditar una unidad de aprendizaje',
    'Excedió el tiempo reglamentario para concluir el programa',
    'No cumple con la carga mínima de créditos',
    'Solicita reingreso después de una baja',
    'Otra',
  ];

  /// Qué lo dejó fuera del reglamento.
  ///
  /// TODO(gescolar): mismo caso que [causasCosie], confirmar contra el sistema.
  static const motivosFueraReglamento = <String>[
    'Reprobó unidades de aprendizaje',
    'Problemas de salud',
    'Problemas económicos',
    'Problemas familiares',
    'Trabajo u horario incompatible',
    'Otra',
  ];

  static final Map<String, List<String>> _municipiosCache = {};

  /// Los municipios que corresponden a un estado.
  static List<String> municipiosDe(String? estado) {
    if (estado == null) return const <String>[];
    return _municipiosCache.putIfAbsent(estado, () {
      final lista = municipiosPorEstado[estado];
      if (lista != null) {
        return [...lista, 'OTRO'];
      }
      return const <String>[];
    });
  }
}
