import '../models/dictamen.dart';

/// Datos de ejemplo del Consejo Técnico.
///
/// TODO(backend): desaparece cuando exista la API.
///
/// Los textos son los del sistema real, **convertidos a plantilla**: donde
/// decían "27/1" o "ENERO 2027" ahora va una variable. Es el único cambio;
/// la redacción es la que ya aprobó el Consejo y no se toca a la ligera.
abstract final class DatosDemoConsejo {
  static final periodoActivo = Periodo.deTexto('27/1');

  static final textos = <TextoDictamen>[
    const TextoDictamen(
      id: 'solo-recursar-1',
      titulo: 'Solo recursar (1 p.e.)',
      plantilla:
          'SE LE AUTORIZA PRESENTAR SU(S) ADEUDO(S), EN EL PERIODO DE E.T.S. '
          'DE {ets_enero}. RECURSAR SU(S) ADEUDO(S) NO RECURSADOS PREVIAMENTE '
          'EN LA MISMA MODALIDAD EDUCATIVA, EN EL PERIODO ESCOLAR {periodo}. '
          'DE ACREDITAR SU(S) ADEUDO(S) DESFASADO(S), PROCEDE SU '
          'REINSCRIPCIÓN A LA(S) UNIDAD(ES) DE APRENDIZAJE QUE LE CORRESPONDE '
          'CURSAR EN EL PERIODO ESCOLAR {periodo_sig}. DE NO CUMPLIR CAUSARÁ '
          'BAJA DEFINITIVA DE LA MODALIDAD EDUCATIVA DEL PROGRAMA '
          'CORRESPONDIENTE.',
    ),
    const TextoDictamen(
      id: 'solo-recursar-2',
      titulo: 'Solo recursar (2 p.e.)',
      plantilla:
          'SE LE AUTORIZA PRESENTAR SU(S) ADEUDO(S), EN EL PERIODO DE E.T.S. '
          'DE {ets_enero} Y/O {ets_julio}. RECURSAR SU(S) ADEUDO(S) NO '
          'RECURSADOS PREVIAMENTE EN LA MISMA MODALIDAD EDUCATIVA, EN EL '
          'PERIODO ESCOLAR {periodo} O {periodo_sig}. DE ACREDITAR SU(S) '
          'ADEUDO(S) DESFASADO(S), PROCEDE SU REINSCRIPCIÓN A LA(S) UNIDAD(ES) '
          'DE APRENDIZAJE QUE LE CORRESPONDE CURSAR EN EL PERIODO ESCOLAR '
          '{periodo_sig} O {periodo_sig2}. DE NO CUMPLIR CAUSARÁ BAJA '
          'DEFINITIVA DE LA MODALIDAD EDUCATIVA DEL PROGRAMA CORRESPONDIENTE.',
    ),
    const TextoDictamen(
      id: 'reinscripcion-extemporanea',
      titulo: 'Reinscripción extemporánea',
      plantilla:
          'SE LE AUTORIZA LA REINSCRIPCIÓN EXTEMPORÁNEA AL NIVEL QUE LE '
          'CORRESPONDA CURSAR, EN EL PERIODO ESCOLAR {periodo}, SEGÚN SU '
          'SITUACIÓN ACADÉMICA TOMANDO EN CUENTA LA SERIACIÓN EN LOS CASOS QUE '
          'CORRESPONDA, LO ANTERIOR SI LA OFERTA Y EL CUPO LO PERMITEN. SI HAY '
          'REINCIDENCIA SE DARÁ BAJA POR UN PERIODO ESCOLAR.',
    ),
    const TextoDictamen(
      id: 'debajo-minima-1',
      titulo: 'Inscripción por debajo de la mínima (1 p.e.)',
      plantilla:
          'SE LE AUTORIZA LA REINSCRIPCIÓN AL NIVEL QUE LE CORRESPONDA CURSAR, '
          'EN EL PERIODO ESCOLAR {periodo} CON LA CARGA DE CRÉDITOS POR DEBAJO '
          'DE LA MÍNIMA. PRESENTAR SU(S) ADEUDO(S), EN EL PERIODO DE E.T.S. DE '
          '{ets_enero}. RECURSAR SU(S) ADEUDO(S) NO RECURSADOS PREVIAMENTE EN '
          'LA MISMA MODALIDAD EDUCATIVA, EN EL PERIODO ESCOLAR {periodo}. DE '
          'NO CUMPLIR CAUSARÁ BAJA DEFINITIVA DE LA MODALIDAD EDUCATIVA DEL '
          'PROGRAMA CORRESPONDIENTE.',
    ),
    const TextoDictamen(
      id: 'debajo-minima-2',
      titulo: 'Inscripción por debajo de la mínima (2 p.e.)',
      plantilla:
          'SE LE AUTORIZA LA REINSCRIPCIÓN AL NIVEL QUE LE CORRESPONDA CURSAR, '
          'EN EL PERIODO ESCOLAR {periodo} O {periodo_sig} CON LA CARGA DE '
          'CRÉDITOS POR DEBAJO DE LA MÍNIMA. PRESENTAR SU(S) ADEUDO(S), EN EL '
          'PERIODO DE E.T.S. DE {ets_enero} Y/O {ets_julio}. RECURSAR SU(S) '
          'ADEUDO(S) NO RECURSADOS PREVIAMENTE EN LA MISMA MODALIDAD '
          'EDUCATIVA, EN EL PERIODO ESCOLAR {periodo} O {periodo_sig}. DE NO '
          'CUMPLIR CAUSARÁ BAJA DEFINITIVA DE LA MODALIDAD EDUCATIVA DEL '
          'PROGRAMA CORRESPONDIENTE.',
    ),
    const TextoDictamen(
      id: 'recursa-avanza-1',
      titulo: 'Recursa y avanza carga media (1 p.e.)',
      plantilla:
          'SE LE AUTORIZA PRESENTAR SU(S) ADEUDO(S), EN EL PERIODO DE E.T.S. '
          'DE {ets_enero}. RECURSAR SU(S) ADEUDO(S) NO RECURSADOS PREVIAMENTE '
          'EN LA MISMA MODALIDAD EDUCATIVA, EN EL PERIODO ESCOLAR {periodo}. '
          'PROCEDE REINSCRIPCIÓN A LA(S) UNIDADES DE APRENDIZAJE, QUE LE '
          'CORRESPONDE CURSAR EN EL PERIODO ESCOLAR {periodo} SI SE OFERTA, '
          'SIN EXCEDER DE LA CARGA MEDIA ESTABLECIDA EN EL PLAN DE ESTUDIOS. '
          'DE ACREDITAR SU(S) ADEUDO(S) DESFASADO(S), PROCEDE SU REINSCRIPCIÓN '
          'A LA(S) UNIDAD(ES) DE APRENDIZAJE QUE LE CORRESPONDE CURSAR EN EL '
          'PERIODO ESCOLAR {periodo_sig}. DE NO CUMPLIR CAUSARÁ BAJA '
          'DEFINITIVA DE LA MODALIDAD EDUCATIVA DEL PROGRAMA CORRESPONDIENTE.',
    ),
    const TextoDictamen(
      id: 'recursa-avanza-2',
      titulo: 'Recursa y avanza carga media (2 p.e.)',
      plantilla:
          'SE LE AUTORIZA PRESENTAR SU(S) ADEUDO(S), EN EL PERIODO DE E.T.S. '
          'DE {ets_enero} Y/O {ets_julio}. RECURSAR SU(S) ADEUDO(S) NO '
          'RECURSADOS PREVIAMENTE EN LA MISMA MODALIDAD EDUCATIVA, EN EL '
          'PERIODO ESCOLAR {periodo} Y/O {periodo_sig}. PROCEDE REINSCRIPCIÓN '
          'A LA(S) UNIDADES DE APRENDIZAJE, QUE LE CORRESPONDE CURSAR EN EL '
          'PERIODO ESCOLAR {periodo} Y/O {periodo_sig} SI SE OFERTA, SIN '
          'EXCEDER DE LA CARGA MEDIA ESTABLECIDA EN EL PLAN DE ESTUDIOS. DE '
          'ACREDITAR SU(S) ADEUDO(S) DESFASADO(S), PROCEDE SU REINSCRIPCIÓN A '
          'LA(S) UNIDAD(ES) DE APRENDIZAJE QUE LE CORRESPONDE CURSAR EN EL '
          'PERIODO ESCOLAR {periodo_sig} Y/O {periodo_sig2}. DE NO CUMPLIR '
          'CAUSARÁ BAJA DEFINITIVA DE LA MODALIDAD EDUCATIVA DEL PROGRAMA '
          'CORRESPONDIENTE.',
    ),
    const TextoDictamen(
      id: 'ets-recursar-1',
      titulo: 'E.T.S. y recursar (1 p.e.)',
      plantilla:
          'SE LE AUTORIZA PRESENTAR SU(S) ADEUDO(S), EN EL PERIODO DE E.T.S. '
          'DE {ets_julio}. RECURSAR SU(S) ADEUDO(S) NO RECURSADOS PREVIAMENTE '
          'EN LA MISMA MODALIDAD EDUCATIVA, EN EL PERIODO ESCOLAR {periodo}. '
          'DE NO CUMPLIR CAUSARÁ BAJA DEFINITIVA DE LA MODALIDAD EDUCATIVA DEL '
          'PROGRAMA CORRESPONDIENTE.',
    ),
    const TextoDictamen(
      id: 'sd',
      titulo: 'Sin dictamen (s/d)',
      plantilla:
          'LA SITUACIÓN ACADÉMICA NO APLICA PARA LA COSIE DEL CTCE, POR LO QUE '
          'PUEDE INSCRIBIRSE AL PERIODO ESCOLAR QUE LE CORRESPONDA.',
    ),
    const TextoDictamen(
      id: 'cosie-cg',
      titulo: 'Se turna a COSIE CG',
      plantilla:
          'SE MANDA A LA COMISIÓN DE SITUACIÓN ESCOLAR DEL CONSEJO GENERAL '
          'CONSULTIVO (COSIE CG). REVISAR DOCUMENTACIÓN A ENTREGAR.',
    ),
  ];

