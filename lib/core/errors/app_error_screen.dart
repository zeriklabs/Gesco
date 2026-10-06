import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'error_codes.dart';

/// Pantalla moderna y elegante de prevención de crashes para GESCO.
class AppErrorScreen extends StatefulWidget {
  final GescoErrorDetails errorDetails;
  final VoidCallback? onRetry;

  AppErrorScreen({
    super.key,
    GescoErrorDetails? errorDetails,
    FlutterErrorDetails? flutterErrorDetails,
    Object? error,
    StackTrace? stackTrace,
    this.onRetry,
  }) : errorDetails = errorDetails ??
            GescoErrorAnalyzer.analyze(
              flutterErrorDetails?.exception ?? error ?? 'Error de sistema no identificado',
              flutterErrorDetails?.stack ?? stackTrace,
            );

  @override
  State<AppErrorScreen> createState() => _AppErrorScreenState();
}

class _AppErrorScreenState extends State<AppErrorScreen> {
  bool _mostrarDetalles = false;
  bool _copiado = false;

  void _copiarAlPortapapeles() {
    Clipboard.setData(
      ClipboardData(text: widget.errorDetails.formattedReport),
    );

    setState(() => _copiado = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Código ${widget.errorDetails.code} copiado al portapapeles.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copiado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.errorDetails;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con Ícono e Insignia
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.dangerTint,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.dangerBorder),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.guinda,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.guinda.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${details.code} · ${details.categoryName}',
                                style: AppTypography.pill.copyWith(
                                  color: AppColors.guinda,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'GESCO · Control de Errores',
                              style: AppTypography.overline,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Título Principal
                  Text(
                    '¡Ups! Algo ha salido mal',
                    style: AppTypography.displaySmall,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Explicación Amigable
                  Text(
                    details.userMessage,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Caja de Sugerencia / Acción
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.neutralTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.inkSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            details.actionHint,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Botones de Acción Principal
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      // Botón Recargar / Reiniciar
                      FilledButton.icon(
                        onPressed: widget.onRetry ??
                            () {
                              // Intenta hacer pop si es posible, o redirige a la raíz
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/',
                                  (route) => false,
                                );
                              }
                            },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.guinda,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: Text('Recargar página', style: AppTypography.button),
                      ),

                      // Botón Copiar Código de Error
                      OutlinedButton.icon(
                        onPressed: _copiarAlPortapapeles,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: AppColors.borderStrong),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(
                          _copiado ? Icons.check_rounded : Icons.copy_rounded,
                          size: 18,
                          color: _copiado ? AppColors.success : AppColors.ink,
                        ),
                        label: Text(
                          _copiado ? '¡Copiado!' : 'Copiar código de error',
                          style: AppTypography.button.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Panel desplegable con detalles técnicos
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        _mostrarDetalles
                            ? 'Ocultar información técnica para el desarrollador'
                            : 'Ver información técnica para el desarrollador',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onExpansionChanged: (val) {
                        setState(() => _mostrarDetalles = val);
                      },
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 180),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.ground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              details.formattedReport,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: AppColors.inkSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
