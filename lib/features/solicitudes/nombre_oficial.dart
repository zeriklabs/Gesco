import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';

/// Cómo se llama este trámite en los formatos y en la ventanilla.
///
/// En la interfaz les decimos por su nombre común —"baja de materias", "baja
/// de la escuela"— porque es como los nombra el alumno. Pero el PDF que
/// firma, el oficio que le devuelven y la persona que lo atiende usan el
/// nombre del reglamento. Traducir sin decirlo dejaría al alumno pidiendo en
/// ventanilla algo que ahí no existe.
class NombreOficial extends StatelessWidget {
  const NombreOficial({super.key, required this.nombre, this.nota});

  final String nombre;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      color: AppColors.surfaceAlt,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 16, color: AppColors.muted),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'EN VENTANILLA SE LLAMA',
                style: AppTypography.overline.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            nombre,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          if (nota != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(nota!, style: AppTypography.hint),
          ],
        ],
      ),
    );
  }
}
