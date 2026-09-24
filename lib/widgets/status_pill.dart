import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Los cuatro estados que maneja Gestión Escolar para un documento o solicitud.
///
/// Son los mismos del sistema actual, nada más que ahí viven como una leyenda
/// repetida al pie de cada página de subida.
enum EstadoTramite {
  /// Ya está aprobado; el alumno ya no puede modificarlo.
  aprobado,

  /// Subido, en espera de que lo revisen.
  enRevision,

  /// Tiene observaciones y hay que reemplazarlo. Es el único estado que
  /// **exige** algo del alumno, por eso se lleva el guinda sólido.
  conObservaciones,

  /// Todavía no se sube.
  sinSubir,

  /// No corresponde a la situación de este alumno.
  noAplica;

  String get etiqueta => switch (this) {
        aprobado => 'Aprobado',
        enRevision => 'En revisión',
        conObservaciones => 'Con observaciones',
        sinSubir => 'Sin subir',
        noAplica => 'No aplica',
      };

  /// Cada estado tiene icono propio además de color: el color por sí solo deja
  /// fuera a quien no lo distingue.
  IconData get icono => switch (this) {
        aprobado => Icons.check_rounded,
        enRevision => Icons.schedule_rounded,
        conObservaciones => Icons.priority_high_rounded,
        sinSubir => Icons.arrow_upward_rounded,
        noAplica => Icons.remove_rounded,
      };

  Color get fondo => switch (this) {
        aprobado => AppColors.successTint,
        enRevision => AppColors.warningTint,
        conObservaciones => AppColors.danger,
        sinSubir => AppColors.neutralTint,
        noAplica => AppColors.neutralTint,
      };

  Color get tinta => switch (this) {
        aprobado => AppColors.successInk,
        enRevision => AppColors.warningInk,
        conObservaciones => AppColors.onGuinda,
        sinSubir => AppColors.muted,
        noAplica => AppColors.muted,
      };

  /// `true` cuando el alumno tiene que hacer algo.
  bool get requiereAccion =>
      this == conObservaciones || this == sinSubir;
}

/// Píldora de estado.
class StatusPill extends StatelessWidget {
  const StatusPill(this.estado, {super.key, this.compacta = false});

  final EstadoTramite estado;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compacta ? 9 : 11,
        vertical: compacta ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: estado.fondo,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(estado.icono, size: compacta ? 11 : 13, color: estado.tinta),
          const SizedBox(width: 5),
          Text(
            estado.etiqueta,
            style: AppTypography.pill.copyWith(
              color: estado.tinta,
              fontSize: compacta ? 10.5 : 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Punto de estado para listas densas, donde no cabe la píldora completa.
///
/// Lleva `semanticLabel` para que un lector de pantalla anuncie el estado:
/// sin eso, sería un cuadro de color sin significado.
class StatusDot extends StatelessWidget {
  const StatusDot(this.estado, {super.key, this.size = 26});

  final EstadoTramite estado;
  final double size;

  @override
  Widget build(BuildContext context) {
    final vacio =
        estado == EstadoTramite.sinSubir || estado == EstadoTramite.noAplica;

    return Semantics(
      label: estado.etiqueta,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: vacio ? Colors.transparent : estado.fondo,
          shape: BoxShape.circle,
          border: vacio
              ? Border.all(color: AppColors.borderMuted, width: 1.5)
              : null,
        ),
        child: Icon(
          estado.icono,
          size: size * 0.5,
          color: vacio ? AppColors.muted : estado.tinta,
        ),
      ),
    );
  }
}
