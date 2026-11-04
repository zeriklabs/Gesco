import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../data/datos_demo_admin.dart';
import '../data/datos_demo_reportes.dart';
import '../models/reporte.dart';
import 'resumen_reporte.dart';

/// Un reporte abierto.
///
/// Tres cosas que el reporte del sistema actual no tiene: el periodo activo a
/// la vista, filtros (carrera, texto y "solo los que no cierran") y un
/// exportado que saca **lo que está viendo**, no la lista completa. Si alguien
/// filtró Mecatrónica y descarga, el archivo trae Mecatrónica.
class ReporteScreen extends StatefulWidget {
  const ReporteScreen({super.key, required this.reporte});

  final Reporte reporte;

  @override
  State<ReporteScreen> createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  final _busqueda = TextEditingController();

  /// `null` = todas.
  String? _carrera;
  bool _soloPendientes = false;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<FilaReporte> get _filtradas {
    return DatosDemoReportes.filas(widget.reporte).where((f) {
      if (_carrera != null && f.carrera != _carrera) return false;
      if (_soloPendientes && f.cierra) return false;
      return f.coincide(_busqueda.text);
    }).toList();
  }

  Future<void> _exportar(List<FilaReporte> filas) async {
    final csv = DatosDemoReportes.csv(widget.reporte, filas);
    final archivo = widget.reporte.nombreArchivo(DatosDemoAdmin.periodoActual);

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: 760,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (_) => _HojaExportar(
        archivo: archivo,
        csv: csv,
        renglones: filas.length,
        filtrado: _hayFiltro,
      ),
    );
  }

  bool get _hayFiltro =>
      _carrera != null || _soloPendientes || _busqueda.text.trim().isNotEmpty;

  void _limpiar() {
    setState(() {
      _carrera = null;
      _soloPendientes = false;
      _busqueda.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final reporte = widget.reporte;
    final todas = DatosDemoReportes.filas(reporte);
    final filas = _filtradas;
    final pendientes = todas.where((f) => !f.cierra).length;
    final columnas = [
      for (final c in reporte.columnas)
        if (!compacto || !c.soloEscritorio) c,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(reporte.titulo),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.ink,
          fontSize: compacto ? 16 : 19,
        ),
        actions: [
          if (compacto)
            IconButton(
              onPressed: filas.isEmpty ? null : () => _exportar(filas),
              tooltip: 'Exportar',
              icon: const Icon(Icons.download_rounded, size: 20),
              color: AppColors.guinda,
            )
          else
            FilledButton.icon(
              onPressed: filas.isEmpty ? null : () => _exportar(filas),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(_hayFiltro ? 'Exportar lo filtrado' : 'Exportar'),
            ),
          SizedBox(width: compacto ? AppSpacing.xs : AppSpacing.gutterDesktop),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        ),
        children: [
          Text(
            'Periodo ${DatosDemoAdmin.periodoActual} · '
            '${DatosDemoAdmin.periodoLegible}',
            style: AppTypography.overline.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            reporte.pregunta,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.inkSecondary, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.md),
          ResumenReporte(resumen: DatosDemoReportes.resumen(reporte)),
          const SizedBox(height: AppSpacing.lg),
          _Filtros(
            busqueda: _busqueda,
            carrera: _carrera,
            carreras: DatosDemoReportes.carreras(reporte),
            soloPendientes: _soloPendientes,
            pendientes: pendientes,
            etiquetaPendientes: reporte.sinCerrar,
            compacto: compacto,
            onBuscar: () => setState(() {}),
            onCarrera: (c) => setState(() => _carrera = c),
            onPendientes: (v) => setState(() => _soloPendientes = v),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  filas.length == todas.length
                      ? '${todas.length} '
                          '${todas.length == 1 ? 'renglón' : 'renglones'}'
                      : '${filas.length} de ${todas.length}',
                  style: AppTypography.hint.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ),
              if (_hayFiltro)
                TextButton(
                  onPressed: _limpiar,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.guinda,
                    visualDensity: VisualDensity.compact,
                    textStyle: AppTypography.hint
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Quitar filtros'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (!compacto) _Encabezado(columnas: columnas),
                for (var i = 0; i < filas.length; i++) ...[
                  if (i > 0 || !compacto)
                    const Divider(height: 1, color: AppColors.border),
                  _Renglon(
                    fila: filas[i],
                    columnas: columnas,
                    compacto: compacto,
                  ),
                ],
                if (filas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      todas.isEmpty
                          ? 'Nadie en este reporte para el periodo activo.'
                          : 'Nada coincide con el filtro.',
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

class _Filtros extends StatelessWidget {
  const _Filtros({
    required this.busqueda,
    required this.carrera,
    required this.carreras,
    required this.soloPendientes,
    required this.pendientes,
    required this.etiquetaPendientes,
    required this.compacto,
    required this.onBuscar,
    required this.onCarrera,
    required this.onPendientes,
  });

  final TextEditingController busqueda;
  final String? carrera;
  final List<String> carreras;
  final bool soloPendientes;
  final int pendientes;
  final String etiquetaPendientes;
  final bool compacto;
  final VoidCallback onBuscar;
  final ValueChanged<String?> onCarrera;
  final ValueChanged<bool> onPendientes;

  @override
  Widget build(BuildContext context) {
    final buscador = TextField(
      controller: busqueda,
      onChanged: (_) => onBuscar(),
      decoration: InputDecoration(
        hintText: 'Boleta o nombre',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: busqueda.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  busqueda.clear();
                  onBuscar();
                },
              ),
      ),
    );

    final selectorCarrera = _SelectorCarrera(
      carrera: carrera,
      carreras: carreras,
      onCarrera: onCarrera,
    );

    final chipPendientes = _ChipPendientes(
      activo: soloPendientes,
      cuantos: pendientes,
      etiqueta: etiquetaPendientes,
      onTap: () => onPendientes(!soloPendientes),
    );

    if (compacto) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buscador,
          const SizedBox(height: AppSpacing.sm),
          selectorCarrera,
          const SizedBox(height: AppSpacing.sm),
          Align(alignment: Alignment.centerLeft, child: chipPendientes),
        ],
      );
    }

    // Wrap y no Row: con una carrera de nombre largo y una ventana de 1100,
    // los tres controles no caben en una línea y es mejor que bajen solos.
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(width: 300, child: buscador),
        selectorCarrera,
        chipPendientes,
      ],
    );
  }
}

