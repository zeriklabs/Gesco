import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/gesco_text_field.dart';
import '../registro_datos.dart';

class PasoCuenta extends StatefulWidget {
  const PasoCuenta({super.key, required this.datos, required this.formKey});

  final RegistroDatos datos;
  final GlobalKey<FormState> formKey;

  @override
  State<PasoCuenta> createState() => _PasoCuentaState();
}

class _PasoCuentaState extends State<PasoCuenta> {
  RegistroDatos get d => widget.datos;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usa el correo que revisas de verdad: ahí te avisamos cuando '
            'Gestión Escolar apruebe o rechace algo.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),

          GescoTextField(
            label: 'Boleta o preboleta',
            controller: d.boleta,
            hintText: '2023670029',
            helperText: 'Si eres de nuevo ingreso usa tu preboleta con guion: '
                'PE-12345678.',
            isRequired: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(11),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z\-]')),
            ],
            textInputAction: TextInputAction.next,
            validator: Validators.boleta,
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoTextField(
            label: 'Correo electrónico',
            controller: d.correo,
            hintText: 'tucorreo@gmail.com',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.correo,
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoPasswordField(
            label: 'Contraseña',
            controller: d.password,
            validator: Validators.contrasena,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoPasswordField(
            label: 'Confirmar contraseña',
            controller: d.passwordConfirmar,
            validator: (v) => Validators.confirmarContrasena(v, d.password.text),
          ),
          const SizedBox(height: AppSpacing.md),

          ReglasContrasena(valor: d.password.text),
          const SizedBox(height: AppSpacing.lg),

          InkWell(
            onTap: () => setState(() => d.aceptaAviso = !d.aceptaAviso),
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: d.aceptaAviso,
                  onChanged: (v) => setState(() => d.aceptaAviso = v ?? false),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 11),
                    child: Text.rich(
                      TextSpan(
                        text: 'Acepto que la UPIIZ trate mis datos para fines '
                            'de gestión escolar. ',
                        children: [
                          TextSpan(
                            text: 'Aviso de privacidad',
                            style: TextStyle(
                              color: AppColors.guinda,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      style: AppTypography.bodyMedium
                          .copyWith(fontSize: 13.5, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Las tres reglas de la contraseña, marcándose conforme se cumplen.
///
/// Se muestran siempre, no solo al fallar: así el alumno sabe a qué le tira
/// antes de que lo regañe el validador.
class ReglasContrasena extends StatelessWidget {
  const ReglasContrasena({super.key, required this.valor});

  final String valor;

  @override
  Widget build(BuildContext context) {
    final reglas = <String, bool>{
      '8 caracteres': valor.length >= 8,
      'Una mayúscula': RegExp(r'[A-ZÁÉÍÓÚÑ]').hasMatch(valor),
      'Un número': RegExp(r'\d').hasMatch(valor),
    };

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.xs,
      children: [
        for (final MapEntry(key: texto, value: ok) in reglas.entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ok ? Icons.check_rounded : Icons.circle_outlined,
                size: 15,
                color: ok ? AppColors.success : AppColors.placeholder,
              ),
              const SizedBox(width: 6),
              Text(
                texto,
                style: AppTypography.hint.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ok ? AppColors.success : AppColors.placeholder,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
