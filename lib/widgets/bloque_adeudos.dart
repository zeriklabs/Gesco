import 'package:flutter/material.dart';

import '../core/models/expediente.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// La lista de adeudos, para capturarla sin salirse de un trámite.
///
/// Vive aquí y no dentro de una pantalla porque la usan el dictamen y la
/// reinscripción. Es el mismo principio que la sección de Adeudos: en el
/// GESCO actual este bloque está cuatro veces, cada una con su captura.
class BloqueAdeudos extends StatelessWidget {
  const BloqueAdeudos({
    super.key,
    required this.adeudos,
    required this.onAgregar,
    required this.onQuitar,
    this.textoVacio,
  });

  final List<Adeudo> adeudos;
  final VoidCallback onAgregar;
  final void Function(Adeudo) onQuitar;

  /// Qué decir cuando no hay ninguno.
  final String? textoVacio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (adeudos.isEmpty)
          Text(
            textoVacio ??
                'Tu expediente no registra materias que debas. Si reprobaste '
                    'alguna y no aparece, agrégala aquí mismo.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.inkSecondary,
              height: 1.5,
            ),
          )
        else
          for (final a in adeudos)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _FilaAdeudo(adeudo: a, onQuitar: () => onQuitar(a)),
            ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onAgregar,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Agregar una materia que debes'),
          ),
        ),
      ],
    );
  }
}

class _FilaAdeudo extends StatelessWidget {
  const _FilaAdeudo({required this.adeudo, required this.onQuitar});

  final Adeudo adeudo;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm + 2,
        AppSpacing.xs,
        AppSpacing.xxs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adeudo.unidadAprendizaje,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${adeudo.nivel} · reprobada en ${adeudo.periodoReprobada} '
                  '· ${adeudo.estado}',
                  style: AppTypography.hint,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onQuitar,
            tooltip: 'Quitar ${adeudo.unidadAprendizaje}',
            icon: const Icon(Icons.close_rounded, size: 17),
            color: AppColors.muted,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
