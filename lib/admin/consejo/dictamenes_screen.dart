import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_consejo.dart';
import '../models/dictamen.dart';

/// Los dictámenes emitidos: consultar, corregir e imprimir.
class DictamenesScreen extends StatefulWidget {
  const DictamenesScreen({super.key});

  @override
  State<DictamenesScreen> createState() => _DictamenesScreenState();
}

class _DictamenesScreenState extends State<DictamenesScreen> {
  Future<void> _editar(CasoConsejo caso) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DictaminarScreen(caso: caso)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final lista = DatosDemoConsejo.porEtapa(EtapaPredictamen.dictaminado);

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                lista.length == 1
                    ? '1 dictamen de este periodo'
                    : '${lista.length} dictámenes de este periodo',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.inkSecondary),
              ),
            ),
            OutlinedButton.icon(
              onPressed: lista.isEmpty
                  ? null
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La exportación sale con el servidor.'),
                        ),
                      ),
              icon: const Icon(Icons.download_rounded, size: 17),
              label: const Text('Exportar todos'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (lista.isEmpty)
          GescoCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.gavel_outlined,
                    size: 34, color: AppColors.placeholder),
                const SizedBox(height: AppSpacing.sm),
                Text('Sin dictámenes', style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Los que dictamines en Predictamen aparecen aquí.',
                  style:
                      AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          for (final c in lista)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _TarjetaDictamen(caso: c, onEditar: () => _editar(c)),
            ),
      ],
    );
  }
}

class _TarjetaDictamen extends StatelessWidget {
  const _TarjetaDictamen({required this.caso, required this.onEditar});

  final CasoConsejo caso;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final texto = DatosDemoConsejo.texto(caso.textoId);

