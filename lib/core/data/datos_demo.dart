import '../../widgets/status_pill.dart';
import '../models/documento.dart';
import '../models/expediente.dart';
import '../models/tramite.dart';

/// Datos de ejemplo mientras no hay backend.
///
/// TODO(backend): esto desaparece cuando exista la API. Todo lo que hay aquí
/// es inventado para poder ver las pantallas llenas; ningún dato sale de un
/// alumno real.
///
/// Está en un solo archivo a propósito: cuando llegue el servidor, se cambia
/// el origen en un lugar y las pantallas no se enteran.
abstract final class DatosDemo {
  static const periodoActual = '27/1';
  static const periodoLegible = 'Ago 2026 – Ene 2027';

  static const nombreAlumno = 'Gael García';
  static const boleta = '2023670029';
  static const carrera = 'Ing. en Sistemas Computacionales';
  static const grupo = '8CM1';

  static String get iniciales {
    final partes = nombreAlumno.split(' ');
    if (partes.length < 2) return nombreAlumno.substring(0, 2).toUpperCase();
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  static Expediente get expediente => Expediente(
        actualizadoEl: DateTime(2026, 9, 24, 11, 42),
        adeudos: const [],
        secciones: const {
          SeccionExpediente.personales: ResumenSeccion(
            camposLlenos: 21,
            total: 21,
            lineas: [
              ('Nombre', 'Gael García Torres'),
              ('Domicilio', 'Ojocaliente, Zacatecas'),
            ],
          ),
          SeccionExpediente.tutor: ResumenSeccion(
            camposLlenos: 14,
            total: 14,
            lineas: [
              ('Tutor', 'Maricela Torres'),
              ('Parentesco', 'Madre · Maestra'),
              ('Domicilio', 'Mismo que el alumno'),
            ],
          ),
          SeccionExpediente.generales: ResumenSeccion(
            camposLlenos: 3,
            total: 3,
            lineas: [
              ('¿Trabajas?', 'No'),
              ('Visible al tutor', 'No'),
            ],
          ),
          SeccionExpediente.escolares: ResumenSeccion(
            camposLlenos: 9,
            total: 11,
            lineas: [
              ('Semestre', '8vo · Grupo 8CM1'),
              ('Carga', 'Por debajo de la mínima'),
            ],
          ),
        },
      );

  static List<Tramite> get tramites => [
        Tramite(
          id: 'reins-27-1',
          tipo: TipoTramite.reinscripcion,
          estado: EstadoTramite.conObservaciones,
          periodo: periodoActual,
          creadoEl: DateTime(2026, 9, 24),
          documentos: [
            Documento(
              id: 'donativo',
              nombre: 'Comprobante del donativo',
              estado: EstadoTramite.conObservaciones,
              nombreArchivo: 'donativo_2026.pdf',
              bytes: 860160,
              subidoEl: DateTime(2026, 9, 21),
              revisadoEl: DateTime(2026, 9, 22, 10, 15),
              revisadoPor: 'Gestión Escolar',
              observacion: 'El comprobante está a nombre de otra persona. '
                  'Sube el que tenga tu número de boleta.',
            ),
            Documento(
              id: 'carga-minima',
              nombre: 'Oficio de dirección · carga por debajo de la mínima',
              estado: EstadoTramite.aprobado,
              nombreArchivo: 'oficio_carga.pdf',
              bytes: 420000,
              revisadoEl: DateTime(2026, 9, 19),
            ),
            const Documento(
              id: 'horario-saes',
              nombre: 'Comprobante de horario del SAES',
              estado: EstadoTramite.sinSubir,
            ),
            const Documento(
              id: 'dictamen-ct',
              nombre: 'Dictamen de COSIE del CT',
              estado: EstadoTramite.noAplica,
              aplica: false,
              porQueNoAplica: 'Tu expediente dice que no cuentas con dictamen.',
            ),
            const Documento(
              id: 'baja-temporal',
              nombre: 'Oficio de baja temporal',
              estado: EstadoTramite.noAplica,
              aplica: false,
              porQueNoAplica: 'No provienes de una baja.',
            ),
            const Documento(
              id: 'cambio-pa',
              nombre: 'Documentos de cambio de programa académico',
              estado: EstadoTramite.noAplica,
              aplica: false,
              porQueNoAplica: 'No vienes de otro programa.',
            ),
          ],
        ),
        Tramite(
          id: 'ge01-27-1',
          tipo: TipoTramite.ge01,
          estado: EstadoTramite.enRevision,
          periodo: periodoActual,
          creadoEl: DateTime(2026, 9, 22),
          resumen: '4 unidades de aprendizaje · 30 créditos',
        ),
        Tramite(
          id: 'baja-26-2',
          tipo: TipoTramite.bajaUnidades,
          estado: EstadoTramite.aprobado,
          periodo: '26/2',
          creadoEl: DateTime(2026, 3, 14),
          resumen: '1 unidad dada de baja',
        ),
      ];

  /// Todos los documentos de todos los trámites, para la vista general.
  static List<(Tramite, Documento)> get documentosDeTodosLosTramites => [
        for (final t in tramites)
          for (final d in t.documentos) (t, d),
      ];
}
