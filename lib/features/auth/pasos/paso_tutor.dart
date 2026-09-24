import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/catalogos.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/gesco_select.dart';
import '../../../widgets/gesco_text_field.dart';
import '../registro_datos.dart';

/// Datos del tutor.
///
/// La pieza que vale aquí es el interruptor de "mismo domicilio": en el GESCO
/// actual el alumno recaptura calle, número, colonia, C.P., estado y municipio
/// aunque viva en la misma casa que su tutor.
class PasoTutor extends StatefulWidget {
  const PasoTutor({super.key, required this.datos, required this.formKey});

  final RegistroDatos datos;
  final GlobalKey<FormState> formKey;

  @override
  State<PasoTutor> createState() => _PasoTutorState();
}

class _PasoTutorState extends State<PasoTutor> {
  RegistroDatos get d => widget.datos;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La persona a la que Gestión Escolar puede llamar si hay un '
            'problema con tu trámite.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Quién es'),

          CamposEnFila(
            children: [
              GescoTextField(
                label: 'Nombre(s)',
                controller: d.tutorNombre,
                isRequired: true,
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    Validators.requerido(v, campo: 'El nombre del tutor'),
              ),
              GescoTextField(
                label: 'Apellido paterno',
                controller: d.tutorApellidoPaterno,
                isRequired: true,
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    Validators.requerido(v, campo: 'El apellido paterno'),
              ),
              GescoTextField(
                label: 'Apellido materno',
                controller: d.tutorApellidoMaterno,
                textCapitalization: TextCapitalization.characters,
              ),
            ],
            anchoMinimo: 560,
          ),
          const SizedBox(height: AppSpacing.lg),

          CamposEnFila(
            children: [
              GescoSelect<String>(
                label: 'Parentesco',
                isRequired: true,
                opciones: Catalogos.parentesco,
                value: d.tutorParentesco,
                onChanged: (v) => setState(() => d.tutorParentesco = v),
                validator: (v) => v == null ? 'Elige el parentesco' : null,
              ),
              GescoTextField(
                label: 'Ocupación',
                controller: d.tutorOcupacion,
                isRequired: true,
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    Validators.requerido(v, campo: 'La ocupación'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Cómo localizarlo'),

          CamposEnFila(
            children: [
              GescoTextField(
                label: 'Teléfono celular',
                controller: d.tutorTelefonoCelular,
                hintText: '458-989-7969',
                isRequired: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(14)],
                validator: Validators.telefono,
              ),
              GescoTextField(
                label: 'Teléfono fijo',
                controller: d.tutorTelefonoFijo,
                hintText: 'Opcional',
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(14)],
                validator: (v) => Validators.telefono(v, obligatorio: false),
              ),
              GescoTextField(
                label: 'Teléfono del trabajo',
                controller: d.tutorTelefonoTrabajo,
                hintText: 'Opcional',
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(14)],
                validator: (v) => Validators.telefono(v, obligatorio: false),
              ),
            ],
            anchoMinimo: 560,
          ),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Domicilio del tutor'),

          _InterruptorMismoDomicilio(
            activo: d.tutorMismoDomicilio,
            domicilio: d.domicilioResumido,
            onChanged: (v) => setState(() {
              d.tutorMismoDomicilio = v;
              if (v) d.sincronizarDomicilioTutor();
            }),
          ),

          if (!d.tutorMismoDomicilio) ...[
            const SizedBox(height: AppSpacing.lg),
            CamposEnFila(
              children: [
                GescoTextField(
                  label: 'Código postal',
                  controller: d.tutorCodigoPostal,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: Validators.codigoPostal,
                ),
                GescoSelect<String>(
                  label: 'Estado',
                  isRequired: true,
                  opciones: Catalogos.estados,
                  value: d.tutorEstado,
                  onChanged: (v) => setState(() {
                    d.tutorEstado = v;
                    d.tutorMunicipio = null;
                  }),
                  validator: (v) => v == null ? 'Elige el estado' : null,
                ),
                GescoSelect<String>(
                  label: 'Municipio',
                  isRequired: true,
                  opciones: Catalogos.municipiosDe(d.tutorEstado),
                  value: d.tutorMunicipio,
                  onChanged: (v) => setState(() => d.tutorMunicipio = v),
                  validator: (v) => v == null ? 'Elige el municipio' : null,
                ),
              ],
              anchoMinimo: 560,
            ),
            const SizedBox(height: AppSpacing.lg),
            GescoTextField(
              label: 'Colonia',
              controller: d.tutorColonia,
              isRequired: true,
              textCapitalization: TextCapitalization.characters,
              validator: (v) => Validators.requerido(v, campo: 'La colonia'),
            ),
            const SizedBox(height: AppSpacing.lg),
            CamposEnFila(
              flex: const [3, 1, 1],
              children: [
                GescoTextField(
                  label: 'Calle',
                  controller: d.tutorCalle,
                  isRequired: true,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => Validators.requerido(v, campo: 'La calle'),
                ),
                GescoTextField(
                  label: 'No. exterior',
                  controller: d.tutorNumeroExterior,
                  isRequired: true,
                  validator: (v) =>
                      Validators.requerido(v, campo: 'El número exterior'),
                ),
                GescoTextField(
                  label: 'No. interior',
                  controller: d.tutorNumeroInterior,
                  hintText: 'Opcional',
                ),
              ],
              anchoMinimo: 520,
            ),
          ],
        ],
      ),
    );
  }
}

class _InterruptorMismoDomicilio extends StatelessWidget {
  const _InterruptorMismoDomicilio({
    required this.activo,
    required this.domicilio,
    required this.onChanged,
  });

  final bool activo;
  final String domicilio;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: activo ? AppColors.successTint : AppColors.ground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: activo ? AppColors.successBorder : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vive en mi mismo domicilio',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Te ahorra teclear 7 campos otra vez.',
                      style: AppTypography.hint,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch(value: activo, onChanged: onChanged),
            ],
          ),
          if (activo) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(color: AppColors.successBorder),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.successInk),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    domicilio,
                    style: AppTypography.hint.copyWith(
                      color: AppColors.successInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
