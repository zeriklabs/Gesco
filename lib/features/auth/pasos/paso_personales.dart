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

/// Datos personales.
///
/// La idea de esta pantalla: el alumno teclea el CURP y con eso ya no vuelve a
/// escribir su RFC, su fecha de nacimiento ni su estado. El GESCO actual pide
/// los cuatro por separado, que es pedirle que se contradiga.
class PasoPersonales extends StatefulWidget {
  const PasoPersonales({super.key, required this.datos, required this.formKey});

  final RegistroDatos datos;
  final GlobalKey<FormState> formKey;

  @override
  State<PasoPersonales> createState() => _PasoPersonalesState();
}

class _PasoPersonalesState extends State<PasoPersonales> {
  RegistroDatos get d => widget.datos;

  @override
  Widget build(BuildContext context) {
    final derivados = d.derivados;
    final curpListo = derivados != null;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estos datos se imprimen tal cual en tus solicitudes. Si están '
            'mal, Gestión Escolar cancela el trámite.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Identidad', nota: '* obligatorio'),

          CamposEnFila(
            children: [
              GescoTextField(
                label: 'Nombre(s)',
                controller: d.nombre,
                isRequired: true,
                textCapitalization: TextCapitalization.characters,
                validator: (v) => Validators.requerido(v, campo: 'El nombre'),
              ),
              GescoTextField(
                label: 'Apellido paterno',
                controller: d.apellidoPaterno,
                isRequired: true,
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    Validators.requerido(v, campo: 'El apellido paterno'),
              ),
              GescoTextField(
                label: 'Apellido materno',
                controller: d.apellidoMaterno,
                textCapitalization: TextCapitalization.characters,
              ),
            ],
            anchoMinimo: 560,
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoTextField(
            label: 'CURP',
            controller: d.curp,
            hintText: 'GATG040822HZSRRLA7',
            helperText: 'De aquí salen tu RFC, tu fecha de nacimiento y tu '
                'estado de nacimiento.',
            isRequired: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(18),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-zÑñ]')),
            ],
            validator: Validators.curp,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),

          CamposEnFila(
            children: [
              GescoTextField(
                label: 'RFC',
                derivado: true,
                initialValue: d.rfcDerivado,
                key: ValueKey('rfc-${d.rfcDerivado}'),
                hintText: 'Escribe tu CURP',
                helperText: 'Sin homoclave: esos 3 los asigna el SAT.',
              ),
              GescoTextField(
                label: 'Fecha de nacimiento',
                derivado: true,
                initialValue: d.fechaNacimientoDerivada,
                key: ValueKey('fnac-${d.fechaNacimientoDerivada}'),
                hintText: '—',
                helperText: curpListo ? d.edadDerivada : null,
              ),
              GescoTextField(
                label: 'Estado de nacimiento',
                derivado: true,
                initialValue: d.estadoNacimientoDerivado,
                key: ValueKey('enac-${d.estadoNacimientoDerivado}'),
                hintText: '—',
              ),
            ],
            anchoMinimo: 560,
          ),

          if (curpListo) ...[
            const SizedBox(height: AppSpacing.md),
            _AvisoAutocompletado(cantidad: d.camposAutocompletados),
          ],
          const SizedBox(height: AppSpacing.lg),

          CamposEnFila(
            children: [
              GescoSelect<String>(
                label: 'Estado civil',
                isRequired: true,
                opciones: Catalogos.estadoCivil,
                value: d.estadoCivil,
                onChanged: (v) => setState(() => d.estadoCivil = v),
                validator: (v) =>
                    v == null ? 'Elige tu estado civil' : null,
              ),
              GescoSelect<String>(
                label: 'Municipio de nacimiento',
                isRequired: true,
                opciones: Catalogos.municipiosDe(d.estadoNacimientoDerivado),
                value: d.municipioNacimiento,
                helperText: curpListo &&
                        Catalogos.municipiosDe(d.estadoNacimientoDerivado)
                            .isEmpty
                    ? 'Todavía no hay catálogo para ese estado.'
                    : null,
                onChanged: (v) => setState(() => d.municipioNacimiento = v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Contacto'),

          CamposEnFila(
            children: [
              GescoTextField(
                label: 'Teléfono celular',
                controller: d.telefonoCelular,
                hintText: '492-123-8504',
                isRequired: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(14)],
                validator: Validators.telefono,
              ),
              GescoTextField(
                label: 'Teléfono fijo',
                controller: d.telefonoFijo,
                hintText: 'Opcional',
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(14)],
                validator: (v) => Validators.telefono(v, obligatorio: false),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Domicilio actual'),

          CamposEnFila(
            children: [
              GescoTextField(
                label: 'Código postal',
                controller: d.codigoPostal,
                hintText: '98718',
                isRequired: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: Validators.codigoPostal,
                onChanged: (_) => setState(() {}),
              ),
              GescoSelect<String>(
                label: 'Estado',
                isRequired: true,
                opciones: Catalogos.estados,
                value: d.estado,
                onChanged: (v) => setState(() {
                  d.estado = v;
                  // Los municipios dependen del estado: si cambia, el que
                  // estaba elegido ya no aplica.
                  d.municipio = null;
                }),
                validator: (v) => v == null ? 'Elige tu estado' : null,
              ),
              GescoSelect<String>(
                label: 'Municipio',
                isRequired: true,
                opciones: Catalogos.municipiosDe(d.estado),
                value: d.municipio,
                onChanged: (v) => setState(() => d.municipio = v),
                validator: (v) => v == null ? 'Elige tu municipio' : null,
              ),
            ],
            anchoMinimo: 560,
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoTextField(
            label: 'Colonia',
            controller: d.colonia,
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
                controller: d.calle,
                isRequired: true,
                textCapitalization: TextCapitalization.characters,
                validator: (v) => Validators.requerido(v, campo: 'La calle'),
              ),
              GescoTextField(
                label: 'No. exterior',
                controller: d.numeroExterior,
                isRequired: true,
                validator: (v) =>
                    Validators.requerido(v, campo: 'El número exterior'),
              ),
              GescoTextField(
                label: 'No. interior',
                controller: d.numeroInterior,
                hintText: 'Opcional',
              ),
            ],
            anchoMinimo: 520,
          ),
        ],
      ),
    );
  }
}

class _AvisoAutocompletado extends StatelessWidget {
  const _AvisoAutocompletado({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.successTint,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, size: 17, color: AppColors.successInk),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '$cantidad campos se llenaron solos con tu CURP',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.successInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
