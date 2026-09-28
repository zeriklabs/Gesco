import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/catalogos.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/models/materia.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_select.dart';
import '../../widgets/gesco_text_field.dart';

/// Captura una materia para el GE-01.
///
/// Hoja abajo en celular, diálogo centrado en escritorio. Devuelve la materia
/// o `null` si se canceló. Si recibe una [inicial], edita esa en vez de crear
/// una nueva.
Future<Materia?> pedirMateria(BuildContext context, {Materia? inicial}) {
  final form = _FormMateria(inicial: inicial);

  if (context.isCompact) {
    return showModalBottomSheet<Materia>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => form,
    );
  }

  return showDialog<Materia>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: form,
      ),
    ),
  );
}

class _FormMateria extends StatefulWidget {
  const _FormMateria({this.inicial});

  final Materia? inicial;

  @override
  State<_FormMateria> createState() => _FormMateriaState();
}

class _FormMateriaState extends State<_FormMateria> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.inicial?.nombre);
  late final _creditos =
      TextEditingController(text: widget.inicial?.creditos.toString());

  late String? _nivel = widget.inicial?.nivel;
  late String? _grupo = widget.inicial?.grupo;
  late String? _semestre = widget.inicial?.semestre;
  late String _estado = widget.inicial?.estado ?? 'NORMAL';

  bool get _editando => widget.inicial != null;

  @override
  void dispose() {
    _nombre.dispose();
    _creditos.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!(_form.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      Materia(
        id: widget.inicial?.id ??
            'm-${DateTime.now().microsecondsSinceEpoch}',
        nombre: _nombre.text.trim(),
        nivel: _nivel!,
        creditos: int.parse(_creditos.text.trim()),
        grupo: _grupo,
        semestre: _semestre,
        estado: _estado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg + 2,
          AppSpacing.lg,
          AppSpacing.lg + 2,
          AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _editando ? 'Editar materia' : 'Agregar una materia',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Una materia que vas a cursar este periodo.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),

              // TODO(gescolar): esto debería ser un desplegable con el plan de
              // estudios de la carrera, y los créditos deberían venir solos
              // con la materia. Sin ese catálogo, el alumno los teclea.
              GescoTextField(
                label: 'Materia',
                controller: _nombre,
                isRequired: true,
                textCapitalization: TextCapitalization.words,
                helperText: 'Escríbela igual que aparece en el SAES.',
                validator: (v) => (v == null || v.trim().length < 4)
                    ? 'Escribe el nombre de la materia'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              CamposEnFila(
                anchoMinimo: 460,
                children: [
                  GescoSelect<String>(
                    label: 'Nivel',
                    opciones: Catalogos.niveles,
                    value: _nivel,
                    isRequired: true,
                    onChanged: (v) => setState(() => _nivel = v),
                    validator: (v) => v == null ? 'Elige el nivel' : null,
                  ),
                  GescoTextField(
                    label: 'Créditos',
                    controller: _creditos,
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null) return 'Obligatorio';
                      if (n < 1 || n > 20) return 'Entre 1 y 20';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CamposEnFila(
                anchoMinimo: 460,
                children: [
                  GescoSelect<String>(
                    label: 'Grupo',
                    opciones: Catalogos.grupos,
                    value: _grupo,
                    onChanged: (v) => setState(() => _grupo = v),
                  ),
                  GescoSelect<String>(
                    label: 'Semestre',
                    opciones: Catalogos.semestres,
                    value: _semestre,
                    onChanged: (v) => setState(() => _semestre = v),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              GescoSelect<String>(
                label: 'Cómo la vas a cursar',
                opciones: Catalogos.estadosAdeudo,
                value: _estado,
                isRequired: true,
                onChanged: (v) => setState(() => _estado = v ?? 'NORMAL'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _guardar,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(_editando ? 'Guardar' : 'Agregar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
