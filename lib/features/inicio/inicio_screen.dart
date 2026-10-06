import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/layout/secciones.dart';
import '../../core/models/documento.dart';
import '../../core/models/expediente.dart';
import '../../core/models/tramite.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/boton_notificaciones.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/status_pill.dart';


/// La pantalla que GESCO no tiene.
///
/// Hoy el alumno no tiene dónde ver en qué van sus trámites: la simbología de
/// estatus está como leyenda al pie de cada página de subida, y para saber si
/// le falta algo tiene que entrar a cada sección. Aquí se lo decimos de
/// entrada, y lo que está bloqueado va hasta arriba.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, required this.onIr});

  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    final expediente = DatosDemo.expediente;
    final tramites = DatosDemo.tramites;
    final bloqueado = _primerBloqueo(tramites);
    final compacto = context.isCompact;

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        if (compacto)
          _PerfilHeaderCard(
            bloqueo: bloqueado,
            onIr: onIr,
          )
        else
          CabeceraPantalla(
            contexto: 'Boleta ${DatosDemo.boleta} · ${DatosDemo.carrera} · '
                '${DatosDemo.grupo}',
            titulo: 'Hola, ${DatosDemo.nombreAlumno.split(' ').first}',
            acciones: [
              BotonNotificaciones(
                bloqueo: bloqueado,
                onIr: onIr,
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.lg),

        _TarjetaExpediente(expediente: expediente, onIr: onIr),
        const SizedBox(height: AppSpacing.lg),

        if (compacto) ...[
          _BloqueSolicitudes(tramites: tramites, onIr: onIr),
          const SizedBox(height: AppSpacing.lg),
          _BloqueDocumentos(tramites: tramites, onIr: onIr),
        ] else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: _BloqueSolicitudes(tramites: tramites, onIr: onIr),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: _BloqueDocumentos(tramites: tramites, onIr: onIr),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// El primer documento con observaciones, de cualquier trámite.
  (Tramite, Documento)? _primerBloqueo(List<Tramite> tramites) {
    for (final t in tramites) {
      final d = t.documentoBloqueante;
      if (d != null) return (t, d);
    }
    return null;
  }
}

/// Tarjeta de perfil del alumno para la vista móvil con botón de cierre de sesión.
class _PerfilHeaderCard extends StatelessWidget {
  const _PerfilHeaderCard({
    required this.bloqueo,
    required this.onIr,
  });

  final (Tramite, Documento)? bloqueo;
  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.guinda,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.guinda.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              DatosDemo.iniciales,
              style: AppTypography.titleLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onGuinda,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DatosDemo.nombreAlumno,
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Boleta ${DatosDemo.boleta} · ${DatosDemo.grupo}',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DatosDemo.carrera,
                  style: AppTypography.hint.copyWith(
                    fontSize: 11.5,
                    color: AppColors.inkSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          BotonNotificaciones(
            bloqueo: bloqueo,
            onIr: onIr,
          ),
        ],
      ),
    );
  }
}

/// La tarjeta guinda con el estado del expediente y sus cuatro pasos.
class _TarjetaExpediente extends StatelessWidget {
  const _TarjetaExpediente({required this.expediente, required this.onIr});

  final Expediente expediente;
  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    final completo = expediente.estaCompleto;

    final chips = [
      for (final seccion in SeccionExpediente.values)
        _ChipPaso(
          seccion: seccion,
          completa: expediente.secciones[seccion]?.completa ?? false,
        ),
    ];

