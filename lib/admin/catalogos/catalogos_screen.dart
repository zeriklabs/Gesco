import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_admin.dart';
import '../data/datos_demo_catalogos.dart';
import '../models/catalogo.dart';
import 'documentos_screen.dart';
import 'periodos_screen.dart';
import 'plan_estudios_screen.dart';
import 'usuarios_screen.dart';

/// Lo que el sistema da por hecho.
///
/// Eran ocho entradas de un menú, todas del mismo peso. Pero cuatro de ellas
/// —carreras, niveles, grupos y materias— son **la misma cosa vista en
/// pedazos**, y por eso para mover un grupo había que entrar a una lista de
/// ciento veinte. Ahora esas cuatro son el plan de estudios, y quedan tres
/// listas sueltas que sí son listas sueltas.
class CatalogosScreen extends StatefulWidget {
  const CatalogosScreen({super.key});

  @override
  State<CatalogosScreen> createState() => _CatalogosScreenState();
}

class _CatalogosScreenState extends State<CatalogosScreen> {
  /// Los que de verdad son una lista plana.
  static const _sueltos = ['documentos', 'periodos', 'usuarios'];

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => pantalla),
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
          titulo: 'Catálogos',
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Lo que alimenta al resto del sistema.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.inkSecondary,
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _TarjetaPlan(onTap: () => _abrir(const PlanEstudiosScreen())),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnas = constraints.maxWidth >= 860 ? 3 : 1;
            final tarjetas = [
              for (final id in _sueltos)
                _TarjetaSuelta(
                  def: DatosDemoCatalogos.definicion(id),
                  onTap: () => _abrir(switch (id) {
                    'documentos' => const DocumentosScreen(),
                    'periodos' => const PeriodosScreen(),
                    _ => const UsuariosScreen(),
                  }),
                ),
            ];

            if (columnas == 1) {
              return Column(
                children: [
                  for (final t in tarjetas)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: t,
                    ),
                ],
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < tarjetas.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.sm + 2),
                    Expanded(child: tarjetas[i]),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// El plan de estudios, con el peso que le toca: es el que se usa.
class _TarjetaPlan extends StatelessWidget {
  const _TarjetaPlan({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final carreras = DatosDemoCatalogos.filas('carreras').length;
    final niveles = DatosDemoCatalogos.filas('niveles').length;
    final grupos = DatosDemoCatalogos.filas('grupos').length;
    final materias = DatosDemoCatalogos.filas('materias').length;

    return GescoCard(
      onTap: onTap,
      color: AppColors.guinda,
      colorBorde: AppColors.guinda,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree_outlined,
                  size: 22, color: AppColors.dorado),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Plan de estudios',
                  style: AppTypography.displaySmall
                      .copyWith(color: AppColors.onGuinda),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.onGuindaMuted),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Carreras, niveles, grupos y materias.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onGuindaMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.sm,
            children: [
              _Cuenta(numero: carreras, que: 'carreras'),
              _Cuenta(numero: niveles, que: 'niveles'),
              _Cuenta(numero: grupos, que: 'grupos'),
              _Cuenta(numero: materias, que: 'materias'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cuenta extends StatelessWidget {
  const _Cuenta({required this.numero, required this.que});

  final int numero;
  final String que;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$numero',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 22,
            height: 1,
            color: AppColors.onGuinda,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          que,
          style: AppTypography.hint.copyWith(color: AppColors.onGuindaFaint),
        ),
      ],
    );
  }
}

class _TarjetaSuelta extends StatelessWidget {
  const _TarjetaSuelta({required this.def, required this.onTap});

  final DefinicionCatalogo def;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cuantos = DatosDemoCatalogos.filas(def.id).length;

    return GescoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(def.icono, size: 19, color: AppColors.guinda),
              const Spacer(),
              Text(
                '$cuantos',
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 18,
                  color: AppColors.guinda,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(def.nombre, style: AppTypography.titleLarge.copyWith(fontSize: 15)),
          const SizedBox(height: 3),
          Text(def.paraQue, style: AppTypography.hint.copyWith(height: 1.45)),
          if (def.soloLectura) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 12, color: AppColors.muted),
                const SizedBox(width: 4),
                Text('Solo consulta', style: AppTypography.hint),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
