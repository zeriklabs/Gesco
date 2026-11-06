import '../../widgets/status_pill.dart';
import '../models/revision.dart';

/// Datos de ejemplo del lado administrativo.
///
/// TODO(backend): desaparece cuando exista la API.
///
/// **Todo es inventado.** Las capturas del sistema real traían nombres,
/// boletas, correos y CURPs de alumnos de verdad; nada de eso está aquí ni
/// debe acabar en el repo.
abstract final class DatosDemoAdmin {
  static const periodoActual = '27/1';
  static const periodoLegible = 'Ago 2026 – Ene 2027';

  static const nombreRevisor = 'Gestión Escolar';

  /// Los 17 documentos del catálogo, con su nombre corto y su descripción.
  ///
  /// La descripción es la que debe verse en pantalla; el nombre corto se
  /// conserva porque es como los nombra la base y como les dice la gente de
  /// ventanilla.
  static const catalogoDocumentos = <(String, String, DirigidoA)>[
    ('donativo', 'Comprobante del donativo', DirigidoA.ambos),
    (
      'pordebajominima',
      'Oficio de dirección · autorización de inscripción por debajo de la mínima',
      DirigidoA.reinscripcion,
    ),
    ('DICTAMENCT', 'Dictamen de COSIE del CT', DirigidoA.reinscripcion),
    ('DictamenCG', 'Dictamen de COSIE del CG', DirigidoA.reinscripcion),
    ('bajatemporal', 'Oficio de baja temporal', DirigidoA.reinscripcion),
    ('horariosaes', 'Comprobante de horario del SAES', DirigidoA.reinscripcion),
    ('DatosSAES', 'Actualización de datos del SAES', DirigidoA.reinscripcion),
    (
      'cambio_programa_academico',
      'Documentos de cambio de programa académico',
      DirigidoA.reinscripcion,
    ),
    ('Inscripcion', 'Documento de inscripción', DirigidoA.nuevoIngreso),
    ('Resultados', 'Hoja de resultados', DirigidoA.nuevoIngreso),
    (
      'consindocumentos',
      'Solicitud de inscripción con o sin documentos',
      DirigidoA.nuevoIngreso,
    ),
    ('curp', 'CURP', DirigidoA.nuevoIngreso),
    ('oficio_cosie', 'Oficio para el consejo', DirigidoA.cosie),
    ('solicitud_dictamen', 'Solicitud de dictamen', DirigidoA.cosie),
    ('boleta saes', 'Boleta global', DirigidoA.cosie),
    ('documentoscomprobatorios', 'Documentos comprobatorios', DirigidoA.cosie),
    ('estado general SAES', 'Estado general del SAES', DirigidoA.cosie),
  ];

  /// Comentarios que el revisor usa una y otra vez.
  ///
  /// Mismo principio que los doce textos del dictamen: lo que se repite se
  /// elige, no se teclea. Quien revisa cuarenta expedientes al día no debería
  /// escribir "el comprobante está a nombre de otra persona" cuarenta veces.
  ///
  /// TODO(gescolar): confirmar la lista con quien revisa. Estos salieron de
  /// las observaciones que se ven en el sistema, no de preguntarle a nadie.
  static const comentariosFrecuentes = <String>[
    'El documento está a nombre de otra persona.',
    'El archivo está incompleto: falta una o más páginas.',
    'No se alcanza a leer. Vuelve a escanearlo o tómale una foto más clara.',
    'Es de un periodo anterior. Sube el del periodo actual.',
    'Le falta la firma.',
    'Subiste un documento que no corresponde a este apartado.',
  ];

  static DocumentoEnRevision _doc(
    String nombreCorto, {
    required EstadoTramite estado,
    String? archivo,
    int? bytes,
    DateTime? subidoEl,
    String? observacionPrevia,
  }) {
    final fila = catalogoDocumentos.firstWhere((d) => d.$1 == nombreCorto);
    return DocumentoEnRevision(
      id: nombreCorto,
      nombreCorto: fila.$1,
      descripcion: fila.$2,
      dirigidoA: fila.$3,
      estado: estado,
      nombreArchivo: archivo,
      bytes: bytes,
      subidoEl: subidoEl,
      observacionPrevia: observacionPrevia,
    );
  }

