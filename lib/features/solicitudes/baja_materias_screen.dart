import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/models/materia.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/gesco_text_field.dart';
import 'nombre_oficial.dart';

/// Baja de materias del periodo.
///
/// El sistema actual pide **dos listas**: las materias que se dan de baja y
/// las que se quedan, las dos armadas a mano con el mismo par de selectores.
/// De ahí sale la advertencia que trae hoy en rojo — *"debes inscribir todas
/// las que llevas en el periodo escolar actual"* —: la lista de las que se
/// quedan se le olvida a la gente, y con razón, porque el sistema ya las
/// conoce.
///
/// Aquí es una sola lista con palomitas. El alumno marca lo que va a dar de
/// baja y lo demás se queda solo. La advertencia sobra.
class BajaMateriasScreen extends StatefulWidget {
  const BajaMateriasScreen({super.key});

  @override
  State<BajaMateriasScreen> createState() => _BajaMateriasScreenState();
}

class _BajaMateriasScreenState extends State<BajaMateriasScreen> {
  final _form = GlobalKey<FormState>();
  final _motivo = TextEditingController();
  final _seleccionadas = <String>{};

  List<Materia> get _materias => DatosDemo.materiasInscritas;

  int get _creditosDeBaja => _materias
      .where((m) => _seleccionadas.contains(m.id))
      .fold(0, (suma, m) => suma + m.creditos);

  int get _creditosRestantes => DatosDemo.creditosInscritos - _creditosDeBaja;

  bool get _quedaBajoMinimo =>
      _seleccionadas.isNotEmpty && _creditosRestantes < DatosDemo.creditosMinimos;

  bool get _sinMaterias => _seleccionadas.length == _materias.length;

  bool get _puedeGenerar => _seleccionadas.isNotEmpty;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  void _alternar(Materia m) {
    setState(() {
      if (!_seleccionadas.remove(m.id)) _seleccionadas.add(m.id);
    });
  }

  void _generar() {
    if (!(_form.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generando la solicitud de baja de ${_seleccionadas.length} '
          'materia${_seleccionadas.length == 1 ? '' : 's'}…',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    final lista = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GescoCard(
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
                        'Materias que estás cursando',
                        style: AppTypography.titleLarge.copyWith(fontSize: 16),
                      ),
                    ),
                    Text(
                      '${_materias.length} · ${DatosDemo.creditosInscritos} '
                      'créditos',
                      style: AppTypography.hint,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: Text(
                  'Marca las que vas a dar de baja. Las que no marques se '
                  'quedan como están.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.inkSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              for (final m in _materias)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _FilaMateria(
                    materia: m,
                    marcada: _seleccionadas.contains(m.id),
                    onTap: () => _alternar(m),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Form(
          key: _form,
          child: GescoCard(
            child: GescoTextField(
              label: 'Motivo de la baja',
              controller: _motivo,
              isRequired: true,
              maxLines: 4,
              hintText: 'Por qué necesitas dar de baja estas materias.',
              helperText: 'Lo lee Gestión Escolar para autorizarla.',
              validator: (v) => (v == null || v.trim().length < 15)
                  ? 'Explícalo en un par de renglones'
                  : null,
            ),
          ),
        ),
      ],
    );

    final lateral = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarjetaCreditos(
          antes: DatosDemo.creditosInscritos,
          despues: _creditosRestantes,
          deBaja: _creditosDeBaja,
          cuantas: _seleccionadas.length,
        ),
        if (_sinMaterias) ...[
          const SizedBox(height: AppSpacing.md),
          const BannerAviso(
            titulo: 'Te quedarías sin materias',
            mensaje: 'Dar de baja todas las materias del periodo no es una '
                'baja de materias: es una baja de la escuela, y ese es otro '
                'trámite. Desmarca alguna o regresa y elige "Baja de la '
                'escuela".',
          ),
        ] else if (_quedaBajoMinimo) ...[
          const SizedBox(height: AppSpacing.md),
          BannerAviso(
            titulo: 'Vas a quedar por debajo de la carga mínima',
            mensaje: 'Te quedarían $_creditosRestantes créditos y el mínimo '
                'del periodo es ${DatosDemo.creditosMinimos}. Vas a necesitar '
                'el oficio de la dirección que autoriza la carga baja, y se '
                'te va a pedir en tu reinscripción.',
            pie: 'No te frena el trámite, pero más vale saberlo ahora.',
            tono: TonoAviso.informativo,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        const NombreOficial(
          nombre: 'Solicitud de baja de unidades de aprendizaje',
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Baja de materias'),
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
      bottomNavigationBar: _PieGenerar(
        habilitado: _puedeGenerar,
        cuantas: _seleccionadas.length,
        onGenerar: _generar,
      ),
    );
  }
}

/// Una materia con su palomita.
class _FilaMateria extends StatelessWidget {
  const _FilaMateria({
    required this.materia,
    required this.marcada,
    required this.onTap,
  });

  final Materia materia;
  final bool marcada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: marcada ? AppColors.dangerTint : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: marcada ? AppColors.guinda : AppColors.border,
              width: marcada ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: marcada,
                onChanged: (_) => onTap(),
                activeColor: AppColors.guinda,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materia.nombre,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: marcada ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.guinda,
                        decorationThickness: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(materia.detalle, style: AppTypography.hint),
                  ],
                ),
              ),
              if (materia.estado != 'NORMAL') ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warningTint,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    materia.estado,
                    style: AppTypography.pill
                        .copyWith(color: AppColors.warningInk),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Cuántos créditos quedan si se da de baja lo marcado.
class _TarjetaCreditos extends StatelessWidget {
  const _TarjetaCreditos({
    required this.antes,
    required this.despues,
    required this.deBaja,
    required this.cuantas,
  });

  final int antes;
  final int despues;
  final int deBaja;
  final int cuantas;

  @override
  Widget build(BuildContext context) {
    final hayCambio = cuantas > 0;

    return GescoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cómo te quedas', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$despues',
                style: AppTypography.numeral.copyWith(
                  color: hayCambio ? AppColors.guinda : AppColors.ink,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  hayCambio ? 'créditos, de $antes' : 'créditos',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hayCambio
                ? 'Das de baja $cuantas materia${cuantas == 1 ? '' : 's'} '
                    '($deBaja créditos).'
                : 'Todavía no marcas ninguna materia.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.inkSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// El botón de generar, fijo al pie.
class _PieGenerar extends StatelessWidget {
  const _PieGenerar({
    required this.habilitado,
    required this.cuantas,
    required this.onGenerar,
  });

  final bool habilitado;
  final int cuantas;
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
              Expanded(
                child: Text(
                  habilitado
                      ? '$cuantas materia${cuantas == 1 ? '' : 's'} marcada'
                          '${cuantas == 1 ? '' : 's'}'
                      : 'Marca al menos una materia',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: habilitado ? onGenerar : null,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('Generar solicitud'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
