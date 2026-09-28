import 'package:flutter/material.dart';

import '../core/data/datos_demo.dart';
import '../core/layout/breakpoints.dart';
import '../core/models/documento.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Pide un archivo para un documento del trámite.
///
/// Aquí vive lo único que aportaba la sección "Mis documentos": **varios
/// trámites piden el mismo PDF**. La boleta global, el comprobante de horario
/// del SAES o el estado general del SAES se los pide el dictamen y también la
/// reinscripción, y sin esto el alumno vuelve a buscar el mismo archivo en su
/// teléfono y lo sube otra vez.
///
/// Devuelve el nombre del archivo elegido, o `null` si se canceló.
Future<String?> pedirArchivo(
  BuildContext context, {
  required String nombreDocumento,
}) {
  // Los que ya subió alguna vez, sin repetir el mismo archivo dos veces.
  final yaSubidos = <String, Documento>{};
  for (final (_, d) in DatosDemo.documentosDeTodosLosTramites) {
    final archivo = d.nombreArchivo;
    if (archivo != null) yaSubidos.putIfAbsent(archivo, () => d);
  }

  final hoja = _HojaArchivo(
    nombreDocumento: nombreDocumento,
    yaSubidos: yaSubidos.values.toList(),
  );

  if (context.isCompact) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => hoja,
    );
  }

  return showDialog<String>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: hoja,
      ),
    ),
  );
}

class _HojaArchivo extends StatelessWidget {
  const _HojaArchivo({required this.nombreDocumento, required this.yaSubidos});

  final String nombreDocumento;
  final List<Documento> yaSubidos;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg + 2,
          AppSpacing.lg,
          AppSpacing.lg + 2,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(nombreDocumento, style: AppTypography.displaySmall),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'PDF de menos de 2 MB.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              // TODO(backend): aquí va el selector de archivos de verdad.
              onPressed: () => Navigator.of(context).pop('archivo_nuevo.pdf'),
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('Elegir un archivo'),
            ),
            if (yaSubidos.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Text(
                      'O USA UNO QUE YA SUBISTE',
                      style: AppTypography.overline
                          .copyWith(color: AppColors.muted),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              for (final d in yaSubidos)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _FilaArchivo(documento: d),
                ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaArchivo extends StatelessWidget {
  const _FilaArchivo({required this.documento});

  final Documento documento;

  @override
  Widget build(BuildContext context) {
    final d = documento;

    return Material(
      color: AppColors.ground,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(d.nombreArchivo),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf_outlined,
                  size: 19, color: AppColors.guinda),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.nombreArchivo ?? '',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Lo subiste para: ${d.nombre.toLowerCase()}'
                      '${d.pesoLegible.isEmpty ? '' : ' · ${d.pesoLegible}'}',
                      style: AppTypography.hint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
