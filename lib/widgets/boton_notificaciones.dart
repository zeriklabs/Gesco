import 'package:flutter/material.dart';

import '../core/layout/secciones.dart';
import '../core/models/documento.dart';
import '../core/models/tramite.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Un botón con campana e indicador de notificaciones pendientes.
///
/// Al presionar despliega un menú flotante justo debajo del botón con los avisos.
class BotonNotificaciones extends StatefulWidget {
  const BotonNotificaciones({
    super.key,
    required this.bloqueo,
    required this.onIr,
  });

  final (Tramite, Documento)? bloqueo;
  final ValueChanged<Seccion> onIr;

  @override
  State<BotonNotificaciones> createState() => _BotonNotificacionesState();
}

class _BotonNotificacionesState extends State<BotonNotificaciones>
    with SingleTickerProviderStateMixin {
  final _controller = MenuController();
  AnimationController? _animController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _opacityAnimation;

  void _initAnimations() {
    if (_animController != null) return;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController!, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController!, curve: Curves.easeOut));
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations(); // Garantizar que exista durante Hot Reload
    final tieneNotificaciones = widget.bloqueo != null;

    return MenuAnchor(
      controller: _controller,
      alignmentOffset: const Offset(-356, 8),
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.surface),
        elevation: WidgetStateProperty.all(6),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
          ),
        ),
        shadowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.08)),
      ),
      builder: (context, controller, child) {
        return Badge(
          isLabelVisible: tieneNotificaciones,
          label: const Text('1'),
          backgroundColor: AppColors.guinda,
          textColor: AppColors.onGuinda,
          alignment: const Alignment(0.6, -0.6),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () {
                if (controller.isOpen) {
                  _animController!.reverse().then((_) => controller.close());
                } else {
                  controller.open();
                  _animController!.forward(from: 0.0);
                }
              },
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderSubtle),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  tieneNotificaciones
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_outlined,
                  size: 22,
                  color: tieneNotificaciones
                      ? AppColors.guinda
                      : AppColors.inkSecondary,
                ),
              ),
            ),
          ),
        );
      },
      menuChildren: [
        AnimatedBuilder(
          animation: _animController!,
          builder: (context, child) {
            return FadeTransition(
              opacity: _opacityAnimation!,
              child: ScaleTransition(
                scale: _scaleAnimation!,
                alignment: const Alignment(0.8, -1.0),
                child: child,
              ),
            );
          },
          child: SizedBox(
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _NotificacionesMenuContenido(
                bloqueo: widget.bloqueo,
                onIr: (sec) {
                  _animController!.reverse().then((_) {
                    _controller.close();
                    widget.onIr(sec);
                  });
                },
                onCerrar: () {
                  _animController!.reverse().then((_) => _controller.close());
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificacionesMenuContenido extends StatelessWidget {
  const _NotificacionesMenuContenido({
    required this.bloqueo,
    required this.onIr,
    required this.onCerrar,
  });

  final (Tramite, Documento)? bloqueo;
  final ValueChanged<Seccion> onIr;
  final VoidCallback onCerrar;

  @override
  Widget build(BuildContext context) {
    final tieneAviso = bloqueo != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Notificaciones',
                  style: AppTypography.titleLarge.copyWith(fontSize: 18),
                ),
                if (tieneAviso) ...[
                  const SizedBox(width: AppSpacing.xs + 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerTint,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.dangerBorder),
                    ),
                    child: Text(
                      '1 pendiente',
                      style: AppTypography.hint.copyWith(
                        color: AppColors.guinda,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            IconButton(
              onPressed: onCerrar,
              icon: const Icon(Icons.close_rounded, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!tieneAviso)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 36,
                    color: AppColors.muted,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sin notificaciones pendientes',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _TarjetaAvisoNotificacion(
            tramite: bloqueo!.$1,
            documento: bloqueo!.$2,
            onIr: onIr,
          ),
        ],
      ],
    );
  }
}

class _TarjetaAvisoNotificacion extends StatelessWidget {
  const _TarjetaAvisoNotificacion({
    required this.tramite,
    required this.documento,
    required this.onIr,
  });

  final Tramite tramite;
  final Documento documento;
  final ValueChanged<Seccion> onIr;

  String _fechaLegible(DateTime? f) {
    if (f == null) return '';
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final hora =
        '${f.hour.toString().padLeft(2, '0')}:'
        '${f.minute.toString().padLeft(2, '0')}';
    return '${f.day} de ${meses[f.month - 1]}, $hora';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.dangerTint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.dangerBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.guinda,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.priority_high_rounded,
                  size: 16,
                  color: AppColors.onGuinda,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${documento.nombre} — necesita corrección',
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '“${documento.observacion}”',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.inkSecondary,
                        height: 1.45,
                      ),
                    ),
                    if (documento.revisadoPor != null) ...[
                      const SizedBox(height: AppSpacing.xxs + 2),
                      Text(
                        '${documento.revisadoPor} · ${_fechaLegible(documento.revisadoEl)}',
                        style: AppTypography.hint.copyWith(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => onIr(Seccion.solicitudes),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.guinda,
                foregroundColor: AppColors.onGuinda,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                textStyle: AppTypography.button.copyWith(fontSize: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm + 1),
                ),
              ),
              child: Text('Abrir en ${tramite.tipo.titulo}'),
            ),
          ),
        ],
      ),
    );
  }
}