/// La carrera, en un menú y no en chips: los nombres son largos y son seis.
class _SelectorCarrera extends StatelessWidget {
  const _SelectorCarrera({
    required this.carrera,
    required this.carreras,
    required this.onCarrera,
  });

  final String? carrera;
  final List<String> carreras;
  final ValueChanged<String?> onCarrera;

  @override
  Widget build(BuildContext context) {
    final elegida = carrera != null;

    // "Todas" viaja como cadena vacía y no como null: PopupMenuButton trata
    // una selección null como cancelación y nunca avisa.
    return PopupMenuButton<String>(
      tooltip: 'Filtrar por carrera',
      onSelected: (v) => onCarrera(v.isEmpty ? null : v),
      color: AppColors.surface,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          value: '',
          child: Text('Todas las carreras'),
        ),
        const PopupMenuDivider(),
        for (final c in carreras)
          PopupMenuItem<String>(
            value: c,
            child: Text(c, style: AppTypography.bodyMedium),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 1,
        ),
        decoration: BoxDecoration(
          color: elegida ? AppColors.dangerTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: elegida ? AppColors.guinda : AppColors.borderStrong,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ancho topado en lugar de Flexible: en el renglón de escritorio
            // este botón no recibe ancho máximo, y un hijo con flex dentro de
            // restricciones infinitas revienta el layout.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(
                carrera ?? 'Todas las carreras',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: elegida ? AppColors.guinda : AppColors.inkSecondary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 17,
              color: elegida ? AppColors.guinda : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipPendientes extends StatelessWidget {
  const _ChipPendientes({
    required this.activo,
    required this.cuantos,
    required this.etiqueta,
    required this.onTap,
  });

  final bool activo;
  final int cuantos;
  final String etiqueta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? AppColors.guinda : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: cuantos == 0 ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 1,
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
              Icon(
                activo ? Icons.check_rounded : Icons.filter_alt_outlined,
                size: 15,
                color: activo ? AppColors.onGuinda : AppColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                '$etiqueta ($cuantos)',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: activo
                      ? AppColors.onGuinda
                      : cuantos == 0
                          ? AppColors.placeholder
                          : AppColors.inkSecondary,
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
  const _Encabezado({required this.columnas});

  final List<ColumnaReporte> columnas;

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
          for (final c in columnas)
            Expanded(
              flex: c.flex,
              child: Text(
                c.titulo.toUpperCase(),
                style: AppTypography.overline.copyWith(color: AppColors.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _Renglon extends StatelessWidget {
  const _Renglon({
    required this.fila,
    required this.columnas,
    required this.compacto,
  });

  final FilaReporte fila;
  final List<ColumnaReporte> columnas;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2,
        vertical: AppSpacing.sm,
      ),
      child: compacto ? _apilado() : _enColumnas(),
    );
  }

  Widget _enColumnas() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final c in columnas)
          Expanded(
            flex: c.flex,
            child: c.pastilla
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: _Pastilla(texto: fila[c.clave], tono: fila.tono),
                  )
                : Text(
                    fila[c.clave],
                    style: _estilo(c.clave),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
      ],
    );
  }

  /// En celular no caben seis columnas, así que el renglón se apila: el alumno
  /// arriba y lo demás como "columna: valor".
  Widget _apilado() {
    final restantes = columnas
        .where((c) => c.clave != 'alumno' && c.clave != 'boleta' && !c.pastilla)
        .toList();
    final pastilla = columnas.where((c) => c.pastilla).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fila['alumno'], style: _estilo('alumno')),
        const SizedBox(height: 2),
        Text(fila['boleta'], style: _estilo('boleta')),
        if (restantes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          for (final c in restantes)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 94,
                    child: Text(c.titulo, style: AppTypography.hint),
                  ),
                  Expanded(
                    child: Text(
                      fila[c.clave],
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (pastilla.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs + 1),
          _Pastilla(texto: fila[pastilla.first.clave], tono: fila.tono),
        ],
      ],
    );
  }

