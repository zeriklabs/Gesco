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

  /// TODO(gescolar): de las capturas solo salió Ingeniería en Sistemas
  /// Computacionales. Falta la lista completa de programas de la UPIIZ.
  static const carreras = <String>[
    'ING. EN SISTEMAS COMPUTACIONALES',
  ];

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

  /// TODO(gescolar): confirmar. De las capturas salió
  /// "POR DEBAJO DE LA MÍNIMA".
  static const tipoCarga = <String>[
    'CARGA COMPLETA',
    'POR DEBAJO DE LA MÍNIMA',
    'POR ENCIMA DE LA MÁXIMA',
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

  /// Municipios de Zacatecas. Los de otros estados los tendría que dar la API.
  ///
  /// TODO(gescolar): idealmente el código postal resuelve colonia, municipio y
  /// estado contra el catálogo de SEPOMEX, y esta lista desaparece.
  static const municipiosZacatecas = <String>[
    'ZACATECAS', 'GUADALUPE', 'FRESNILLO', 'JEREZ', 'OJOCALIENTE',
    'CALERA', 'SOMBRERETE', 'RÍO GRANDE', 'LORETO', 'PINOS',
    'VILLANUEVA', 'NOCHISTLÁN', 'TLALTENANGO', 'JUCHIPILA', 'OTRO',
  ];

  /// Los municipios que corresponden a un estado.
  static List<String> municipiosDe(String? estado) {
    if (estado == 'ZACATECAS') return municipiosZacatecas;
    // Fuera de Zacatecas todavía no hay catálogo; se deja capturar libre.
    return const <String>[];
  }
}