  static TextoDictamen? texto(String? id) {
    if (id == null) return null;
    for (final t in textos) {
      if (t.id == id) return t;
    }
    return null;
  }

  static void guardarTexto(TextoDictamen texto) {
    final i = textos.indexWhere((t) => t.id == texto.id);
    if (i != -1) textos[i] = texto;
  }

  static var sesion = const SesionConsejo(
    numeroConsejo: 'XI',
    fechaSesion: '08 DE SEPTIEMBRE DE 2026',
    numeroSesion: 'SEGUNDA SESIÓN EXTRAORDINARIA',
    numeroAbreviado: '2DA. EXT.',
    presidente: 'M. EN C. NOMBRE DEL PRESIDENTE',
    secretario: 'M.I.S. NOMBRE DEL SECRETARIO',
  );

  /// Los casos del consejo. Todos inventados.
  static final casos = <CasoConsejo>[
    CasoConsejo(
      boleta: '2024670011',
      nombre: 'LUGO ZAVALA MAXIMILIANO',
      carrera: 'ING. EN SISTEMAS COMPUTACIONALES',
      etapa: EtapaPredictamen.solicito,
      materiasAdeudadas: const ['CÁLCULO VECTORIAL'],
      solicitadoEl: DateTime(2026, 10, 9),
    ),
    CasoConsejo(
      boleta: '2025670012',
      nombre: 'VALDÉS GARCÍA OMAR',
      carrera: 'ING. MECATRÓNICA',
      etapa: EtapaPredictamen.solicito,
      materiasAdeudadas: const ['ÁLGEBRA LINEAL Y NÚMEROS COMPLEJOS'],
      solicitadoEl: DateTime(2026, 10, 13),
    ),
    CasoConsejo(
      boleta: '2026670013',
      nombre: 'MANZANARES MONREAL RODRIGO',
      carrera: 'ING. MECATRÓNICA',
      etapa: EtapaPredictamen.entregoDocumentos,
      documentos: const [
        'oficio_cosie',
        'solicitud_dictamen',
        'boleta saes',
        'estado general SAES',
      ],
      materiasAdeudadas: const [
        'ECUACIONES DIFERENCIALES',
        'ELECTRICIDAD Y MAGNETISMO',
      ],
      solicitadoEl: DateTime(2026, 10, 6),
    ),
    CasoConsejo(
      boleta: '2026670014',
      nombre: 'BAEZA MORALES JESHUA',
      carrera: 'ING. EN INTELIGENCIA ARTIFICIAL',
      etapa: EtapaPredictamen.entregoDocumentos,
      documentos: const [
        'oficio_cosie',
        'solicitud_dictamen',
        'boleta saes',
        'documentoscomprobatorios',
        'estado general SAES',
      ],
      materiasAdeudadas: const ['MATEMÁTICAS DISCRETAS'],
      periodosEnDictamen: 2,
      solicitadoEl: DateTime(2026, 10, 2),
    ),
    CasoConsejo(
      boleta: '2024670015',
      nombre: 'OVIEDO CAMPOS JOSÉ',
      carrera: 'ING. MECATRÓNICA',
      etapa: EtapaPredictamen.dictaminado,
      documentos: const ['oficio_cosie', 'solicitud_dictamen', 'boleta saes'],
      materiasAdeudadas: const ['ESTÁTICA'],
      textoId: 'solo-recursar-1',
      nota3: 'PRIMER DICTAMEN POR: ESTÁTICA.',
      solicitadoEl: DateTime(2026, 9, 28),
    ),
    CasoConsejo(
      boleta: '2026670016',
      nombre: 'OLAGUE HERNÁNDEZ FRANCISCO',
      carrera: 'ING. METALÚRGICA',
      etapa: EtapaPredictamen.dictaminado,
      documentos: const ['oficio_cosie', 'solicitud_dictamen', 'boleta saes'],
      materiasAdeudadas: const [],
      textoId: 'debajo-minima-1',
      nota3: '',
      solicitadoEl: DateTime(2026, 9, 25),
    ),
  ];

  static List<CasoConsejo> porEtapa(EtapaPredictamen etapa) =>
      casos.where((c) => c.etapa == etapa).toList();

  static void guardarCaso(CasoConsejo caso) {
    final i = casos.indexWhere((c) => c.boleta == caso.boleta);
    if (i != -1) casos[i] = caso;
  }
}
