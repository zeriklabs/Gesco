import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../models/reporte.dart';

/// El resumen de un reporte: la barra de proporción y las etapas con su cuenta.
///
/// Vive aparte porque sale en los dos lados —en la lista de reportes y dentro
/// de cada uno— y tiene que decir lo mismo en ambos.
class ResumenReporte extends StatelessWidget {
  const ResumenReporte({
    super.key,
    required this.resumen,
    this.conBarra = true,
  });

  final List<(String, int, TonoFila)> resumen;
  final bool conBarra;

  int get _total {
    var suma = 0;
    for (final (_, cuantos, _) in resumen) {
      suma += cuantos;
    }
    return suma;
  }

  @override
  Widget build(BuildContext context) {
    if (_total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (conBarra) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              height: 7,
              child: Row(
                children: [
                  for (final (_, cuantos, tono) in resumen)
                    if (cuantos > 0)
                      Expanded(
                        flex: cuantos,
                        child: ColoredBox(color: tono.tinta),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            for (final (etiqueta, cuantos, tono) in resumen)
              if (cuantos > 0)
                MarcaEtapa(etiqueta: etiqueta, cuantos: cuantos, tono: tono),
          ],
        ),
      ],
    );
  }
}

/// Un punto de color, la cuenta y el nombre de la etapa.
class MarcaEtapa extends StatelessWidget {
  const MarcaEtapa({
    super.key,
    required this.etiqueta,
    required this.cuantos,
    required this.tono,
  });

  final String etiqueta;
  final int cuantos;
  final TonoFila tono;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: tono.tinta, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        // "Validado (2)" y no "2 validado": con la cuenta adelante hay que
        // pluralizar la etiqueta, y "validado", "con dictamen" o "solicitó
        // predictamen" no se pluralizan igual.
        Text(
          '$etiqueta ($cuantos)',
          style: AppTypography.hint.copyWith(
            color: AppColors.inkSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
