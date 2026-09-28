import 'package:flutter/material.dart';

import '../core/layout/breakpoints.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Un paso de un asistente: cómo se llama y con qué icono.
typedef PasoWizard = (String titulo, IconData icono);

/// La barra de pasos, arriba y siempre visible.
///
/// La comparten el dictamen y la reinscripción. En celular se quedan solo los
/// tramos y el icono: los títulos no caben y taparían el contenido.
class BarraPasos extends StatelessWidget {
  const BarraPasos({super.key, required this.pasos, required this.actual});

  final List<PasoWizard> pasos;
  final int actual;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal:
            compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          for (var i = 0; i < pasos.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _Tramo(
                paso: pasos[i],
                hecho: i < actual,
                activo: i == actual,
                compacto: compacto,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tramo extends StatelessWidget {
  const _Tramo({
    required this.paso,
    required this.hecho,
    required this.activo,
    required this.compacto,
  });

  final PasoWizard paso;
  final bool hecho;
  final bool activo;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final color = activo || hecho ? AppColors.guinda : AppColors.placeholder;
    final (titulo, icono) = paso;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: activo || hecho ? AppColors.guinda : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(hecho ? Icons.check_rounded : icono, size: 15, color: color),
            const SizedBox(width: 5),
            if (!compacto)
              Flexible(
                child: Text(
                  titulo,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Atrás / continuar, fijo al pie del asistente.
class PieWizard extends StatelessWidget {
  const PieWizard({
    super.key,
    required this.onSiguiente,
    required this.etiqueta,
    this.onAtras,
    this.icono = Icons.arrow_forward_rounded,
    this.nota,
    this.habilitado = true,
  });

  final VoidCallback onSiguiente;
  final String etiqueta;
  final VoidCallback? onAtras;
  final IconData icono;

  /// Una línea a la izquierda: por qué no se puede avanzar, o qué falta.
  final String? nota;

  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: const Color(0x14000000),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              if (onAtras != null)
                OutlinedButton.icon(
                  onPressed: onAtras,
                  icon: const Icon(Icons.arrow_back_rounded, size: 17),
                  label: const Text('Atrás'),
                ),
              if (nota != null && !compacto) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    nota!,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: habilitado ? onSiguiente : null,
                icon: Icon(icono, size: 18),
                label: Text(etiqueta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
