import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_consejo.dart';
import '../models/dictamen.dart';
import 'dictamenes_screen.dart';

/// El predictamen: quién pidió ir al consejo y en qué va.
///
/// El sistema actual pone dos tablas en la misma página —los que solicitaron
/// y los que ya entregaron documentos— sin decir que son dos momentos del
/// mismo trámite. Aquí es una fila: solicita, entrega, se dictamina.
class PredictamenScreen extends StatefulWidget {
  const PredictamenScreen({super.key});

  @override
  State<PredictamenScreen> createState() => _PredictamenScreenState();
}

class _PredictamenScreenState extends State<PredictamenScreen> {
  void _marcarCompleto(CasoConsejo caso) {
    setState(() {
      DatosDemoConsejo.guardarCaso(
        caso.copyWith(etapa: EtapaPredictamen.entregoDocumentos),
      );
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${caso.nombre}: documentos completos'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => setState(() {
              DatosDemoConsejo.guardarCaso(
                caso.copyWith(etapa: EtapaPredictamen.solicito),
              );
            }),
          ),
        ),
      );
  }

  Future<void> _dictaminar(CasoConsejo caso) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DictaminarScreen(caso: caso)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final pendientes = DatosDemoConsejo.porEtapa(EtapaPredictamen.solicito);
    final completos =
        DatosDemoConsejo.porEtapa(EtapaPredictamen.entregoDocumentos);

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        _Etapa(
          numero: 1,
          titulo: 'Solicitaron predictamen',
          descripcion: 'Todavía no entregan los documentos de COSIE.',
          cuantos: pendientes.length,
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        if (pendientes.isEmpty)
          const _Vacio(texto: 'Nadie esperando.')
        else
          for (final c in pendientes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _TarjetaCaso(
                caso: c,
                accion: _Accion(
                  icono: Icons.check_rounded,
                  texto: 'Documentos completos',
                  onTap: () => _marcarCompleto(c),
                ),
              ),
            ),
        const SizedBox(height: AppSpacing.xl),
        _Etapa(
          numero: 2,
          titulo: 'Entregaron documentos',
          descripcion: 'Listos para que el consejo los dictamine.',
          cuantos: completos.length,
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        if (completos.isEmpty)
          const _Vacio(texto: 'Nadie listo para dictaminar.')
        else
          for (final c in completos)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _TarjetaCaso(
                caso: c,
                mostrarDocumentos: true,
                accion: _Accion(
                  icono: Icons.gavel_rounded,
                  texto: 'Dictaminar',
                  onTap: () => _dictaminar(c),
                  primaria: true,
                ),
              ),
            ),
      ],
    );
  }
}

class _Etapa extends StatelessWidget {
  const _Etapa({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.cuantos,
  });

  final int numero;
  final String titulo;
  final String descripcion;
  final int cuantos;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.guinda,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          alignment: Alignment.center,
          child: Text(
            '$numero',
            style: AppTypography.pill.copyWith(color: AppColors.onGuinda),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(titulo, style: AppTypography.displaySmall),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '· $cuantos',
                    style: AppTypography.displaySmall
                        .copyWith(color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(descripcion, style: AppTypography.hint),
            ],
          ),
        ),
      ],
    );
  }
}

class _Accion {
  const _Accion({
    required this.icono,
    required this.texto,
    required this.onTap,
    this.primaria = false,
  });

  final IconData icono;
  final String texto;
  final VoidCallback onTap;
  final bool primaria;
}

class _TarjetaCaso extends StatelessWidget {
  const _TarjetaCaso({
    required this.caso,
    required this.accion,
    this.mostrarDocumentos = false,
  });

  final CasoConsejo caso;
  final _Accion accion;
  final bool mostrarDocumentos;

  @override
  Widget build(BuildContext context) {
    final dias = caso.solicitadoEl == null
        ? 0
        : DateTime.now().difference(caso.solicitadoEl!).inDays;

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
              if (caso.periodosEnDictamen > 1) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningTint,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    '${caso.periodosEnDictamen}º dictamen',
                    style: AppTypography.pill
                        .copyWith(color: AppColors.warningInk),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              if (dias > 0)
                _Mini(
                  icono: Icons.schedule_rounded,
                  texto: 'Esperando $dias día${dias == 1 ? '' : 's'}',
                ),
              if (caso.materiasAdeudadas.isNotEmpty)
                _Mini(
                  icono: Icons.menu_book_outlined,
                  texto: caso.materiasAdeudadas.length == 1
                      ? '1 materia'
                      : '${caso.materiasAdeudadas.length} materias',
                ),
              if (mostrarDocumentos)
                _Mini(
                  icono: Icons.folder_outlined,
                  texto: '${caso.documentos.length} de 5 documentos',
                ),
            ],
          ),
          if (caso.materiasAdeudadas.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              caso.materiasAdeudadas.join(' · '),
              style: AppTypography.hint.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm + 2),
          Align(
            alignment: Alignment.centerLeft,
            child: accion.primaria
                ? FilledButton.icon(
                    onPressed: accion.onTap,
                    icon: Icon(accion.icono, size: 17),
                    label: Text(accion.texto),
                  )
                : OutlinedButton.icon(
                    onPressed: accion.onTap,
                    icon: Icon(accion.icono, size: 17),
                    label: Text(accion.texto),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: AppColors.muted),
        const SizedBox(width: 5),
        Text(texto, style: AppTypography.hint),
      ],
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Text(
        texto,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
        textAlign: TextAlign.center,
      ),
    );
  }
}
