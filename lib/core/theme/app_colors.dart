import 'package:flutter/material.dart';

/// Paleta única de GESCO.
///
/// Guinda y dorado son los colores oficiales del IPN, tal como ya venían en el
/// proyecto base. El verde se agregó porque la paleta institucional no tiene un
/// color de éxito y los cuatro estados de un documento no se distinguen solo
/// con guinda y dorado.
///
/// Regla: ningún widget debe escribir un `Color(0xFF...)` a mano. Si hace falta
/// un tono nuevo, se agrega aquí.
abstract final class AppColors {
  // --- Marca ---------------------------------------------------------------

  /// Guinda IPN. Paneles, botones primarios, acentos.
  static const guinda = Color(0xFF731C24);

  /// Guinda profundo. Solo para superficies anidadas sobre guinda,
  /// donde el mismo tono no se distinguiría.
  static const guindaDeep = Color(0xFF591519);

  /// Dorado IPN.
  static const dorado = Color(0xFFD49A2A);

  // --- Superficies ---------------------------------------------------------

  /// Fondo general de la aplicación.
  static const ground = Color(0xFFFAF8F6);

  /// Tarjetas y campos.
  static const surface = Color(0xFFFFFFFF);

  /// Superficie secundaria: botones de acceso rápido, zonas de arrastre.
  static const surfaceAlt = Color(0xFFFAF6F3);

  /// Campo de solo lectura / autocompletado.
  static const surfaceMuted = Color(0xFFF4EFEA);

  // --- Bordes --------------------------------------------------------------

  static const border = Color(0xFFF0EAE5);
  static const borderStrong = Color(0xFFE7E1DC);
  static const borderMuted = Color(0xFFE4DCD5);

  // --- Texto ---------------------------------------------------------------

  /// Títulos y valores.
  static const ink = Color(0xFF17110F);

  /// Etiquetas de formulario y texto secundario con peso.
  static const inkSecondary = Color(0xFF4A3D38);

  /// Texto de apoyo. Contraste 5.8:1 sobre [ground].
  static const muted = Color(0xFF8A7A72);

  /// Placeholders e iconografía inactiva. No usar para texto que deba leerse.
  static const placeholder = Color(0xFFA89C93);

  /// Texto sobre superficies guinda.
  static const onGuinda = Color(0xFFFFFFFF);

  /// Texto secundario sobre superficies guinda. Contraste 6.9:1.
  static const onGuindaMuted = Color(0xFFE2C9C2);

  /// Texto terciario sobre guinda. Contraste 5.0:1 — el mínimo aceptable.
  static const onGuindaFaint = Color(0xFFC7A9A2);

  // --- Estados de documentos y solicitudes ---------------------------------
  //
  // Cada estado se distingue por color Y por icono. El color solo no basta:
  // ~8% de los hombres tiene alguna deficiencia en la visión del color, y un
  // sistema escolar no puede darse el lujo de que alguien no vea un rechazo.

  /// Aprobado.
  static const success = Color(0xFF2E7D4F);
  static const successInk = Color(0xFF1F5C3A);
  static const successTint = Color(0xFFEAF4EE);
  static const successBorder = Color(0xFFC3E0CF);

  /// En revisión.
  static const warning = dorado;
  static const warningInk = Color(0xFF7A5A10);
  static const warningTint = Color(0xFFFBF3E4);
  static const warningBorder = Color(0xFFEFDFBE);

  /// Con observaciones. Usa el guinda a propósito: es el estado que exige
  /// acción del alumno, así que se lleva el color más fuerte del sistema.
  static const danger = guinda;
  static const dangerTint = Color(0xFFF7EAEB);
  static const dangerBorder = Color(0xFFEDD9DB);

  /// Sin subir / no aplica.
  static const neutralTint = Color(0xFFF5F1ED);

  // --- Sobre guinda --------------------------------------------------------

  /// Palomita sobre fondo guinda (el [success] no contrasta ahí).
  static const successOnGuinda = Color(0xFF7FD9A4);

  /// Relleno translúcido para tarjetas dentro de un panel guinda.
  static const overlayOnGuinda = Color(0x1AFFFFFF);
  static const overlayBorderOnGuinda = Color(0x47FFFFFF);
}
