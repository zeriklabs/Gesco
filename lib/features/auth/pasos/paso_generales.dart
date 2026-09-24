import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/gesco_select.dart';
import '../../../widgets/gesco_text_field.dart';
import '../registro_datos.dart';

/// Datos generales: una pregunta, y dos campos más solo si contestas que sí.
///
/// El GESCO actual hace lo mismo, y está bien: es de las pocas pantallas que
/// no pide de más.
class PasoGenerales extends StatefulWidget {
  const PasoGenerales({super.key, required this.datos, required this.formKey});

  final RegistroDatos datos;
  final GlobalKey<FormState> formKey;

  @override
  State<PasoGenerales> createState() => _PasoGeneralesState();
}

class _PasoGeneralesState extends State<PasoGenerales> {
  RegistroDatos get d => widget.datos;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dos preguntas rápidas y terminamos con esta parte.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),

          OpcionSiNo(
            label: '¿Trabajas?',
            value: d.trabaja,
            helperText: 'Si trabajas, la escuela lo toma en cuenta al '
                'revisar una solicitud de carga mínima.',
            onChanged: (v) => setState(() => d.trabaja = v),
          ),

          if (d.trabaja) ...[
            const SizedBox(height: AppSpacing.lg),
            GescoTextField(
              label: 'Horario de trabajo',
              controller: d.horarioTrabajo,
              hintText: 'Lunes a viernes, 15:00 a 21:00',
              isRequired: true,
              validator: (v) =>
                  Validators.requerido(v, campo: 'El horario de trabajo'),
            ),
            const SizedBox(height: AppSpacing.lg),
            GescoTextField(
              label: 'Datos del trabajo',
              controller: d.datosTrabajo,
              hintText: 'Nombre de la empresa, dirección y teléfono',
              helperText: 'Los tres datos en el mismo campo, como los pide '
                  'el formato.',
              isRequired: true,
              maxLines: 3,
              validator: (v) =>
                  Validators.requerido(v, campo: 'Los datos del trabajo'),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          const SeccionForm(titulo: 'Privacidad'),

          OpcionSiNo(
            label: '¿Tu tutor puede consultar tu información?',
            value: d.visibleParaTutor,
            onChanged: (v) => setState(() => d.visibleParaTutor = v),
          ),
          const SizedBox(height: AppSpacing.sm),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.ground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.guinda),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    d.visibleParaTutor
                        ? 'Tu tutor podrá ver el estado de tus trámites si '
                            'llama o se presenta en Gestión Escolar.'
                        : 'Solo tú puedes consultar tus trámites. Puedes '
                            'cambiarlo después desde tu perfil.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.inkSecondary, height: 1.5),
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
