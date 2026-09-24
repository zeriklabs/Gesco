/// Escala de espaciado, radios y tamaños.
///
/// Todo múltiplo de 4. Si un valor no está aquí, probablemente no debería
/// existir: antes de escribir `SizedBox(height: 13)`, revisa cuál de estos
/// encaja.
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  /// Margen lateral en celular.
  static const gutterMobile = 24.0;

  /// Margen lateral del contenido en escritorio.
  static const gutterDesktop = 32.0;
}

/// Radios de esquina.
abstract final class AppRadius {
  /// Chips y etiquetas pequeñas.
  static const xs = 8.0;

  /// Iconos contenedores, botones secundarios chicos.
  static const sm = 12.0;

  /// Campos de formulario y botones.
  static const md = 14.0;

  /// Botones grandes y tarjetas pequeñas.
  static const lg = 16.0;

  /// Tarjetas.
  static const xl = 22.0;

  /// La hoja blanca que monta sobre el encabezado guinda en celular.
  static const sheet = 28.0;

  /// Píldoras de estado.
  static const pill = 999.0;
}

/// Tamaños mínimos de área táctil.
///
/// 48 es el mínimo de Material, no 44. El proyecto base usaba botones de 44 de
/// alto, que en un celular chico queda justo.
abstract final class AppSize {
  static const touchTarget = 48.0;
  static const fieldHeight = 52.0;
  static const fieldHeightDesktop = 48.0;
  static const buttonHeight = 54.0;
  static const buttonHeightDesktop = 50.0;
  static const sidebarWidth = 268.0;

  /// Ancho máximo de una columna de formulario. Más allá de esto, las líneas
  /// se vuelven incómodas de leer.
  static const formMaxWidth = 460.0;
}
