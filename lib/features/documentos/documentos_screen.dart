import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/layout/secciones.dart';
import '../../core/models/documento.dart';
import '../../core/models/tramite.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/fila_documento.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/status_pill.dart';
import '../solicitudes/reinscripcion_screen.dart';

/// "Mis documentos": el archivero, **solo para consultar**.
///
/// Es lo que queda de las dos secciones de documentos del GESCO actual después
/// del cambio que pidió Gael: subir ya no se hace aquí, se hace dentro del
/// trámite que pide el archivo, al lado del botón que genera el PDF. Aquí nada
/// más se ve qué hay, de qué trámite salió, cuándo lo revisaron y qué dijeron.
///
/// Por eso los documentos van **agrupados por trámite** y no en una lista
/// plana: un archivo suelto no le dice nada al alumno; "esto es del trámite de
/// reinscripción del 27/1" sí.
class DocumentosScreen extends StatelessWidget {
  const DocumentosScreen({super.key, required this.onIr});

  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final tramites = DatosDemo.tramites;

    // Solo los trámites que de verdad piden archivos. Los otros aparecerían
    // como tarjetas vacías.
    final conDocumentos =
        tramites.where((t) => t.documentos.isNotEmpty).toList();

    final todos = [
      for (final t in conDocumentos)
        for (final d in t.documentosAplicables) d,
    ];

    final grupos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < conDocumentos.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _GrupoTramite(
            tramite: conDocumentos[i],
            onAbrirTramite: () => _abrirTramite(context, conDocumentos[i]),
          ),
        ],
        if (conDocumentos.isEmpty) const _SinDocumentos(),
      ],
    );

    final lateral = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Resumen(documentos: todos),
        const SizedBox(height: AppSpacing.md),
        _NotaDondeSeSube(onIr: onIr),
      ],
    );

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        const CabeceraPantalla(
          contexto: 'Todo lo que has entregado, por trámite',
          titulo: 'Mis documentos',
        ),
        const SizedBox(height: AppSpacing.lg),
        if (compacto) ...[
          _Resumen(documentos: todos),
          const SizedBox(height: AppSpacing.lg),
          grupos,
          const SizedBox(height: AppSpacing.md),
          _NotaDondeSeSube(onIr: onIr),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: grupos),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 2, child: lateral),
            ],
          ),
      ],
    );
  }

  void _abrirTramite(BuildContext context, Tramite tramite) {
    if (tramite.tipo == TipoTramite.reinscripcion) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReinscripcionScreen()),
      );
      return;
    }
    onIr(Seccion.solicitudes);
  }
}

/// Cuántos van de cuántos, con la barra por tramos.
class _Resumen extends StatelessWidget {
  const _Resumen({required this.documentos});

  final List<Documento> documentos;

  @override
  Widget build(BuildContext context) {
    final aprobados =
        documentos.where((d) => d.estado == EstadoTramite.aprobado).length;
    final enRevision =
        documentos.where((d) => d.estado == EstadoTramite.enRevision).length;
    final conObservaciones = documentos
        .where((d) => d.estado == EstadoTramite.conObservaciones)
        .length;
    final sinSubir =
        documentos.where((d) => d.estado == EstadoTramite.sinSubir).length;

    return GescoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$aprobados',
                style: AppTypography.numeral.copyWith(color: AppColors.guinda),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'de ${documentos.length} aprobados',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          BarraSegmentos(
            colores: [
              for (final d in documentos) _colorTramo(d.estado),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              if (conObservaciones > 0)
                _Conteo(
                  estado: EstadoTramite.conObservaciones,
                  cantidad: conObservaciones,
                ),
              if (sinSubir > 0)
                _Conteo(estado: EstadoTramite.sinSubir, cantidad: sinSubir),
              if (enRevision > 0)
                _Conteo(estado: EstadoTramite.enRevision, cantidad: enRevision),
              if (aprobados > 0)
                _Conteo(estado: EstadoTramite.aprobado, cantidad: aprobados),
            ],
          ),
        ],
      ),
    );
  }

  static Color _colorTramo(EstadoTramite estado) => switch (estado) {
        EstadoTramite.aprobado => AppColors.success,
        EstadoTramite.enRevision => AppColors.dorado,
        EstadoTramite.conObservaciones => AppColors.guinda,
        EstadoTramite.sinSubir => AppColors.borderStrong,
        EstadoTramite.noAplica => AppColors.border,
      };
}

class _Conteo extends StatelessWidget {
  const _Conteo({required this.estado, required this.cantidad});

  final EstadoTramite estado;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(estado.icono, size: 14, color: estado.tinta),
        const SizedBox(width: 5),
        Text(
          '$cantidad ${estado.etiqueta.toLowerCase()}',
          style: AppTypography.hint.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    );
  }
}

/// Los documentos de un trámite, con su encabezado y la liga para volver a él.
class _GrupoTramite extends StatelessWidget {
  const _GrupoTramite({required this.tramite, required this.onAbrirTramite});

  final Tramite tramite;
  final VoidCallback onAbrirTramite;

