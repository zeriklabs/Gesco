import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/catalogos.dart';
import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/models/documento.dart';
import '../../core/models/expediente.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/bloque_adeudos.dart';
import '../../widgets/fila_documento.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/gesco_select.dart';
import '../../widgets/gesco_text_field.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/subir_archivo.dart';
import '../../widgets/wizard.dart';
import '../adeudos/adeudos_screen.dart';

/// La solicitud de dictamen ante la Comisión de Situación Escolar (COSIE).
///
/// El orden importa. El sistema actual —y la primera versión de esta
/// pantalla— arrancaba preguntando *"¿cuál es la causa por la que acudes a
/// COSIE?"*, que es la pregunta que el alumno todavía no sabe contestar:
/// viene con un problema concreto en la cabeza (*"debo tres materias"*), no
/// con la etiqueta reglamentaria de su problema.
///
/// Así que se invirtió: primero se captura lo que el alumno sí tiene claro
/// —lo que debe—, y con eso el sistema le **propone** la causa y le enseña de
/// qué dato la sacó. La propuesta nunca se aplica sola: se acepta o se
/// cambia.
///
/// Lo demás que trae respecto al sistema actual:
///
/// - **Los cinco documentos de COSIE** dejan de ser una pestaña del menú y
///   son el último paso de esta solicitud.
/// - **Tres de los seis contadores no se teclean**: salen de los adeudos. Los
///   otros tres se capturan, pero se verifica que cuadren
///   (`cursadas = acreditadas + adeudadas`). Hoy nada impide mandar a la
///   comisión una solicitud que se contradice sola.
class DictamenScreen extends StatefulWidget {
  const DictamenScreen({super.key});

  @override
  State<DictamenScreen> createState() => _DictamenScreenState();
}

/// El orden es el argumento de esta pantalla: primero lo que el alumno sabe,
/// después lo que el sistema deduce, al final el trámite.
enum _Paso {
  adeudos('Qué debes', Icons.playlist_add_check_rounded),
  situacion('Por qué acudes', Icons.help_outline_rounded),
  documentos('Documentos', Icons.folder_outlined);

  const _Paso(this.titulo, this.icono);

  final String titulo;
  final IconData icono;
}

/// Una causa propuesta por el sistema, con el dato del que salió.
///
/// La razón viaja junto a la propuesta a propósito: una sugerencia sin motivo
/// es adivinanza, y el alumno no tiene forma de saber si le conviene.
typedef Sugerencia = ({String causa, String porque});

class _DictamenScreenState extends State<DictamenScreen> {
  _Paso _paso = _Paso.adeudos;

  final _formNumeros = GlobalKey<FormState>();
  final _formSituacion = GlobalKey<FormState>();

  String? _causa;
  String? _motivo;

  /// Si ya contestó la propuesta del sistema (o no hubo ninguna).
  bool _respondioPropuesta = false;

  /// Si pidió cambiar la causa que ya había aceptado.
  bool _editandoCausa = false;

  final _especifica = TextEditingController();
  final _peticion = TextEditingController();

  final _cursadas = TextEditingController();
  final _acreditadas = TextEditingController();
  final _promedio = TextEditingController();

  late List<Documento> _documentos = DatosDemo.documentosCosie;

  List<Adeudo> get _adeudos => DatosDemo.adeudos;

  // --- Los tres que salen de los adeudos -----------------------------------

  int get _adeudadas => _adeudos.length;

  int get _recursadas =>
      _adeudos.where((a) => a.estado.toUpperCase().contains('RECURSA')).length;

  int get _acreditadasEts =>
      _adeudos.where((a) => a.estado.toUpperCase().contains('ETS')).length;

  // --- La causa que el sistema propone --------------------------------------

  /// Qué causa parece ser, según lo que el alumno ya capturó.
  ///
  /// El orden de las reglas es el de gravedad: haber agotado oportunidades
  /// pesa más que traer carga baja. Si nada aplica, no se inventa nada y el
  /// alumno elige.
  ///
  /// TODO(gescolar): confirmar estas reglas. Están deducidas del reglamento y
  /// de lo que pide el formulario, no validadas con la comisión.
  Sugerencia? get _sugerencia {
    if (_acreditadasEts > 0) {
      return (
        causa: Catalogos.causasCosie[0],
        porque: 'tienes $_acreditadasEts unidad'
            '${_acreditadasEts == 1 ? '' : 'es'} en E.T.S., que es la última '
            'oportunidad reglamentaria',
      );
    }
    if (DatosDemo.provieneDeBaja) {
      return (
        causa: Catalogos.causasCosie[3],
        porque: 'tu expediente dice que vienes de una baja',
      );
    }
    if (DatosDemo.tipoCarga.toUpperCase().contains('DEBAJO')) {
      return (
        causa: Catalogos.causasCosie[2],
        porque: 'tu carga de este periodo está por debajo de la mínima',
      );
    }
    return null;
  }

