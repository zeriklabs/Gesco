import 'package:flutter/material.dart';

import '../../widgets/status_pill.dart';
import 'documento.dart';

/// Los cinco trámites que se generan en GESCO.
///
/// Los tres "Descargar oficio" del menú actual no están aquí a propósito: no
/// son solicitudes, son el resultado que Gestión Escolar devuelve.
enum TipoTramite {
  reinscripcion(
    'Reinscripción',
    'No pide nada nuevo. Se arma con tu expediente.',
    Icons.description_outlined,
  ),
  bajaUnidades(
    'Baja de materias',
    'Dar de baja materias del periodo que estás cursando.',
    Icons.playlist_remove_rounded,
  ),
  dictamen(
    'Dictamen',
    'Ante la Comisión de Situación Escolar.',
    Icons.gavel_rounded,
  ),
  bajaUnidadAcademica(
    'Baja de la escuela',
    'Temporal o definitiva de la UPIIZ.',
    Icons.logout_rounded,
  ),
  ge01(
    'Formato GE-01',
    'Inscripción de materias del periodo.',
    Icons.list_alt_rounded,
  );

  const TipoTramite(this.titulo, this.descripcion, this.icono);

  final String titulo;
  final String descripcion;
  final IconData icono;

  /// Qué partes del expediente necesita para poder generarse.
  List<String> get requiere => switch (this) {
        TipoTramite.reinscripcion => const ['Expediente completo'],
        TipoTramite.bajaUnidades => const ['Datos escolares', 'Adeudos'],
        TipoTramite.dictamen => const ['Datos escolares', 'Adeudos'],
        TipoTramite.bajaUnidadAcademica => const ['Datos escolares'],
        TipoTramite.ge01 => const ['Datos escolares'],
      };
}

/// Una solicitud que el alumno ya generó o está armando.
class Tramite {
  const Tramite({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.periodo,
    this.creadoEl,
    this.resumen,
    this.documentos = const [],
  });

  final String id;
  final TipoTramite tipo;
  final EstadoTramite estado;
  final String periodo;
  final DateTime? creadoEl;

  /// Una línea con lo que lo distingue: "4 unidades · 30 créditos".
  final String? resumen;

  final List<Documento> documentos;

  /// Los que de verdad le tocan a este alumno.
  List<Documento> get documentosAplicables =>
      documentos.where((d) => d.aplica).toList();

  List<Documento> get documentosNoAplicables =>
      documentos.where((d) => !d.aplica).toList();

  int get documentosAprobados =>
      documentosAplicables.where((d) => d.estaAprobado).length;

  int get documentosRequeridos => documentosAplicables.length;

  /// El documento que está frenando el trámite, si hay alguno.
  Documento? get documentoBloqueante {
    for (final d in documentosAplicables) {
      if (d.estado == EstadoTramite.conObservaciones) return d;
    }
    return null;
  }

  bool get listoParaGenerar =>
      documentosRequeridos > 0 && documentosAprobados == documentosRequeridos;
}
