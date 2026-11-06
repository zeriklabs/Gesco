import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/catalogos.dart';
import '../../core/data/datos_demo.dart';
import '../../core/models/documento.dart';
import '../../core/models/expediente.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../widgets/bloque_adeudos.dart';
import '../../widgets/fila_documento.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/gesco_select.dart';
import '../../widgets/gesco_text_field.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/subir_archivo.dart';
import '../solicitudes/baja_escuela_screen.dart';
import '../solicitudes/dictamen_screen.dart';

/// Pantalla para completar los Datos Escolares del expediente.
class CompletarDatosEscolaresScreen extends StatefulWidget {
  const CompletarDatosEscolaresScreen({super.key});

  @override
  State<CompletarDatosEscolaresScreen> createState() =>
      _CompletarDatosEscolaresScreenState();
}

class _CompletarDatosEscolaresScreenState
    extends State<CompletarDatosEscolaresScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _carrera = DatosDemo.carrera;
  String? _planEstudio = 'SISTEMAS 2020';
  bool _esNuevoIngreso = false;

  String? _situacionAcademica = 'REGULAR';
  String? _semestre = '8VO';
  String? _tipoCarga = 'Media';
  final _promedioSaes = TextEditingController(text: '8.45');
  bool _cuentaConDictamen = false;
  String _tipoDictamenCosie = 'Consejo Técnico (CT)';
  bool _provieneDeBaja = false;

  final List<Adeudo> _adeudos = List.from(DatosDemo.adeudos);

  // --- Documentos de nuevo ingreso ------------------------------------------
  Documento _docHojaResultados = const Documento(
    id: 'doc-hoja-resultados',
    nombre: 'Hoja de resultados (Examen de admisión)',
    estado: EstadoTramite.sinSubir,
  );

  Documento _docCurp = const Documento(
    id: 'doc-curp',
    nombre: 'CURP (Formato oficial PDF)',
    estado: EstadoTramite.sinSubir,
  );

  Documento _docDeof = const Documento(
    id: 'doc-deof',
    nombre: 'Documento DEOF (Asignación)',
    estado: EstadoTramite.sinSubir,
  );

  Future<void> _subirDoc(
    Documento doc,
    void Function(Documento) onActualizar,
  ) async {
    final archivo = await pedirArchivo(context, nombreDocumento: doc.nombre);
    if (archivo != null) {
      setState(() {
        onActualizar(
          doc.copyWith(
            estado: EstadoTramite.enRevision,
            observacion: null,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _promedioSaes.dispose();
    super.dispose();
  }

  void _agregarAdeudoModal() {
    final materiaCtrl = TextEditingController();
    String nivel = 'NIVEL II';
    final periodoCtrl = TextEditingController(text: DatosDemo.periodoActual);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text('Agregar materia reprobada', style: AppTypography.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GescoTextField(
                  label: 'Unidad de aprendizaje (Materia)',
                  controller: materiaCtrl,
                  isRequired: true,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.md),
                GescoSelect<String>(
                  label: 'Nivel',
                  isRequired: true,
                  opciones: const ['NIVEL I', 'NIVEL II', 'NIVEL III', 'NIVEL IV'],
                  value: nivel,
                  onChanged: (v) => setModalState(() => nivel = v ?? nivel),
                ),
                const SizedBox(height: AppSpacing.md),
                GescoTextField(
                  label: 'Periodo en que la reprobaste',
                  controller: periodoCtrl,
                  hintText: '26/2',
                  isRequired: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (materiaCtrl.text.trim().isEmpty) return;
                setState(() {
                  _adeudos.add(
                    Adeudo(
                      unidadAprendizaje: materiaCtrl.text.trim(),
                      nivel: nivel,
                      periodoReprobada: periodoCtrl.text.trim(),
                    ),
                  );
                });
                Navigator.of(ctx).pop();
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.guinda),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _guardar() {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Datos escolares guardados en tu expediente!'),
        backgroundColor: AppColors.guinda,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final esIrregular = _situacionAcademica == 'IRREGULAR';
    final esCargaBaja = _tipoCarga == 'Debajo de la mínima';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa tus datos escolares'),
        backgroundColor: AppColors.guinda,
        foregroundColor: AppColors.onGuinda,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutterMobile),
          children: [
            Text(
              'Configuración de expediente escolar',
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Registra tu situación actual para que tus trámites se preparen automáticamente.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 1. Programa / Carrera y Plan de estudio
            SeccionForm(titulo: 'Tu programa'),
            const SizedBox(height: AppSpacing.sm),
            CamposEnFila(
              anchoMinimo: 560,
              children: [
                GescoSelect<String>(
                  label: 'Carrera',
                  isRequired: true,
                  opciones: Catalogos.carreras,
                  value: _carrera,
                  onChanged: (v) => setState(() {
                    _carrera = v;
                    final planes = Catalogos.planesDe(v);
                    if (planes.isNotEmpty) {
                      _planEstudio = planes.first;
                    }
                  }),
                  validator: (v) => v == null ? 'Elige tu carrera' : null,
                ),
                GescoSelect<String>(
                  label: 'Plan de estudio',
                  isRequired: true,
                  opciones: Catalogos.planesDe(_carrera),
                  value: _planEstudio ??
                      (Catalogos.planesDe(_carrera).isNotEmpty
                          ? Catalogos.planesDe(_carrera).first
                          : null),
                  onChanged: (v) => setState(() => _planEstudio = v),
                  validator: (v) => v == null ? 'Elige el plan' : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. ¿Es nuevo ingreso?
            Text('¿Eres alumno de nuevo ingreso?', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Sí, nuevo ingreso'),
                    subtitle: const Text('Primer semestre en este programa'),
                    value: true,
                    groupValue: _esNuevoIngreso,
                    activeColor: AppColors.guinda,
                    onChanged: (v) => setState(() => _esNuevoIngreso = v ?? false),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('No, reinscripción'),
                    subtitle: const Text('Ya he cursado semestres previos'),
                    value: false,
                    groupValue: _esNuevoIngreso,
                    activeColor: AppColors.guinda,
                    onChanged: (v) => setState(() => _esNuevoIngreso = v ?? false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // SI ES NUEVO INGRESO: Requisitos de documentación
            if (_esNuevoIngreso) ...[
              SeccionForm(titulo: 'Documentación de Nuevo Ingreso'),
              const SizedBox(height: AppSpacing.sm),
              GescoCard(
                color: AppColors.surfaceAlt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.upload_file_rounded,
                            color: AppColors.guinda, size: 22),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Documentos requeridos para inscripción',
                            style: AppTypography.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Como alumno de nuevo ingreso, sube tu Hoja de Resultados, tu CURP y tu Documento DEOF para validar tu expediente en Gestión Escolar.',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              FilaDocumento(
                documento: _docHojaResultados,
                onSubir: () => _subirDoc(
                  _docHojaResultados,
                  (nuevo) => _docHojaResultados = nuevo,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              FilaDocumento(
                documento: _docCurp,
                onSubir: () => _subirDoc(
                  _docCurp,
                  (nuevo) => _docCurp = nuevo,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              FilaDocumento(
                documento: _docDeof,
                onSubir: () => _subirDoc(
                  _docDeof,
                  (nuevo) => _docDeof = nuevo,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // SI ES REINSCRIPCIÓN
            if (!_esNuevoIngreso) ...[
              SeccionForm(titulo: 'Situación académica y reinscripción'),
              const SizedBox(height: AppSpacing.sm),

              // Regular / Irregular
              GescoSelect<String>(
                label: 'Situación académica',
                isRequired: true,
                opciones: const ['REGULAR', 'IRREGULAR'],
                value: _situacionAcademica,
                onChanged: (v) => setState(() => _situacionAcademica = v),
                validator: (v) => v == null ? 'Selecciona tu situación' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Paso adicional para IRREGULAR: Adeudos
              if (esIrregular) ...[
                GescoCard(
                  color: AppColors.warningTint,
                  colorBorde: AppColors.warningBorder,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.warningInk, size: 20),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Registro de adeudos (Materias reprobadas)',
                            style: AppTypography.titleLarge
                                .copyWith(color: AppColors.warningInk),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Como alumno irregular, agrega las unidades de aprendizaje que adeudas.',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.warningInk),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BloqueAdeudos(
                        adeudos: _adeudos,
                        onAgregar: _agregarAdeudoModal,
                        onQuitar: (a) => setState(() => _adeudos.remove(a)),
                        textoVacio:
                            'No tienes adeudos registrados. Haz clic abajo para agregar uno.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Semestre y Carga
              CamposEnFila(
                children: [
                  GescoSelect<String>(
                    label: 'Semestre a cursar',
                    isRequired: true,
                    opciones: Catalogos.semestres,
                    value: _semestre,
                    onChanged: (v) => setState(() => _semestre = v),
                    validator: (v) => v == null ? 'Elige tu semestre' : null,
                  ),
                  GescoSelect<String>(
                    label: 'Carga con la que te reinscribes',
                    isRequired: true,
                    opciones: Catalogos.tipoCarga,
                    value: _tipoCarga,
                    onChanged: (v) => setState(() => _tipoCarga = v),
                    validator: (v) => v == null ? 'Elige tu carga' : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // SI CARGA DEBAJO DE LA MÍNIMA
              if (esCargaBaja) ...[
                GescoCard(
                  color: AppColors.dangerTint,
                  colorBorde: AppColors.dangerBorder,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.note_alt_outlined,
                              color: AppColors.guinda, size: 22),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'Inscripción por debajo de la carga mínima',
                              style: AppTypography.titleLarge
                                  .copyWith(color: AppColors.guinda),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Al registrarte por debajo de la carga mínima se requieren el oficio de autorización de la Dirección y el dictamen emitido por el COSIE o CT.',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Oficio de solicitud de carga mínima generado en PDF.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                        label: const Text('Generar oficio de carga mínima'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.guinda,
                          foregroundColor: AppColors.onGuinda,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Promedio SAES
              GescoTextField(
                label: 'Promedio en el SAES',
                controller: _promedioSaes,
                hintText: '8.47',
                isRequired: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                validator: Validators.promedio,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Dictamen y Baja
              SeccionForm(titulo: 'Historial administrativo'),
              const SizedBox(height: AppSpacing.sm),

              OpcionSiNo(
                label: '¿Cuentas con dictamen emitido por el COSIE?',
                value: _cuentaConDictamen,
                onChanged: (v) => setState(() => _cuentaConDictamen = v),
              ),

              if (_cuentaConDictamen) ...[
                const SizedBox(height: AppSpacing.sm),
                GescoSelect<String>(
                  label: 'Tipo de dictamen COSIE',
                  value: _tipoDictamenCosie,
                  opciones: const [
                    'Consejo Técnico (CT)',
                    'Consejo General (CG)',
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _tipoDictamenCosie = v);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                GescoCard(
                  color: AppColors.surfaceAlt,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sección de Dictamen de COSIE (${_tipoDictamenCosie.contains('General') ? 'Consejo General' : 'Consejo Técnico'})',
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Se adjuntará la copia de tu dictamen (${_tipoDictamenCosie.contains('General') ? 'CG' : 'CT'}) en los trámites que lo requieran.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DictamenScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.launch_rounded, size: 16),
                        label: const Text('Abrir trámite de dictamen'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              const SizedBox(height: AppSpacing.sm),
              OpcionSiNo(
                label: '¿Provienes de baja de la unidad académica?',
                value: _provieneDeBaja,
                onChanged: (v) => setState(() => _provieneDeBaja = v),
              ),

              if (_provieneDeBaja) ...[
                const SizedBox(height: AppSpacing.sm),
                GescoCard(
                  color: AppColors.surfaceAlt,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sección de Baja de la Unidad Académica',
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Se adjuntará la copia de tu oficio de baja temporal/definitiva en los trámites que lo requieran.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BajaEscuelaScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.launch_rounded, size: 16),
                        label: const Text('Abrir trámite de baja de escuela'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],

            SizedBox(
              width: double.infinity,
              height: AppSize.buttonHeightDesktop,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Guardar datos escolares'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.guinda,
                  foregroundColor: AppColors.onGuinda,
                  textStyle: AppTypography.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
