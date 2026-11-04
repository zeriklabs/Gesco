import 'package:flutter/material.dart';

import '../core/layout/breakpoints.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../widgets/brand_mark.dart';
import '../features/auth/login_screen.dart';
import 'catalogos/catalogos_screen.dart';
import 'consejo/consejo_screen.dart';
import 'core/secciones_admin.dart';
import 'data/datos_demo_admin.dart';
import 'reportes/reportes_screen.dart';
import 'validar/bandeja_screen.dart';

/// El armazón del lado de Gestión Escolar.
///
/// Mismo tema y mismas piezas que el lado del alumno —es la misma
/// plataforma—, pero con su propia navegación y una franja que deja claro en
/// qué cuenta estás parado. Quien revisa expedientes también es alumno de
/// alguien: confundir las dos vistas es fácil y caro.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  SeccionAdmin _seccion = SeccionAdmin.validar;

  void _ir(SeccionAdmin destino) => setState(() => _seccion = destino);

  Widget get _contenido => switch (_seccion) {
        SeccionAdmin.validar => const BandejaScreen(),
        SeccionAdmin.consejo => const ConsejoScreen(),
        SeccionAdmin.catalogos => const CatalogosScreen(),
        SeccionAdmin.reportes => const ReportesScreen(),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion.index,
        onDestinationSelected: (i) => _ir(SeccionAdmin.values[i]),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.dangerTint,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final s in SeccionAdmin.values)
            NavigationDestination(
              icon: Icon(s.icono, color: AppColors.placeholder),
              selectedIcon: Icon(s.iconoActivo, color: AppColors.guinda),
              label: s.tituloCorto,
              tooltip: s.titulo,
            ),
        ],
      ),
    );
  }
}

class _MenuLateral extends StatelessWidget {
  const _MenuLateral({required this.actual, required this.onSeleccionar});

  final SeccionAdmin actual;
  final ValueChanged<SeccionAdmin> onSeleccionar;

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
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final s in SeccionAdmin.values)
                        _ItemMenu(
                          seccion: s,
                          activo: s == actual,
                          onTap: () => onSeleccionar(s),
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

  final SeccionAdmin seccion;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            'PERIODO ACTIVO',
            style: AppTypography.overline.copyWith(
              fontSize: 10.5,
              color: AppColors.dorado,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DatosDemoAdmin.periodoActual,
            style: AppTypography.titleLarge.copyWith(
              fontSize: 22,
              height: 1,
              color: AppColors.onGuinda,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DatosDemoAdmin.periodoLegible,
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
              color: AppColors.overlayOnGuinda,
              borderRadius: BorderRadius.circular(AppRadius.sm + 1),
              border: Border.all(color: AppColors.overlayBorderOnGuinda),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.shield_outlined,
                size: 19, color: AppColors.onGuinda),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DatosDemoAdmin.nombreRevisor,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onGuinda,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Administrador',
                  style: AppTypography.hint
                      .copyWith(color: AppColors.onGuindaFaint),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded, size: 18),
            color: AppColors.onGuindaFaint,
          ),
        ],
      ),
    );
  }
}
