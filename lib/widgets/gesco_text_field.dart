import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Campo de formulario de GESCO: etiqueta, campo y texto de ayuda.
///
/// Reemplaza el bloque de ~45 líneas que el proyecto base repetía por cada
/// campo (los cuatro `OutlineInputBorder`, el `contentPadding`, el estilo de
/// la etiqueta). Todo eso vive ahora en `AppTheme.inputDecorationTheme`.
class GescoTextField extends StatelessWidget {
  const GescoTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.isRequired = false,
    this.readOnly = false,
    this.derivado = false,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.trailingAction,
    this.suffixIcon,
    this.autofillHints,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? helperText;
  final bool isRequired;
  final bool readOnly;

  /// Marca el campo como **autocompletado**: fondo gris, borde punteado
  /// implícito y una etiqueta verde "Automático".
  ///
  /// Es deliberado que se note. Que el CURP llene el RFC y la fecha es el
  /// argumento de por qué esto es mejor que el sistema actual; si se ve igual
  /// que un campo normal, el alumno nunca se entera.
  final bool derivado;

  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  /// Botón al ras de la etiqueta, a la derecha. Para "¿Nuevo ingreso?".
  final Widget? trailingAction;

  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final bloqueado = readOnly || derivado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: AppTypography.label,
                  children: [
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.guinda),
                      ),
                  ],
                ),
              ),
            ),
            if (derivado) ...[
              const SizedBox(width: AppSpacing.xs),
              const _EtiquetaAutomatico(),
            ],
            const Spacer(),
            if (trailingAction != null) trailingAction!,
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          readOnly: bloqueado,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          onChanged: onChanged,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTypography.input.copyWith(
            color: bloqueado ? AppColors.inkSecondary : AppColors.ink,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: bloqueado ? AppColors.surfaceMuted : AppColors.surface,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText!, style: AppTypography.hint),
        ],
      ],
    );
  }
}

class _EtiquetaAutomatico extends StatelessWidget {
  const _EtiquetaAutomatico();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successTint,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'AUTOMÁTICO',
        style: AppTypography.overline.copyWith(
          fontSize: 9.5,
          color: AppColors.successInk,
        ),
      ),
    );
  }
}

/// Campo de contraseña con el ojito para mostrarla.
class GescoPasswordField extends StatefulWidget {
  const GescoPasswordField({
    super.key,
    required this.label,
    this.controller,
    this.hintText = '••••••••••',
    this.helperText,
    this.isRequired = true,
    this.validator,
    this.onChanged,
    this.autofillHints,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  State<GescoPasswordField> createState() => _GescoPasswordFieldState();
}

class _GescoPasswordFieldState extends State<GescoPasswordField> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return GescoTextField(
      label: widget.label,
      controller: widget.controller,
      hintText: widget.hintText,
      helperText: widget.helperText,
      isRequired: widget.isRequired,
      obscureText: _oculta,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _oculta = !_oculta),
        tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
        icon: Icon(
          _oculta
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
