import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_catalogos.dart';
import 'form_catalogo.dart';

/// El plan de estudios, en una sola pantalla.
///
/// Carreras, niveles, grupos y materias eran cuatro menús con cuatro listas
/// planas: treinta renglones que decían "NIVEL 1 — ING. MECATRÓNICA, NIVEL 2
/// — ING. MECATRÓNICA…", ciento veinte grupos, y las materias repetidas una
/// vez por carrera. Para mover un grupo había que entrar a una lista de 120 y
/// buscarlo.
///
/// Pero no son cuatro cosas: son **una**, y tiene forma de árbol. Carrera →
/// nivel → sus grupos y sus materias. Aquí se ve así, y agregar algo ya no
/// pregunta a qué carrera ni a qué nivel: estás parado ahí.
class PlanEstudiosScreen extends StatefulWidget {
  const PlanEstudiosScreen({super.key});

  @override
  State<PlanEstudiosScreen> createState() => _PlanEstudiosScreenState();
}

class _PlanEstudiosScreenState extends State<PlanEstudiosScreen> {
  late String _carrera = DatosDemoCatalogos.opcionesDe('carreras').first;
  final _abiertos = <String>{'NIVEL 1'};

  List<String> get _carreras => DatosDemoCatalogos.opcionesDe('carreras');

  Future<void> _agregarCarrera() async {
    final nueva = await pedirRegistro(
      context,
      def: DatosDemoCatalogos.definicion('carreras'),
    );
    if (nueva == null) return;
    setState(() {
      DatosDemoCatalogos.agregar('carreras', nueva);
      _carrera = nueva['nombre'] ?? _carrera;
    });
  }

  Future<void> _agregarNivel() async {
    final nuevo = await pedirRegistro(
      context,
      def: DatosDemoCatalogos.definicion('niveles'),
      fijos: {'carrera': _carrera},
    );
    if (nuevo == null) return;
    setState(() => DatosDemoCatalogos.agregar('niveles', nuevo));
  }

  Future<void> _agregar(String catalogo, String nivel) async {
    final nuevo = await pedirRegistro(
      context,
      def: DatosDemoCatalogos.definicion(catalogo),
      fijos: {'carrera': _carrera, 'nivel': nivel},
    );
    if (nuevo == null) return;
    setState(() => DatosDemoCatalogos.agregar(catalogo, nuevo));
  }

  Future<void> _editar(String catalogo, Map<String, String> fila) async {
    final cambiada = await pedirRegistro(
      context,
      def: DatosDemoCatalogos.definicion(catalogo),
      inicial: fila,
      fijos: {'carrera': _carrera},
    );
    if (cambiada == null) return;
    final i = DatosDemoCatalogos.indiceDe(catalogo, fila);
    if (i == -1) return;
    setState(() => DatosDemoCatalogos.reemplazar(catalogo, i, cambiada));
  }

  Future<void> _quitar(
    String catalogo,
    Map<String, String> fila,
    String que,
  ) async {
    final ok = await confirmarBorrado(
      context,
      que: que,
      dependientes: DatosDemoCatalogos.dependientesDe(catalogo, fila),
    );
    if (!ok) return;
    final i = DatosDemoCatalogos.indiceDe(catalogo, fila);
    if (i == -1) return;
    setState(() => DatosDemoCatalogos.quitar(catalogo, i));
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final niveles = DatosDemoCatalogos.nivelesDe(_carrera);

    final totalGrupos = niveles.fold<int>(
      0,
      (s, n) => s + DatosDemoCatalogos.gruposDe(_carrera, n['nombre']!).length,
    );
    final totalMaterias = niveles.fold<int>(
      0,
      (s, n) =>
          s + DatosDemoCatalogos.materiasDe(_carrera, n['nombre']!).length,
    );

    final contenido = ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_carrera, style: AppTypography.displaySmall),
                  const SizedBox(height: 3),
                  Text(
                    '${niveles.length} niveles · $totalGrupos grupos · '
                    '$totalMaterias materias',
                    style: AppTypography.hint,
                  ),
                ],
              ),
            ),
            if (!compacto)
              OutlinedButton.icon(
                onPressed: _agregarNivel,
                icon: const Icon(Icons.add_rounded, size: 17),
                label: const Text('Nivel'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (niveles.isEmpty)
          _Vacio(
            texto: 'Esta carrera todavía no tiene niveles.',
            accion: 'Agregar el primero',
            onAccion: _agregarNivel,
          )
        else
          for (final n in niveles)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _Nivel(
                carrera: _carrera,
                nivel: n,
                abierto: _abiertos.contains(n['nombre']),
                onAbrir: () => setState(() {
                  final nombre = n['nombre']!;
                  if (!_abiertos.remove(nombre)) _abiertos.add(nombre);
                }),
                onAgregarGrupo: () => _agregar('grupos', n['nombre']!),
                onAgregarMateria: () => _agregar('materias', n['nombre']!),
                onEditar: _editar,
                onQuitar: _quitar,
                onQuitarNivel: () => _quitar(
                  'niveles',
                  n,
                  '${n['nombre']} de $_carrera',
                ),
              ),
            ),
        if (compacto) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _agregarNivel,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Agregar un nivel'),
          ),
        ],
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Plan de estudios'),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.ink,
          fontSize: compacto ? 16 : 19,
        ),
      ),
      body: compacto
          ? Column(
              children: [
                _SelectorCarreraCompacto(
                  carreras: _carreras,
                  actual: _carrera,
                  onCambiar: (c) => setState(() => _carrera = c),
                  onAgregar: _agregarCarrera,
                ),
                Expanded(child: contenido),
              ],
            )
          : Row(
              children: [
                _RielCarreras(
                  carreras: _carreras,
                  actual: _carrera,
                  onCambiar: (c) => setState(() => _carrera = c),
                  onAgregar: _agregarCarrera,
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(child: contenido),
              ],
            ),
    );
  }
}

