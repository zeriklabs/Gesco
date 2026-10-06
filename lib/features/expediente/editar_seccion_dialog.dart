import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/catalogos.dart';
import '../../core/data/codigos_postales.dart';
import '../../core/data/datos_demo.dart';
import '../../core/models/expediente.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_select.dart';
import '../../widgets/gesco_text_field.dart';

/// Modal para editar los datos de una sección del Expediente (Personales, Tutor, Generales).
class EditarSeccionDialog extends StatefulWidget {
  const EditarSeccionDialog({super.key, required this.seccion});

  final SeccionExpediente seccion;

  static Future<bool?> mostrar(
    BuildContext context, {
    required SeccionExpediente seccion,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditarSeccionDialog(seccion: seccion),
    );
  }

  @override
  State<EditarSeccionDialog> createState() => _EditarSeccionDialogState();
}

class _EditarSeccionDialogState extends State<EditarSeccionDialog> {
  // --- Personales Controllers ----------------------------------------------
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _paternoCtrl;
  late final TextEditingController _maternoCtrl;
  late final TextEditingController _celularCtrl;
  late final TextEditingController _fijoCtrl;
  late final TextEditingController _cpCtrl;
  late final TextEditingController _estadoCtrl;
  late final TextEditingController _municipioCtrl;
  late final TextEditingController _coloniaCtrl;
  late final TextEditingController _calleCtrl;
  late final TextEditingController _extCtrl;
  late final TextEditingController _intCtrl;

  String _genero = 'Femenino';
  String _estadoCivil = 'SOLTERO';

  // --- Tutor Controllers ---------------------------------------------------
  late final TextEditingController _tutorNombreCtrl;
  late final TextEditingController _tutorPaternoCtrl;
  late final TextEditingController _tutorMaternoCtrl;
  late final TextEditingController _tutorOcupacionCtrl;
  late final TextEditingController _tutorCelularCtrl;
  late final TextEditingController _tutorCorreoCtrl;
  late final TextEditingController _tutorCpCtrl;
  late final TextEditingController _tutorEstadoCtrl;
  late final TextEditingController _tutorMunicipioCtrl;
  late final TextEditingController _tutorColoniaCtrl;
  late final TextEditingController _tutorCalleCtrl;
  late final TextEditingController _tutorExtCtrl;
  late final TextEditingController _tutorIntCtrl;

  String _tutorParentesco = 'MADRE';
  bool _tutorMismoDomicilio = true;

  // --- Generales Controllers -----------------------------------------------
  bool _trabaja = false;
  late final TextEditingController _horarioTrabajoCtrl;
  late final TextEditingController _datosTrabajoCtrl;

