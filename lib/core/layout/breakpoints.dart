import 'package:flutter/widgets.dart';

/// Un solo código, dos respiraciones.
///
/// GESCO corre en web y en celular desde el mismo árbol de widgets. Lo que
/// cambia con el ancho es el **layout** (menú lateral vs. barra inferior,
/// una columna vs. dos), nunca el tema ni los colores.
enum FormFactor {
  /// Celular. Barra inferior, una columna, hoja blanca sobre encabezado guinda.
  compact,

  /// Tablet o ventana angosta. Una columna ancha, sin menú lateral.
  medium,

  /// Escritorio. Menú lateral guinda y contenido en varias columnas.
  expanded;

  bool get isCompact => this == FormFactor.compact;
  bool get isExpanded => this == FormFactor.expanded;

  /// `true` cuando toca dibujar el menú lateral en vez de la barra inferior.
  bool get hasSidebar => this == FormFactor.expanded;
}

abstract final class Breakpoints {
  /// Debajo de esto, una sola columna y navegación inferior.
  static const compact = 600.0;

  /// A partir de aquí cabe el layout de dos paneles sin apretarse.
  ///
  /// Estaba en 1000 y no alcanzaba: el panel de marca más el formulario más
  /// sus márgenes piden ~1100. Entre 1000 y 1100 las filas se desbordaban.
  static const expanded = 1100.0;

  static FormFactor of(BuildContext context) {
    return fromWidth(MediaQuery.sizeOf(context).width);
  }

  static FormFactor fromWidth(double width) {
    if (width < compact) return FormFactor.compact;
    if (width < expanded) return FormFactor.medium;
    return FormFactor.expanded;
  }
}

/// Azúcar para no escribir `Breakpoints.of(context)` en cada build.
extension FormFactorContext on BuildContext {
  FormFactor get formFactor => Breakpoints.of(this);
  bool get isCompact => formFactor.isCompact;
  bool get hasSidebar => formFactor.hasSidebar;
}
