import 'package:flutter/material.dart';

import '../../../core/data/catalogos.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/gesco_card.dart';
import '../../../widgets/gesco_select.dart';
import '../registro_datos.dart';

/// Paso de datos escolares básicos durante el alta inicial.
///
/// Solo pregunta la Carrera y si es Nuevo Ingreso. Los datos detallados de
/// reinscripción (promedio, adeudos, dictamen, carga) se completan después en el
/// inicio mediante "Completa tu expediente".
class PasoEscolares extends StatefulWidget {
  const PasoEscolares({super.key, required this.datos, required this.formKey});

  final RegistroDatos datos;
  final GlobalKey<FormState> formKey;

  @override
  State<PasoEscolares> createState() => _PasoEscolaresState();
}

class _PasoEscolaresState extends State<PasoEscolares> {
  RegistroDatos get d => widget.datos;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona tu programa académico para vincular tu expediente.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Tu programa'),
          const SizedBox(height: AppSpacing.sm),

          CamposEnFila(
            anchoMinimo: 560,
            children: [
              GescoSelect<String>(
                label: 'Carrera',
                isRequired: true,
                opciones: Catalogos.carreras,
                value: d.carrera,
                onChanged: (v) => setState(() {
                  d.carrera = v;
                  final planes = Catalogos.planesDe(v);
                  if (planes.isNotEmpty) {
                    d.planEstudio = planes.first;
                  }
                }),
                validator: (v) => v == null ? 'Elige tu carrera' : null,
              ),
              GescoSelect<String>(
                label: 'Plan de estudio',
                isRequired: true,
                opciones: Catalogos.planesDe(d.carrera),
                value: d.planEstudio ??
                    (Catalogos.planesDe(d.carrera).isNotEmpty
                        ? Catalogos.planesDe(d.carrera).first
                        : null),
                onChanged: (v) => setState(() => d.planEstudio = v),
                validator: (v) => v == null ? 'Elige el plan' : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            '¿Eres alumno de nuevo ingreso a este programa?',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Sí, nuevo ingreso'),
                  subtitle: const Text('Primer semestre'),
                  value: true,
                  groupValue: d.esNuevoIngreso,
                  activeColor: AppColors.guinda,
                  onChanged: (v) {
                    setState(() {
                      d.esNuevoIngreso = v ?? true;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('No, reinscripción'),
                  subtitle: const Text('Semestres superiores'),
                  value: false,
                  groupValue: d.esNuevoIngreso,
                  activeColor: AppColors.guinda,
                  onChanged: (v) {
                    setState(() {
                      d.esNuevoIngreso = v ?? false;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          if (!d.esNuevoIngreso)
            GescoCard(
              color: AppColors.surfaceAlt,
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.guinda, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Al ingresar a la app, encontrarás la tarjeta "Completa tu expediente" en el inicio para capturar tu semestre, promedio, adeudos y dictamen.',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.inkSecondary),
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