    return GescoCard(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caso.nombre,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('${caso.boleta} · ${caso.carrera}',
                        style: AppTypography.hint),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEditar,
                tooltip: 'Corregir el dictamen',
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: AppColors.muted,
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La impresión sale con el servidor.'),
                  ),
                ),
                tooltip: 'Imprimir',
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.muted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texto?.titulo ?? 'Sin texto asignado',
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.guinda,
                  ),
                ),
                if (caso.nota3.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    caso.nota3,
                    style: AppTypography.hint.copyWith(
                      color: AppColors.inkSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Emitir o corregir el dictamen de un alumno.
///
/// Lo que cambia respecto al sistema actual: el **mensaje** se elige viendo
/// el párrafo completo que se va a imprimir, no un título suelto de una lista
/// desplegable. Quien captura no tiene que acordarse de memoria de qué dice
/// "recursa y avanza carga media (2 p.e.)".
class DictaminarScreen extends StatefulWidget {
  const DictaminarScreen({super.key, required this.caso});

  final CasoConsejo caso;

  @override
  State<DictaminarScreen> createState() => _DictaminarScreenState();
}

class _DictaminarScreenState extends State<DictaminarScreen> {
  late String? _textoId = widget.caso.textoId;
  late final _nota3 = TextEditingController(
    text: widget.caso.nota3.isEmpty
        ? widget.caso.nota3Sugerida
        : widget.caso.nota3,
  );

  @override
  void dispose() {
    _nota3.dispose();
    super.dispose();
  }

  void _guardar() {
    DatosDemoConsejo.guardarCaso(
      widget.caso.copyWith(
        etapa: EtapaPredictamen.dictaminado,
        textoId: _textoId,
        nota3: _nota3.text.trim(),
      ),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dictamen guardado para ${widget.caso.nombre}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final elegido = DatosDemoConsejo.texto(_textoId);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.caso.nombre),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.ink,
          fontSize: compacto ? 16 : 19,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: Padding(
            padding: EdgeInsets.only(
              left: compacto ? AppSpacing.md : AppSpacing.gutterDesktop,
              bottom: AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.caso.boleta} · ${widget.caso.carrera}',
                style: AppTypography.hint.copyWith(color: AppColors.muted),
              ),
            ),
          ),
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
                  if (widget.caso.materiasAdeudadas.isNotEmpty) ...[
                    _Contexto(caso: widget.caso),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text('Qué resuelve el consejo',
                      style: AppTypography.displaySmall),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Elige el texto viendo lo que de verdad se va a imprimir.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.inkSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final t in DatosDemoConsejo.textos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: _OpcionTexto(
                        texto: t,
                        elegido: t.id == _textoId,
                        onTap: () => setState(() => _textoId = t.id),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Nota 3', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'El texto libre que acompaña al dictamen. Lo llené con las '
                    'materias que ya están en su expediente; corrígelo si hace '
                    'falta.',
                    style: AppTypography.hint.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _nota3,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'PRIMER DICTAMEN POR: …',
                    ),
                  ),
                  if (elegido != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _VistaPreviaDictamen(
                      caso: widget.caso,
                      texto: elegido,
                      nota3: _nota3.text,
                    ),
                  ],
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
                Expanded(
                  child: Text(
                    _textoId == null
                        ? 'Elige un texto para poder guardar'
                        : 'Listo para guardar',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: _textoId == null ? null : _guardar,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Guardar dictamen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Contexto extends StatelessWidget {
  const _Contexto({required this.caso});

  final CasoConsejo caso;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_outlined,
                  size: 17, color: AppColors.guinda),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Por qué viene al consejo',
                  style: AppTypography.titleLarge.copyWith(fontSize: 15),
                ),
              ),
              if (caso.periodosEnDictamen > 1)
                Text(
                  '${caso.periodosEnDictamen}º dictamen',
                  style: AppTypography.pill
                      .copyWith(color: AppColors.warningInk),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            caso.materiasAdeudadas.join(' · '),
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

class _OpcionTexto extends StatelessWidget {
  const _OpcionTexto({
    required this.texto,
    required this.elegido,
    required this.onTap,
  });

  final TextoDictamen texto;
  final bool elegido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final resuelto = texto.resolver(DatosDemoConsejo.periodoActivo);

    return Material(
      color: elegido ? AppColors.dangerTint : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: elegido ? AppColors.guinda : AppColors.border,
              width: elegido ? 2 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                elegido
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: elegido ? AppColors.guinda : AppColors.placeholder,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texto.titulo,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      resuelto,
                      style: AppTypography.hint.copyWith(height: 1.5),
                      maxLines: elegido ? null : 2,
                      overflow: elegido ? null : TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cómo va a salir impreso.
class _VistaPreviaDictamen extends StatelessWidget {
  const _VistaPreviaDictamen({
    required this.caso,
    required this.texto,
    required this.nota3,
  });

  final CasoConsejo caso;
  final TextoDictamen texto;
  final String nota3;

  @override
  Widget build(BuildContext context) {
    final sesion = DatosDemoConsejo.sesion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloBloque(texto: 'Así sale impreso'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg + 2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderStrong, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CONSEJO TÉCNICO CONSULTIVO ESCOLAR Nº ${sesion.numeroConsejo}',
                style: _serif(12, peso: FontWeight.w700),
              ),
              Text(
                '${sesion.numeroSesion} · ${sesion.fechaSesion}',
                style: _serif(11, color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.sm),
              Text(caso.nombre, style: _serif(13, peso: FontWeight.w800)),
              Text(
                '${caso.boleta} · ${caso.carrera}',
                style: _serif(11, color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                texto.resolver(DatosDemoConsejo.periodoActivo),
                style: _serif(11.5).copyWith(height: 1.6),
                textAlign: TextAlign.justify,
              ),
              if (nota3.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  nota3.trim(),
                  style: _serif(11.5, peso: FontWeight.w700)
                      .copyWith(height: 1.6),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Divider(color: AppColors.borderStrong),
                        Text(sesion.presidente,
                            style: _serif(10), textAlign: TextAlign.center),
                        Text('PRESIDENTE',
                            style: _serif(9, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    child: Column(
                      children: [
                        const Divider(color: AppColors.borderStrong),
                        Text(sesion.secretario,
                            style: _serif(10), textAlign: TextAlign.center),
                        Text('SECRETARIO',
                            style: _serif(9, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static TextStyle _serif(
    double size, {
    FontWeight peso = FontWeight.w500,
    Color color = AppColors.ink,
  }) {
    return TextStyle(
      fontFamily: 'Georgia',
      fontSize: size,
      fontWeight: peso,
      color: color,
    );
  }
}