  @override
  Widget build(BuildContext context) {
    final aplicables = tramite.documentosAplicables;
    final noAplican = tramite.documentosNoAplicables;

    return GescoCard(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Row(
              children: [
                Icon(tramite.tipo.icono, size: 18, color: AppColors.guinda),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tramite.tipo.titulo,
                        style: AppTypography.titleLarge.copyWith(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Periodo ${tramite.periodo} · '
                        '${tramite.documentosAprobados} de '
                        '${tramite.documentosRequeridos} aprobados',
                        style: AppTypography.hint,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                StatusPill(tramite.estado, compacta: true),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < aplicables.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.xs),
            FilaDocumento(
              documento: aplicables[i],
              compacta: true,
              onVer: () => _verDetalle(context, aplicables[i]),
            ),
          ],
          if (noAplican.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _NoAplicanEnGrupo(documentos: noAplican),
          ],
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAbrirTramite,
              icon: const Icon(Icons.north_east_rounded, size: 15),
              label: const Text('Ir al trámite para subir o reemplazar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.guinda,
                textStyle: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _verDetalle(BuildContext context, Documento documento) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      // Sin esto la hoja se queda en 9/16 de la pantalla y el detalle con
      // observacion larga se desborda por abajo.
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (_) => _DetalleDocumento(
        documento: documento,
        tramite: tramite,
        onAbrirTramite: () {
          Navigator.of(context).pop();
          onAbrirTramite();
        },
      ),
    );
  }
}

/// El detalle completo de un archivo ya entregado.
///
/// Incluye quién lo revisó y la observación entera. En el sistema actual esto
/// no existe: hay un icono rojo y el alumno va a preguntar en la ventanilla.
class _DetalleDocumento extends StatelessWidget {
  const _DetalleDocumento({
    required this.documento,
    required this.tramite,
    required this.onAbrirTramite,
  });

  final Documento documento;
  final Tramite tramite;
  final VoidCallback onAbrirTramite;

  @override
  Widget build(BuildContext context) {
    final d = documento;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg + 2,
          0,
          AppSpacing.lg + 2,
          AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(d.nombre, style: AppTypography.displaySmall),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusPill(d.estado),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${tramite.tipo.titulo} · periodo ${tramite.periodo}',
              style: AppTypography.hint,
            ),
            const SizedBox(height: AppSpacing.md),
            if (d.observacion != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.dangerTint,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.dangerBorder, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lo que dijo ${d.revisadoPor ?? 'Gestión Escolar'}',
                      style: AppTypography.label
                          .copyWith(color: AppColors.guinda),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      d.observacion!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.inkSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _Dato(etiqueta: 'Archivo', valor: d.nombreArchivo ?? 'Sin subir'),
            if (d.bytes != null) _Dato(etiqueta: 'Peso', valor: d.pesoLegible),
            _Dato(etiqueta: 'Subido', valor: _fechaLarga(d.subidoEl)),
            _Dato(etiqueta: 'Revisado', valor: _fechaLarga(d.revisadoEl)),
            if (d.revisadoPor != null)
              _Dato(etiqueta: 'Revisó', valor: d.revisadoPor!),
            const SizedBox(height: AppSpacing.md),
            if (d.estaAprobado)
              Text(
                'Aprobado. Ya no se puede reemplazar.',
                style: AppTypography.hint.copyWith(
                  color: AppColors.successInk,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAbrirTramite,
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: Text(
                    d.estado == EstadoTramite.sinSubir
                        ? 'Subirlo en el trámite'
                        : 'Reemplazarlo en el trámite',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(etiqueta, style: AppTypography.hint),
          ),
          Expanded(
            child: Text(
              valor,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Los que no le tocan a este alumno, plegados.
class _NoAplicanEnGrupo extends StatelessWidget {
  const _NoAplicanEnGrupo({required this.documentos});

  final List<Documento> documentos;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm + 2,
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          leading: const Icon(
            Icons.remove_circle_outline_rounded,
            size: 18,
            color: AppColors.placeholder,
          ),
          title: Text(
            '${documentos.length} no te aplican',
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.inkSecondary,
            ),
          ),
          children: [
            for (final d in documentos)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.remove_rounded,
                          size: 13, color: AppColors.placeholder),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.nombre,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                          Text(
                            d.porQueNoAplica ?? 'No aplica a tu situación',
                            style: AppTypography.hint,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// La explicación del cambio, para quien venga del sistema viejo buscando
/// "Subir documentos".
class _NotaDondeSeSube extends StatelessWidget {
  const _NotaDondeSeSube({required this.onIr});

  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded,
                  size: 18, color: AppColors.guinda),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '¿Dónde se suben?',
                  style: AppTypography.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dentro del trámite que los pide, junto al botón que genera el '
            'PDF. Así no tienes que adivinar a qué trámite pertenece cada '
            'archivo ni brincar entre dos pantallas.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.inkSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => onIr(Seccion.solicitudes),
              icon: const Icon(Icons.description_outlined, size: 17),
              label: const Text('Ver mis trámites'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SinDocumentos extends StatelessWidget {
  const _SinDocumentos();

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_outlined,
              size: 34, color: AppColors.placeholder),
          const SizedBox(height: AppSpacing.sm),
          Text('Todavía no hay documentos',
              style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Aparecerán aquí en cuanto empieces un trámite que los pida.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _fechaLarga(DateTime? f) {
  if (f == null) return 'Pendiente';
  const meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  return '${f.day} de ${meses[f.month - 1]} de ${f.year}';
}
