import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_select.dart';
import '../../widgets/gesco_text_field.dart';
import '../data/datos_demo_catalogos.dart';
import '../models/catalogo.dart';

/// Pide los datos de un renglón de catálogo.
///
/// [fijos] son los campos que ya vienen resueltos por dónde se está parado:
/// si agregas un grupo desde el nivel 3 de Mecatrónica, la carrera y el nivel
/// no se vuelven a preguntar. Ese es el punto de tener el árbol.
Future<Map<String, String>?> pedirRegistro(
  BuildContext context, {
  required DefinicionCatalogo def,
  Map<String, String>? inicial,
  Map<String, String> fijos = const {},
}) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (_) => _Formulario(def: def, inicial: inicial, fijos: fijos),
  );
}

/// Pregunta antes de borrar, diciendo qué se queda colgando.
Future<bool> confirmarBorrado(
  BuildContext context, {
  required String que,
  Map<String, int> dependientes = const {},
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (_) => _DialogoBorrar(que: que, dependientes: dependientes),
  );
  return r ?? false;
}

class _Formulario extends StatefulWidget {
  const _Formulario({
    required this.def,
    required this.inicial,
    required this.fijos,
  });

  final DefinicionCatalogo def;
  final Map<String, String>? inicial;
  final Map<String, String> fijos;

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _form = GlobalKey<FormState>();

  late final Map<String, TextEditingController> _textos = {
    for (final c in widget.def.campos)
      if (c.tipo == TipoCampo.texto || c.tipo == TipoCampo.numero)
        c.clave: TextEditingController(
          text: widget.inicial?[c.clave] ?? widget.fijos[c.clave],
        ),
  };

  late final Map<String, String?> _valores = {
    for (final c in widget.def.campos)
      if (c.tipo == TipoCampo.seleccion || c.tipo == TipoCampo.siNo)
        c.clave: widget.inicial?[c.clave] ??
            widget.fijos[c.clave] ??
            (c.tipo == TipoCampo.siNo ? 'No' : null),
  };

  bool get _editando => widget.inicial != null;

  @override
  void dispose() {
    for (final c in _textos.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _guardar() {
    if (!(_form.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(<String, String>{
      for (final c in widget.def.campos)
        c.clave: _textos[c.clave]?.text.trim() ?? _valores[c.clave] ?? '',
    });
  }

  List<String> _opciones(CampoCatalogo campo) {
    if (campo.opcionesDe != null) {
      return DatosDemoCatalogos.opcionesDe(campo.opcionesDe!);
    }
    return campo.opciones;
  }

  @override
  Widget build(BuildContext context) {
    // Los campos que ya vienen resueltos se enseñan, pero no se preguntan.
    final preguntables =
        widget.def.campos.where((c) => !widget.fijos.containsKey(c.clave));
    final heredados =
        widget.def.campos.where((c) => widget.fijos.containsKey(c.clave));

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
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
                  _editando
                      ? 'Editar ${widget.def.singular}'
                      : 'Agregar ${widget.def.singular}',
                  style: AppTypography.displaySmall,
                ),
                if (heredados.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    heredados
                        .map((c) => widget.fijos[c.clave])
                        .where((v) => (v ?? '').isNotEmpty)
                        .join(' · '),
                    style: AppTypography.hint,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                for (final c in preguntables) ...[
                  if (c.tipo == TipoCampo.texto || c.tipo == TipoCampo.numero)
                    GescoTextField(
                      label: c.etiqueta,
                      controller: _textos[c.clave],
                      isRequired: c.requerido,
                      helperText: c.ayuda,
                      keyboardType: c.tipo == TipoCampo.numero
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : null,
                      inputFormatters: c.tipo == TipoCampo.numero
                          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                          : null,
                      validator: c.requerido
                          ? (v) => (v == null || v.trim().isEmpty)
                              ? 'Obligatorio'
                              : null
                          : null,
                    )
                  else if (c.tipo == TipoCampo.siNo)
                    OpcionSiNo(
                      label: c.etiqueta,
                      value: _valores[c.clave] == 'Sí',
                      onChanged: (v) =>
                          setState(() => _valores[c.clave] = v ? 'Sí' : 'No'),
                      helperText: c.ayuda,
                    )
                  else
                    GescoSelect<String>(
                      label: c.etiqueta,
                      opciones: _opciones(c),
                      value: _valores[c.clave],
                      isRequired: c.requerido,
                      helperText: c.ayuda,
                      onChanged: (v) => setState(() => _valores[c.clave] = v),
                      validator: c.requerido
                          ? (v) => v == null ? 'Elige una opción' : null
                          : null,
                    ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.xs),
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
      ),
    );
  }
}

/// Avisa qué se queda colgando antes de borrar.
///
/// El sistema actual tiene una X roja por renglón y nada más. Borrar una
/// carrera deja sin padre a sus niveles, sus grupos y sus materias, y nadie
/// se entera hasta que algo truena.
class _DialogoBorrar extends StatelessWidget {
  const _DialogoBorrar({required this.que, required this.dependientes});

  final String que;
  final Map<String, int> dependientes;

  @override
  Widget build(BuildContext context) {
    final hay = dependientes.isNotEmpty;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      title: Text(hay ? 'Cuidado con esto' : '¿Quitarlo?'),
      titleTextStyle: AppTypography.displaySmall,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vas a quitar "$que".',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.inkSecondary,
                height: 1.5,
              ),
            ),
            if (hay) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.dangerTint,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.dangerBorder, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Se quedan sin a qué apuntar:',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.guinda,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    for (final e in dependientes.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '${e.value} en ${e.key}',
                          style: AppTypography.hint
                              .copyWith(color: AppColors.inkSecondary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Conviene mover esos registros antes de borrar este.',
                style: AppTypography.hint.copyWith(height: 1.45),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.guinda),
          child: Text(hay ? 'Quitar de todos modos' : 'Quitar'),
        ),
      ],
    );
  }
}
