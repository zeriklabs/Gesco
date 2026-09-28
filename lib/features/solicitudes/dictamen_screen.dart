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
import '../../widgets/fila_documento.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/gesco_select.dart';
import '../../widgets/gesco_text_field.dart';
import '../../widgets/status_pill.dart';
import '../adeudos/adeudos_screen.dart';

/// La solicitud de dictamen ante la Comisión de Situación Escolar (COSIE).
///
/// Dos cambios de fondo respecto al sistema actual:
///
/// 1. **Los cinco documentos de COSIE dejan de ser una pestaña del menú** y se
///    vuelven el último paso de esta solicitud, que es el único lugar donde
///    significan algo.
/// 2. **Los seis contadores dejan de ser seis campos vacíos.** Tres salen de
///    los adeudos que ya están en el expediente y no se teclean; los otros
///    tres se capturan, pero el sistema verifica que cuadren entre sí. Hoy
///    nada impide que el alumno escriba 40 cursadas, 38 acreditadas y 5
///    adeudadas, y la comisión recibe una solicitud que se contradice sola.
class DictamenScreen extends StatefulWidget {
  const DictamenScreen({super.key});

  @override
  State<DictamenScreen> createState() => _DictamenScreenState();
}

enum _Paso {
  situacion('Tu situación', Icons.help_outline_rounded),
  numeros('Los números', Icons.calculate_outlined),
  documentos('Documentos', Icons.folder_outlined);

  const _Paso(this.titulo, this.icono);

  final String titulo;
  final IconData icono;
}

class _DictamenScreenState extends State<DictamenScreen> {
  _Paso _paso = _Paso.situacion;

  final _formSituacion = GlobalKey<FormState>();
  final _formNumeros = GlobalKey<FormState>();

  String? _causa;
  String? _motivo;
  final _especifica = TextEditingController();
  final _peticion = TextEditingController();

  final _cursadas = TextEditingController();
  final _acreditadas = TextEditingController();
  final _promedio = TextEditingController();

  late List<Documento> _documentos = DatosDemo.documentosCosie;

  List<Adeudo> get _adeudos => DatosDemo.expediente.adeudos;

  // --- Los tres que salen de los adeudos -----------------------------------

  int get _adeudadas => _adeudos.length;

  int get _recursadas =>
      _adeudos.where((a) => a.estado.toUpperCase().contains('RECURSA')).length;

