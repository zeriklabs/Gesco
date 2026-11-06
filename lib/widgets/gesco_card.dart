import 'package:flutter/material.dart';

import '../core/layout/breakpoints.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// La tarjeta base del sistema: fondo blanco, borde de 1.5 y esquinas de 22.
class GescoCard extends StatelessWidget {
  const GescoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg + 2),
    this.color,
    this.colorBorde,
    this.bordeGrueso = false,
    this.accionEsquina,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? colorBorde;

  /// Borde de 2 px para la tarjeta que exige atención.
  final bool bordeGrueso;

  /// Un widget que se posiciona de forma absoluta en la esquina superior derecha.
  final Widget? accionEsquina;

  final VoidCallback? onTap;

  Widget _buildContenido() {
    if (accionEsquina == null) {
      return Padding(
        padding: padding,
        child: child,
      );
    }

    return Stack(
      children: [
        Padding(
          padding: padding,
          child: child,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: accionEsquina!,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoracion = BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      border: Border.all(
        color: colorBorde ?? AppColors.border,
        width: bordeGrueso ? 2 : 1.5,
      ),
    );

    if (onTap == null) {
      return Container(
        decoration: decoracion,
        child: _buildContenido(),
      );
    }

    return Material(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: decoracion.copyWith(color: Colors.transparent),
          child: _buildContenido(),
        ),
      ),
    );
  }
}

/// Encabezado de pantalla: una línea de contexto arriba y el título abajo.
class CabeceraPantalla extends StatelessWidget {
  const CabeceraPantalla({
    super.key,
    required this.titulo,
    this.contexto,
    this.acciones = const [],
  });

  final String titulo;
  final String? contexto;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    final texto = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titulo,
          style: compacto
              ? AppTypography.displayMedium
              : AppTypography.displayLarge,
        ),
        if (contexto != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(contexto!, style: AppTypography.bodySmall.copyWith(fontSize: 13)),
        ],
      ],
    );

    if (acciones.isEmpty) return texto;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: texto),
        const SizedBox(width: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < acciones.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              acciones[i],
            ],
          ],
        ),
      ],
    );
  }
}

/// El aviso que encabeza una pantalla cuando algo exige acción.
///
/// Lleva el texto completo de la observación, no solo un icono: hoy el alumno
/// ve un tache rojo y tiene que ir a Gestión Escolar a preguntar qué pasó.
class BannerAviso extends StatelessWidget {
  const BannerAviso({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.pie,
    this.accion,
    this.tono = TonoAviso.alerta,
  });

  final String titulo;
  final String mensaje;
  final String? pie;
  final Widget? accion;
  final TonoAviso tono;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    final cuerpo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titulo,
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          mensaje,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.inkSecondary,
            height: 1.5,
          ),
        ),
        if (pie != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(pie!, style: AppTypography.hint),
        ],
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tono.fondo,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        border: Border.all(color: tono.borde, width: 2),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tono.acento,
                  shape: BoxShape.circle,
                ),
                child: Icon(tono.icono, size: 16, color: AppColors.onGuinda),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: cuerpo),
              if (accion != null && !compacto) ...[
                const SizedBox(width: AppSpacing.md),
                accion!,
              ],
            ],
          ),
          if (accion != null && compacto) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(width: double.infinity, child: accion!),
          ],
        ],
      ),
    );
  }
}

enum TonoAviso {
  alerta,
  informativo;

  Color get fondo => switch (this) {
        TonoAviso.alerta => AppColors.dangerTint,
        TonoAviso.informativo => AppColors.warningTint,
      };

  Color get borde => switch (this) {
        TonoAviso.alerta => AppColors.dangerBorder,
        TonoAviso.informativo => AppColors.warningBorder,
      };

  Color get acento => switch (this) {
        TonoAviso.alerta => AppColors.guinda,
        TonoAviso.informativo => AppColors.warningInk,
      };

  IconData get icono => switch (this) {
        TonoAviso.alerta => Icons.priority_high_rounded,
        TonoAviso.informativo => Icons.info_outline_rounded,
      };
}

/// Título de bloque dentro de una pantalla, con acción opcional a la derecha.
class TituloBloque extends StatelessWidget {
  const TituloBloque({
    super.key,
    required this.texto,
    this.accion,
    this.insignia,
  });

  final String texto;
  final Widget? accion;
  final Widget? insignia;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            texto,
            style: AppTypography.displaySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (insignia != null) ...[
          const SizedBox(width: AppSpacing.xs),
          insignia!,
        ],
        const Spacer(),
        ?accion,
      ],
    );
  }
}

/// Barra de avance segmentada: un tramo por elemento.
///
/// Se usa para el expediente (4 pasos) y para los documentos de un trámite.
class BarraSegmentos extends StatelessWidget {
  const BarraSegmentos({
    super.key,
    required this.colores,
    this.alto = 7,
  });

  /// Un color por tramo, en orden.
  final List<Color> colores;
  final double alto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < colores.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: Container(
              height: alto,
              decoration: BoxDecoration(
                color: colores[i],
                borderRadius: BorderRadius.circular(alto / 2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
