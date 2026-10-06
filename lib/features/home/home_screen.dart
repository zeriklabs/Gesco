import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/layout/secciones.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/brand_mark.dart';
import '../adeudos/adeudos_screen.dart';
import '../auth/login_screen.dart';
import '../expediente/expediente_screen.dart';
import '../inicio/inicio_screen.dart';
import '../solicitudes/solicitudes_screen.dart';

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
  bool _railHovered = false;

  void _ir(Seccion destino) => setState(() => _seccion = destino);

  Widget get _contenido => switch (_seccion) {
    Seccion.inicio => InicioScreen(onIr: _ir),
    Seccion.expediente => ExpedienteScreen(onIr: _ir),
    Seccion.solicitudes => SolicitudesScreen(onIr: _ir),
    Seccion.adeudos => AdeudosScreen(onIr: _ir),
  };

  @override
  Widget build(BuildContext context) {
    if (!context.formFactor.isCompact) {
      return Scaffold(
        body: Stack(
          children: [
            Row(
              children: [
                const SizedBox(width: 80),
                Expanded(child: SafeArea(child: _contenido)),
              ],
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: _railHovered ? AppSize.sidebarWidth : 80.0,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _railHovered = true),
                  onExit: (_) => setState(() => _railHovered = false),
                  child: Material(
                    elevation: _railHovered ? 8 : 0,
                    color: AppColors.guinda,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: AppSize.sidebarWidth,
                        maxWidth: AppSize.sidebarWidth,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              width: 80,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: _railHovered ? 0.0 : 1.0,
                                child: IgnorePointer(
                                  ignoring: _railHovered,
                                  child: _MenuLateralRail(
                                    actual: _seccion,
                                    onSeleccionar: _ir,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              width: AppSize.sidebarWidth,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: _railHovered ? 1.0 : 0.0,
                                child: IgnorePointer(
                                  ignoring: !_railHovered,
                                  child: _MenuLateral(
                                    actual: _seccion,
                                    onSeleccionar: (s) {
                                      _ir(s);
                                      setState(() => _railHovered = false);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                  style: AppTypography.hint.copyWith(
                    color: AppColors.onGuindaFaint,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => cerrarSesion(context),
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded, size: 18),
            color: AppColors.onGuindaFaint,
          ),
        ],
      ),
    );
  }
}

/// Muestra un diálogo de confirmación y regresa al LoginScreen.
void cerrarSesion(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('¿Cerrar sesión?', style: AppTypography.titleLarge),
      content: Text(
        'Saldrás de tu cuenta de GESCO y regresarás a la pantalla de inicio de sesión.',
        style: AppTypography.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesión cerrada correctamente.'),
                backgroundColor: AppColors.guinda,
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.guinda,
            foregroundColor: AppColors.onGuinda,
          ),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );
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

class _MenuLateralRail extends StatelessWidget {
  const _MenuLateralRail({required this.actual, required this.onSeleccionar});

  final Seccion actual;
  final ValueChanged<Seccion> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: actual.index,
      onDestinationSelected: (i) => onSeleccionar(Seccion.values[i]),
      backgroundColor: AppColors.guinda,
      minWidth: 80,
      selectedIconTheme: const IconThemeData(color: AppColors.guinda),
      unselectedIconTheme: const IconThemeData(color: Color(0xFFD6BDB7)),
      selectedLabelTextStyle: AppTypography.bodySmall.copyWith(
        color: AppColors.surface,
        fontWeight: FontWeight.bold,
        fontSize: 11.5,
      ),
      unselectedLabelTextStyle: AppTypography.bodySmall.copyWith(
        color: const Color(0xFFD6BDB7),
        fontSize: 11.5,
      ),
      indicatorColor: AppColors.surface,
      labelType: NavigationRailLabelType.all,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: BrandMark(mostrarNombre: false),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: IconButton(
              onPressed: () => cerrarSesion(context),
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout_rounded),
              color: const Color(0xFFD6BDB7),
            ),
          ),
        ),
      ),
      destinations: [
        for (final seccion in Seccion.values)
          NavigationRailDestination(
            icon: Icon(seccion.icono),
            selectedIcon: Icon(seccion.iconoActivo),
            label: Text(
              seccion.tituloCorto,
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ),
      ],
    );
  }
}
