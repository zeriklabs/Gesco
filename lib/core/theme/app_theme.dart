import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// El tema de GESCO.
///
/// Aquí viven las decisiones visuales que antes estaban repetidas en cada
/// pantalla: el guinda, los bordes de los campos, el radio de las esquinas.
/// Una pantalla nueva no debería necesitar declarar ninguna de esas cosas.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.guinda,
      primary: AppColors.guinda,
      onPrimary: AppColors.onGuinda,
      secondary: AppColors.dorado,
      onSecondary: const Color(0xFF3A2404),
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.danger,
      onError: AppColors.onGuinda,
      brightness: Brightness.light,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.ground,
      textTheme: AppTypography.textTheme,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.guinda,
        foregroundColor: AppColors.onGuinda,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.displaySmall.copyWith(
          color: AppColors.onGuinda,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // --- Campos de texto ---------------------------------------------------
      // Esto reemplaza los cuatro OutlineInputBorder que el proyecto base
      // repetía en cada TextFormField.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.input.copyWith(
          color: AppColors.placeholder,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: AppTypography.hint,
        errorStyle: AppTypography.hint.copyWith(
          color: AppColors.danger,
          fontWeight: FontWeight.w700,
        ),
        border: _fieldBorder(AppColors.borderStrong),
        enabledBorder: _fieldBorder(AppColors.borderStrong),
        focusedBorder: _fieldBorder(AppColors.guinda, width: 2),
        errorBorder: _fieldBorder(AppColors.danger),
        focusedErrorBorder: _fieldBorder(AppColors.danger, width: 2),
        disabledBorder: _fieldBorder(AppColors.border),
      ),

      // --- Botones -----------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.guinda,
          foregroundColor: AppColors.onGuinda,
          disabledBackgroundColor: AppColors.borderStrong,
          disabledForegroundColor: AppColors.placeholder,
          elevation: 0,
          minimumSize: const Size(0, AppSize.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(0, AppSize.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w700),
          side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.guinda,
          minimumSize: const Size(0, AppSize.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // --- Otros -------------------------------------------------------------
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.guinda
              : Colors.transparent,
        ),
        side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs / 2),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(AppColors.surface),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.success
              : AppColors.borderStrong,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.guinda
              : AppColors.borderStrong,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.onGuinda,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: AppTypography.titleLarge,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.guinda,
        linearTrackColor: AppColors.border,
        linearMinHeight: 7,
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
