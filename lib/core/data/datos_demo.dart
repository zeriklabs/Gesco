import '../../widgets/status_pill.dart';
import '../models/documento.dart';
import '../models/expediente.dart';
import '../models/materia.dart';
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

  // Historial escolar. En el sistema actual el alumno lo teclea otra vez en
  // cada solicitud que lo pide; aquí sale del expediente.
  static const periodoIngresoIpn = '23/1';
  static const ultimoPeriodoInscrito = '26/2';
  static const ultimoNivel = 'NIVEL III';
  static const ultimoGrupo = '8CM1';

  // Datos escolares que el dictamen usa para proponerle una causa al alumno.
  // Los captura él mismo en el paso 4 del registro.
  static const tipoCarga = 'POR DEBAJO DE LA MÍNIMA';
  static const provieneDeBaja = false;
  static const cuentaConDictamen = false;

  /// Los datos que de verdad cambian de un periodo a otro.
  ///
  /// El aviso del GESCO actual lo dice él mismo: "reingreso solo actualiza
  /// domicilio, teléfono y seguro social". Por eso la reinscripción no vuelve
  /// a pedir los 49 campos del expediente: enseña estos cinco y pregunta si
  /// siguen igual.
  ///
  /// TODO(backend): inventados. Ninguno sale de una persona real.
  static final datosDeContacto = <String, String>{
    'Domicilio': 'Av. Hidalgo 118, Centro, Ojocaliente, Zacatecas, 98700',
    'Teléfono celular': '492 100 2030',
    'Teléfono fijo': '492 955 1010',
    'Correo': 'alumno@alumno.ipn.mx',
    'Número de seguro social': '00000000000',
  };

  /// Las materias del periodo actual.
  ///
  /// Salen del GE-01, que es donde el alumno las inscribe. Tenerlas aquí es
  /// lo que permite que la baja de materias sea una lista con palomitas en
  /// vez de dos listas que el alumno recaptura a mano.
  static final materiasInscritas = <Materia>[
    const Materia(
      id: 'm-1',
      nombre: 'Inteligencia Artificial Generativa',
      nivel: 'NIVEL III',
      creditos: 8,
      grupo: '9CM1',
    ),
    const Materia(
      id: 'm-2',
      nombre: 'Procesamiento de Lenguaje Natural',
      nivel: 'NIVEL III',
      creditos: 8,
      grupo: '9CM1',
    ),
    const Materia(
      id: 'm-3',
      nombre: 'Sistemas Inteligentes y Agentes Autónomos',
      nivel: 'NIVEL III',
      creditos: 8,
      grupo: '9CM1',
    ),
    const Materia(
      id: 'm-4',
      nombre: 'Circuitos Eléctricos',
      nivel: 'NIVEL I',
      creditos: 6,
      grupo: '3CM1',
      estado: 'RECURSAMIENTO',
    ),
  ];

  static int get creditosInscritos =>
      materiasInscritas.fold(0, (suma, m) => suma + m.creditos);

  /// El mínimo de créditos del periodo.
  ///
  /// TODO(gescolar): este número es inventado para poder enseñar el aviso.
  /// El real lo tiene Gestión Escolar y cambia por programa académico; abajo
  /// de él, el alumno necesita oficio de la dirección.
  static const creditosMinimos = 24;

  /// Unidades de aprendizaje reprobadas.
  ///
  /// Es lo único de carácter académico que GESCO sí tiene, porque lo captura
  /// el alumno. Las calificaciones y el kardex viven en el SAES.
  ///
  /// Es `final` y no `const` a propósito: la pantalla de Adeudos agrega y
  /// quita elementos aquí para que el cambio se note de inmediato en el
  /// dictamen, que lee esta misma lista.
  /// TODO(backend): esto se vuelve una llamada a la API.
  static final adeudos = <Adeudo>[
    const Adeudo(
      unidadAprendizaje: 'Análisis y Diseño de Algoritmos',
      nivel: 'NIVEL II',
      periodoReprobada: '25/2',
      semestreReprobada: '5to',
      estado: 'RECURSAMIENTO',
    ),
    const Adeudo(
      unidadAprendizaje: 'Teoría de la Computación',
      nivel: 'NIVEL II',
      periodoReprobada: '26/1',
      semestreReprobada: '6to',
      estado: 'ETS',
    ),
  ];

  static String get iniciales {
    final partes = nombreAlumno.split(' ');
    if (partes.length < 2) return nombreAlumno.substring(0, 2).toUpperCase();
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  static Expediente get expediente => Expediente(
        actualizadoEl: DateTime(2026, 9, 24, 11, 42),
        adeudos: adeudos,
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
          resumen: '4 materias · 30 créditos',
        ),
        Tramite(
          id: 'baja-26-2',
          tipo: TipoTramite.bajaUnidades,
          estado: EstadoTramite.aprobado,
          periodo: '26/2',
          creadoEl: DateTime(2026, 3, 14),
          resumen: '1 materia dada de baja',
        ),
      ];

  /// Los cinco documentos de COSIE.
  ///
  /// En el GESCO actual son una pestaña propia del menú, desconectada de la
  /// solicitud de dictamen. Aquí son el último paso de esa solicitud, que es
  /// el único lugar donde tienen sentido.
  static List<Documento> get documentosCosie => [
        const Documento(
          id: 'cosie-oficio-consejo',
          nombre: 'Oficio para el consejo',
          estado: EstadoTramite.sinSubir,
        ),
        const Documento(
          id: 'cosie-solicitud',
          nombre: 'Solicitud de dictamen firmada',
          estado: EstadoTramite.sinSubir,
        ),
        Documento(
          id: 'cosie-boleta-global',
          nombre: 'Boleta global',
          estado: EstadoTramite.aprobado,
          nombreArchivo: 'boleta_global.pdf',
          bytes: 310000,
          subidoEl: DateTime(2026, 9, 15),
          revisadoEl: DateTime(2026, 9, 16),
          revisadoPor: 'Gestión Escolar',
        ),
        const Documento(
          id: 'cosie-comprobatorios',
          nombre: 'Documentos comprobatorios',
          estado: EstadoTramite.sinSubir,
        ),
        Documento(
          id: 'cosie-saes',
          nombre: 'Estado general del SAES',
          estado: EstadoTramite.enRevision,
          nombreArchivo: 'estado_saes.pdf',
          bytes: 190000,
          subidoEl: DateTime(2026, 9, 25),
        ),
      ];

  /// Todos los documentos de todos los trámites, para la vista general.
  static List<(Tramite, Documento)> get documentosDeTodosLosTramites => [
        for (final t in tramites)
          for (final d in t.documentos) (t, d),
      ];
}
