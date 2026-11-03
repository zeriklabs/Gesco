import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_catalogos.dart';
import 'form_catalogo.dart';

/// Los periodos escolares.
///
/// De los treinta y tres que hay, el único que se usa es el activo: es el que
/// ordena la bandeja, los dictámenes y los textos. Por eso va arriba y aparte,
/// y los demás quedan como historial.
///
/// Activar se hace con un botón, no editando un campo "¿actual? sí/no" por
/// renglón: así no hay forma de dejar dos activos ni ninguno.
class PeriodosScreen extends StatefulWidget {
  const PeriodosScreen({super.key});

  @override
  State<PeriodosScreen> createState() => _PeriodosScreenState();
}

class _PeriodosScreenState extends State<PeriodosScreen> {
  List<Map<String, String>> get _todos => DatosDemoCatalogos.filas('periodos');

  Map<String, String>? get _activo {
    for (final p in _todos) {
      if (p['actual'] == 'Sí') return p;
    }
    return null;
  }

  Future<void> _agregar() async {
    final nuevo = await pedirRegistro(
      context,
      def: DatosDemoCatalogos.definicion('periodos'),
      fijos: const {'actual': 'No'},
    );
    if (nuevo == null) return;
    setState(() => DatosDemoCatalogos.agregar('periodos', nuevo));
  }

  Future<void> _editar(Map<String, String> fila) async {
    final cambiado = await pedirRegistro(
      context,
      def: DatosDemoCatalogos.definicion('periodos'),
      inicial: fila,
      fijos: {'actual': fila['actual'] ?? 'No'},
    );
    if (cambiado == null) return;
    final i = DatosDemoCatalogos.indiceDe('periodos', fila);
    if (i == -1) return;
    setState(() => DatosDemoCatalogos.reemplazar('periodos', i, cambiado));
  }

  Future<void> _activar(Map<String, String> fila) async {
    final anterior = _activo;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text('Cambiar el periodo activo'),
        titleTextStyle: AppTypography.displaySmall,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            anterior == null
                ? 'Se activa ${fila['nombre']}.'
                : 'Se activa ${fila['nombre']} y se desactiva '
                    '${anterior['nombre']}.\n\n'
                    'Afecta la bandeja de validación, los dictámenes y los '
                    'textos del consejo.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.inkSecondary,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Activar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    final i = DatosDemoCatalogos.indiceDe('periodos', fila);
    if (i == -1) return;
    setState(() {
      DatosDemoCatalogos.reemplazar('periodos', i, {...fila, 'actual': 'Sí'});
    });
  }

  Future<void> _quitar(Map<String, String> fila) async {
    final ok = await confirmarBorrado(context, que: fila['nombre'] ?? '');
    if (!ok) return;
    final i = DatosDemoCatalogos.indiceDe('periodos', fila);
    if (i == -1) return;
    setState(() => DatosDemoCatalogos.quitar('periodos', i));
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final activo = _activo;
    final historial = _todos.where((p) => p['actual'] != 'Sí').toList();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Periodos'),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.ink,
          fontSize: compacto ? 16 : 19,
        ),
        actions: [
          TextButton.icon(
            onPressed: _agregar,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Agregar'),
            style: TextButton.styleFrom(foregroundColor: AppColors.guinda),
          ),
          SizedBox(
            width: compacto ? AppSpacing.md : AppSpacing.gutterDesktop,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        ),
        children: [
          if (activo == null)
            GescoCard(
              color: AppColors.dangerTint,
              colorBorde: AppColors.dangerBorder,
              bordeGrueso: true,
              child: Row(
                children: [
                  const Icon(Icons.priority_high_rounded,
                      size: 20, color: AppColors.guinda),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'No hay periodo activo. La bandeja y los dictámenes '
                      'no saben a qué semestre pertenecen.',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.guinda,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            _Activo(periodo: activo, onEditar: () => _editar(activo)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'HISTORIAL',
            style: AppTypography.overline.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final p in historial)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _Historico(
                periodo: p,
                onActivar: () => _activar(p),
                onEditar: () => _editar(p),
                onQuitar: () => _quitar(p),
              ),
            ),
        ],
      ),
    );
  }
}

class _Activo extends StatelessWidget {
  const _Activo({required this.periodo, required this.onEditar});

  final Map<String, String> periodo;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final nombre = periodo['nombre'] ?? '';
    // "27/1 (AGO 2026 - ENE 2027)" → clave y rango por separado.
    final abre = nombre.indexOf('(');
    final clave = abre == -1 ? nombre : nombre.substring(0, abre).trim();
    final rango = abre == -1
        ? ''
        : nombre.substring(abre).replaceAll(RegExp(r'[()]'), '').trim();

    return GescoCard(
      color: AppColors.guinda,
      colorBorde: AppColors.guinda,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERIODO ACTIVO',
                  style:
                      AppTypography.overline.copyWith(color: AppColors.dorado),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  clave,
                  style: AppTypography.numeral.copyWith(
                    height: 1,
                    color: AppColors.onGuinda,
                  ),
                ),
                if (rango.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    rango,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.onGuindaMuted),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEditar,
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.onGuindaMuted,
          ),
        ],
      ),
    );
  }
}

class _Historico extends StatelessWidget {
  const _Historico({
    required this.periodo,
    required this.onActivar,
    required this.onEditar,
    required this.onQuitar,
  });

  final Map<String, String> periodo;
  final VoidCallback onActivar;
  final VoidCallback onEditar;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xxs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              periodo['nombre'] ?? '',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onActivar,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.guinda,
              visualDensity: VisualDensity.compact,
              textStyle:
                  AppTypography.hint.copyWith(fontWeight: FontWeight.w800),
            ),
            child: const Text('Activar'),
          ),
          IconButton(
            onPressed: onEditar,
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined, size: 16),
            color: AppColors.muted,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onQuitar,
            tooltip: 'Quitar',
            icon: const Icon(Icons.close_rounded, size: 16),
            color: AppColors.muted,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