  int get _acreditadasEts =>
      _adeudos.where((a) => a.estado.toUpperCase().contains('ETS')).length;

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
      return 'Acreditaste más unidades de las que cursaste. Revisa los dos '
          'números.';
    }
    final esperadas = c - a;
    if (esperadas != _adeudadas) {
      return 'Según estos números adeudas $esperadas unidad'
          '${esperadas == 1 ? '' : 'es'}, pero tu expediente tiene '
          '$_adeudadas registrada${_adeudadas == 1 ? '' : 's'}. '
          'Corrige los números o captura los adeudos que falten.';
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

  /// TODO(backend): aquí va el selector de archivos y la subida real.
  void _subir(Documento doc) {
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
      SnackBar(content: Text('${doc.nombre}: enviado a revisión')),
    );
  }

  void _avanzar() {
    switch (_paso) {
      case _Paso.situacion:
        if (!(_formSituacion.currentState?.validate() ?? false)) return;
        setState(() => _paso = _Paso.numeros);
      case _Paso.numeros:
        if (!(_formNumeros.currentState?.validate() ?? false)) return;
        if (_contradiccion != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_contradiccion!)),
          );
          return;
        }
        setState(() => _paso = _Paso.documentos);
      case _Paso.documentos:
        _generar();
    }
  }

  void _retroceder() {
    final anterior = _Paso.values[_paso.index - 1];
    setState(() => _paso = anterior);
  }

  /// Abre los adeudos sin salirse de la solicitud y vuelve con los tres
  /// contadores ya recalculados.
  Future<void> _abrirAdeudos() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (contexto) => Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Adeudos'),
            titleTextStyle: AppTypography.titleLarge.copyWith(
              color: AppColors.onGuinda,
              fontSize: 19,
            ),
          ),
          body: AdeudosScreen(onIr: (_) => Navigator.of(contexto).maybePop()),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

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
          _BarraPasos(actual: _paso),
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
                      _Paso.situacion => _pasoSituacion(),
                      _Paso.numeros => _pasoNumeros(),
                      _Paso.documentos => _pasoDocumentos(),
                    },
                  ),
                ),
              ],
            ),
          ),
          _PieAcciones(
            paso: _paso,
            puedeGenerar: _documentosListos,
            onAtras: _paso == _Paso.situacion ? null : _retroceder,
            onSiguiente: _avanzar,
          ),
        ],
      ),
    );
  }

  // --- Paso 1 ---------------------------------------------------------------

  Widget _pasoSituacion() {
    final esOtraCausa = _causa == 'Otra';
    final esOtroMotivo = _motivo == 'Otra';

    return Form(
      key: _formSituacion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TarjetaHistorial(),
          const SizedBox(height: AppSpacing.lg),
          GescoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SeccionForm(titulo: 'Por qué acudes a la comisión'),
                GescoSelect<String>(
                  label: 'Causa por la que acudes a COSIE',
                  opciones: Catalogos.causasCosie,
                  value: _causa,
                  isRequired: true,
                  onChanged: (v) => setState(() => _causa = v),
                ),
                const SizedBox(height: AppSpacing.md),
                GescoSelect<String>(
                  label: '¿Qué originó que quedaras fuera del reglamento?',
                  opciones: Catalogos.motivosFueraReglamento,
                  value: _motivo,
                  isRequired: true,
                  onChanged: (v) => setState(() => _motivo = v),
                ),
                // El campo "si selecciona (otras) especifique" del sistema
                // actual está siempre visible, aunque casi nadie lo use.
                if (esOtraCausa || esOtroMotivo) ...[
                  const SizedBox(height: AppSpacing.md),
                  GescoTextField(
                    label: 'Especifica cuál',
                    controller: _especifica,
                    isRequired: true,
                    maxLines: 2,
                    helperText: 'Escogiste "Otra": describe tu caso en una '
                        'o dos líneas.',
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

  // --- Paso 2 ---------------------------------------------------------------

  Widget _pasoNumeros() {
    final aviso = _contradiccion;

    return Form(
      key: _formNumeros,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TarjetaDerivados(
            adeudadas: _adeudadas,
            recursadas: _recursadas,
            acreditadasEts: _acreditadasEts,
            adeudos: _adeudos,
            onCorregir: _abrirAdeudos,
          ),
          const SizedBox(height: AppSpacing.lg),
          GescoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SeccionForm(
                  titulo: 'Esto sí lo capturas tú',
                  nota: 'GESCO no tiene tu kardex',
                ),
                Text(
                  'Estos tres números viven en el SAES, no aquí. Cópialos tal '
                  'cual: abajo se verifica que cuadren con tus adeudos.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.inkSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CamposEnFila(
                  anchoMinimo: 520,
                  children: [
                    GescoTextField(
                      label: 'UAp cursadas',
                      controller: _cursadas,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      validator: _validarEntero,
                    ),
                    GescoTextField(
                      label: 'UAp acreditadas',
                      controller: _acreditadas,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      validator: _validarEntero,
                    ),
                    GescoTextField(
                      label: 'Promedio en el SAES',
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
                    pie: 'Cursadas = acreditadas + adeudadas.',
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

  // --- Paso 3 ---------------------------------------------------------------

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
          BannerAviso(
            titulo: 'Faltan documentos por aprobar',
            mensaje: 'La solicitud se genera cuando los cinco estén '
                'aprobados por Gestión Escolar. Los que están en revisión no '
                'necesitan que hagas nada más.',
            tono: TonoAviso.informativo,
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

/// Los tres contadores que salen solos de los adeudos del expediente.
class _TarjetaDerivados extends StatelessWidget {
  const _TarjetaDerivados({
    required this.adeudadas,
    required this.recursadas,
    required this.acreditadasEts,
    required this.adeudos,
    required this.onCorregir,
  });

  final int adeudadas;
  final int recursadas;
  final int acreditadasEts;
  final List<Adeudo> adeudos;
  final VoidCallback onCorregir;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SeccionForm(
            titulo: 'Esto sale de tus adeudos',
            nota: 'No se teclea',
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Contador(numero: adeudadas, etiqueta: 'UAp adeudadas'),
              _Contador(numero: recursadas, etiqueta: 'UAp recursadas'),
              _Contador(
                numero: acreditadasEts,
                etiqueta: 'Acreditadas en E.T.S.',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (adeudos.isEmpty)
            Text(
              'Tu expediente no registra adeudos. Si te falta capturar alguno, '
              'hazlo en Adeudos: estos tres números salen de ahí.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.inkSecondary,
                height: 1.5,
              ),
            )
          else
            for (final a in adeudos)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 6, color: AppColors.muted),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '${a.unidadAprendizaje} · ${a.nivel} · '
                        'reprobada en ${a.periodoReprobada} · ${a.estado}',
                        style: AppTypography.hint.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onCorregir,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Corregir mis adeudos'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.guinda,
                textStyle: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
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
      width: 148,
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
          Text(etiqueta, style: AppTypography.hint),
          const SizedBox(height: 5),
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

/// Los tres pasos, arriba, siempre visibles.
class _BarraPasos extends StatelessWidget {
  const _BarraPasos({required this.actual});

  final _Paso actual;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        vertical: AppSpacing.sm + 2,
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (final p in _Paso.values) ...[
                if (p.index > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _FilaPaso(
                    paso: p,
                    actual: actual,
                    compacto: compacto,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaPaso extends StatelessWidget {
  const _FilaPaso({
    required this.paso,
    required this.actual,
    required this.compacto,
  });

  final _Paso paso;
  final _Paso actual;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final hecho = paso.index < actual.index;
    final activo = paso == actual;
    final color = activo || hecho ? AppColors.guinda : AppColors.placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: activo || hecho ? AppColors.guinda : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(hecho ? Icons.check_rounded : paso.icono, size: 15, color: color),
            const SizedBox(width: 5),
            if (!compacto)
              Flexible(
                child: Text(
                  paso.titulo,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Atrás / continuar, fijo al pie.
class _PieAcciones extends StatelessWidget {
  const _PieAcciones({
    required this.paso,
    required this.puedeGenerar,
    required this.onAtras,
    required this.onSiguiente,
  });

  final _Paso paso;
  final bool puedeGenerar;
  final VoidCallback? onAtras;
  final VoidCallback onSiguiente;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final ultimo = paso == _Paso.documentos;
    final habilitado = !ultimo || puedeGenerar;

    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: const Color(0x14000000),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              if (onAtras != null)
                OutlinedButton.icon(
                  onPressed: onAtras,
                  icon: const Icon(Icons.arrow_back_rounded, size: 17),
                  label: const Text('Atrás'),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: habilitado ? onSiguiente : null,
                icon: Icon(
                  ultimo
                      ? Icons.picture_as_pdf_outlined
                      : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: Text(ultimo ? 'Generar solicitud' : 'Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