  @override
  void initState() {
    super.initState();

    // Personales
    _nombreCtrl = TextEditingController(text: 'Ana');
    _paternoCtrl = TextEditingController(text: 'Martínez');
    _maternoCtrl = TextEditingController(text: 'Reyes');
    _celularCtrl = TextEditingController(
      text: DatosDemo.datosPersonales['Celular'] ?? '492 100 2030',
    );
    _fijoCtrl = TextEditingController(
      text: DatosDemo.datosPersonales['Teléfono fijo'] ?? '492 955 1010',
    );
    _cpCtrl = TextEditingController(
      text: DatosDemo.domicilioActual['C.P.'] ?? '98000',
    );
    _estadoCtrl = TextEditingController(
      text: DatosDemo.domicilioActual['Estado'] ?? 'Zacatecas',
    );
    _municipioCtrl = TextEditingController(
      text: DatosDemo.domicilioActual['Municipio'] ?? 'Zacatecas',
    );
    _coloniaCtrl = TextEditingController(
      text: DatosDemo.domicilioActual['Colonia'] ?? 'Centro',
    );
    _calleCtrl = TextEditingController(
      text: DatosDemo.domicilioActual['Calle'] ?? 'Av. Siempre Viva',
    );
    _extCtrl = TextEditingController(
      text: DatosDemo.domicilioActual['N° ext'] ?? '100',
    );
    _intCtrl = TextEditingController(
      text: DatosDemo.domicilioActual['N° int'] ?? '',
    );

    _genero = DatosDemo.datosPersonales['Género'] ?? 'Femenino';
    _estadoCivil =
        (DatosDemo.datosPersonales['Estado civil'] ?? 'SOLTERO').toUpperCase();

    // Tutor
    _tutorNombreCtrl = TextEditingController(text: 'Rosa');
    _tutorPaternoCtrl = TextEditingController(text: 'Reyes');
    _tutorMaternoCtrl = TextEditingController(text: 'Luna');
    _tutorOcupacionCtrl = TextEditingController(text: 'Hogar');
    _tutorCelularCtrl = TextEditingController(
      text: DatosDemo.datosTutor['Teléfono del tutor'] ?? '492 921 5544',
    );
    _tutorCorreoCtrl = TextEditingController(
      text: DatosDemo.datosTutor['Correo del tutor'] ?? 'rosa.reyes@gmail.com',
    );
    _tutorCpCtrl = TextEditingController(text: '98000');
    _tutorEstadoCtrl = TextEditingController(text: 'Zacatecas');
    _tutorMunicipioCtrl = TextEditingController(text: 'Zacatecas');
    _tutorColoniaCtrl = TextEditingController(text: 'Centro');
    _tutorCalleCtrl = TextEditingController(text: 'Av. Siempre Viva');
    _tutorExtCtrl = TextEditingController(text: '100');
    _tutorIntCtrl = TextEditingController(text: '');

    _tutorParentesco =
        (DatosDemo.datosTutor['Parentesco'] ?? 'MADRE').toUpperCase();
    _tutorMismoDomicilio = true;

    // Generales
    _trabaja = (DatosDemo.datosPersonales['¿Trabajas?'] ?? 'No') == 'Sí';
    _horarioTrabajoCtrl = TextEditingController(
      text: DatosDemo.datosPersonales['Horario de trabajo'] ??
          'Lunes a viernes, 15:00 a 21:00',
    );
    _datosTrabajoCtrl = TextEditingController(
      text: DatosDemo.datosPersonales['Datos del trabajo'] ??
          'Empresa S.A. de C.V.',
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _paternoCtrl.dispose();
    _maternoCtrl.dispose();
    _celularCtrl.dispose();
    _fijoCtrl.dispose();
    _cpCtrl.dispose();
    _estadoCtrl.dispose();
    _municipioCtrl.dispose();
    _coloniaCtrl.dispose();
    _calleCtrl.dispose();
    _extCtrl.dispose();
    _intCtrl.dispose();

    _tutorNombreCtrl.dispose();
    _tutorPaternoCtrl.dispose();
    _tutorMaternoCtrl.dispose();
    _tutorOcupacionCtrl.dispose();
    _tutorCelularCtrl.dispose();
    _tutorCorreoCtrl.dispose();
    _tutorCpCtrl.dispose();
    _tutorEstadoCtrl.dispose();
    _tutorMunicipioCtrl.dispose();
    _tutorColoniaCtrl.dispose();
    _tutorCalleCtrl.dispose();
    _tutorExtCtrl.dispose();
    _tutorIntCtrl.dispose();

    _horarioTrabajoCtrl.dispose();
    _datosTrabajoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    switch (widget.seccion) {
      case SeccionExpediente.personales:
        DatosDemo.datosPersonales['Género'] = _genero;
        DatosDemo.datosPersonales['Estado civil'] = _estadoCivil;
        DatosDemo.datosPersonales['Celular'] = _celularCtrl.text.trim();
        DatosDemo.datosPersonales['Teléfono fijo'] = _fijoCtrl.text.trim();

        DatosDemo.domicilioActual['C.P.'] = _cpCtrl.text.trim();
        DatosDemo.domicilioActual['Estado'] = _estadoCtrl.text.trim();
        DatosDemo.domicilioActual['Municipio'] = _municipioCtrl.text.trim();
        DatosDemo.domicilioActual['Colonia'] = _coloniaCtrl.text.trim();
        DatosDemo.domicilioActual['Calle'] = _calleCtrl.text.trim();
        DatosDemo.domicilioActual['N° ext'] = _extCtrl.text.trim();
        DatosDemo.domicilioActual['N° int'] = _intCtrl.text.trim();

      case SeccionExpediente.tutor:
        DatosDemo.datosTutor['Nombre del tutor'] =
            '${_tutorNombreCtrl.text.trim()} ${_tutorPaternoCtrl.text.trim()} ${_tutorMaternoCtrl.text.trim()}';
        DatosDemo.datosTutor['Parentesco'] = _tutorParentesco;
        DatosDemo.datosTutor['Teléfono del tutor'] =
            _tutorCelularCtrl.text.trim();
        DatosDemo.datosTutor['Correo del tutor'] =
            _tutorCorreoCtrl.text.trim();
        DatosDemo.datosTutor['Domicilio del tutor'] = _tutorMismoDomicilio
            ? 'Mismo que el alumno'
            : '${_tutorCalleCtrl.text.trim()} #${_tutorExtCtrl.text.trim()}, Col. ${_tutorColoniaCtrl.text.trim()}';

      case SeccionExpediente.generales:
        DatosDemo.datosPersonales['¿Trabajas?'] = _trabaja ? 'Sí' : 'No';
        if (_trabaja) {
          DatosDemo.datosPersonales['Horario de trabajo'] =
              _horarioTrabajoCtrl.text.trim();
          DatosDemo.datosPersonales['Datos del trabajo'] =
              _datosTrabajoCtrl.text.trim();
        }

      case SeccionExpediente.escolares:
        break;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.88),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        mq.viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tirador superior
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Título de la sección
          Row(
            children: [
              Icon(widget.seccion.icono, color: AppColors.guinda, size: 24),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: Text(
                  'Editar ${widget.seccion.titulo}',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.xs),

          // Contenido desplazable del formulario
          Expanded(
            child: SingleChildScrollView(
              child: switch (widget.seccion) {
                SeccionExpediente.personales => _buildFormPersonales(),
                SeccionExpediente.tutor => _buildFormTutor(),
                SeccionExpediente.generales => _buildFormGenerales(),
                SeccionExpediente.escolares => const SizedBox.shrink(),
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Guardar cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.guinda,
              foregroundColor: AppColors.onGuinda,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPersonales() {
    final cpVal = _cpCtrl.text;
    final cpInfo = cpVal.length == 5 ? CodigosPostales.buscar(cpVal) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: GescoTextField(
                label: 'Nombre(s)',
                controller: _nombreCtrl,
                isRequired: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'Apellido paterno',
                controller: _paternoCtrl,
                isRequired: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'Apellido materno',
                controller: _maternoCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GescoSelect<String>(
                label: 'Género',
                value: _genero,
                opciones: const ['Femenino', 'Masculino', 'Otro'],
                onChanged: (v) {
                  if (v != null) setState(() => _genero = v);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoSelect<String>(
                label: 'Estado civil',
                value: Catalogos.estadoCivil.contains(_estadoCivil)
                    ? _estadoCivil
                    : Catalogos.estadoCivil.first,
                opciones: Catalogos.estadoCivil,
                onChanged: (v) {
                  if (v != null) setState(() => _estadoCivil = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GescoTextField(
                label: 'Teléfono celular',
                controller: _celularCtrl,
                isRequired: true,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'Teléfono fijo',
                controller: _fijoCtrl,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Text(
          'Domicilio actual',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.guinda,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: GescoTextField(
                label: 'C.P.',
                controller: _cpCtrl,
                isRequired: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (val) {
                  if (val.length == 5) {
                    final info = CodigosPostales.buscar(val);
                    if (info != null) {
                      setState(() {
                        _estadoCtrl.text = info.estado;
                        _municipioCtrl.text = info.municipio;
                        if (info.colonias.isNotEmpty) {
                          _coloniaCtrl.text = info.primeraColonia;
                        }
                      });
                    }
                  } else {
                    setState(() {});
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'Estado',
                controller: _estadoCtrl,
                isRequired: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'Municipio',
                controller: _municipioCtrl,
                isRequired: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GescoTextField(
                label: 'Calle',
                controller: _calleCtrl,
                isRequired: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: (cpInfo != null && cpInfo.colonias.isNotEmpty)
                  ? GescoSelect<String>(
                      label: 'Colonia',
                      value: cpInfo.colonias.contains(_coloniaCtrl.text)
                          ? _coloniaCtrl.text
                          : cpInfo.primeraColonia,
                      opciones: cpInfo.colonias,
                      isRequired: true,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _coloniaCtrl.text = val);
                        }
                      },
                    )
                  : GescoTextField(
                      label: 'Colonia',
                      controller: _coloniaCtrl,
                      isRequired: true,
                    ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GescoTextField(
                label: 'N° ext',
                controller: _extCtrl,
                isRequired: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'N° int',
                controller: _intCtrl,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormTutor() {
    final cpVal = _tutorCpCtrl.text;
    final cpInfo = cpVal.length == 5 ? CodigosPostales.buscar(cpVal) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: GescoTextField(
                label: 'Nombre(s)',
                controller: _tutorNombreCtrl,
                isRequired: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'Apellido paterno',
                controller: _tutorPaternoCtrl,
                isRequired: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'Apellido materno',
                controller: _tutorMaternoCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GescoSelect<String>(
                label: 'Parentesco',
                value: Catalogos.parentesco.contains(_tutorParentesco)
                    ? _tutorParentesco
                    : Catalogos.parentesco.first,
                opciones: Catalogos.parentesco,
                isRequired: true,
                onChanged: (v) {
                  if (v != null) setState(() => _tutorParentesco = v);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'Ocupación',
                controller: _tutorOcupacionCtrl,
                isRequired: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GescoTextField(
                label: 'Teléfono celular',
                controller: _tutorCelularCtrl,
                isRequired: true,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GescoTextField(
                label: 'Correo electrónico',
                controller: _tutorCorreoCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        OpcionSiNo(
          label: '¿El tutor vive en el mismo domicilio que tú?',
          value: _tutorMismoDomicilio,
          onChanged: (v) => setState(() => _tutorMismoDomicilio = v),
        ),

        if (!_tutorMismoDomicilio) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: GescoTextField(
                  label: 'C.P. Tutor',
                  controller: _tutorCpCtrl,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (val) {
                    if (val.length == 5) {
                      final info = CodigosPostales.buscar(val);
                      if (info != null) {
                        setState(() {
                          _tutorEstadoCtrl.text = info.estado;
                          _tutorMunicipioCtrl.text = info.municipio;
                          if (info.colonias.isNotEmpty) {
                            _tutorColoniaCtrl.text = info.primeraColonia;
                          }
                        });
                      }
                    } else {
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GescoTextField(
                  label: 'Estado',
                  controller: _tutorEstadoCtrl,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GescoTextField(
                  label: 'Municipio',
                  controller: _tutorMunicipioCtrl,
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GescoTextField(
                  label: 'Calle',
                  controller: _tutorCalleCtrl,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: (cpInfo != null && cpInfo.colonias.isNotEmpty)
                    ? GescoSelect<String>(
                        label: 'Colonia',
                        value: cpInfo.colonias.contains(_tutorColoniaCtrl.text)
                            ? _tutorColoniaCtrl.text
                            : cpInfo.primeraColonia,
                        opciones: cpInfo.colonias,
                        isRequired: true,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _tutorColoniaCtrl.text = val);
                          }
                        },
                      )
                    : GescoTextField(
                        label: 'Colonia',
                        controller: _tutorColoniaCtrl,
                        isRequired: true,
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: GescoTextField(
                  label: 'N° ext',
                  controller: _tutorExtCtrl,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GescoTextField(
                  label: 'N° int',
                  controller: _tutorIntCtrl,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFormGenerales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OpcionSiNo(
          label: '¿Trabajas actualmente?',
          value: _trabaja,
          onChanged: (v) => setState(() => _trabaja = v),
        ),
        if (_trabaja) ...[
          const SizedBox(height: AppSpacing.sm),
          GescoTextField(
            label: 'Horario de trabajo',
            controller: _horarioTrabajoCtrl,
            hintText: 'Ej. Lunes a viernes, 15:00 a 21:00',
            isRequired: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          GescoTextField(
            label: 'Datos de la empresa / empleador',
            controller: _datosTrabajoCtrl,
            hintText: 'Ej. Empresa S.A. de C.V. - Tel. 492 900 1122',
            isRequired: true,
          ),
        ],
      ],
    );
  }
}
