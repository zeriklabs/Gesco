import '../../widgets/status_pill.dart';

/// A quién le toca un documento, según el catálogo de Gestión Escolar.
///
/// Es un campo que **ya existe** en el sistema actual (`¿Dirigido a?` en el
/// catálogo de documentos). Que exista y no se use es la razón de que al
/// revisor le aparezcan los ocho documentos aunque al alumno solo le toquen
/// tres.
enum DirigidoA {
  nuevoIngreso('Nuevo ingreso'),
  reinscripcion('Reinscripción'),
  ambos('Ambos'),
  cosie('COSIE');

  const DirigidoA(this.etiqueta);

  final String etiqueta;

  bool aplicaA(TipoTramiteAlumno tipo) => switch (this) {
        DirigidoA.ambos => true,
        DirigidoA.nuevoIngreso => tipo == TipoTramiteAlumno.inscripcion,
        DirigidoA.reinscripcion => tipo == TipoTramiteAlumno.reinscripcion,
        DirigidoA.cosie => tipo == TipoTramiteAlumno.cosie,
      };
}

/// La "I" y la "R" de la columna Estatus de la bandeja.
enum TipoTramiteAlumno {
  inscripcion('I', 'Inscripción'),
  reinscripcion('R', 'Reinscripción'),
  cosie('C', 'COSIE');

  const TipoTramiteAlumno(this.letra, this.etiqueta);

  final String letra;
  final String etiqueta;
}

/// En qué etapa va un expediente. Son las tres tablas de la pantalla actual.
enum EtapaExpediente {
  esperandoRevision('Esperando revisión'),
  corrigiendo('Corrigiendo observaciones'),
  validado('Validado');

  const EtapaExpediente(this.etiqueta);

  final String etiqueta;
}

/// Lo que el revisor decide sobre un documento.
///
/// `pendiente` existe a propósito y es el valor inicial. En el sistema actual
/// el desplegable arranca en REGRESAR, así que un guardado distraído le rebota
/// el expediente completo al alumno. Una acción destructiva nunca debe ser el
/// valor por omisión.
enum Decision {
  pendiente('Sin decidir'),
  aprobar('Aprobar'),
  regresar('Regresar al alumno');

  const Decision(this.etiqueta);

  final String etiqueta;
}

/// Un documento dentro de la revisión de un expediente.
class DocumentoEnRevision {
  const DocumentoEnRevision({
    required this.id,
    required this.nombreCorto,
    required this.descripcion,
    required this.dirigidoA,
    required this.estado,
    this.nombreArchivo,
    this.bytes,
    this.subidoEl,
    this.observacionPrevia,
    this.decision = Decision.pendiente,
    this.comentario = '',
  });

  final String id;

  /// Como lo guarda la base: `pordebajominima`, `DatosSAES`.
  final String nombreCorto;

  /// Como lo entiende una persona. El catálogo ya lo tiene y dice literalmente
  /// "es el nombre que le mostrará al alumno"; la pantalla actual no lo usa.
  final String descripcion;

  final DirigidoA dirigidoA;

  /// En qué quedó la última vez.
  final EstadoTramite estado;

  final String? nombreArchivo;
  final int? bytes;
  final DateTime? subidoEl;

  /// Lo que se le dijo al alumno la vez pasada.
  final String? observacionPrevia;

  final Decision decision;
  final String comentario;

  bool get tieneArchivo => nombreArchivo != null;

  bool get yaAprobado => estado == EstadoTramite.aprobado;

  /// Un documento aprobado ya no se vuelve a juzgar.
  bool get sePuedeDecidir => tieneArchivo && !yaAprobado;

  String get pesoLegible {
    final b = bytes;
    if (b == null) return '';
    if (b < 1024 * 1024) return '${(b / 1024).round()} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  DocumentoEnRevision copyWith({Decision? decision, String? comentario}) {
    return DocumentoEnRevision(
      id: id,
      nombreCorto: nombreCorto,
      descripcion: descripcion,
      dirigidoA: dirigidoA,
      estado: estado,
      nombreArchivo: nombreArchivo,
      bytes: bytes,
      subidoEl: subidoEl,
      observacionPrevia: observacionPrevia,
      decision: decision ?? this.decision,
      comentario: comentario ?? this.comentario,
    );
  }
}

/// El expediente de un alumno, visto desde Gestión Escolar.
class ExpedienteEnRevision {
  const ExpedienteEnRevision({
    required this.boleta,
    required this.nombre,
    required this.correo,
    required this.carrera,
    required this.tipo,
    required this.etapa,
    required this.documentos,
    this.situacionAcademica = 'Regular',
    this.creditos,
    this.promedio,
    this.tipoCarga,
    this.actualizadoEl,
    this.entregoFisico = false,
  });

  final String boleta;
  final String nombre;
  final String correo;
  final String carrera;
  final TipoTramiteAlumno tipo;
  final EtapaExpediente etapa;
  final List<DocumentoEnRevision> documentos;

  final String situacionAcademica;

  /// Los tres números que el alumno captura a mano y que nadie valida contra
  /// nada. Aquí se enseñan juntos porque es donde cobran sentido: si el
  /// promedio es 6.73 y la carga va por debajo de la mínima, el revisor sabe
  /// qué documentos esperar.
  final double? creditos;
  final double? promedio;
  final String? tipoCarga;

  final DateTime? actualizadoEl;
  final bool entregoFisico;

  /// Los que de verdad le tocan a este alumno, según el catálogo.
  List<DocumentoEnRevision> get aplicables =>
      documentos.where((d) => d.dirigidoA.aplicaA(tipo)).toList();

  /// Los que el catálogo no le pide. Se muestran plegados, no escondidos.
  List<DocumentoEnRevision> get noAplicables =>
      documentos.where((d) => !d.dirigidoA.aplicaA(tipo)).toList();

  /// Los que esperan una decisión en esta pasada.
  List<DocumentoEnRevision> get porDecidir =>
      aplicables.where((d) => d.sePuedeDecidir).toList();

  List<DocumentoEnRevision> get sinSubir =>
      aplicables.where((d) => !d.tieneArchivo).toList();

  int get decididos =>
      porDecidir.where((d) => d.decision != Decision.pendiente).length;

  int get pendientes => porDecidir.length - decididos;

  int get aprobados => aplicables.where((d) => d.yaAprobado).length;

  /// Los documentos a los que les falta el comentario que explique el regreso.
  ///
  /// Regresar sin decir por qué es exactamente lo que hace que el alumno tenga
  /// que ir a preguntar a la ventanilla.
  List<DocumentoEnRevision> get regresadosSinMotivo => porDecidir
      .where((d) =>
          d.decision == Decision.regresar && d.comentario.trim().length < 10)
      .toList();

  bool get sePuedeEnviar =>
      decididos > 0 && regresadosSinMotivo.isEmpty;

  ExpedienteEnRevision conDocumentos(List<DocumentoEnRevision> nuevos) {
    return ExpedienteEnRevision(
      boleta: boleta,
      nombre: nombre,
      correo: correo,
      carrera: carrera,
      tipo: tipo,
      etapa: etapa,
      documentos: nuevos,
      situacionAcademica: situacionAcademica,
      creditos: creditos,
      promedio: promedio,
      tipoCarga: tipoCarga,
      actualizadoEl: actualizadoEl,
      entregoFisico: entregoFisico,
    );
  }
}
