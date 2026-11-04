import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/layout/secciones.dart';
import '../../core/models/expediente.dart';
import '../../core/models/tramite.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/bloque_adeudos.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/gesco_select.dart';
import '../../widgets/gesco_text_field.dart';
import '../../widgets/status_pill.dart';
import 'completar_datos_escolares_screen.dart';
import 'editar_seccion_dialog.dart';

/// El expediente: las cuatro secciones más los adeudos.
class ExpedienteScreen extends StatefulWidget {
  const ExpedienteScreen({super.key, required this.onIr});

  final IrASeccion onIr;

  @override
  State<ExpedienteScreen> createState() => _ExpedienteScreenState();
}

class _ExpedienteScreenState extends State<ExpedienteScreen> {
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CompletarDatosEscolaresScreen(),
                  ),
                );
              },
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
                onActualizar: () => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.sm + 2),
            ],
            const SizedBox(height: AppSpacing.xs),
            _TarjetaAdeudos(
              expediente: expediente,
              onActualizar: () => setState(() {}),
            ),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _TarjetaSeccion(
                                seccion: SeccionExpediente.values[i],
                                resumen: expediente
                                    .secciones[SeccionExpediente.values[i]],
                                onActualizar: () => setState(() {}),
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
                                      onActualizar: () => setState(() {}),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
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
                    _TarjetaAdeudos(
                      expediente: expediente,
                      onActualizar: () => setState(() {}),
                    ),
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
    final compacto = context.isCompact;

    if (compacto) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusPill(
            completo ? EstadoTramite.aprobado : EstadoTramite.enRevision,
            compacta: true,
          ),
          const SizedBox(height: 3),
          Text(
            '${expediente.seccionesCompletas} de ${expediente.totalSecciones} secciones',
            style: AppTypography.hint.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

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
  const _TarjetaSeccion({
    required this.seccion,
    required this.resumen,
    required this.onActualizar,
  });

  final SeccionExpediente seccion;
  final ResumenSeccion? resumen;
  final VoidCallback onActualizar;

  Future<void> _abrir(BuildContext context) async {
    if (seccion == SeccionExpediente.escolares) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CompletarDatosEscolaresScreen(),
        ),
      );
      onActualizar();
    } else {
      final guardo = await EditarSeccionDialog.mostrar(
        context,
        seccion: seccion,
      );
      if (guardo == true) {
        onActualizar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = resumen;
    final completa = r?.completa ?? false;
    final faltan = r == null ? seccion.totalCampos : r.total - r.camposLlenos;

    return GescoCard(
      colorBorde: completa ? AppColors.border : AppColors.warningBorder,
      onTap: () => _abrir(context),
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
            onPressed: () => _abrir(context),
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
  const _TarjetaAdeudos({
    required this.expediente,
    required this.onActualizar,
  });

  final Expediente expediente;
  final VoidCallback onActualizar;

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
                    onPressed: () => _mostrarModalEditarAdeudos(context, onActualizar),
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
          else ...[
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
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton.icon(
              onPressed: () => _mostrarModalEditarAdeudos(context, onActualizar),
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.guinda),
              label: const Text('Editar adeudos'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                textStyle: AppTypography.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],

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

void _mostrarModalEditarAdeudos(BuildContext context, VoidCallback onActualizar) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) {
        final mq = MediaQuery.of(ctx);

        void agregarAdeudo() {
          final materiaCtrl = TextEditingController();
          String nivel = 'NIVEL II';
          final periodoCtrl = TextEditingController(text: DatosDemo.periodoActual);

          showDialog(
            context: ctx,
            builder: (dialogCtx) => StatefulBuilder(
              builder: (dialogCtx, setDialogState) => AlertDialog(
                title: Text('Agregar materia reprobada',
                    style: AppTypography.titleLarge),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GescoTextField(
                        label: 'Unidad de aprendizaje (Materia)',
                        controller: materiaCtrl,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GescoSelect<String>(
                        label: 'Nivel',
                        value: nivel,
                        opciones: const [
                          'NIVEL I',
                          'NIVEL II',
                          'NIVEL III',
                          'NIVEL IV'
                        ],
                        onChanged: (v) => setDialogState(() => nivel = v ?? nivel),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GescoTextField(
                        label: 'Periodo en que la reprobaste',
                        controller: periodoCtrl,
                        isRequired: true,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (materiaCtrl.text.trim().isEmpty) return;
                      setModalState(() {
                        DatosDemo.adeudos.add(
                          Adeudo(
                            unidadAprendizaje: materiaCtrl.text.trim(),
                            nivel: nivel,
                            periodoReprobada: periodoCtrl.text.trim(),
                          ),
                        );
                      });
                      onActualizar();
                      Navigator.of(dialogCtx).pop();
                    },
                    style:
                        FilledButton.styleFrom(backgroundColor: AppColors.guinda),
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            mq.viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded,
                      color: AppColors.guinda, size: 24),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Expanded(
                    child: Text(
                      'Gestionar Adeudos Escolares',
                      style: AppTypography.titleLarge
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: SingleChildScrollView(
                  child: BloqueAdeudos(
                    adeudos: DatosDemo.adeudos,
                    onAgregar: agregarAdeudo,
                    onQuitar: (a) {
                      setModalState(() {
                        DatosDemo.adeudos.remove(a);
                      });
                      onActualizar();
                    },
                    textoVacio:
                        'No tienes unidades de aprendizaje adeudadas registradas en tu expediente.',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Listo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.guinda,
                  foregroundColor: AppColors.onGuinda,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
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