  /// Los ocho de reinscripción, con el estado que traiga cada uno.
  static List<DocumentoEnRevision> _expedienteReinscripcion({
    Map<String, EstadoTramite> estados = const {},
    Map<String, String> observaciones = const {},
  }) {
    const archivos = {
      'donativo': ('donativo.pdf', 860160),
      'pordebajominima': ('oficio_direccion.pdf', 420000),
      'DICTAMENCT': ('dictamen_ct.pdf', 510000),
      'DictamenCG': ('dictamen_cg.pdf', 495000),
      'bajatemporal': ('baja_temporal.pdf', 300000),
      'horariosaes': ('horario_saes.pdf', 190000),
      'DatosSAES': ('datos_saes.pdf', 240000),
      'cambio_programa_academico': ('cambio_pa.pdf', 680000),
    };

    return [
      for (final entrada in archivos.entries)
        _doc(
          entrada.key,
          estado: estados[entrada.key] ?? EstadoTramite.sinSubir,
          archivo: (estados[entrada.key] ?? EstadoTramite.sinSubir) ==
                  EstadoTramite.sinSubir
              ? null
              : entrada.value.$1,
          bytes: (estados[entrada.key] ?? EstadoTramite.sinSubir) ==
                  EstadoTramite.sinSubir
              ? null
              : entrada.value.$2,
          subidoEl: DateTime(2026, 10, 12),
          observacionPrevia: observaciones[entrada.key],
        ),
    ];
  }

