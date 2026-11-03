import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../data/datos_demo_catalogos.dart';
import 'form_catalogo.dart';

/// El catálogo de documentos.
///
/// Son diecisiete renglones de tres datos cada uno: una tabla. El color vive
/// en una pastilla, no en el fondo — la app es guinda y dorado, y pintar cada
/// grupo de un color distinto la volvía otra cosa.
class DocumentosScreen extends StatefulWidget {
  const DocumentosScreen({super.key});

  @override
  State<DocumentosScreen> createState() => _DocumentosScreenState();
}

class _DocumentosScreenState extends State<DocumentosScreen> {
  static const _destinos = ['Nuevo ingreso', 'Reinscripción', 'Ambos', 'COSIE'];

  /// `null` = todos.
  String? _filtro;

  List<Map<String, String>> get _filtrados {
    final todos = DatosDemoCatalogos.filas('documentos');
    if (_filtro == null) return todos;
    return todos.where((d) => d['dirigido'] == _filtro).toList();
  }

  int _cuantos(String destino) => DatosDemoCatalogos.filas('documentos')
      .where((d) => d['dirigido'] == destino)
      .length;

  Future<void> _agregar() async {
    final nuevo = await pedirRegistro(
      context,
      def: DatosDemoCatalogos.definicion('documentos'),
      fijos: _filtro == null ? const {} : {'dirigido': _filtro!},
    );
    if (nuevo == null) return;
    setState(() => DatosDemoCatalogos.agregar('documentos', nuevo));
  }

  Future<void> _editar(Map<String, String> fila) async {
    final cambiado = await pedirRegistro(
      context,
      def: DatosDemoCatalogos.definicion('documentos'),
      inicial: fila,
    );
    if (cambiado == null) return;
    final i = DatosDemoCatalogos.indiceDe('documentos', fila);
    if (i == -1) return;
    setState(() => DatosDemoCatalogos.reemplazar('documentos', i, cambiado));
  }

  Future<void> _quitar(Map<String, String> fila) async {
    final ok = await confirmarBorrado(
      context,
      que: fila['descripcion'] ?? fila['nombre'] ?? '',
    );
    if (!ok) return;
    final i = DatosDemoCatalogos.indiceDe('documentos', fila);
    if (i == -1) return;
    setState(() => DatosDemoCatalogos.quitar('documentos', i));
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final filas = _filtrados;
    final total = DatosDemoCatalogos.filas('documentos').length;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Documentos'),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.ink,
          fontSize: compacto ? 16 : 19,
        ),
        actions: [
          FilledButton.icon(
            onPressed: _agregar,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Agregar'),
          ),
          SizedBox(width: compacto ? AppSpacing.md : AppSpacing.gutterDesktop),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        ),
        children: [
          Text(
            '$total documentos. El destino decide a quién se le pide.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.inkSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ChipFiltro(
                  texto: 'Todos',
                  cuantos: total,
                  activo: _filtro == null,
                  onTap: () => setState(() => _filtro = null),
                ),
                for (final d in _destinos) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _ChipFiltro(
                    texto: d,
                    cuantos: _cuantos(d),
                    activo: _filtro == d,
                    onTap: () => setState(() => _filtro = d),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (!compacto) const _Encabezado(),
                for (var i = 0; i < filas.length; i++) ...[
                  if (i > 0 || !compacto)
                    const Divider(height: 1, color: AppColors.border),
                  _Renglon(
                    documento: filas[i],
                    compacto: compacto,
                    onEditar: () => _editar(filas[i]),
                    onQuitar: () => _quitar(filas[i]),
                  ),
                ],
                if (filas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'Ningún documento con ese destino.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.muted),
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

class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    required this.texto,
    required this.cuantos,
    required this.activo,
    required this.onTap,
  });

  final String texto;
  final int cuantos;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? AppColors.guinda : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: activo ? AppColors.guinda : AppColors.borderStrong,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                texto,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                  color: activo ? AppColors.onGuinda : AppColors.inkSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$cuantos',
                style: AppTypography.hint.copyWith(
                  color: activo ? AppColors.onGuindaFaint : AppColors.placeholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceAlt,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(flex: 5, child: _titulo('Documento')),
          Expanded(flex: 3, child: _titulo('Nombre en la base')),
          Expanded(flex: 3, child: _titulo('Dirigido a')),
          const SizedBox(width: 72),
        ],
      ),
    );
  }

  static Widget _titulo(String texto) => Text(
        texto.toUpperCase(),
        style: AppTypography.overline.copyWith(color: AppColors.muted),
      );
}

class _Renglon extends StatelessWidget {
  const _Renglon({
    required this.documento,
    required this.compacto,
    required this.onEditar,
    required this.onQuitar,
  });

  final Map<String, String> documento;
  final bool compacto;
  final VoidCallback onEditar;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    final descripcion = documento['descripcion'] ?? '';
    final nombre = documento['nombre'] ?? '';
    final destino = documento['dirigido'] ?? '';

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onEditar,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2,
            vertical: AppSpacing.sm,
          ),
          child: compacto
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(descripcion, style: _textoFuerte),
                          const SizedBox(height: 2),
                          Text(nombre, style: _mono),
                          const SizedBox(height: 5),
                          _Pastilla(destino: destino),
                        ],
                      ),
                    ),
                    _acciones(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(descripcion, style: _textoFuerte),
                    ),
                    Expanded(flex: 3, child: Text(nombre, style: _mono)),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _Pastilla(destino: destino),
                      ),
                    ),
                    _acciones(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _acciones() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onEditar,
          tooltip: 'Editar',
          icon: const Icon(Icons.edit_outlined, size: 16),
          color: AppColors.muted,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          padding: EdgeInsets.zero,
        ),
        IconButton(
          onPressed: onQuitar,
          tooltip: 'Quitar',
          icon: const Icon(Icons.close_rounded, size: 16),
          color: AppColors.muted,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  static final _textoFuerte = AppTypography.bodyMedium.copyWith(
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
  );

  static final _mono = AppTypography.hint.copyWith(
    fontFamily: 'monospace',
    color: AppColors.placeholder,
  );
}

/// El destino, con los dos colores de la app y nada más.
///
/// Cuatro destinos, dos colores: guinda para lo que se le pide al alumno,
/// dorado para lo del consejo. Los tres guindas se distinguen por el relleno
/// —lleno el que aplica a todos, tinte el de nuevo ingreso, solo contorno el
/// de reinscripción— porque si los tres se vieran igual, la columna no diría
/// nada.
class _Pastilla extends StatelessWidget {
  const _Pastilla({required this.destino});

  final String destino;

  @override
  Widget build(BuildContext context) {
    final (fondo, borde, tinta) = switch (destino) {
      'Ambos' => (AppColors.guinda, AppColors.guinda, AppColors.onGuinda),
      'Nuevo ingreso' => (
          AppColors.dangerTint,
          AppColors.dangerTint,
          AppColors.guinda,
        ),
      'COSIE' => (
          AppColors.warningTint,
          AppColors.warningTint,
          AppColors.warningInk,
        ),
      _ => (
          AppColors.surface,
          AppColors.guinda.withValues(alpha: 0.4),
          AppColors.guinda,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: borde, width: 1.2),
      ),
      child: Text(
        destino,
        style: AppTypography.pill.copyWith(color: tinta),
      ),
    );
  }
}