  // --- La verificación ------------------------------------------------------

  int? get _cursadasNum => int.tryParse(_cursadas.text.trim());
  int? get _acreditadasNum => int.tryParse(_acreditadas.text.trim());

  /// El mensaje cuando los números no cuadran, o `null` si todo bien.
  ///
  /// La regla es simple: lo que cursaste es lo que acreditaste más lo que
  /// debes. Si no da, uno de los tres está mal y más vale saberlo antes de
  /// que llegue a la comisión.
  String? get _contradiccion {
    final c = _cursadasNum;
    final a = _acreditadasNum;
    if (c == null || a == null) return null;
    if (a > c) {
      return 'Acreditaste más materias de las que cursaste. Revisa los dos '
          'números.';
    }
    final esperadas = c - a;
    if (esperadas != _adeudadas) {
      return 'Según estos números debes $esperadas materia'
          '${esperadas == 1 ? '' : 's'}, pero arriba tienes '
          '$_adeudadas registrada${_adeudadas == 1 ? '' : 's'}. '
          'Corrige los números o agrega la materia que falte.';
    }
    return null;
  }

  bool get _documentosListos =>
      _documentos.every((d) => d.estado == EstadoTramite.aprobado);

  int get _documentosAprobados =>
      _documentos.where((d) => d.estado == EstadoTramite.aprobado).length;

  @override
  void dispose() {
    _especifica.dispose();
    _peticion.dispose();
    _cursadas.dispose();
    _acreditadas.dispose();
    _promedio.dispose();
    super.dispose();
  }

  // --- Acciones -------------------------------------------------------------

  Future<void> _agregarAdeudo() async {
    final nuevo = await pedirAdeudo(context);
    if (nuevo == null) return;
    setState(() => DatosDemo.adeudos.add(nuevo));
  }

