import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_admin.dart';
import 'configuracion_screen.dart';
import 'dictamenes_screen.dart';
import 'predictamen_screen.dart';
import 'textos_screen.dart';

/// Consejo Técnico: las cuatro pantallas del proceso de dictamen.
///
/// En el sistema actual son cuatro entradas sueltas de un menú, sin pista de
/// que una lleva a la otra. Aquí van juntas y en el orden en que ocurren: el
/// alumno solicita, entrega documentos, el consejo dictamina, y de fondo
/// están los textos y los datos de la sesión que se imprimen.
class ConsejoScreen extends StatefulWidget {
  const ConsejoScreen({super.key});

  @override
  State<ConsejoScreen> createState() => _ConsejoScreenState();
}

enum _Vista {
  predictamen('Predictamen', Icons.how_to_reg_outlined),
  dictamenes('Dictámenes', Icons.gavel_outlined),
  textos('Textos', Icons.article_outlined),
  configuracion('Sesión', Icons.settings_outlined);

  const _Vista(this.titulo, this.icono);

  final String titulo;
  final IconData icono;
}

class _ConsejoScreenState extends State<ConsejoScreen> {
  _Vista _vista = _Vista.predictamen;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
            compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
            compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CabeceraPantalla(
                contexto: 'Periodo ${DatosDemoAdmin.periodoActual} · '
                    '${DatosDemoAdmin.periodoLegible}',
                titulo: 'Consejo Técnico',
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final v in _Vista.values) ...[
                      if (v.index > 0) const SizedBox(width: AppSpacing.xs),
                      _Tab(
                        vista: v,
                        activa: v == _vista,
                        onTap: () => setState(() => _vista = v),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (_vista) {
            _Vista.predictamen => const PredictamenScreen(),
            _Vista.dictamenes => const DictamenesScreen(),
            _Vista.textos => const TextosScreen(),
            _Vista.configuracion => const ConfiguracionScreen(),
          },
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.vista,
    required this.activa,
    required this.onTap,
  });

  final _Vista vista;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activa ? AppColors.guinda : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: activa ? AppColors.guinda : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                vista.icono,
                size: 16,
                color: activa ? AppColors.onGuinda : AppColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                vista.titulo,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 13.5,
                  fontWeight: activa ? FontWeight.w800 : FontWeight.w600,
                  color: activa ? AppColors.onGuinda : AppColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
