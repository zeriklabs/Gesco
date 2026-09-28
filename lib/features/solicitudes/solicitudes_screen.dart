import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/layout/secciones.dart';
import '../../core/models/tramite.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/status_pill.dart';
import 'dictamen_screen.dart';
import 'reinscripcion_screen.dart';

/// El catálogo de trámites.
///
/// En el GESCO actual esto es un menú desplegable con ocho opciones que mezcla
/// dos cosas distintas: cuatro que **generan** algo y tres que solo
/// **descargan** un oficio ya emitido. Aquí van separadas.
class SolicitudesScreen extends StatelessWidget {
  const SolicitudesScreen({super.key, required this.onIr});

  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final tramites = DatosDemo.tramites;

    final catalogo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloBloque(texto: 'Generar un trámite'),
        const SizedBox(height: AppSpacing.sm + 2),
        LayoutBuilder(
          builder: (context, constraints) {
            final dosColumnas = constraints.maxWidth >= 640;
            final tarjetas = [
              for (final tipo in TipoTramite.values)
                _TarjetaTramite(
                  tipo: tipo,
                  existente: _buscar(tramites, tipo),
                  onTap: () => _abrir(context, tipo),
                ),
            ];

            if (!dosColumnas) {
              return Column(
                children: [
                  for (final t in tarjetas)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                      child: t,
                    ),
                ],
              );
            }

            return Column(
              children: [
                for (var i = 0; i < tarjetas.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: tarjetas[i]),
                          const SizedBox(width: AppSpacing.sm + 2),
                          Expanded(
                            child: i + 1 < tarjetas.length
                                ? tarjetas[i + 1]
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );

    final oficios = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloBloque(texto: 'Descargar oficios'),
        const SizedBox(height: AppSpacing.sm + 2),
        const _TarjetaOficios(),
        const SizedBox(height: AppSpacing.sm + 2),
        const _NotaOficios(),
      ],
    );

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        CabeceraPantalla(
          contexto: 'Periodo ${DatosDemo.periodoActual} · '
              '${DatosDemo.periodoLegible}',
          titulo: 'Solicitudes',
        ),
        const SizedBox(height: AppSpacing.lg),
        if (compacto) ...[
          catalogo,
          const SizedBox(height: AppSpacing.xl),
          oficios,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: catalogo),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 2, child: oficios),
            ],
          ),
      ],
    );
  }

  static Tramite? _buscar(List<Tramite> tramites, TipoTramite tipo) {
    for (final t in tramites) {
      if (t.tipo == tipo) return t;
    }
    return null;
  }

  void _abrir(BuildContext context, TipoTramite tipo) {
    final pantalla = switch (tipo) {
      TipoTramite.reinscripcion => const ReinscripcionScreen(),
      TipoTramite.dictamen => const DictamenScreen(),
      _ => null,
    };

    if (pantalla == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tipo.titulo}: pantalla en construcción')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }
}

class _TarjetaTramite extends StatelessWidget {
  const _TarjetaTramite({
    required this.tipo,
    required this.existente,
    required this.onTap,
  });

  final TipoTramite tipo;
  final Tramite? existente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = existente;
    final alerta = t?.estado == EstadoTramite.conObservaciones;
    final bloqueante = t?.documentoBloqueante;

    return GescoCard(
      onTap: onTap,
      bordeGrueso: alerta,
      colorBorde: alerta ? AppColors.dangerBorder : null,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.dangerTint,
                  borderRadius: BorderRadius.circular(AppRadius.sm + 1),
                ),
                child: Icon(tipo.icono, size: 20, color: AppColors.guinda),
              ),
              const SizedBox(width: AppSpacing.sm + 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipo.titulo,
                      style: AppTypography.titleLarge.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tipo.descripcion,
                      style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              if (t != null) ...[
                const SizedBox(width: AppSpacing.xs),
                StatusPill(t.estado, compacta: true),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          _Requisito(
            icono: Icons.check_rounded,
            color: AppColors.success,
            texto: tipo.requiere.join(' · '),
          ),
          if (bloqueante != null) ...[
            const SizedBox(height: 6),
            _Requisito(
              icono: Icons.priority_high_rounded,
              color: AppColors.guinda,
              texto: 'Falta corregir: ${bloqueante.nombre.toLowerCase()}',
            ),
          ] else if (t?.resumen != null) ...[
            const SizedBox(height: 6),
            _Requisito(
              icono: Icons.schedule_rounded,
              color: AppColors.muted,
              texto: t!.resumen!,
            ),
          ],
        ],
      ),
    );
  }
}

class _Requisito extends StatelessWidget {
  const _Requisito({
    required this.icono,
    required this.color,
    required this.texto,
  });

  final IconData icono;
  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 14, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            texto,
            style: AppTypography.hint.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.inkSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaOficios extends StatelessWidget {
  const _TarjetaOficios();

  @override
  Widget build(BuildContext context) {
    const oficios = [
      ('Oficio para el Consejo', 'Emitido el 12 de septiembre', true),
      ('Oficio para la Dirección', 'Emitido el 12 de septiembre', true),
      ('Oficio para la SSEIS', 'Aún no disponible', false),
    ];

    return GescoCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg + 2,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: [
          for (var i = 0; i < oficios.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          oficios[i].$1,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: oficios[i].$3
                                ? AppColors.ink
                                : AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(oficios[i].$2, style: AppTypography.hint),
                      ],
                    ),
                  ),
                  if (oficios[i].$3)
                    IconButton(
                      onPressed: () {},
                      tooltip: 'Descargar ${oficios[i].$1}',
                      icon: const Icon(Icons.download_rounded, size: 18),
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.guinda,
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm - 2),
                        ),
                      ),
                    )
                  else
                    const StatusPill(EstadoTramite.sinSubir, compacta: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotaOficios extends StatelessWidget {
  const _NotaOficios();

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      color: AppColors.dangerTint,
      colorBorde: AppColors.dangerBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.guinda),
              const SizedBox(width: AppSpacing.xs),
              Text('No son solicitudes', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Los oficios son el resultado que Gestión Escolar te devuelve, no '
            'algo que tú pidas. En el sistema actual están mezclados con los '
            'trámites en el mismo menú.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.inkSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
