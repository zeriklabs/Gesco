import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/models/materia.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import 'form_materia.dart';
import 'nombre_oficial.dart';

/// El formato GE-01: las materias que el alumno se inscribe en el periodo.
///
/// Es la pantalla que le da sentido a las demás. De aquí salen las materias
/// que la baja de materias lista con palomitas, y de aquí sale el **total de
/// créditos**, que en el sistema actual el alumno teclea a mano en su
/// expediente aunque el sistema tenga los renglones para sumarlos.
class Ge01Screen extends StatefulWidget {
  const Ge01Screen({super.key});

  @override
  State<Ge01Screen> createState() => _Ge01ScreenState();
}

class _Ge01ScreenState extends State<Ge01Screen> {
  List<Materia> get _materias => DatosDemo.materiasInscritas;

  int get _creditos => DatosDemo.creditosInscritos;

  bool get _bajoMinimo => _creditos < DatosDemo.creditosMinimos;

  Future<void> _agregar() async {
    final nueva = await pedirMateria(context);
    if (nueva == null) return;
    setState(() => DatosDemo.materiasInscritas.add(nueva));
  }

  Future<void> _editar(Materia materia) async {
    final cambiada = await pedirMateria(context, inicial: materia);
    if (cambiada == null) return;
    setState(() {
      final i = DatosDemo.materiasInscritas.indexWhere((m) => m.id == materia.id);
      if (i != -1) DatosDemo.materiasInscritas[i] = cambiada;
    });
  }

  void _quitar(Materia materia) {
    final posicion = _materias.indexOf(materia);
    setState(() => DatosDemo.materiasInscritas.remove(materia));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Se quitó ${materia.nombre}'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => setState(
              () => DatosDemo.materiasInscritas.insert(posicion, materia),
            ),
          ),
        ),
      );
  }

  void _generar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando el formato GE-01…')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    final lista = GescoCard(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Materias que vas a cursar',
                    style: AppTypography.titleLarge.copyWith(fontSize: 16),
                  ),
                ),
                Text(
                  'Periodo ${DatosDemo.periodoActual}',
                  style: AppTypography.hint,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          if (_materias.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: AppSpacing.md,
              ),
              child: Text(
                'Todavía no agregas ninguna materia.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.muted,
                ),
              ),
            )
          else
            for (final m in _materias)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _FilaMateria(
                  materia: m,
                  onEditar: () => _editar(m),
                  onQuitar: () => _quitar(m),
                ),
              ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _agregar,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('Agregar una materia'),
            ),
          ),
        ],
      ),
    );

    final lateral = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarjetaCarga(
          materias: _materias.length,
          creditos: _creditos,
          minimo: DatosDemo.creditosMinimos,
        ),
        if (_bajoMinimo && _materias.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          BannerAviso(
            titulo: 'Vas por debajo de la carga mínima',
            mensaje: 'Llevas $_creditos créditos y el mínimo del periodo es '
                '${DatosDemo.creditosMinimos}. Necesitas el oficio de la '
                'dirección que autoriza la carga baja, y se te va a pedir en '
                'tu reinscripción.',
            tono: TonoAviso.informativo,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        const NombreOficial(
          nombre: 'Formato GE-01 · inscripción de unidades de aprendizaje',
          nota: 'Este sí conserva su nombre: así lo pide el formato.',
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Formato GE-01'),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.onGuinda,
          fontSize: compacto ? 17 : 19,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        ),
        children: [
          if (compacto) ...[
            lista,
            const SizedBox(height: AppSpacing.md),
            lateral,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: lista),
                const SizedBox(width: AppSpacing.lg),
                Expanded(flex: 2, child: lateral),
              ],
            ),
        ],
      ),
      bottomNavigationBar: _PieGe01(
        habilitado: _materias.isNotEmpty,
        onGenerar: _generar,
      ),
    );
  }
}

class _FilaMateria extends StatelessWidget {
  const _FilaMateria({
    required this.materia,
    required this.onEditar,
    required this.onQuitar,
  });

  final Materia materia;
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
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  materia.nombre,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  materia.estado == 'NORMAL'
                      ? materia.detalle
                      : '${materia.detalle} · ${materia.estado}',
                  style: AppTypography.hint,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditar,
            tooltip: 'Editar ${materia.nombre}',
            icon: const Icon(Icons.edit_outlined, size: 17),
            color: AppColors.muted,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onQuitar,
            tooltip: 'Quitar ${materia.nombre}',
            icon: const Icon(Icons.close_rounded, size: 17),
            color: AppColors.muted,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// El total de créditos, que deja de ser un campo que el alumno teclea.
class _TarjetaCarga extends StatelessWidget {
  const _TarjetaCarga({
    required this.materias,
    required this.creditos,
    required this.minimo,
  });

  final int materias;
  final int creditos;
  final int minimo;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu carga del periodo', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$creditos',
                style: AppTypography.numeral.copyWith(color: AppColors.guinda),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'créditos en $materias materia${materias == 1 ? '' : 's'}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 13, color: AppColors.success),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Se suma solo. En el sistema actual este número lo escribes '
                  'tú en tu expediente.',
                  style: AppTypography.hint.copyWith(height: 1.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieGe01 extends StatelessWidget {
  const _PieGe01({required this.habilitado, required this.onGenerar});

  final bool habilitado;
  final VoidCallback onGenerar;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return Material(
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
              FilledButton.icon(
                onPressed: habilitado ? onGenerar : null,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('Generar GE-01'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
