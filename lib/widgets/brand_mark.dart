import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// El escudo del IPN más el nombre del sistema.
///
/// El PNG del IPN que trae el proyecto es **blanco**: solo se ve sobre guinda.
/// Para fondos claros no hace falta otro archivo — se tiñe con `srcIn`, que
/// respeta el canal alfa y pinta del color que le digamos.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.onDark = true,
    this.logoHeight = 34,
    this.mostrarNombre = true,
    this.subtitulo = 'UPIIZ',
  });

  /// `true` sobre guinda, `false` sobre fondo claro.
  final bool onDark;
  final double logoHeight;
  final bool mostrarNombre;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IpnLogo(height: logoHeight, onDark: onDark),
        if (mostrarNombre) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 1,
            height: logoHeight * 0.7,
            color: onDark ? AppColors.overlayBorderOnGuinda : AppColors.border,
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GESCO',
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: onDark ? AppColors.onGuinda : AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitulo.toUpperCase(),
                style: AppTypography.overline.copyWith(
                  fontSize: 10,
                  color: onDark ? AppColors.dorado : AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// El escudo solo.
class IpnLogo extends StatelessWidget {
  const IpnLogo({super.key, this.height = 34, this.onDark = true});

  final double height;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_ipn.png',
      height: height,
      // `contain`, no `cover`: el proyecto base usaba `cover` dentro de un
      // SizedBox, lo que recortaba el escudo por los lados.
      fit: BoxFit.contain,
      color: onDark ? null : AppColors.guinda,
      colorBlendMode: onDark ? null : BlendMode.srcIn,
      semanticLabel: 'Instituto Politécnico Nacional',
      errorBuilder: (_, __, ___) => Icon(
        Icons.school_outlined,
        size: height * 0.8,
        color: onDark ? AppColors.onGuinda : AppColors.guinda,
      ),
    );
  }
}

/// El engrane de la UPIIZ.
///
/// Este sí tiene fondo blanco sólido, no transparente, así que sobre guinda se
/// vería un recuadro. Va únicamente sobre superficies claras.
class UpiizLogo extends StatelessWidget {
  const UpiizLogo({super.key, this.size = 78});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_upiiz.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Unidad Interdisciplinaria de Ingeniería Campus Zacatecas',
      errorBuilder: (_, __, ___) => Icon(
        Icons.account_balance_outlined,
        size: size * 0.6,
        color: AppColors.guinda,
      ),
    );
  }
}
