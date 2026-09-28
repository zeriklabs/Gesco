import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/models/documento.dart';
import '../../core/models/expediente.dart';
import '../../core/models/tramite.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/bloque_adeudos.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/fila_documento.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/gesco_text_field.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/subir_archivo.dart';
import '../../widgets/wizard.dart';
import '../adeudos/adeudos_screen.dart';

/// La solicitud de reinscripción.
///
/// El hallazgo que ordenó todo el rediseño: **no tiene formulario**. El PDF se
/// arma completo con lo que ya está en el expediente — boleta, grupo, turno,
/// domicilio, situación académica, tutor. No hay una sola pregunta nueva.
///
/// Pero "no hay preguntas nuevas" no quiere decir "no hay nada que hacer": el
/// expediente envejece. El propio GESCO lo dice en su primera pantalla —
/// *"reingreso solo actualiza domicilio, teléfono y seguro social"*— y aun así
/// te manda a recorrer los cuatro pasos del expediente a ver qué cambió.
///
/// Así que esto es un asistente de cuatro pasos donde los dos primeros son
/// **confirmaciones, no formularios**: te enseña lo que ya tenemos y tú dices
/// si sigue igual. El camino rápido —el de la mayoría, que no se mudó ni
/// reprobó nada— son dos toques.
class ReinscripcionScreen extends StatefulWidget {
  const ReinscripcionScreen({super.key});

  @override
  State<ReinscripcionScreen> createState() => _ReinscripcionScreenState();
}

enum _Paso {
  datos('Tus datos', Icons.person_outline_rounded),
  adeudos('Materias que debes', Icons.playlist_add_check_rounded),
  documentos('Documentos', Icons.folder_outlined),
  revisar('Revisar y generar', Icons.picture_as_pdf_outlined);

  const _Paso(this.titulo, this.icono);

  final String titulo;
  final IconData icono;
}

class _ReinscripcionScreenState extends State<ReinscripcionScreen> {
  _Paso _paso = _Paso.datos;

  late Tramite _tramite = DatosDemo.tramites.firstWhere(
    (t) => t.tipo == TipoTramite.reinscripcion,
  );

  /// Los campos que el alumno marcó como "cambió", con su valor nuevo.
  final _editando = <String, TextEditingController>{};

  /// Si ya confirmó que sus datos están bien.
  bool _datosConfirmados = false;

  /// Si ya confirmó su lista de materias que debe.
  bool _adeudosConfirmados = false;

  List<Adeudo> get _adeudos => DatosDemo.expediente.adeudos;

