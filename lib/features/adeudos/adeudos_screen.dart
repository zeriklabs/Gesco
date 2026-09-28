import 'package:flutter/material.dart';

import '../../core/data/catalogos.dart';
import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/layout/secciones.dart';
import '../../core/models/expediente.dart';
import '../../core/models/tramite.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/gesco_select.dart';
import '../../widgets/gesco_text_field.dart';

/// Los adeudos del alumno: las unidades de aprendizaje que debe.
///
/// En el GESCO actual este mismo formulario está **cuatro veces**, como
/// submenú de la baja de UAp, del dictamen, de la baja de unidad académica y
/// del GE-01. Idéntico en los cuatro, y cada uno con su propia captura: si el
/// alumno agrega un adeudo en el dictamen, la baja de UAp no se entera.
///
/// Aquí se captura una vez y los cuatro trámites leen de esta lista. Es el
/// mismo principio del expediente, aplicado a lo único académico que GESCO
/// tiene de verdad.
class AdeudosScreen extends StatefulWidget {
  const AdeudosScreen({super.key, required this.onIr});

  final IrASeccion onIr;

  @override
  State<AdeudosScreen> createState() => _AdeudosScreenState();
}

class _AdeudosScreenState extends State<AdeudosScreen> {
  List<Adeudo> get _adeudos => DatosDemo.adeudos;

  Future<void> _agregar() async {
    final nuevo = await pedirAdeudo(context);
    if (nuevo == null) return;
    setState(() => DatosDemo.adeudos.add(nuevo));
  }

  /// Quitar con deshacer, en vez de un diálogo de confirmación.
  ///
  /// Preguntar "¿estás seguro?" traslada la duda al alumno; deshacer le
  /// devuelve el control sin frenarlo.
  void _quitar(Adeudo adeudo) {
    final posicion = _adeudos.indexOf(adeudo);
    setState(() => DatosDemo.adeudos.remove(adeudo));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Se quitó ${adeudo.unidadAprendizaje}'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () =>
                setState(() => DatosDemo.adeudos.insert(posicion, adeudo)),
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
        TituloBloque(
          texto: 'Unidades que debes',
          accion: compacto
              ? null
              : FilledButton.icon(
                  onPressed: _agregar,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Agregar adeudo'),
                ),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        if (_adeudos.isEmpty)
          const _SinAdeudos()
        else
          for (final a in _adeudos)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _FilaAdeudo(adeudo: a, onQuitar: () => _quitar(a)),
            ),
        if (compacto) ...[
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _agregar,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Agregar adeudo'),
            ),
          ),
        ],
      ],
    );

    final lateral = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarjetaQuienLoUsa(onIr: widget.onIr),
        const SizedBox(height: AppSpacing.md),
        _TarjetaCuentas(adeudos: _adeudos),
      ],
    );

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        CabeceraPantalla(
          contexto: '${_adeudos.length} unidad'
              '${_adeudos.length == 1 ? '' : 'es'} registrada'
              '${_adeudos.length == 1 ? '' : 's'}',
          titulo: 'Adeudos',
        ),
        const SizedBox(height: AppSpacing.lg),
        if (compacto) ...[
          lista,
          const SizedBox(height: AppSpacing.lg),
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
    );
  }
}

/// Un adeudo de la lista.
class _FilaAdeudo extends StatelessWidget {
  const _FilaAdeudo({required this.adeudo, required this.onQuitar});

  final Adeudo adeudo;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md + 2,
        AppSpacing.sm + 2,
        AppSpacing.sm,
        AppSpacing.sm + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adeudo.unidadAprendizaje,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    _Etiqueta(texto: adeudo.nivel),
                    _Etiqueta(
                      texto: 'Reprobada en ${adeudo.periodoReprobada}',
                    ),
                    if (adeudo.semestreReprobada != null)
                      _Etiqueta(texto: '${adeudo.semestreReprobada} semestre'),
                    _Etiqueta(texto: adeudo.estado, destacada: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: onQuitar,
            tooltip: 'Quitar ${adeudo.unidadAprendizaje}',
            icon: const Icon(Icons.delete_outline_rounded, size: 19),
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, this.destacada = false});

  final String texto;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: destacada ? AppColors.dangerTint : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        texto,
        style: AppTypography.pill.copyWith(
          color: destacada ? AppColors.guinda : AppColors.inkSecondary,
        ),
      ),
    );
  }
}