  void _quitarAdeudo(Adeudo adeudo) {
    final posicion = _adeudos.indexOf(adeudo);
    setState(() => DatosDemo.adeudos.remove(adeudo));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Se quitó ${adeudo.unidadAprendizaje}'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () =>
                setState(() => DatosDemo.adeudos.insert(posicion, adeudo)),
          ),
        ),
      );
  }

  /// TODO(backend): la subida real. El selector ya pregunta qué archivo.
  Future<void> _subir(Documento doc) async {
    final archivo = await pedirArchivo(context, nombreDocumento: doc.nombre);
    if (archivo == null || !mounted) return;

    setState(() {
      _documentos = [
        for (final d in _documentos)
          if (d.id == doc.id)
            d.copyWith(estado: EstadoTramite.enRevision, observacion: '')
          else
            d,
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$archivo: enviado a revisión')),
    );
  }

  void _avanzar() {
    switch (_paso) {
      case _Paso.adeudos:
        if (!(_formNumeros.currentState?.validate() ?? false)) return;
        if (_contradiccion != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_contradiccion!)),
          );
          return;
        }
        // Al llegar a la causa, la propuesta ya está lista y esperando.
        setState(() => _paso = _Paso.situacion);
      case _Paso.situacion:
        if (!(_formSituacion.currentState?.validate() ?? false)) return;
        if (_causa == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falta confirmar la causa')),
          );
          return;
        }
        setState(() => _paso = _Paso.documentos);
      case _Paso.documentos:
        _generar();
    }
  }

  void _retroceder() =>
      setState(() => _paso = _Paso.values[_paso.index - 1]);

  void _generar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando la solicitud de dictamen…')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Solicitud de dictamen'),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.onGuinda,
          fontSize: compacto ? 17 : 19,
        ),
      ),
      body: Column(
        children: [
          BarraPasos(
            pasos: [for (final p in _Paso.values) (p.titulo, p.icono)],
            actual: _paso.index,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(
                compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: switch (_paso) {
                      _Paso.adeudos => _pasoAdeudos(),
                      _Paso.situacion => _pasoSituacion(),
                      _Paso.documentos => _pasoDocumentos(),
                    },
                  ),
                ),
              ],
            ),
          ),
          PieWizard(
            onAtras: _paso == _Paso.adeudos ? null : _retroceder,
            onSiguiente: _avanzar,
            habilitado: _paso != _Paso.documentos || _documentosListos,
            etiqueta: _paso == _Paso.documentos
                ? 'Generar solicitud'
                : 'Continuar',
            icono: _paso == _Paso.documentos
                ? Icons.picture_as_pdf_outlined
                : Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }

  // --- Paso 1: qué debes ----------------------------------------------------

  Widget _pasoAdeudos() {
    final aviso = _contradiccion;

    return Form(
      key: _formNumeros,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Intro(
            titulo: 'Empecemos por lo que debes',
            texto: 'Con esto el sistema arma tres de los seis contadores que '
                'pide la comisión y te propone la causa por la que acudes. No '
                'tienes que saber cómo se llama tu caso en el reglamento.',
          ),
          const SizedBox(height: AppSpacing.lg),
          GescoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SeccionForm(
                  titulo: 'Unidades que debes',
                  nota: 'Salen de tu expediente',
                ),
                BloqueAdeudos(
                  adeudos: _adeudos,
                  onAgregar: _agregarAdeudo,
                  onQuitar: _quitarAdeudo,
                  textoVacio: 'Tu expediente no registra materias que debas. '
                      'Si vas a dictamen por materias reprobadas, agrégalas '
                      'aquí mismo.',
                ),
                const SizedBox(height: AppSpacing.lg),
                const SeccionForm(
                  titulo: 'Lo que la comisión cuenta',
                  nota: 'No se teclea',
                ),
                _FilaContadores(
                  contadores: [
                    (_adeudadas, 'Materias que debes'),
                    (_recursadas, 'En recursamiento'),
                    (_acreditadasEts, 'En E.T.S.'),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm + 2),
                const _Glosario(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GescoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SeccionForm(
                  titulo: 'Actualiza estos datos',
                  nota: 'Vienen del SAES',
                ),
                Text(
                  'Estos tres números viven en el SAES, no aquí. Cópialos tal '
                  'cual: se verifica que cuadren con las materias que debes.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.inkSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CamposEnFila(
                  anchoMinimo: 600,
                  children: [
                    GescoTextField(
                      label: 'Materias cursadas',
                      controller: _cursadas,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      validator: _validarEntero,
                    ),
                    GescoTextField(
                      label: 'Materias acreditadas',
                      controller: _acreditadas,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      validator: _validarEntero,
                    ),
                    GescoTextField(
                      label: 'Promedio del SAES',
                      controller: _promedio,
                      isRequired: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      validator: _validarPromedio,
                    ),
                  ],
                ),
                if (aviso != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  BannerAviso(
                    titulo: 'Los números no cuadran',
                    mensaje: aviso,
                    pie: 'Cursadas = acreditadas + las que debes.',
                  ),
                ] else if (_cursadasNum != null && _acreditadasNum != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  const _Cuadran(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _validarEntero(String? v) {
    if (v == null || v.trim().isEmpty) return 'Obligatorio';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Solo números enteros';
    if (n > 120) return '¿Seguro? Son demasiadas unidades';
    return null;
  }

  static String? _validarPromedio(String? v) {
    if (v == null || v.trim().isEmpty) return 'Obligatorio';
    final n = double.tryParse(v.trim().replaceAll(',', '.'));
    if (n == null) return 'Escríbelo como número, por ejemplo 7.8';
    if (n < 0 || n > 10) return 'El promedio va de 0 a 10';
    return null;
  }

  // --- Paso 2: por qué acudes ----------------------------------------------

  Widget _pasoSituacion() {
    final sugerida = _sugerencia;
    final esOtra = _causa == 'Otra' || _motivo == 'Otra';

    // Tres estados: la propuesta esperando respuesta, la causa ya elegida, o
    // el selector para escogerla a mano.
    final esperandoRespuesta = sugerida != null && !_respondioPropuesta;
    final yaElegida = _causa != null && !_editandoCausa;

    return Form(
      key: _formSituacion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (esperandoRespuesta)
            _Propuesta(
              sugerencia: sugerida!,
              onAceptar: () => setState(() {
                _causa = sugerida!.causa;
                _respondioPropuesta = true;
                _editandoCausa = false;
              }),
              onRechazar: () => setState(() {
                _causa = null;
                _respondioPropuesta = true;
                _editandoCausa = true;
              }),
            )
          else
            _Intro(
              titulo: 'Por qué acudes a la comisión',
              texto: sugerida == null
                  ? 'Con lo que capturaste no puedo proponerte una causa sin '
                      'adivinar, así que la eliges tú.'
                  : 'Puedes cambiar la causa cuando quieras.',
            ),
          const SizedBox(height: AppSpacing.lg),
          const _TarjetaHistorial(),
          const SizedBox(height: AppSpacing.md),
          GescoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SeccionForm(titulo: 'Tu caso'),
                // Mientras la propuesta espera respuesta, la causa se
                // contesta arriba: repetir el desplegable aquí sería
                // preguntar dos veces lo mismo.
                if (!esperandoRespuesta) ...[
                  if (yaElegida)
                    _CausaElegida(
                      causa: _causa!,
                      onCambiar: () => setState(() => _editandoCausa = true),
                    )
                  else
                    GescoSelect<String>(
                      label: 'Causa por la que acudes a COSIE',
                      opciones: Catalogos.causasCosie,
                      value: _causa,
                      isRequired: true,
                      onChanged: (v) => setState(() {
                        _causa = v;
                        _editandoCausa = false;
                      }),
                      validator: (v) => v == null ? 'Elige la causa' : null,
                    ),
                  const SizedBox(height: AppSpacing.md),
                ],
                GescoSelect<String>(
                  label: '¿Qué originó que quedaras fuera del reglamento?',
                  opciones: Catalogos.motivosFueraReglamento,
                  value: _motivo,
                  isRequired: true,
                  onChanged: (v) => setState(() => _motivo = v),
                  validator: (v) => v == null ? 'Elige una opción' : null,
                ),
                // El campo "si selecciona (otras) especifique" del sistema
                // actual está siempre visible, aunque casi nadie lo use.
                if (esOtra) ...[
                  const SizedBox(height: AppSpacing.md),
                  GescoTextField(
                    label: 'Especifica cuál',
                    controller: _especifica,
                    isRequired: true,
                    maxLines: 2,
                    helperText: 'Escogiste "Otra": describe tu caso en una o '
                        'dos líneas.',
                    validator: (v) => (v == null || v.trim().length < 5)
                        ? 'Describe brevemente tu caso'
                        : null,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                GescoTextField(
                  label: 'Tu petición a la comisión',
                  controller: _peticion,
                  isRequired: true,
                  maxLines: 5,
                  hintText: 'Qué le estás pidiendo a la comisión y por qué.',
                  helperText: 'Es el texto que leen los miembros de COSIE. '
                      'Escríbelo tú, con tus palabras.',
                  validator: (v) => (v == null || v.trim().length < 20)
                      ? 'Escribe al menos un par de renglones'
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Paso 3: documentos ---------------------------------------------------

  Widget _pasoDocumentos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GescoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Documentos para COSIE',
                      style: AppTypography.titleLarge,
                    ),
                  ),
                  Text(
                    '$_documentosAprobados de ${_documentos.length}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'En el sistema actual estos cinco archivos están en una '
                'pestaña aparte del menú, sin relación visible con la '
                'solicitud que los pide. Aquí se suben donde se usan.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.inkSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < _documentos.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.xs),
                FilaDocumento(
                  documento: _documentos[i],
                  onSubir: () => _subir(_documentos[i]),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                'PDF de menos de 2 MB cada uno. Entrega los originales en '
                'ventanilla hasta que Gestión Escolar los valide.',
                style: AppTypography.hint,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (!_documentosListos)
          const BannerAviso(
            titulo: 'Faltan documentos por aprobar',
            mensaje: 'La solicitud se genera cuando los cinco estén aprobados '
                'por Gestión Escolar. Los que están en revisión no necesitan '
                'que hagas nada más.',
            tono: TonoAviso.informativo,
          ),
      ],
    );
  }
}

/// La causa que el sistema propone, con el dato del que salió.
class _Propuesta extends StatelessWidget {
  const _Propuesta({
    required this.sugerencia,
    required this.onAceptar,
    required this.onRechazar,
  });

  final Sugerencia sugerencia;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.dangerTint,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.dangerBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 17, color: AppColors.guinda),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'POR LO QUE CAPTURASTE',
                style: AppTypography.overline.copyWith(color: AppColors.guinda),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            sugerencia.causa,
            style: AppTypography.displaySmall.copyWith(fontSize: 19),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Te lo propongo porque ${sugerencia.porque}.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.inkSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              FilledButton.icon(
                onPressed: onAceptar,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Sí, es eso'),
              ),
              OutlinedButton(
                onPressed: onRechazar,
                child: const Text('No, es otra cosa'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// La causa ya aceptada, con opción de cambiarla.
class _CausaElegida extends StatelessWidget {
  const _CausaElegida({required this.causa, required this.onCambiar});

  final String causa;
  final VoidCallback onCambiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.successTint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.successBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_rounded,
                size: 18, color: AppColors.success),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Causa ante COSIE', style: AppTypography.hint),
                const SizedBox(height: 2),
                Text(
                  causa,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onCambiar,
            style: TextButton.styleFrom(foregroundColor: AppColors.guinda),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }
}

/// Una línea de contexto al inicio de un paso.
class _Intro extends StatelessWidget {
  const _Intro({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: AppTypography.displaySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          texto,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.inkSecondary,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

/// Lo que ya está capturado y no se vuelve a preguntar.
class _TarjetaHistorial extends StatelessWidget {
  const _TarjetaHistorial();

  @override
  Widget build(BuildContext context) {
    const datos = [
      ('Periodo de ingreso al IPN', DatosDemo.periodoIngresoIpn),
      ('Último periodo inscrito', DatosDemo.ultimoPeriodoInscrito),
      ('Último nivel', DatosDemo.ultimoNivel),
      ('Último grupo', DatosDemo.ultimoGrupo),
    ];

    return GescoCard(
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 17, color: AppColors.success),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Esto no te lo volvemos a preguntar',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (etiqueta, valor) in datos)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(etiqueta, style: AppTypography.hint),
                    const SizedBox(height: 2),
                    Text(
                      valor,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Los tres contadores, del mismo alto y repartidos a lo ancho.
///
/// Estaban en un `Wrap` con ancho fijo: la etiqueta más larga se iba a dos
/// renglones y esa tarjeta quedaba más alta que las otras dos.
class _FilaContadores extends StatelessWidget {
  const _FilaContadores({required this.contadores});

  final List<(int, String)> contadores;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tarjetas = [
          for (final (numero, etiqueta) in contadores)
            _Contador(numero: numero, etiqueta: etiqueta),
        ];

        if (constraints.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < tarjetas.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.xs),
                tarjetas[i],
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < tarjetas.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(child: tarjetas[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Qué quiere decir la jerga de los formatos oficiales.
///
/// Va aquí y no en una ayuda escondida porque "UAp" y "E.T.S." aparecen en el
/// PDF que firma el alumno, y nadie pregunta por miedo a quedar mal.
class _Glosario extends StatelessWidget {
  const _Glosario();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.muted),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTypography.hint.copyWith(height: 1.5),
              children: const [
                TextSpan(
                  text: 'En los formatos oficiales ',
                ),
                TextSpan(
                  text: 'UAp',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: ' quiere decir unidad de aprendizaje, o sea una '
                      'materia. ',
                ),
                TextSpan(
                  text: 'E.T.S.',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: ' es el examen a título de suficiencia: la última '
                      'oportunidad de acreditarla.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({required this.numero, required this.etiqueta});

  final int numero;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderMuted, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$numero',
            style: AppTypography.numeral.copyWith(
              fontSize: 28,
              height: 1,
              color: AppColors.guinda,
            ),
          ),
          const SizedBox(height: 5),
          // Alto fijo de dos renglones: así las tres tarjetas alinean la
          // etiqueta "AUTOMÁTICO" aunque una etiqueta ocupe dos líneas.
          SizedBox(
            height: 12 * 1.45 * 2,
            child: Text(
              etiqueta,
              style: AppTypography.hint,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 12, color: AppColors.success),
              const SizedBox(width: 3),
              Text(
                'AUTOMÁTICO',
                style: AppTypography.overline.copyWith(
                  fontSize: 9,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cuadran extends StatelessWidget {
  const _Cuadran();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded,
            size: 17, color: AppColors.success),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Los números cuadran con tus adeudos.',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.successInk,
            ),
          ),
        ),
      ],
    );
  }
}
