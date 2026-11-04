import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_admin.dart';
import '../data/datos_demo_reportes.dart';
import '../models/reporte.dart';
import 'reporte_screen.dart';
import 'resumen_reporte.dart';

/// Los tres reportes.
///
/// En el sistema actual son tres enlaces de un menú: le picas y te sale la
/// lista. Aquí cada uno trae de entrada en qué va, porque el reporte casi
/// nunca se pide por curiosidad: se pide para ver cuántos faltan antes de que
/// cierre el periodo, y esa cuenta se puede dar sin abrir nada.
class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  Future<void> _abrir(Reporte reporte) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ReporteScreen(reporte: reporte)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        CabeceraPantalla(
          contexto: 'Periodo ${DatosDemoAdmin.periodoActual} · '
              '${DatosDemoAdmin.periodoLegible}',
          titulo: 'Reportes',
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Todos salen del periodo activo. Se pueden filtrar y descargar '
          'como CSV.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.inkSecondary,
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final r in Reporte.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
            child: _Banda(reporte: r, onTap: () => _abrir(r)),
          ),
      ],
    );
  }
}

class _Banda extends StatelessWidget {
  const _Banda({required this.reporte, required this.onTap});

  final Reporte reporte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final filas = DatosDemoReportes.filas(reporte);
    final resumen = DatosDemoReportes.resumen(reporte);
    final sinCerrar = filas.where((f) => !f.cierra).length;

    return GescoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(reporte.icono, size: 20, color: AppColors.guinda),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reporte.titulo,
                      style: AppTypography.titleLarge.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reporte.pregunta,
                      style: AppTypography.hint.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${filas.length}',
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 22,
                      height: 1,
                      color: AppColors.guinda,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    filas.length == 1 ? 'alumno' : 'alumnos',
                    style: AppTypography.hint,
                  ),
                ],
              ),
              if (!compacto) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.placeholder),
              ],
            ],
          ),
          if (filas.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ResumenReporte(resumen: resumen),
            if (sinCerrar > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$sinCerrar ${sinCerrar == 1 ? 'pendiente' : 'pendientes'}: '
                '${reporte.sinCerrar.toLowerCase()}.',
                style: AppTypography.hint.copyWith(
                  color: AppColors.guinda,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

