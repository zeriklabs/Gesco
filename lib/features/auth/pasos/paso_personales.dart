import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/catalogos.dart';
import '../../../core/data/codigos_postales.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/curp.dart';
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
  String _ultimoRfcAuto = '';
  String _ultimoEstadoNacimiento = '';
  bool _modoOtraColonia = false;

  @override
  void initState() {
    super.initState();
    if (d.rfc.text.isEmpty && d.curp.text.isNotEmpty) {
      _ultimoRfcAuto = d.rfcDerivado;
      d.rfc.text = _ultimoRfcAuto;
    }
    _ultimoEstadoNacimiento = d.estadoNacimientoDerivado;
  }

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
            anchoMinimo: 560,
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
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoTextField(
            label: 'CURP',
            controller: d.curp,
            hintText: 'GATG040822HZSRRLA7',
            helperText:
                'De aquí salen tu RFC, tu fecha de nacimiento y tu '
                'estado de nacimiento.',
            isRequired: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(18),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-zÑñ]')),
            ],
            validator: Validators.curp,
            onChanged: (val) {
              setState(() {
                final curpInfo = Curp.analizar(val);
                final rfcAuto = curpInfo?.rfc ?? '';
                if (d.rfc.text.isEmpty || d.rfc.text == _ultimoRfcAuto) {
                  d.rfc.text = rfcAuto;
                  _ultimoRfcAuto = rfcAuto;
                }

                final nuevoEstado = curpInfo?.estadoNacimiento ?? '';
                if (_ultimoEstadoNacimiento != nuevoEstado) {
                  d.municipioNacimiento = null;
                  _ultimoEstadoNacimiento = nuevoEstado;
                }
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          CamposEnFila(
            anchoMinimo: 560,
            children: [
              GescoTextField(
                label: 'RFC',
                controller: d.rfc,
                isRequired: true,
                textCapitalization: TextCapitalization.characters,
                hintText: 'Escribe tu RFC',
                helperText: 'Autocompletado desde el CURP, editable.',
                validator: (v) => Validators.requerido(v, campo: 'El RFC'),
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
                validator: (v) => v == null ? 'Elige tu estado civil' : null,
              ),
              Catalogos.municipiosDe(d.estadoNacimientoDerivado).isNotEmpty
                  ? GescoSelect<String>(
                      label: 'Municipio de nacimiento',
                      isRequired: true,
                      opciones: Catalogos.municipiosDe(
                        d.estadoNacimientoDerivado,
                      ),
                      value: d.municipioNacimiento,
                      onChanged: (v) =>
                          setState(() => d.municipioNacimiento = v),
                      validator: (v) => v == null ? 'Elige tu municipio' : null,
                    )
                  : GescoTextField(
                      label: 'Municipio de nacimiento',
                      controller: d.municipioNacimientoTextController,
                      isRequired: true,
                      hintText: 'Escribe tu municipio de nacimiento',
                      helperText: curpListo
                          ? 'Escribe el municipio de tu estado.'
                          : null,
                      validator: (v) => Validators.requerido(
                        v,
                        campo: 'El municipio de nacimiento',
                      ),
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
            anchoMinimo: 560,
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
                onChanged: (val) {
                  if (val.length == 5) {
                    final info = CodigosPostales.buscar(val);
                    if (info != null) {
                      setState(() {
                        _modoOtraColonia = false;
                        d.estado = info.estado;
                        d.municipio = info.municipio;
                        if (info.colonias.isNotEmpty) {
                          d.colonia.text = info.primeraColonia;
                        }
                      });
                    } else {
                      setState(() {});
                    }
                  } else {
                    setState(() {});
                  }
                },
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
          ),
          const SizedBox(height: AppSpacing.lg),

          // Selector o campo de texto para Colonia según el CP
          Builder(
            builder: (context) {
              final cpInfo = CodigosPostales.buscar(d.codigoPostal.text);
              const opcionOtra = 'OTRA (ESCRIBIR MANUALMENTE)';

              if (cpInfo != null &&
                  cpInfo.colonias.isNotEmpty &&
                  !_modoOtraColonia) {
                final opciones = [...cpInfo.colonias, opcionOtra];
                final valorValido = cpInfo.colonias.contains(d.colonia.text)
                    ? d.colonia.text
                    : (d.colonia.text.isEmpty
                          ? cpInfo.primeraColonia
                          : opcionOtra);

                return GescoSelect<String>(
                  label: 'Colonia',
                  isRequired: true,
                  opciones: opciones,
                  value: valorValido,
                  onChanged: (v) {
                    if (v == opcionOtra) {
                      setState(() {
                        _modoOtraColonia = true;
                        d.colonia.clear();
                      });
                    } else if (v != null) {
                      setState(() {
                        d.colonia.text = v;
                      });
                    }
                  },
                  validator: (v) =>
                      d.colonia.text.trim().isEmpty ? 'Elige tu colonia' : null,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GescoTextField(
                    label: 'Colonia',
                    controller: d.colonia,
                    isRequired: true,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        Validators.requerido(v, campo: 'La colonia'),
                  ),
                  if (cpInfo != null && cpInfo.colonias.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _modoOtraColonia = false;
                            d.colonia.text = cpInfo.primeraColonia;
                          });
                        },
                        icon: const Icon(Icons.list, size: 16),
                        label: Text(
                          'Elegir de la lista de SEPOMEX (${cpInfo.colonias.length} colonias)',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.guinda,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          CamposEnFila(
            flex: const [2, 1, 1],
            anchoMinimo: 520,
            children: [
              GescoTextField(
                label: 'Calle',
                controller: d.calle,
                isRequired: true,
                textCapitalization: TextCapitalization.characters,
                validator: (v) => Validators.requerido(v, campo: 'La calle'),
              ),
              GescoTextField(
                label: 'No. ext',
                controller: d.numeroExterior,
                isRequired: true,
                validator: (v) =>
                    Validators.requerido(v, campo: 'El número exterior'),
              ),
              GescoTextField(
                label: 'No. int',
                controller: d.numeroInterior,
                hintText: 'Opcional',
              ),
            ],
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
          const Icon(
            Icons.check_rounded,
            size: 17,
            color: AppColors.successInk,
          ),
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