class _SinAdeudos extends StatelessWidget {
  const _SinAdeudos();

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 34, color: AppColors.success),
          const SizedBox(height: AppSpacing.sm),
          Text('No debes ninguna unidad', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Si reprobaste alguna y no aparece aquí, agrégala: los trámites '
            'que la piden la toman de esta lista.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Por qué esta sección existe aparte.
class _TarjetaQuienLoUsa extends StatelessWidget {
  const _TarjetaQuienLoUsa({required this.onIr});

  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    const usan = [
      TipoTramite.bajaUnidades,
      TipoTramite.dictamen,
      TipoTramite.bajaUnidadAcademica,
      TipoTramite.ge01,
    ];

    return GescoCard(
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_outlined, size: 18, color: AppColors.guinda),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text('Se captura una vez',
                    style: AppTypography.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hoy este mismo formulario está dentro de cuatro trámites, y lo '
            'que capturas en uno no aparece en los otros. Estos cuatro leen '
            'de aquí:',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.inkSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final t in usan)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(t.icono, size: 15, color: AppColors.muted),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      t.titulo,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => onIr(Seccion.solicitudes),
              icon: const Icon(Icons.description_outlined, size: 17),
              label: const Text('Ir a Solicitudes'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Los tres números que el dictamen ya no pide teclear.
class _TarjetaCuentas extends StatelessWidget {
  const _TarjetaCuentas({required this.adeudos});

  final List<Adeudo> adeudos;

  @override
  Widget build(BuildContext context) {
    final recursadas = adeudos
        .where((a) => a.estado.toUpperCase().contains('RECURSA'))
        .length;
    final ets =
        adeudos.where((a) => a.estado.toUpperCase().contains('ETS')).length;

    final cuentas = [
      ('UAp adeudadas', adeudos.length),
      ('UAp recursadas', recursadas),
      ('Acreditadas en E.T.S.', ets),
    ];

    return GescoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lo que sale de aquí', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'La solicitud de dictamen ya no te pide estos tres números: los '
            'toma de esta lista.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.inkSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < cuentas.length; i++) ...[
            if (i > 0) const Divider(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    cuentas[i].$1,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ),
                Text(
                  '${cuentas[i].$2}',
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 20,
                    color: AppColors.guinda,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// --- El formulario ---------------------------------------------------------

/// Abre el formulario donde quepa mejor: hoja abajo en celular, diálogo
/// centrado en escritorio. Devuelve el adeudo o `null` si se canceló.
///
/// Es público porque el dictamen también lo usa: ahí los adeudos se capturan
/// sin salirse de la solicitud.
Future<Adeudo?> pedirAdeudo(BuildContext context) {
  if (context.isCompact) {
    return showModalBottomSheet<Adeudo>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => const _FormAdeudo(),
    );
  }

  return showDialog<Adeudo>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: const _FormAdeudo(),
      ),
    ),
  );
}

class _FormAdeudo extends StatefulWidget {
  const _FormAdeudo();

  @override
  State<_FormAdeudo> createState() => _FormAdeudoState();
}

class _FormAdeudoState extends State<_FormAdeudo> {
  final _form = GlobalKey<FormState>();
  final _unidad = TextEditingController();

  String? _nivel;
  String? _estado;
  String? _periodo;
  String? _semestre;

  @override
  void dispose() {
    _unidad.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!(_form.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      Adeudo(
        unidadAprendizaje: _unidad.text.trim(),
        nivel: _nivel!,
        periodoReprobada: _periodo!,
        semestreReprobada: _semestre,
        estado: _estado!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodos = Catalogos.periodosHasta(DatosDemo.periodoActual);

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
              Text('Agregar un adeudo', style: AppTypography.displaySmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Una unidad de aprendizaje que reprobaste y todavía debes.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // TODO(gescolar): esto debería ser un desplegable con el plan de
              // estudios de la carrera del alumno, como en el sistema actual.
              // No lo invento: un nombre de materia mal escrito por mí sería
              // peor que uno escrito por el alumno.
              GescoTextField(
                label: 'Unidad de aprendizaje',
                controller: _unidad,
                isRequired: true,
                textCapitalization: TextCapitalization.words,
                helperText: 'Escríbela igual que aparece en el SAES.',
                validator: (v) => (v == null || v.trim().length < 4)
                    ? 'Escribe el nombre de la unidad'
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
                  GescoSelect<String>(
                    label: 'Cómo la vas a cursar',
                    opciones: Catalogos.estadosAdeudo,
                    value: _estado,
                    isRequired: true,
                    onChanged: (v) => setState(() => _estado = v),
                    validator: (v) => v == null ? 'Elige una opción' : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CamposEnFila(
                anchoMinimo: 460,
                children: [
                  GescoSelect<String>(
                    label: 'Periodo en que la reprobaste',
                    opciones: periodos,
                    value: _periodo,
                    isRequired: true,
                    onChanged: (v) => setState(() => _periodo = v),
                    validator: (v) => v == null ? 'Elige el periodo' : null,
                  ),
                  GescoSelect<String>(
                    label: 'Semestre en que la reprobaste',
                    opciones: Catalogos.semestres,
                    value: _semestre,
                    onChanged: (v) => setState(() => _semestre = v),
                  ),
                ],
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
                    label: const Text('Agregar'),
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