/// Las carreras, siempre a la vista. Son seis: no necesitan su propia lista.
class _RielCarreras extends StatelessWidget {
  const _RielCarreras({
    required this.carreras,
    required this.actual,
    required this.onCambiar,
    required this.onAgregar,
  });

  final List<String> carreras;
  final String actual;
  final ValueChanged<String> onCambiar;
  final VoidCallback onAgregar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              'CARRERAS',
              style: AppTypography.overline.copyWith(color: AppColors.muted),
            ),
          ),
          for (final c in carreras)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: _ItemCarrera(
                nombre: c,
                activa: c == actual,
                onTap: () => onCambiar(c),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          TextButton.icon(
            onPressed: onAgregar,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Agregar carrera'),
            style: TextButton.styleFrom(foregroundColor: AppColors.guinda),
          ),
        ],
      ),
    );
  }
}

class _ItemCarrera extends StatelessWidget {
  const _ItemCarrera({
    required this.nombre,
    required this.activa,
    required this.onTap,
  });

  final String nombre;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final grupos = DatosDemoCatalogos.filas('grupos')
        .where((f) => f['carrera'] == nombre)
        .length;

    return Material(
      color: activa ? AppColors.dangerTint : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: activa ? AppColors.guinda : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: activa ? FontWeight.w800 : FontWeight.w600,
                    color:
                        activa ? AppColors.guinda : AppColors.inkSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$grupos',
                style: AppTypography.hint.copyWith(
                  color: activa ? AppColors.guinda : AppColors.placeholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectorCarreraCompacto extends StatelessWidget {
  const _SelectorCarreraCompacto({
    required this.carreras,
    required this.actual,
    required this.onCambiar,
    required this.onAgregar,
  });

  final List<String> carreras;
  final String actual;
  final ValueChanged<String> onCambiar;
  final VoidCallback onAgregar;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutterMobile),
        child: Row(
          children: [
            for (final c in carreras) ...[
              _ChipCarrera(
                nombre: c,
                activa: c == actual,
                onTap: () => onCambiar(c),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            IconButton(
              onPressed: onAgregar,
              tooltip: 'Agregar carrera',
              icon: const Icon(Icons.add_rounded, size: 19),
              color: AppColors.guinda,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipCarrera extends StatelessWidget {
  const _ChipCarrera({
    required this.nombre,
    required this.activa,
    required this.onTap,
  });

  final String nombre;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // En celular el nombre completo no cabe: "ING. EN SISTEMAS
    // COMPUTACIONALES" se queda en "SISTEMAS COMPUTACIONALES".
    final corto = nombre.replaceFirst(RegExp(r'^ING\.\s*(EN\s*)?'), '');

    return Material(
      color: activa ? AppColors.guinda : AppColors.surfaceAlt,
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
              color: activa ? AppColors.guinda : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            corto,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: activa ? FontWeight.w800 : FontWeight.w600,
              color: activa ? AppColors.onGuinda : AppColors.inkSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Un nivel con sus grupos y sus materias.
class _Nivel extends StatelessWidget {
  const _Nivel({
    required this.carrera,
    required this.nivel,
    required this.abierto,
    required this.onAbrir,
    required this.onAgregarGrupo,
    required this.onAgregarMateria,
    required this.onEditar,
    required this.onQuitar,
    required this.onQuitarNivel,
  });

  final String carrera;
  final Map<String, String> nivel;
  final bool abierto;
  final VoidCallback onAbrir;
  final VoidCallback onAgregarGrupo;
  final VoidCallback onAgregarMateria;
  final void Function(String, Map<String, String>) onEditar;
  final void Function(String, Map<String, String>, String) onQuitar;
  final VoidCallback onQuitarNivel;

  @override
  Widget build(BuildContext context) {
    final nombre = nivel['nombre']!;
    final grupos = DatosDemoCatalogos.gruposDe(carrera, nombre);
    final materias = DatosDemoCatalogos.materiasDe(carrera, nombre);
    final creditos = materias.fold<double>(
      0,
      (s, m) => s + (double.tryParse(m['creditos'] ?? '') ?? 0),
    );

    return GescoCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onAbrir,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md + 2),
              child: Row(
                children: [
                  Icon(
                    abierto
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: AppTypography.titleLarge.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${grupos.length} grupo'
                          '${grupos.length == 1 ? '' : 's'} · '
                          '${materias.length} materia'
                          '${materias.length == 1 ? '' : 's'}'
                          '${creditos == 0 ? '' : ' · '
                              '${_sinCeros(creditos)} créditos'}',
                          style: AppTypography.hint,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onQuitarNivel,
                    tooltip: 'Quitar $nombre',
                    icon: const Icon(Icons.delete_outline_rounded, size: 17),
                    color: AppColors.muted,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
          if (abierto) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Seccion(
                    titulo: 'Grupos',
                    onAgregar: onAgregarGrupo,
                    vacio: 'Sin grupos en este nivel.',
                    hayAlgo: grupos.isNotEmpty,
                    hijo: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final g in grupos)
                          _ChipGrupo(
                            nombre: g['nombre'] ?? '',
                            onEditar: () => onEditar('grupos', g),
                            onQuitar: () => onQuitar(
                              'grupos',
                              g,
                              'el grupo ${g['nombre']}',
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Seccion(
                    titulo: 'Materias',
                    onAgregar: onAgregarMateria,
                    vacio: 'Sin materias en este nivel.',
                    hayAlgo: materias.isNotEmpty,
                    hijo: Column(
                      children: [
                        for (final m in materias)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: _FilaMateria(
                              materia: m,
                              carrera: carrera,
                              onEditar: () => onEditar('materias', m),
                              onQuitar: () => onQuitar(
                                'materias',
                                m,
                                m['nombre'] ?? '',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _sinCeros(double n) =>
      n % 1 == 0 ? n.toInt().toString() : n.toStringAsFixed(1);
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.onAgregar,
    required this.vacio,
    required this.hayAlgo,
    required this.hijo,
  });

  final String titulo;
  final VoidCallback onAgregar;
  final String vacio;
  final bool hayAlgo;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              titulo.toUpperCase(),
              style: AppTypography.overline.copyWith(color: AppColors.muted),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add_rounded, size: 15),
              label: Text('Agregar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.guinda,
                visualDensity: VisualDensity.compact,
                textStyle: AppTypography.hint
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (hayAlgo)
          hijo
        else
          Text(vacio, style: AppTypography.hint),
      ],
    );
  }
}

class _ChipGrupo extends StatelessWidget {
  const _ChipGrupo({
    required this.nombre,
    required this.onEditar,
    required this.onQuitar,
  });

  final String nombre;
  final VoidCallback onEditar;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderMuted, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nombre,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: onEditar,
            tooltip: 'Editar $nombre',
            icon: const Icon(Icons.edit_outlined, size: 14),
            color: AppColors.muted,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            onPressed: onQuitar,
            tooltip: 'Quitar $nombre',
            icon: const Icon(Icons.close_rounded, size: 14),
            color: AppColors.muted,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            padding: const EdgeInsets.only(right: 4),
          ),
        ],
      ),
    );
  }
}

class _FilaMateria extends StatelessWidget {
  const _FilaMateria({
    required this.materia,
    required this.carrera,
    required this.onEditar,
    required this.onQuitar,
  });

  final Map<String, String> materia;
  final String carrera;
  final VoidCallback onEditar;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    final nombre = materia['nombre'] ?? '';
    final equivalencias =
        DatosDemoCatalogos.equivalenciasDe(nombre, carrera);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm + 2,
        AppSpacing.xs,
        AppSpacing.xxs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.dangerTint,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              materia['creditos'] ?? '—',
              style: AppTypography.pill.copyWith(color: AppColors.guinda),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (equivalencias.isNotEmpty)
                  Text(
                    'Equivale en: '
                    '${equivalencias.map((e) => e['equivalente']).join(', ')}',
                    style: AppTypography.hint,
                  ),
              ],
            ),
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

class _Vacio extends StatelessWidget {
  const _Vacio({
    required this.texto,
    required this.accion,
    required this.onAccion,
  });

  final String texto;
  final String accion;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            texto,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: onAccion,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(accion),
          ),
        ],
      ),
    );
  }
}
