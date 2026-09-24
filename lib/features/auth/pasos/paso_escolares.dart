import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/catalogos.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/gesco_select.dart';
import '../../../widgets/gesco_text_field.dart';
import '../registro_datos.dart';

/// Datos escolares: el último paso, y el único donde el alumno copia cosas
/// del SAES a mano.
///
/// GESCO no tiene esos datos — por eso los pide. Mientras no haya integración
/// con el SAES, lo único que se puede hacer es validar rangos y avisar cuando
/// algo no cuadra, que es más de lo que hace hoy.
class PasoEscolares extends StatefulWidget {
  const PasoEscolares({super.key, required this.datos, required this.formKey});

  final RegistroDatos datos;
  final GlobalKey<FormState> formKey;

  @override
  State<PasoEscolares> createState() => _PasoEscolaresState();
}

class _PasoEscolaresState extends State<PasoEscolares> {
  RegistroDatos get d => widget.datos;

  /// Si dice que trae dictamen o que viene de baja, va a tener que subir
  /// papeles. Más vale avisarle desde ahora que cuando lo rechacen.
  List<String> get _documentosQueVaANecesitar {
    return [
      if (d.cuentaConDictamen) 'Copia del dictamen de COSIE',
      if (d.provieneDeBaja) 'Copia del oficio de baja',
      if (d.tipoCarga == 'POR DEBAJO DE LA MÍNIMA')
        'Oficio de dirección que autorice la carga mínima',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = _documentosQueVaANecesitar;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Copia estos datos de tu SAES. Son los que se imprimen en la '
            'solicitud de reinscripción.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),

          const _TarjetaPeriodo(),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Tu programa'),

          GescoSelect<String>(
            label: 'Carrera',
            isRequired: true,
            opciones: Catalogos.carreras,
            value: d.carrera,
            onChanged: (v) => setState(() => d.carrera = v),
            validator: (v) => v == null ? 'Elige tu carrera' : null,
          ),
          const SizedBox(height: AppSpacing.lg),

          CamposEnFila(
            children: [
              GescoSelect<String>(
                label: 'Semestre',
                isRequired: true,
                opciones: Catalogos.semestres,
                value: d.semestre,
                helperText: 'Donde esté la mayoría de tus materias.',
                onChanged: (v) => setState(() => d.semestre = v),
                validator: (v) => v == null ? 'Elige tu semestre' : null,
              ),
              GescoSelect<String>(
                label: 'Grupo',
                isRequired: true,
                opciones: Catalogos.grupos,
                value: d.grupo,
                helperText: 'El de número más alto que lleves.',
                onChanged: (v) => setState(() => d.grupo = v),
                validator: (v) => v == null ? 'Elige tu grupo' : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoSelect<String>(
            label: 'Situación académica',
            isRequired: true,
            opciones: Catalogos.situacionAcademica,
            value: d.situacionAcademica,
            onChanged: (v) => setState(() => d.situacionAcademica = v),
            validator: (v) => v == null ? 'Elige tu situación' : null,
          ),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Tu carga'),

          GescoSelect<String>(
            label: 'Tipo de carga',
            isRequired: true,
            opciones: Catalogos.tipoCarga,
            value: d.tipoCarga,
            onChanged: (v) => setState(() => d.tipoCarga = v),
            validator: (v) => v == null ? 'Elige el tipo de carga' : null,
          ),
          const SizedBox(height: AppSpacing.lg),

          CamposEnFila(
            children: [
              GescoTextField(
                label: 'Total de créditos',
                controller: d.totalCreditos,
                hintText: '30',
                isRequired: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (v) => Validators.entero(
                  v,
                  campo: 'Los créditos',
                  min: 1,
                  max: 200,
                ),
              ),
              GescoTextField(
                label: 'Niveles inscritos',
                controller: d.nivelesInscritos,
                hintText: '8',
                isRequired: true,
                helperText: 'Todos los niveles a los que te inscribiste.',
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(12)],
                validator: (v) =>
                    Validators.requerido(v, campo: 'Los niveles inscritos'),
              ),
              GescoTextField(
                label: 'Promedio en el SAES',
                controller: d.promedioSaes,
                hintText: '8.47',
                isRequired: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                validator: Validators.promedio,
              ),
            ],
            anchoMinimo: 560,
          ),
          const SizedBox(height: AppSpacing.xl),

          const SeccionForm(titulo: 'Tu historial'),

          CamposEnFila(
            children: [
              OpcionSiNo(
                label: '¿Cuentas con dictamen?',
                value: d.cuentaConDictamen,
                onChanged: (v) => setState(() => d.cuentaConDictamen = v),
              ),
              OpcionSiNo(
                label: '¿Provienes de baja de la unidad académica?',
                value: d.provieneDeBaja,
                onChanged: (v) => setState(() => d.provieneDeBaja = v),
              ),
            ],
          ),

          if (pendientes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _AvisoDocumentos(documentos: pendientes),
          ],
        ],
      ),
    );
  }
}

class _TarjetaPeriodo extends StatelessWidget {
  const _TarjetaPeriodo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.dangerTint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.dangerBorder, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, size: 19, color: AppColors.guinda),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Periodo a cursar: ',
                children: [
                  TextSpan(
                    text: '27/1 (Ago 2026 – Ene 2027)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  // TODO(backend): el periodo lo debe fijar el servidor, no
                  // el alumno. Aquí va quemado mientras no haya API.
                ],
              ),
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.inkSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Le adelanta al alumno qué papeles va a tener que subir, según lo que acaba
/// de contestar.
///
/// Hoy esa relación existe (el PDF de reinscripción la menciona) pero nadie se
/// la dice hasta que el trámite se atora.
class _AvisoDocumentos extends StatelessWidget {
  const _AvisoDocumentos({required this.documentos});

  final List<String> documentos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: AppColors.warningTint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.warningBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_file_rounded,
                  size: 18, color: AppColors.warningInk),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Con lo que contestaste, vas a necesitar subir:',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.warningInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final doc in documentos)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 7, right: AppSpacing.xs),
                    decoration: const BoxDecoration(
                      color: AppColors.warningInk,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      doc,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.warningInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'No es ahorita: los subes desde el trámite, cuando lo generes.',
            style: AppTypography.hint.copyWith(color: AppColors.warningInk),
          ),
        ],
      ),
    );
  }
}
