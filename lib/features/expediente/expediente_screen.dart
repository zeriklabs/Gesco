import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/layout/secciones.dart';
import '../../core/models/expediente.dart';
import '../../core/models/tramite.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/status_pill.dart';

/// El expediente: las cuatro secciones más los adeudos.
///
/// La idea de fondo del rediseño está aquí. Esto se captura una vez y los
/// cinco trámites lo leen; en el GESCO actual cada solicitud vuelve a pedir lo
/// mismo, y los adeudos se recapturan en cuatro formularios idénticos.
class ExpedienteScreen extends StatelessWidget {
  const ExpedienteScreen({super.key, required this.onIr});

  final IrASeccion onIr;

  @override
  Widget build(BuildContext context) {
    final expediente = DatosDemo.expediente;
    final compacto = context.isCompact;

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        CabeceraPantalla(
          contexto: 'Se captura una vez y lo usan todas tus solicitudes',
          titulo: 'Mi expediente',
          acciones: [
            _InsigniaAvance(expediente: expediente),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        if (!expediente.estaCompleto) ...[
          BannerAviso(
            tono: TonoAviso.informativo,
            titulo: 'Te falta terminar '
                '${expediente.pendientes.map((s) => s.titulo.toLowerCase()).join(', ')}',
            mensaje: 'Mientras no esté completo no puedes generar una '
                'solicitud de reinscripción.',
            accion: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.guinda,
                foregroundColor: AppColors.onGuinda,
                minimumSize: const Size(0, 44),
                textStyle: AppTypography.button.copyWith(fontSize: 13.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm + 1),
                ),
              ),
              child: const Text('Continuar'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        if (compacto)
          ...[
            for (final seccion in SeccionExpediente.values) ...[
              _TarjetaSeccion(
                seccion: seccion,
                resumen: expediente.secciones[seccion],
              ),
              const SizedBox(height: AppSpacing.sm + 2),
            ],
            const SizedBox(height: AppSpacing.xs),
            _TarjetaAdeudos(expediente: expediente),
            const SizedBox(height: AppSpacing.sm + 2),
            const _TarjetaQuienLoUsa(),
          ]
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    for (var i = 0; i < SeccionExpediente.values.length; i += 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _TarjetaSeccion(
                                  seccion: SeccionExpediente.values[i],
                                  resumen: expediente
                                      .secciones[SeccionExpediente.values[i]],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: i + 1 <
                                        SeccionExpediente.values.length
                                    ? _TarjetaSeccion(
                                        seccion:
                                            SeccionExpediente.values[i + 1],
                                        resumen: expediente.secciones[
                                            SeccionExpediente.values[i + 1]],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _TarjetaAdeudos(expediente: expediente),
                    const SizedBox(height: AppSpacing.md),
                    const _TarjetaQuienLoUsa(),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _InsigniaAvance extends StatelessWidget {
  const _InsigniaAvance({required this.expediente});

  final Expediente expediente;

  @override
  Widget build(BuildContext context) {
    final completo = expediente.estaCompleto;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusPill(
          completo ? EstadoTramite.aprobado : EstadoTramite.enRevision,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${expediente.seccionesCompletas} de ${expediente.totalSecciones} '
          'secciones',
          style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
        ),
      ],
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  const _TarjetaSeccion({required this.seccion, required this.resumen});

  final SeccionExpediente seccion;
  final ResumenSeccion? resumen;

  @override
  Widget build(BuildContext context) {
    final r = resumen;
    final completa = r?.completa ?? false;
    final faltan = r == null ? seccion.totalCampos : r.total - r.camposLlenos;

    return GescoCard(
      colorBorde: completa ? AppColors.border : AppColors.warningBorder,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.dangerTint,
                  borderRadius: BorderRadius.circular(AppRadius.sm + 1),
                ),
                child: Icon(seccion.icono, size: 19, color: AppColors.guinda),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(seccion.titulo, style: AppTypography.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      completa
                          ? '${seccion.totalCampos} campos · Paso ${seccion.paso}'
                          : 'Faltan $faltan campos',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12.5,
                        color: completa
                            ? AppColors.muted
                            : AppColors.warningInk,
                        fontWeight:
                            completa ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                completa
                    ? Icons.check_circle_rounded
                    : Icons.pending_outlined,
                size: 20,
                color: completa ? AppColors.success : AppColors.dorado,
              ),
            ],
          ),
          if (r != null && r.lineas.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final (clave, valor) in r.lineas)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        clave,
                        style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        valor,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(
              completa ? Icons.edit_outlined : Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.guinda,
            ),
            label: Text(completa ? 'Editar' : 'Completar'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              textStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaAdeudos extends StatelessWidget {
  const _TarjetaAdeudos({required this.expediente});

  final Expediente expediente;

  @override
  Widget build(BuildContext context) {
    final adeudos = expediente.adeudos;

    return GescoCard(
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
                    Text('Adeudos', style: AppTypography.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      'Unidades de aprendizaje reprobadas',
                      style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              StatusPill(
                adeudos.isEmpty
                    ? EstadoTramite.aprobado
                    : EstadoTramite.conObservaciones,
                compacta: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (adeudos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md + 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.borderMuted,
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'No tienes unidades de aprendizaje adeudadas registradas.',
                    style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded,
                        size: 16, color: AppColors.guinda),
                    label: const Text('Agregar adeudo'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      textStyle: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            )
          else
            for (final a in adeudos)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.guinda,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.unidadAprendizaje,
                            style: AppTypography.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${a.nivel} · ${a.periodoReprobada}',
                            style: AppTypography.hint,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            'Se captura aquí una sola vez. El dictamen, las bajas y el GE-01 '
            'lo leen de este lugar.',
            style: AppTypography.hint,
          ),
        ],
      ),
    );
  }
}

/// Qué trámite usa qué parte del expediente.
///
/// Sirve para dos cosas: que el alumno entienda por qué le pedimos cada dato,
/// y que vea que corregir algo aquí lo corrige en todos lados.
class _TarjetaQuienLoUsa extends StatelessWidget {
  const _TarjetaQuienLoUsa();

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      color: AppColors.dangerTint,
      colorBorde: AppColors.dangerBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quién usa estos datos', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm + 2),
          for (final tipo in TipoTramite.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm - 1),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.guinda,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      tipo.titulo,
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      tipo.requiere.join(' + ').toLowerCase(),
                      style: AppTypography.hint,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Si algo cambia aquí, cambia en todas. No hay que volver a '
            'teclearlo trámite por trámite.',
            style: AppTypography.hint.copyWith(color: AppColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}