    final encabezado = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TU EXPEDIENTE',
          style: AppTypography.overline.copyWith(color: AppColors.dorado),
        ),
        const SizedBox(height: 6),
        Text(
          completo ? 'Completo' : 'Te faltan ${expediente.pendientes.length}',
          style: AppTypography.displaySmall.copyWith(
            fontSize: 25,
            color: AppColors.onGuinda,
          ),
        ),
      ],
    );

    return GescoCard(
      color: AppColors.guinda,
      colorBorde: AppColors.guinda,
      onTap: () => onIr(Seccion.expediente),
      child: context.isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: encabezado),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.dorado),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(spacing: AppSpacing.xs, runSpacing: AppSpacing.xs, children: chips),
              ],
            )
          : Row(
              children: [
                encabezado,
                const SizedBox(width: AppSpacing.lg),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.overlayBorderOnGuinda,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: chips,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Revisar →',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.dorado,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ChipPaso extends StatelessWidget {
  const _ChipPaso({required this.seccion, required this.completa});

  final SeccionExpediente seccion;
  final bool completa;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlayOnGuinda,
        borderRadius: BorderRadius.circular(AppRadius.sm + 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completa ? Icons.check_rounded : Icons.remove_rounded,
            size: 15,
            color: completa
                ? AppColors.successOnGuinda
                : AppColors.onGuindaFaint,
          ),
          const SizedBox(width: AppSpacing.xxs + 2),
          Flexible(
            child: Text(
              seccion.titulo.replaceFirst('Datos ', ''),
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: completa
                    ? AppColors.onGuinda
                    : AppColors.onGuindaMuted,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _BloqueSolicitudes extends StatelessWidget {
  const _BloqueSolicitudes({required this.tramites, required this.onIr});

  final List<Tramite> tramites;
  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TituloBloque(
                texto: 'Mis solicitudes',
              ),
              const SizedBox(height: AppSpacing.xs),
              for (var i = 0; i < tramites.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _FilaTramite(
                  tramite: tramites[i],
                  onTap: () => onIr(Seccion.solicitudes),
                ),
              ],
            ],
          ),
          Positioned(
            top: -2,
            right: -4,
            child: TextButton(
              onPressed: () => onIr(Seccion.solicitudes),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.guinda,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Ver historial →'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaTramite extends StatelessWidget {
  const _FilaTramite({required this.tramite, required this.onTap});

  final Tramite tramite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    final subtitulo = tramite.resumen ??
        'Generada el ${_fechaCorta(tramite.creadoEl)} · '
            'Periodo ${tramite.periodo}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tramite.estado.fondo == AppColors.danger
                    ? AppColors.dangerTint
                    : tramite.estado.fondo,
                borderRadius: BorderRadius.circular(AppRadius.sm + 1),
              ),
              child: Icon(
                tramite.tipo.icono,
                size: 19,
                color: tramite.estado == EstadoTramite.conObservaciones
                    ? AppColors.guinda
                    : tramite.estado.tinta,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tramite.tipo.titulo,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: AppTypography.bodySmall.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            StatusPill(tramite.estado, compacta: compacto),
          ],
        ),
      ),
    );
  }
}

String _fechaCorta(DateTime? f) {
  if (f == null) return '—';
  const meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${f.day} ${meses[f.month - 1]}';
}

class _BloqueDocumentos extends StatelessWidget {
  const _BloqueDocumentos({required this.tramites, required this.onIr});

  final List<Tramite> tramites;
  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    final aplicables = [
      for (final t in tramites) ...t.documentosAplicables,
    ];
    final aprobados = aplicables.where((d) => d.estaAprobado).length;

    return GescoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TituloBloque(
            texto: 'Documentos',
            accion: Text(
              '$aprobados de ${aplicables.length}',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          BarraSegmentos(
            colores: [
              for (final d in aplicables)
                d.estado == EstadoTramite.sinSubir
                    ? AppColors.border
                    : d.estado.fondo == AppColors.danger
                        ? AppColors.danger
                        : d.estado == EstadoTramite.aprobado
                            ? AppColors.success
                            : AppColors.dorado,
            ],
            alto: 8,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final d in aplicables.take(4)) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  StatusDot(d.estado, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      d.nombre,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: d.necesitaAccion
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: d.necesitaAccion
                            ? AppColors.ink
                            : AppColors.inkSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxs),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => onIr(Seccion.solicitudes),
              icon: const Icon(Icons.north_east_rounded, size: 18),
              label: const Text('Ir al trámite que los pide'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppSize.touchTarget),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
