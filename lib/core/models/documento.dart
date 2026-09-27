import '../../widgets/status_pill.dart';

/// Un archivo que Gestión Escolar pide para un trámite.
///
/// El GESCO actual lista los ocho documentos de inscripción a todo el mundo y
/// el alumno adivina cuáles le tocan. Aquí cada documento sabe si aplica a
/// esta persona, y los que no se agrupan aparte.
class Documento {
  const Documento({
    required this.id,
    required this.nombre,
    required this.estado,
    this.aplica = true,
    this.nombreArchivo,
    this.bytes,
    this.subidoEl,
    this.revisadoEl,
    this.observacion,
    this.revisadoPor,
    this.porQueNoAplica,
  });

  final String id;
  final String nombre;
  final EstadoTramite estado;

  /// `false` cuando la situación del alumno no lo pide.
  final bool aplica;

  final String? nombreArchivo;
  final int? bytes;
  final DateTime? subidoEl;
  final DateTime? revisadoEl;

  /// Lo que escribió Gestión Escolar al rechazarlo.
  ///
  /// Hoy el sistema solo pinta un icono rojo y el alumno tiene que ir a
  /// preguntar qué estuvo mal.
  final String? observacion;
  final String? revisadoPor;

  /// Por qué este documento no le toca. Se muestra en vez de esconderlo, para
  /// que el alumno pueda verificar que la deducción del sistema es correcta.
  final String? porQueNoAplica;

  bool get estaAprobado => estado == EstadoTramite.aprobado;
  bool get necesitaAccion => aplica && estado.requiereAccion;

  /// El peso en KB o MB, como lo esperaría ver alguien.
  String get pesoLegible {
    final b = bytes;
    if (b == null) return '';
    if (b < 1024 * 1024) return '${(b / 1024).round()} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Documento copyWith({EstadoTramite? estado, String? observacion}) {
    return Documento(
      id: id,
      nombre: nombre,
      estado: estado ?? this.estado,
      aplica: aplica,
      nombreArchivo: nombreArchivo,
      bytes: bytes,
      subidoEl: subidoEl,
      revisadoEl: revisadoEl,
      observacion: observacion ?? this.observacion,
      revisadoPor: revisadoPor,
      porQueNoAplica: porQueNoAplica,
    );
  }
}
