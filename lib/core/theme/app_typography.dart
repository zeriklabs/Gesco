import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografía de GESCO.
///
/// Dos familias:
/// - **Bricolage Grotesque** para títulos y cifras. Geométrica y pesada, con
///   el tracking muy cerrado: es lo que le da el aire moderno al sistema,
///   más que el color.
/// - **Plus Jakarta Sans** para todo el cuerpo.
///
/// Se cargan con `google_fonts`, que las descarga la primera vez y las cachea.
/// Si en la escuela hay equipos sin internet, hay que bajarlas a
/// `assets/fonts/` y declararlas en el pubspec; el resto del código no cambia.
abstract final class AppTypography {
  static TextStyle _display(double size, {FontWeight weight = FontWeight.w700}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: size,
      fontWeight: weight,
      height: 1.05,
      // El tracking negativo es deliberado y escala con el tamaño: en títulos
      // grandes se nota, en los chicos apenas.
      letterSpacing: size * -0.035,
      color: AppColors.ink,
    );
  }

  static TextStyle _body(
    double size, {
    FontWeight weight = FontWeight.w500,
    double height = 1.45,
    Color color = AppColors.ink,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }

  // --- Títulos -------------------------------------------------------------

  /// Encabezado de pantalla en escritorio.
  static TextStyle get displayLarge => _display(33);

  /// Encabezado de pantalla en celular.
  static TextStyle get displayMedium => _display(28, weight: FontWeight.w800);

  /// Título de sección dentro de una tarjeta.
  static TextStyle get displaySmall => _display(21);

  /// Título de tarjeta.
  static TextStyle get titleLarge => _display(18);

  /// Cifra grande (promedio, créditos, contadores).
  static TextStyle get numeral => _display(32, weight: FontWeight.w800);

  // --- Cuerpo --------------------------------------------------------------

  static TextStyle get bodyLarge => _body(16, weight: FontWeight.w500, height: 1.5);
  static TextStyle get bodyMedium => _body(14, weight: FontWeight.w500);
  static TextStyle get bodySmall =>
      _body(12.5, weight: FontWeight.w500, color: AppColors.muted);

  /// Texto dentro de un campo de formulario.
  static TextStyle get input => _body(15, weight: FontWeight.w600, height: 1.2);

  /// Etiqueta de campo.
  static TextStyle get label =>
      _body(12.5, weight: FontWeight.w700, color: AppColors.inkSecondary, height: 1.3);

  /// Texto de ayuda debajo de un campo.
  static TextStyle get hint =>
      _body(12, weight: FontWeight.w500, color: AppColors.muted, height: 1.45);

  /// Texto de un botón.
  static TextStyle get button => _body(15.5, weight: FontWeight.w800, height: 1.2);

  /// Píldora de estado y etiquetas en versalitas.
  static TextStyle get pill => _body(11.5, weight: FontWeight.w800, height: 1.2);

  /// Encabezado en versalitas, con mucho tracking.
  static TextStyle get overline => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        height: 1.3,
        color: AppColors.muted,
      );

  /// Construye el TextTheme que consume Material.
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineSmall: titleLarge,
        titleLarge: titleLarge,
        titleMedium: _body(15, weight: FontWeight.w700),
        titleSmall: _body(13.5, weight: FontWeight.w700),
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: button,
        labelMedium: label,
        labelSmall: pill,
      );
}
