import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Desplegable con la misma etiqueta y el mismo campo que [GescoTextField].
///
/// Existe para que un formulario mezcle texto y selección sin que se note la
/// costura: misma altura, mismo borde, misma tipografía.
class GescoSelect<T> extends StatelessWidget {
  const GescoSelect({
    super.key,
    required this.label,
    required this.opciones,
    required this.onChanged,
    this.value,
    this.hintText = 'Selecciona',
    this.helperText,
    this.isRequired = false,
    this.validator,
    this.etiquetaDe,
  });

  final String label;
  final List<T> opciones;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String hintText;
  final String? helperText;
  final bool isRequired;
  final String? Function(T?)? validator;

  /// Cómo se muestra cada opción. Por defecto, su `toString()`.
  final String Function(T)? etiquetaDe;

  @override
  Widget build(BuildContext context) {
    // Si el valor guardado ya no está en la lista (por ejemplo, cambió el
    // estado y con él los municipios), no se lo pasamos al Dropdown: tronaría.
    final valorValido = value != null && opciones.contains(value)
        ? value
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
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
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          key: ValueKey('$label-$valorValido-${opciones.length}'),
          initialValue: valorValido,
          isExpanded: true,
          onChanged: opciones.isEmpty ? null : onChanged,
          validator: validator,
          style: AppTypography.input,
          icon: const Icon(Icons.expand_more_rounded, color: AppColors.muted),
          decoration: InputDecoration(
            hintText: opciones.isEmpty ? 'Sin opciones' : hintText,
            filled: true,
            fillColor: opciones.isEmpty
                ? AppColors.surfaceMuted
                : AppColors.surface,
          ),
          items: [
            for (final opcion in opciones)
              DropdownMenuItem<T>(
                value: opcion,
                child: Text(
                  etiquetaDe?.call(opcion) ?? opcion.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText!, style: AppTypography.hint),
        ],
      ],
    );
  }
}

/// Par Sí / No como dos botones, no como dos radios.
///
/// El GESCO actual usa radios: en la baja de unidad académica son once
/// preguntas Sí/No, o sea veintidós controles para decir "ninguna". Esto se
/// toca una vez y se ve el estado de un vistazo.
class OpcionSiNo extends StatelessWidget {
  const OpcionSiNo({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helperText,
    this.etiquetaSi = 'Sí',
    this.etiquetaNo = 'No',
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? helperText;
  final String etiquetaSi;
  final String etiquetaNo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: _Opcion(
                  texto: etiquetaNo,
                  activa: !value,
                  onTap: () => onChanged(false),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _Opcion(
                  texto: etiquetaSi,
                  activa: value,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
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

class _Opcion extends StatefulWidget {
  const _Opcion({
    required this.texto,
    required this.activa,
    required this.onTap,
  });

  final String texto;
  final bool activa;
  final VoidCallback onTap;

  @override
  State<_Opcion> createState() => _OpcionState();
}

class _OpcionState extends State<_Opcion> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: widget.activa,
      button: true,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm - 2),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (h) => setState(() => _pressed = h),
            borderRadius: BorderRadius.circular(AppRadius.sm - 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.activa ? AppColors.guinda : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm - 2),
                boxShadow: widget.activa
                    ? [
                        BoxShadow(
                          color: AppColors.guinda.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: widget.activa
                      ? AppColors.onGuinda
                      : AppColors.inkSecondary,
                ),
                child: Text(widget.texto),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Encabezado de sección dentro de un formulario largo.
class SeccionForm extends StatelessWidget {
  const SeccionForm({super.key, required this.titulo, this.nota});

  final String titulo;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            titulo.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppColors.muted),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(child: Divider(color: AppColors.border)),
          if (nota != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(nota!, style: AppTypography.hint),
          ],
        ],
      ),
    );
  }
}

/// Fila que se vuelve columna cuando no hay ancho.
///
/// Mete dos o tres campos lado a lado en escritorio y los apila en celular,
/// sin que cada formulario tenga que repetir el LayoutBuilder.
class CamposEnFila extends StatelessWidget {
  const CamposEnFila({
    super.key,
    required this.children,
    this.anchoMinimo = 420,
    this.flex,
  });

  final List<Widget> children;
  final double anchoMinimo;

  /// Peso de cada campo. Si es null, todos pesan igual.
  final List<int>? flex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < anchoMinimo) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                children[i],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.md),
              Expanded(flex: flex?[i] ?? 1, child: children[i]),
            ],
          ],
        );
      },
    );
  }
}