  /// La bandeja completa. Las tres tablas salen de filtrar esta lista.
  static final expedientes = <ExpedienteEnRevision>[
    ExpedienteEnRevision(
      boleta: '2024670001',
      nombre: 'RAMÍREZ SOLÍS MAGDALENA',
      correo: 'alumna1@example.com',
      carrera: 'ING. MECATRÓNICA',
      tipo: TipoTramiteAlumno.reinscripcion,
      etapa: EtapaExpediente.esperandoRevision,
      situacionAcademica: 'Irregular',
      creditos: 19.5,
      promedio: 6.73,
      tipoCarga: 'POR DEBAJO DE LA MÍNIMA',
      actualizadoEl: DateTime(2026, 10, 14),
      documentos: _expedienteReinscripcion(
        estados: {
          'donativo': EstadoTramite.enRevision,
          'pordebajominima': EstadoTramite.enRevision,
          'DICTAMENCT': EstadoTramite.enRevision,
          'horariosaes': EstadoTramite.enRevision,
          'DatosSAES': EstadoTramite.aprobado,
        },
      ),
    ),
    ExpedienteEnRevision(
      boleta: '2025670002',
      nombre: 'OLAGUE CASTRO JUAN',
      correo: 'alumno2@example.com',
      carrera: 'ING. METALÚRGICA',
      tipo: TipoTramiteAlumno.reinscripcion,
      etapa: EtapaExpediente.esperandoRevision,
      creditos: 42,
      promedio: 8.1,
      tipoCarga: 'CARGA COMPLETA',
      actualizadoEl: DateTime(2026, 10, 15),
      documentos: _expedienteReinscripcion(
        estados: {
          'donativo': EstadoTramite.enRevision,
          'horariosaes': EstadoTramite.enRevision,
          'DatosSAES': EstadoTramite.enRevision,
        },
      ),
    ),
    ExpedienteEnRevision(
      boleta: '2026670003',
      nombre: 'FÉLIX MONREAL JOSUÉ',
      correo: 'alumno3@example.com',
      carrera: 'ING. EN SISTEMAS COMPUTACIONALES',
      tipo: TipoTramiteAlumno.inscripcion,
      etapa: EtapaExpediente.esperandoRevision,
      creditos: 48,
      promedio: 9.0,
      tipoCarga: 'CARGA COMPLETA',
      actualizadoEl: DateTime(2026, 10, 15),
      documentos: [
        _doc('Inscripcion',
            estado: EstadoTramite.enRevision,
            archivo: 'inscripcion.pdf',
            bytes: 350000,
            subidoEl: DateTime(2026, 10, 15)),
        _doc('donativo',
            estado: EstadoTramite.enRevision,
            archivo: 'donativo.pdf',
            bytes: 780000,
            subidoEl: DateTime(2026, 10, 15)),
        _doc('Resultados',
            estado: EstadoTramite.enRevision,
            archivo: 'resultados.pdf',
            bytes: 220000,
            subidoEl: DateTime(2026, 10, 15)),
        _doc('consindocumentos', estado: EstadoTramite.sinSubir),
        _doc('curp',
            estado: EstadoTramite.aprobado,
            archivo: 'curp.pdf',
            bytes: 95000,
            subidoEl: DateTime(2026, 10, 10)),
      ],
    ),
    ExpedienteEnRevision(
      boleta: '2026670004',
      nombre: 'CECEÑAS DÁVILA FÁTIMA',
      correo: 'alumna4@example.com',
      carrera: 'ING. METALÚRGICA',
      tipo: TipoTramiteAlumno.reinscripcion,
      etapa: EtapaExpediente.corrigiendo,
      creditos: 36,
      promedio: 7.4,
      tipoCarga: 'CARGA COMPLETA',
      actualizadoEl: DateTime(2026, 10, 13),
      documentos: _expedienteReinscripcion(
        estados: {
          'donativo': EstadoTramite.aprobado,
          'pordebajominima': EstadoTramite.aprobado,
          'DatosSAES': EstadoTramite.aprobado,
          'horariosaes': EstadoTramite.conObservaciones,
        },
        observaciones: {
          'horariosaes': 'Es el horario del periodo pasado. Sube el del 27/1.',
        },
      ),
    ),
    ExpedienteEnRevision(
      boleta: '2027670005',
      nombre: 'PEDROZA SALDÍVAR MAYTE',
      correo: 'alumna5@example.com',
      carrera: 'ING. EN INTELIGENCIA ARTIFICIAL',
      tipo: TipoTramiteAlumno.inscripcion,
      etapa: EtapaExpediente.corrigiendo,
      actualizadoEl: DateTime(2026, 10, 12),
      documentos: [
        _doc('Inscripcion',
            estado: EstadoTramite.aprobado,
            archivo: 'inscripcion.pdf',
            bytes: 310000),
        _doc('donativo',
            estado: EstadoTramite.aprobado,
            archivo: 'donativo.pdf',
            bytes: 640000),
        _doc('Resultados',
            estado: EstadoTramite.aprobado,
            archivo: 'resultados.pdf',
            bytes: 180000),
        _doc('curp',
            estado: EstadoTramite.aprobado, archivo: 'curp.pdf', bytes: 95000),
        _doc('consindocumentos',
            estado: EstadoTramite.conObservaciones,
            archivo: 'solicitud.pdf',
            bytes: 150000,
            observacionPrevia: 'Le falta la firma.'),
      ],
    ),
    ExpedienteEnRevision(
      boleta: '2021670006',
      nombre: 'SILVA MIRANDA CRISTÓBAL',
      correo: 'alumno6@example.com',
      carrera: 'ING. AMBIENTAL',
      tipo: TipoTramiteAlumno.reinscripcion,
      etapa: EtapaExpediente.validado,
      creditos: 45,
      promedio: 8.6,
      tipoCarga: 'CARGA COMPLETA',
      actualizadoEl: DateTime(2026, 10, 8),
      entregoFisico: true,
      documentos: _expedienteReinscripcion(
        estados: {
          'donativo': EstadoTramite.aprobado,
          'horariosaes': EstadoTramite.aprobado,
          'DatosSAES': EstadoTramite.aprobado,
        },
      ),
    ),
    ExpedienteEnRevision(
      boleta: '2023670007',
      nombre: 'GUERRERO ZAPATA ÁNGELA',
      correo: 'alumna7@example.com',
      carrera: 'ING. EN SISTEMAS COMPUTACIONALES',
      tipo: TipoTramiteAlumno.reinscripcion,
      etapa: EtapaExpediente.validado,
      creditos: 22.5,
      promedio: 7.05,
      tipoCarga: 'POR DEBAJO DE LA MÍNIMA',
      actualizadoEl: DateTime(2026, 10, 7),
      documentos: _expedienteReinscripcion(
        estados: {
          'donativo': EstadoTramite.aprobado,
          'pordebajominima': EstadoTramite.aprobado,
          'horariosaes': EstadoTramite.aprobado,
          'DatosSAES': EstadoTramite.aprobado,
        },
      ),
    ),
  ];

  static List<ExpedienteEnRevision> porEtapa(EtapaExpediente etapa) =>
      expedientes.where((e) => e.etapa == etapa).toList();

  /// Reemplaza un expediente por su versión actualizada.
  static void guardar(ExpedienteEnRevision expediente) {
    final i = expedientes.indexWhere((e) => e.boleta == expediente.boleta);
    if (i != -1) expedientes[i] = expediente;
  }
}
