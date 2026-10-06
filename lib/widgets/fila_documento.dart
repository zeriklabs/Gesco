import 'package:flutter/material.dart';

import '../core/models/documento.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'status_pill.dart';

/// Un documento en una lista.
///
/// Tiene dos modos porque hay dos lugares donde aparece un documento:
///
/// - Dentro de su trámite, donde **se sube** (`onSubir` presente). Es el
///   cambio que reemplaza la sección aparte de "Subir documentos" del GESCO
///   actual: el archivo se sube junto al botón que genera el PDF.
/// - En "Mis documentos", que es solo para consultar.
class FilaDocumento extends StatelessWidget {
  const FilaDocumento({
    super.key,
    required this.documento,
    this.onSubir,
    this.onVer,
    this.compacta = false,
  });

  final Documento documento;

  /// Si viene, se dibuja el botón de subir o reemplazar.
  final VoidCallback? onSubir;

  final VoidCallback? onVer;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final d = documento;
    final alerta = d.estado == EstadoTramite.conObservaciones;
    final noAplica = !d.aplica;

    final subtitulo = switch (d) {
      _ when noAplica => d.porQueNoAplica ?? 'No aplica a tu situación',
      _ when alerta => d.observacion ?? 'Tiene observaciones',
      _ when d.estaAprobado =>
        'Aprobado el ${_fecha(d.revisadoEl)} · ya no se puede modificar',
      _ when d.nombreArchivo != null =>
        '${d.nombreArchivo} · ${d.pesoLegible} · subido el ${_fecha(d.subidoEl)}',
      _ => 'PDF · máximo 2 MB',
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: compacta ? AppSpacing.sm : AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: noAplica ? AppColors.ground : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: alerta ? AppColors.dangerBorder : AppColors.borderSubtle,
          width: alerta ? 2 : 1.0,
        ),
        boxShadow: [
          if (!noAplica && !alerta)
            BoxShadow(
              color: AppColors.ink.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Row(
        children: [
          StatusDot(d.estado, size: compacta ? 24 : 26),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.nombre,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: noAplica ? AppColors.inkSecondary : AppColors.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: AppTypography.hint.copyWith(
                    color: alerta ? AppColors.guinda : AppColors.muted,
                    fontWeight: alerta ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (onSubir != null && !noAplica && !d.estaAprobado)
            _BotonSubir(alerta: alerta, onPressed: onSubir!)
          // En modo consulta se abre el detalle aunque no haya archivo: ahí
          // está la observación completa y la liga al trámite.
          else if (onVer != null && !noAplica)
            IconButton(
              onPressed: onVer,
              tooltip: 'Ver detalle de ${d.nombre}',
              icon: const Icon(Icons.chevron_right_rounded, size: 22),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.inkSecondary,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm - 2),
                ),
              ),
            )
          else
            StatusPill(d.estado, compacta: true),
        ],
      ),
    );
  }
}

class _BotonSubir extends StatelessWidget {
  const _BotonSubir({required this.alerta, required this.onPressed});

  final bool alerta;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final etiqueta = alerta ? 'Reemplazar' : 'Subir';
    final icono = Icon(
      Icons.upload_rounded,
      size: 16,
      color: alerta ? AppColors.onGuinda : AppColors.guinda,
    );

    if (alerta) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: icono,
        label: Text(etiqueta),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.guinda,
          foregroundColor: AppColors.onGuinda,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm - 2),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icono,
      label: Text(etiqueta),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
        textStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm - 2),
        ),
      ),
    );
  }
}

String _fecha(DateTime? f) {
  if (f == null) return '—';
  const meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${f.day} ${meses[f.month - 1]}';
}