  @override
  void dispose() {
    for (final c in _editando.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _corregir(String campo, String valorActual) {
    setState(() {
      _editando[campo] = TextEditingController(text: valorActual);
      _datosConfirmados = false;
    });
  }

  void _cancelarCorreccion(String campo) {
    setState(() {
      _editando.remove(campo)?.dispose();
    });
  }

  void _guardarDatos() {
    for (final MapEntry(key: campo, value: control) in _editando.entries) {
      final valor = control.text.trim();
      if (valor.isNotEmpty) DatosDemo.datosDeContacto[campo] = valor;
    }
    setState(() {
      for (final c in _editando.values) {
        c.dispose();
      }
      _editando.clear();
      _datosConfirmados = true;
      _paso = _Paso.adeudos;
    });
  }

  /// TODO(backend): la subida real. El selector ya pregunta qué archivo.
  Future<void> _subir(Documento doc) async {
    final archivo = await pedirArchivo(context, nombreDocumento: doc.nombre);
    if (archivo == null || !mounted) return;

    setState(() {
      _tramite = Tramite(
        id: _tramite.id,
        tipo: _tramite.tipo,
        estado: _tramite.estado,
        periodo: _tramite.periodo,
        creadoEl: _tramite.creadoEl,
        resumen: _tramite.resumen,
        documentos: [
          for (final d in _tramite.documentos)
            if (d.id == doc.id)
              d.copyWith(estado: EstadoTramite.enRevision, observacion: '')
            else
              d,
        ],
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$archivo: enviado a revisión')),
    );
  }

  Future<void> _agregarAdeudo() async {
    final nuevo = await pedirAdeudo(context);
    if (nuevo == null) return;
    setState(() {
      DatosDemo.adeudos.add(nuevo);
      _adeudosConfirmados = false;
    });
  }

  void _quitarAdeudo(Adeudo adeudo) {
    final posicion = _adeudos.indexOf(adeudo);
    setState(() {
      DatosDemo.adeudos.remove(adeudo);
      _adeudosConfirmados = false;
    });

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

  void _avanzar() {
    switch (_paso) {
      case _Paso.datos:
        _guardarDatos();
      case _Paso.adeudos:
        setState(() {
          _adeudosConfirmados = true;
          _paso = _Paso.documentos;
        });
      case _Paso.documentos:
        setState(() => _paso = _Paso.revisar);
      case _Paso.revisar:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generando la solicitud…')),
        );
    }
  }

  void _retroceder() => setState(() => _paso = _Paso.values[_paso.index - 1]);

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final ultimo = _paso == _Paso.revisar;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Solicitud de reinscripción'),
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
                    constraints: BoxConstraints(
                      maxWidth: _paso == _Paso.revisar ? 1100 : 720,
                    ),
                    child: switch (_paso) {
                      _Paso.datos => _pasoDatos(),
                      _Paso.adeudos => _pasoAdeudos(),
                      _Paso.documentos => _pasoDocumentos(),
                      _Paso.revisar => _pasoRevisar(compacto),
                    },
                  ),
                ),
              ],
            ),
          ),
          PieWizard(
            onAtras: _paso == _Paso.datos ? null : _retroceder,
            onSiguiente: _avanzar,
            habilitado: !ultimo || _tramite.listoParaGenerar,
            etiqueta: switch (_paso) {
              _Paso.datos => _editando.isEmpty
                  ? 'Todo sigue igual'
                  : 'Guardar y continuar',
              _Paso.revisar => 'Generar PDF',
              _ => 'Continuar',
            },
            icono: switch (_paso) {
              _Paso.datos when _editando.isEmpty => Icons.check_rounded,
              _Paso.revisar => Icons.download_rounded,
              _ => Icons.arrow_forward_rounded,
            },
            nota: ultimo && !_tramite.listoParaGenerar
                ? 'Te faltan documentos aprobados'
                : null,
          ),
        ],
      ),
    );
  }

  // --- Paso 1: revisa tus datos ---------------------------------------------

  Widget _pasoDatos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Intro(
          titulo: '¿Sigue igual?',
          texto: 'De un periodo a otro casi nunca cambia nada, así que esto no '
              'es un formulario: es una revisada. Si todo está bien, pásale '
              'derecho. Corrige solo lo que cambió.',
        ),
        const SizedBox(height: AppSpacing.lg),
        GescoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final MapEntry(key: campo, value: valor)
                  in DatosDemo.datosDeContacto.entries)
                _FilaDato(
                  campo: campo,
                  valor: valor,
                  control: _editando[campo],
                  onCorregir: () => _corregir(campo, valor),
                  onCancelar: () => _cancelarCorreccion(campo),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GescoCard(
          color: AppColors.surfaceAlt,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 17, color: AppColors.muted),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '¿Y todo lo demás —tu nombre, tu CURP, tu tutor? Está en tu '
                  'expediente y no cambia de un semestre a otro. Si algo de '
                  'eso sí cambió, corrígelo en Mi expediente.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.inkSecondary,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Paso 2: materias que debes -------------------------------------------

  Widget _pasoAdeudos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Intro(
          titulo: '¿Debes alguna materia?',
          texto: 'Esta lista decide qué documentos te van a pedir abajo y se '
              'reusa en todos tus trámites. Vale la pena que esté al día.',
        ),
        const SizedBox(height: AppSpacing.lg),
        GescoCard(
          child: BloqueAdeudos(
            adeudos: _adeudos,
            onAgregar: _agregarAdeudo,
            onQuitar: _quitarAdeudo,
            textoVacio: 'No debes ninguna materia. Si reprobaste alguna y no '
                'aparece aquí, agrégala antes de generar tu solicitud.',
          ),
        ),
      ],
    );
  }

  // --- Paso 3: documentos ---------------------------------------------------

  Widget _pasoDocumentos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Intro(
          titulo: 'Lo que tienes que entregar',
          texto: 'Solo los que te tocan según tu situación. Los que no te '
              'aplican van abajo, con el motivo, por si crees que el sistema '
              'se equivocó.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _BloqueDocumentos(tramite: _tramite, onSubir: _subir),
      ],
    );
  }

  // --- Paso 4: revisar y generar --------------------------------------------

  Widget _pasoRevisar(bool compacto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _AvisoSinFormulario(),
        const SizedBox(height: AppSpacing.md),
        if (compacto) ...[
          const _BloqueOrigenDatos(),
          const SizedBox(height: AppSpacing.md),
          const _VistaPrevia(),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 3, child: _VistaPrevia()),
              const SizedBox(width: AppSpacing.lg),
              const Expanded(flex: 2, child: _BloqueOrigenDatos()),
            ],
          ),
      ],
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