  TextStyle _estilo(String clave) {
    if (clave == 'boleta') {
      return AppTypography.hint.copyWith(
        fontFamily: 'monospace',
        color: AppColors.placeholder,
      );
    }
    if (clave == 'alumno') {
      return AppTypography.bodyMedium.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      );
    }
    return AppTypography.bodyMedium.copyWith(
      fontSize: 13,
      color: AppColors.inkSecondary,
    );
  }
}

class _Pastilla extends StatelessWidget {
  const _Pastilla({required this.texto, required this.tono});

  final String texto;
  final TonoFila tono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: tono.fondo,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(texto, style: AppTypography.pill.copyWith(color: tono.tinta)),
    );
  }
}

/// La hoja de exportar.
///
/// TODO(backend): la descarga del archivo la hace el servidor. Mientras no
/// exista, el CSV se puede copiar y pegar en Excel, que es lo que resuelve el
/// problema de hoy.
class _HojaExportar extends StatelessWidget {
  const _HojaExportar({
    required this.archivo,
    required this.csv,
    required this.renglones,
    required this.filtrado,
  });

  final String archivo;
  final String csv;
  final int renglones;
  final bool filtrado;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Exportar', style: AppTypography.displaySmall),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cerrar',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.muted,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '$renglones ${renglones == 1 ? 'renglón' : 'renglones'}'
              '${filtrado ? ', los que están filtrados' : ''} · $archivo',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.inkSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csv,
                    style: AppTypography.hint.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.ink,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: () async {
                // Se toman antes de cerrar: después de pop, el context de la
                // hoja ya no sirve para pedir el messenger.
                final messenger = ScaffoldMessenger.of(context);
                final navegador = Navigator.of(context);
                await Clipboard.setData(ClipboardData(text: csv));
                navegador.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Copiado. Pégalo en Excel.')),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copiar'),
            ),
          ],
        ),
      ),
    );
  }
}
