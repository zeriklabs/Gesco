import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/brand_mark.dart';

/// Las secciones del alumno.
enum Seccion {
  inicio('Inicio', Icons.home_rounded, Icons.home_outlined),
  expediente('Mi expediente', Icons.person_rounded, Icons.person_outline_rounded),
  solicitudes('Solicitudes', Icons.description_rounded, Icons.description_outlined),
  documentos('Mis documentos', Icons.folder_rounded, Icons.folder_outlined),
  adeudos('Adeudos', Icons.bar_chart_rounded, Icons.bar_chart_outlined);

  const Seccion(this.titulo, this.iconoActivo, this.icono);

  final String titulo;
  final IconData iconoActivo;
  final IconData icono;

  /// En la barra inferior no cabe "Mi expediente".
  String get tituloCorto => switch (this) {
        expediente => 'Expediente',
        documentos => 'Documentos',
        _ => titulo,
      };
}

/// El armazón de la aplicación.
///
/// Un solo árbol para web y celular. Arriba de 1000 px se dibuja el menú
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

  @override
  Widget build(BuildContext context) {
    if (context.hasSidebar) {
      return Scaffold(
        body: Row(
          children: [
            _MenuLateral(actual: _seccion, onSeleccionar: _ir),
            Expanded(child: _Contenido(seccion: _seccion)),
          ],
        ),
      );
    }

    return Scaffold(
      body: _Contenido(seccion: _seccion),
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
          for (final seccion in Seccion.values)
            _ItemMenu(
              seccion: seccion,
              activo: seccion == actual,
              onTap: () => onSeleccionar(seccion),
            ),
          const Spacer(),
          const _TarjetaPeriodo(),
          const SizedBox(height: AppSpacing.xl),
          const _ChipUsuario(),
        ],
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
                  // El activo va blanco con texto guinda: guinda sobre guinda
                  // no se distingue.
                  color: activo ? AppColors.guinda : const Color(0xFFD6BDB7),
                ),
                const SizedBox(width: AppSpacing.sm + 1),
                Expanded(
                  child: Text(
                    seccion.titulo,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 14.5,
                      fontWeight: activo ? FontWeight.w700 : FontWeight.w600,
                      color: activo ? AppColors.guinda : const Color(0xFFD6BDB7),
                    ),
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
            '27/1',
            style: AppTypography.titleLarge.copyWith(
              fontSize: 22,
              height: 1,
              color: AppColors.onGuinda,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ago 2026 – Ene 2027',
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
              'GG',
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
                  'Gael García',
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onGuinda,
                  ),
                ),
                Text(
                  '2023670029',
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
          ),
      ],
    );
  }
}

/// Provisional: el contenido real de cada sección llega en las siguientes
/// entregas. Lo que ya funciona aquí es el armazón responsivo.
class _Contenido extends StatelessWidget {
  const _Contenido({required this.seccion});

  final Seccion seccion;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Boleta 2023670029 · Ing. en Sistemas Computacionales · 8CM1',
              style: AppTypography.bodySmall.copyWith(fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              seccion == Seccion.inicio ? 'Hola, Gael' : seccion.titulo,
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
      ),
    );
  }
}
