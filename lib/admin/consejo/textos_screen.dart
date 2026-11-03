import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_consejo.dart';
import '../models/dictamen.dart';

/// Los textos que el consejo imprime en los dictámenes.
///
/// **El cambio de fondo está aquí.** En el sistema actual cada texto trae el
/// periodo escrito adentro del párrafo: "EN EL PERIODO ESCOLAR 27/1", "E.T.S.
/// DE ENERO 2027". Cada semestre alguien tiene que entrar a editar los doce a
/// mano, y si se le pasa uno, el dictamen sale impreso con el periodo del año
/// pasado — y eso es un documento oficial con dos firmas.
///
/// Aquí el periodo es una variable. El texto se escribe una vez.
class TextosScreen extends StatefulWidget {
  const TextosScreen({super.key});

  @override
  State<TextosScreen> createState() => _TextosScreenState();
}

class _TextosScreenState extends State<TextosScreen> {
  Future<void> _editar(TextoDictamen texto) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditarTextoScreen(texto: texto)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        GescoCard(
          color: AppColors.surfaceAlt,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_fix_high_rounded,
                  size: 18, color: AppColors.guinda),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'El periodo es una variable',
                      style: AppTypography.titleLarge.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Se resuelve al imprimir con el periodo activo. No hay '
                      'que corregir los textos cada semestre.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.inkSecondary,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final t in DatosDemoConsejo.textos)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _TarjetaTexto(texto: t, onEditar: () => _editar(t)),
          ),
      ],
    );
  }
}

class _TarjetaTexto extends StatelessWidget {
  const _TarjetaTexto({required this.texto, required this.onEditar});

  final TextoDictamen texto;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      onTap: onEditar,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  texto.titulo,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.edit_outlined, size: 17, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            texto.resolver(DatosDemoConsejo.periodoActivo),
            style: AppTypography.hint.copyWith(height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (texto.variablesUsadas.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final v in texto.variablesUsadas) _Variable(nombre: v),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Variable extends StatelessWidget {
  const _Variable({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successTint,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        nombre,
        style: AppTypography.pill.copyWith(
          color: AppColors.successInk,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// Editar un texto, con la vista previa resolviéndose mientras se escribe.
class EditarTextoScreen extends StatefulWidget {
  const EditarTextoScreen({super.key, required this.texto});

  final TextoDictamen texto;

  @override
  State<EditarTextoScreen> createState() => _EditarTextoScreenState();
}

class _EditarTextoScreenState extends State<EditarTextoScreen> {
  late final _titulo = TextEditingController(text: widget.texto.titulo);
  late final _plantilla = TextEditingController(text: widget.texto.plantilla);

  @override
  void dispose() {
    _titulo.dispose();
    _plantilla.dispose();
    super.dispose();
  }

  void _insertar(String variable) {
    final seleccion = _plantilla.selection;
    final texto = _plantilla.text;
    final pos = seleccion.isValid ? seleccion.start : texto.length;

    _plantilla.text = texto.replaceRange(
      pos,
      seleccion.isValid ? seleccion.end : texto.length,
      variable,
    );
    _plantilla.selection =
        TextSelection.collapsed(offset: pos + variable.length);
    setState(() {});
  }

  void _guardar() {
    DatosDemoConsejo.guardarTexto(
      widget.texto.copyWith(
        titulo: _titulo.text.trim(),
        plantilla: _plantilla.text.trim(),
      ),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Texto guardado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final vista = TextoDictamen(
      id: widget.texto.id,
      titulo: _titulo.text,
      plantilla: _plantilla.text,
    ).resolver(DatosDemoConsejo.periodoActivo);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Editar texto'),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.ink,
          fontSize: compacto ? 16 : 19,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Título', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _titulo,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('El párrafo', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Redacción aprobada por el consejo.',
                    style: AppTypography.hint.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _plantilla,
                    onChanged: (_) => setState(() {}),
                    maxLines: 10,
                    style: AppTypography.bodyMedium.copyWith(height: 1.55),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Insertar una variable:', style: AppTypography.hint),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final entrada in TextoDictamen.variables.entries)
                        Tooltip(
                          message: entrada.value,
                          child: ActionChip(
                            label: Text(entrada.key),
                            labelStyle: AppTypography.hint.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.successInk,
                              fontWeight: FontWeight.w700,
                            ),
                            backgroundColor: AppColors.successTint,
                            side: const BorderSide(
                              color: AppColors.successBorder,
                            ),
                            onPressed: () => _insertar(entrada.key),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const TituloBloque(texto: 'Como se va a imprimir'),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md + 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.borderMuted,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CON EL PERIODO ACTIVO '
                          '(${DatosDemoConsejo.periodoActivo})',
                          style: AppTypography.overline
                              .copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          vista,
                          style: AppTypography.bodyMedium.copyWith(height: 1.6),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _VistaSiguientePeriodo(plantilla: _plantilla.text),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: AppColors.surface,
        elevation: 8,
        shadowColor: const Color(0x14000000),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: AppSpacing.xs),
                FilledButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La prueba de que la plantilla sirve: el mismo texto, el periodo que sigue.
class _VistaSiguientePeriodo extends StatelessWidget {
  const _VistaSiguientePeriodo({required this.plantilla});

  final String plantilla;

  @override
  Widget build(BuildContext context) {
    final siguiente = DatosDemoConsejo.periodoActivo.siguiente;
    final texto = TextoDictamen(
      id: 'vista',
      titulo: '',
      plantilla: plantilla,
    ).resolver(siguiente);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successTint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.successBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fast_forward_rounded,
                  size: 15, color: AppColors.successInk),
              const SizedBox(width: 6),
              Text(
                'EL SIGUIENTE ($siguiente), SIN TOCAR NADA',
                style: AppTypography.overline
                    .copyWith(color: AppColors.successInk),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            texto,
            style: AppTypography.hint.copyWith(
              height: 1.55,
              color: AppColors.inkSecondary,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