/// Un dato con su valor actual y el botón de corregir.
///
/// En modo lectura es un renglón; al tocar "Cambió" se vuelve un campo. Así
/// el que no tiene nada que corregir —la mayoría— nunca ve un formulario.
class _FilaDato extends StatelessWidget {
  const _FilaDato({
    required this.campo,
    required this.valor,
    required this.control,
    required this.onCorregir,
    required this.onCancelar,
  });

  final String campo;
  final String valor;
  final TextEditingController? control;
  final VoidCallback onCorregir;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) {
    final editando = control != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: editando
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GescoTextField(
                  label: campo,
                  controller: control,
                  maxLines: campo == 'Domicilio' ? 2 : 1,
                  helperText: 'Antes: $valor',
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onCancelar,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.muted,
                    ),
                    child: const Text('Déjalo como estaba'),
                  ),
                ),
              ],
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.ground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(campo, style: AppTypography.hint),
                        const SizedBox(height: 2),
                        Text(
                          valor,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  TextButton(
                    onPressed: onCorregir,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.guinda,
                      textStyle: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    child: const Text('Cambió'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AvisoSinFormulario extends StatelessWidget {
  const _AvisoSinFormulario();

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      color: AppColors.dangerTint,
      colorBorde: AppColors.dangerBorder,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 19, color: AppColors.guinda),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Esta solicitud no te pide nada nuevo. ',
                style: const TextStyle(fontWeight: FontWeight.w800),
                children: [
                  TextSpan(
                    text: 'Se arma completa con lo que ya capturaste en tu '
                        'expediente. Revisa que todo esté bien antes de '
                        'generarla: si hay un dato falso, Gestión Escolar '
                        'cancela el trámite.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.inkSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.ink,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// De qué parte del expediente sale cada bloque del documento.
class _BloqueOrigenDatos extends StatelessWidget {
  const _BloqueOrigenDatos();

  static const _origen = {
    SeccionExpediente.personales: 'Encabezado, domicilio y contacto',
    SeccionExpediente.escolares: 'Situación académica y créditos',
    SeccionExpediente.tutor: 'Bloque de la página 2',
    SeccionExpediente.generales: '¿Trabajas? y visibilidad al tutor',
  };

  @override
  Widget build(BuildContext context) {
    final expediente = DatosDemo.expediente;

    return GescoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'De dónde salen los datos',
                  style: AppTypography.titleLarge,
                ),
              ),
              StatusPill(
                expediente.estaCompleto
                    ? EstadoTramite.aprobado
                    : EstadoTramite.enRevision,
                compacta: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final MapEntry(key: seccion, value: detalle) in _origen.entries)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    (expediente.secciones[seccion]?.completa ?? false)
                        ? Icons.check_circle_rounded
                        : Icons.pending_outlined,
                    size: 18,
                    color: (expediente.secciones[seccion]?.completa ?? false)
                        ? AppColors.success
                        : AppColors.dorado,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seccion.titulo,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(detalle, style: AppTypography.hint),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Los documentos del trámite, con el botón de subir aquí mismo.
///
/// Esto es lo que reemplaza la sección aparte de "Subir documentos" del GESCO
/// actual: en vez de ocho documentos sueltos en otra pestaña, los tres que te
/// tocan, junto al botón que genera el PDF.
class _BloqueDocumentos extends StatelessWidget {
  const _BloqueDocumentos({required this.tramite, required this.onSubir});

  final Tramite tramite;
  final void Function(Documento) onSubir;

  @override
  Widget build(BuildContext context) {
    final aplican = tramite.documentosAplicables;
    final noAplican = tramite.documentosNoAplicables;

    return GescoCard(
      bordeGrueso: true,
      colorBorde: AppColors.dangerBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Documentos de este trámite',
                  style: AppTypography.titleLarge,
                ),
              ),
              Text(
                '${tramite.documentosAprobados} de '
                '${tramite.documentosRequeridos}',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Solo los que te tocan, según tu situación: carga por debajo de '
            'la mínima, sin dictamen, sin baja previa.',
            style: AppTypography.hint,
          ),
          const SizedBox(height: AppSpacing.md),

          for (final d in aplican)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: FilaDocumento(
                documento: d,
                onSubir: () => onSubir(d),
                compacta: true,
              ),
            ),

          if (noAplican.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _NoAplican(documentos: noAplican),
          ],

          const SizedBox(height: AppSpacing.sm + 2),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: AppColors.warningTint,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.warningInk),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    tramite.listoParaGenerar
                        ? 'Ya puedes generar el PDF. No entregues nada impreso '
                            'antes de eso.'
                        : 'Genera el PDF cuando los tres estén aprobados.',
                    style: AppTypography.hint.copyWith(
                      color: AppColors.warningInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Los documentos que no le tocan, con el porqué.
///
/// Se muestran en vez de esconderse: si el sistema dedujo mal tu situación,
/// aquí lo puedes ver antes de que te rechacen el trámite.
class _NoAplican extends StatelessWidget {
  const _NoAplican({required this.documentos});

  final List<Documento> documentos;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.xs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderMuted, width: 1.5),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderMuted, width: 1.5),
        ),
        leading: const Icon(Icons.remove_circle_outline_rounded,
            size: 20, color: AppColors.muted),
        title: Text(
          '${documentos.length} documentos no te aplican',
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.inkSecondary,
          ),
        ),
        subtitle: Text(
          'Revisa que sea correcto',
          style: AppTypography.hint,
        ),
        children: [
          for (final d in documentos)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 7, right: AppSpacing.xs),
                    decoration: const BoxDecoration(
                      color: AppColors.placeholder,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.nombre,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                        Text(d.porQueNoAplica ?? '', style: AppTypography.hint),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Una representación del documento que se va a generar.
///
/// No es el PDF real: es para que el alumno reconozca su propia solicitud y
/// detecte un dato mal antes de imprimirla y llevarla a ventanilla.
class _VistaPrevia extends StatelessWidget {
  const _VistaPrevia();

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      color: const Color(0xFFEFEAE6),
      colorBorde: AppColors.borderMuted,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.09),
                  blurRadius: 14,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const _HojaDocumento(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: null,
                tooltip: 'Página anterior',
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                'Página 1 de 2',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSecondary,
                ),
              ),
              IconButton(
                onPressed: () {},
                tooltip: 'Página siguiente',
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HojaDocumento extends StatelessWidget {
  const _HojaDocumento();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IpnLogo(height: 34, onDark: false),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'INSTITUTO POLITÉCNICO NACIONAL\n'
                    'UNIDAD PROFESIONAL INTERDISCIPLINARIA DE INGENIERÍA\n'
                    'CAMPUS ZACATECAS',
                    textAlign: TextAlign.center,
                    style: _serif(9, peso: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Subdirección de Servicios Educativos e Integración Social',
                    textAlign: TextAlign.center,
                    style: _serif(7.5),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'DEPARTAMENTO DE GESTIÓN ESCOLAR\nSOLICITUD DE REINSCRIPCIÓN',
                    textAlign: TextAlign.center,
                    style: _serif(8.5, peso: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const UpiizLogo(size: 36),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        const _CampoDoc(etiqueta: 'NO. DE BOLETA', valor: DatosDemo.boleta),
        const _CampoDoc(
          etiqueta: 'PROGRAMA ACADÉMICO',
          valor: 'ING. EN SISTEMAS COMPUTACIONALES',
        ),
        const _CampoDoc(etiqueta: 'GRUPO', valor: DatosDemo.grupo),
        const _CampoDoc(
          etiqueta: 'PERIODO',
          valor: '27/1 (AGO 2026 – ENE 2027)',
        ),

        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            'DATOS GENERALES DEL ALUMNO',
            style: _serif(8.5, peso: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        const _FilaCampos(
          valores: ['GARCÍA', 'TORRES', 'GAEL'],
          etiquetas: ['APELLIDO PATERNO', 'APELLIDO MATERNO', 'NOMBRE(S)'],
        ),
        const SizedBox(height: 6),
        const _FilaCampos(
          valores: ['CANAL ESTEBAN RODRÍGUEZ', '4', 'PAMANES ESCOBEDO'],
          etiquetas: ['CALLE', 'No. EXT', 'COLONIA'],
          pesos: [3, 1, 2],
        ),

        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            'SITUACIÓN ACADÉMICA',
            style: _serif(8.5, peso: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Text('POR DEBAJO DE LA MÍNIMA', style: _serif(7, peso: FontWeight.w700)),
        const SizedBox(height: 4),
        const _CampoDoc(etiqueta: 'SEMESTRE', valor: '8VO'),
        const _CampoDoc(etiqueta: 'TOTAL DE CRÉDITOS', valor: '30'),
        const _CampoDoc(etiqueta: 'PROMEDIO SAES', valor: '8.47'),
      ],
    );
  }
}

TextStyle _serif(double tam, {FontWeight peso = FontWeight.w400}) {
  return TextStyle(
    fontFamily: 'Times New Roman',
    fontFamilyFallback: const ['Georgia', 'serif'],
    fontSize: tam,
    fontWeight: peso,
    height: 1.35,
    color: const Color(0xFF111111),
  );
}

class _CampoDoc extends StatelessWidget {
  const _CampoDoc({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(
              etiqueta,
              textAlign: TextAlign.right,
              style: _serif(6.5, peso: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: _Caja(valor: valor)),
        ],
      ),
    );
  }
}

class _FilaCampos extends StatelessWidget {
  const _FilaCampos({
    required this.valores,
    required this.etiquetas,
    this.pesos,
  });

  final List<String> valores;
  final List<String> etiquetas;
  final List<int>? pesos;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < valores.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                flex: pesos?[i] ?? 1,
                child: _Caja(valor: valores[i]),
              ),
            ],
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < etiquetas.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                flex: pesos?[i] ?? 1,
                child: Text(
                  etiquetas[i],
                  textAlign: TextAlign.center,
                  style: _serif(6, peso: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Caja extends StatelessWidget {
  const _Caja({required this.valor});

  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF999999), width: 0.8),
      ),
      child: Text(
        valor,
        style: _serif(7.5),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
