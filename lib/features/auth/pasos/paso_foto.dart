import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../registro_datos.dart';

/// Paso de Fotografía del Estudiante.
///
/// Permite al alumno subir o capturar su fotografía oficial para
/// y expediente digital del IPN.
class PasoFoto extends StatefulWidget {
  const PasoFoto({super.key, required this.datos, required this.formKey});

  final RegistroDatos datos;
  final GlobalKey<FormState> formKey;

  @override
  State<PasoFoto> createState() => _PasoFotoState();
}

class _PasoFotoState extends State<PasoFoto> {
  RegistroDatos get d => widget.datos;

  void _simularSubida() {
    // Simulamos la carga de una foto con éxito
    setState(() {
      d.fotoPath = 'assets/images/foto_estudiante_demo.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Sube tu fotografía oficial para tu expediente digital del IPN.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Avatar / Foto Previsualización
          Center(
            child: Stack(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.ground,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.dorado, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: d.fotoPath != null
                        ? ClipOval(
                            child: Container(
                              color: AppColors.guinda,
                              child: const Icon(
                                Icons.person_rounded,
                                size: 85,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person_outline_rounded,
                            size: 70,
                            color: AppColors.muted,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.guinda,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      onPressed: _simularSubida,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            d.fotoPath != null ? 'Fotografía cargada correctamente' : 'Ninguna fotografía seleccionada',
            style: AppTypography.label.copyWith(
              color: d.fotoPath != null ? Colors.green.shade700 : AppColors.muted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _simularSubida,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.guinda,
                  side: const BorderSide(color: AppColors.guinda, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Subir archivo'),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: _simularSubida,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.guinda,
                  foregroundColor: AppColors.onGuinda,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                icon: const Icon(Icons.camera_rounded),
                label: const Text('Tomar foto'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl * 1.5),

          // Tarjeta de requisitos
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.ground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.guinda),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Requisitos de la fotografía', style: AppTypography.label),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '• Fondo blanco, sin lentes oscuros ni gorra.\n'
                  '• Rostro descubierto y de frente.\n'
                  '• Formato JPG o PNG, tamaño máximo de 5 MB.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.inkSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
