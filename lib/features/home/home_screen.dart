import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/layout/secciones.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/brand_mark.dart';
import '../expediente/expediente_screen.dart';
import '../inicio/inicio_screen.dart';

/// El armazón de la aplicación.
///
/// Un solo árbol para web y celular. Arriba de 1100 px se dibuja el menú
/// lateral guinda; abajo, la barra inferior. El contenido de cada sección es
/// el mismo widget en los dos casos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Seccion _seccion = Seccion.inicio;

  void _ir(Seccion destino) => setState(() => _seccion = destino);

  Widget get _contenido => switch (_seccion) {
        Seccion.inicio => InicioScreen(onIr: _ir),
        Seccion.expediente => ExpedienteScreen(onIr: _ir),
        _ => _EnConstruccion(seccion: _seccion),
      };

  @override
  Widget build(BuildContext context) {
    if (context.hasSidebar) {
      return Scaffold(
        body: Row(
          children: [
            _MenuLateral(actual: _seccion, onSeleccionar: _ir),
            Expanded(child: SafeArea(child: _contenido)),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(bottom: false, child: _contenido),
      bottomNavigationBar: _BarraInferior(actual: _seccion, onSeleccionar: _ir),
    );
  }
}

class _MenuLateral extends StatelessWidget {
  const _MenuLateral({required this.actual, required this.onSeleccionar});

  final Seccion actual;
  final ValueChanged<Seccion> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.sidebarWidth,
      color: AppColors.guinda,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: AppSpacing.xl + 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: BrandMark(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final seccion in Seccion.values)
                        _ItemMenu(
                          seccion: seccion,
                          activo: seccion == actual,
                          onTap: () => onSeleccionar(seccion),
                        ),
                    ],
                  ),
                ),
              ),
              const _TarjetaPeriodo(),
              const SizedBox(height: AppSpacing.lg),
              const _ChipUsuario(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({
    required this.seccion,
    required this.activo,
    required this.onTap,
  });

  final Seccion seccion;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // El activo va blanco con texto guinda: guinda sobre guinda no se
    // distingue.
    final color = activo ? AppColors.guinda : const Color(0xFFD6BDB7);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: activo ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm + 1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  activo ? seccion.iconoActivo : seccion.icono,
                  size: 19,
                  color: color,
                ),
                const SizedBox(width: AppSpacing.sm + 1),
                Expanded(
                  child: Text(
                    seccion.titulo,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 14.5,
                      fontWeight: activo ? FontWeight.w700 : FontWeight.w600,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaPeriodo extends StatelessWidget {
  const _TarjetaPeriodo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.guindaDeep,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERIODO A CURSAR',
            style: AppTypography.overline.copyWith(
              fontSize: 10.5,
              color: AppColors.dorado,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DatosDemo.periodoActual,
            style: AppTypography.titleLarge.copyWith(
              fontSize: 22,
              height: 1,
              color: AppColors.onGuinda,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DatosDemo.periodoLegible,
            style: AppTypography.hint.copyWith(color: AppColors.onGuindaMuted),
          ),
        ],
      ),
    );
  }
}

class _ChipUsuario extends StatelessWidget {
  const _ChipUsuario();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.dorado,
              borderRadius: BorderRadius.circular(AppRadius.sm + 1),
            ),
            alignment: Alignment.center,
            child: Text(
              DatosDemo.iniciales,
              style: AppTypography.titleLarge.copyWith(
                fontSize: 15,
                color: const Color(0xFF3A2404),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DatosDemo.nombreAlumno,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onGuinda,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DatosDemo.boleta,
                  style: AppTypography.hint
                      .copyWith(color: AppColors.onGuindaFaint),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded, size: 18),
            color: AppColors.onGuindaFaint,
          ),
        ],
      ),
    );
  }
}

class _BarraInferior extends StatelessWidget {
  const _BarraInferior({required this.actual, required this.onSeleccionar});

  final Seccion actual;
  final ValueChanged<Seccion> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: actual.index,
      onDestinationSelected: (i) => onSeleccionar(Seccion.values[i]),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.dangerTint,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final seccion in Seccion.values)
          NavigationDestination(
            icon: Icon(seccion.icono, color: AppColors.placeholder),
            selectedIcon: Icon(seccion.iconoActivo, color: AppColors.guinda),
            label: seccion.tituloCorto,
            tooltip: seccion.titulo,
          ),
      ],
    );
  }
}

/// Provisional, para las secciones que todavía no se construyen.
class _EnConstruccion extends StatelessWidget {
  const _EnConstruccion({required this.seccion});

  final Seccion seccion;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return Padding(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            seccion.titulo,
            style: compacto
                ? AppTypography.displayMedium
                : AppTypography.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(seccion.icono, size: 34, color: AppColors.placeholder),
                    const SizedBox(height: AppSpacing.sm),
                    Text(seccion.titulo, style: AppTypography.titleLarge),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Pantalla en construcción.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
