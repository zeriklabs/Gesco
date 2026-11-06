import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/catalogos.dart';
import '../../core/data/codigos_postales.dart';
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
import '../../widgets/gesco_select.dart';
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
  adeudos('Situación académica', Icons.school_outlined),
  documentos('Documentos', Icons.folder_outlined),
  revisar('Revisar y generar', Icons.picture_as_pdf_outlined);

  const _Paso(this.titulo, this.icono);

  final String titulo;
  final IconData icono;
}

class _DictamenEntrada {
  final String id;
  final String tipo; // 'CT' o 'CG'
  final String motivo;

  const _DictamenEntrada({
    required this.id,
    required this.tipo,
    required this.motivo,
  });
}

class _ReinscripcionScreenState extends State<ReinscripcionScreen> {
  _Paso _paso = _Paso.datos;

  late final Tramite _tramite = DatosDemo.tramites.firstWhere(
    (t) => t.tipo == TipoTramite.reinscripcion,
  );

  /// Los campos de datos personales que el alumno marcó como "cambió".
  final _editandoPersonales = <String, TextEditingController>{};

  /// Si el alumno activó la edición de su domicilio.
  bool _editarDomicilio = false;

  /// Controllers para los campos de domicilio.
  final _domicilioControllers = <String, TextEditingController>{};

  /// Si mantiene al mismo tutor registrado.
  bool _mismoTutor = true;

  /// Campos de situación académica.
  bool _provieneDeBaja = false;
  bool _provieneDeCambioPrograma = false;
  bool _esIrregular = false;
  bool _tieneDictamenCosie = false;
  String _semestreACursar = '5to';
  String _cargaReinscripcion = 'Media';

  /// Lista de dictámenes agregados dinámicamente por el alumno.
  final List<_DictamenEntrada> _dictamenesAgregados = [
    const _DictamenEntrada(
      id: 'doc-dictamen-1',
      tipo: 'CT',
      motivo: 'Dictamen de COSIE',
    ),
  ];

  /// Indicador de lectura de instrucciones en el paso de revisar.
  bool _instruccionesAceptadas = false;

  TextEditingController get _promedioSaesController =>
      _editandoPersonales['Promedio SAES'] ??= TextEditingController(
        text: '8.75',
      );

  /// Controllers para los detalles del trabajo cuando trabaja == true.
  TextEditingController get _horarioTrabajoController =>
      _editandoPersonales['Horario de trabajo'] ??= TextEditingController(
        text: DatosDemo.datosPersonales['Horario de trabajo'] ??
            'Lunes a viernes, 15:00 a 21:00',
      );

  TextEditingController get _datosTrabajoController =>
      _editandoPersonales['Datos del trabajo'] ??= TextEditingController(
        text: DatosDemo.datosPersonales['Datos del trabajo'] ??
            'Empresa S.A. de C.V. - Av. Central 456, Tel. 492 900 1122',
      );

  /// Controllers para los campos del tutor si cambiaron.
  final _tutorControllers = <String, TextEditingController>{};

  List<Adeudo> get _adeudos => DatosDemo.expediente.adeudos;

  @override
  void initState() {
    super.initState();
    _inicializarDomicilioControllers();
    _inicializarTutorControllers();
    final desfasadas =
        _adeudos.where((a) => a.estaDesfasada(DatosDemo.periodoActual)).toList();
    if (desfasadas.isNotEmpty || DatosDemo.requiereExtensionDeTiempo) {
      _tieneDictamenCosie = true;
      _esIrregular = true;
    }
  }

  void _inicializarDomicilioControllers() {
    if (_domicilioControllers.isEmpty) {
      for (final MapEntry(key: k, value: v)
          in DatosDemo.domicilioActual.entries) {
        _domicilioControllers[k] = TextEditingController(text: v);
      }
    }
  }

  String _tutorParentesco = 'MADRE';
  bool _tutorMismoDomicilio = true;

  void _inicializarTutorControllers() {
    if (_tutorControllers.isEmpty) {
      _tutorControllers['Nombre(s)'] = TextEditingController(text: 'Rosa');
      _tutorControllers['Apellido paterno'] =
          TextEditingController(text: 'Reyes');
      _tutorControllers['Apellido materno'] =
          TextEditingController(text: 'Luna');
      _tutorControllers['Ocupación'] = TextEditingController(text: 'Hogar');
      _tutorControllers['Teléfono celular'] =
          TextEditingController(text: '492 921 5544');
      _tutorControllers['Correo del tutor'] =
          TextEditingController(text: 'rosa.reyes@gmail.com');
      _tutorControllers['C.P. Tutor'] = TextEditingController(text: '98000');
      _tutorControllers['Estado Tutor'] =
          TextEditingController(text: 'Zacatecas');
      _tutorControllers['Municipio Tutor'] =
          TextEditingController(text: 'Zacatecas');
      _tutorControllers['Colonia Tutor'] =
          TextEditingController(text: 'Centro');
      _tutorControllers['Calle Tutor'] =
          TextEditingController(text: 'Av. Siempre Viva');
      _tutorControllers['N° ext Tutor'] = TextEditingController(text: '100');
      _tutorControllers['N° int Tutor'] = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    for (final c in _editandoPersonales.values) {
      c.dispose();
    }
    for (final c in _domicilioControllers.values) {
      c.dispose();
    }
    for (final c in _tutorControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _corregirPersonal(String campo, String valorActual) {
    setState(() {
      _editandoPersonales[campo] = TextEditingController(text: valorActual);
    });
  }

  void _cancelarCorreccionPersonal(String campo) {
    setState(() {
      _editandoPersonales.remove(campo)?.dispose();
    });
  }

  void _guardarDatos() {
    for (final MapEntry(key: campo, value: control)
        in _editandoPersonales.entries) {
      final valor = control.text.trim();
      if (valor.isNotEmpty) {
        DatosDemo.datosPersonales[campo] = valor;
      }
    }

    if (_editarDomicilio) {
      for (final MapEntry(key: campo, value: control)
          in _domicilioControllers.entries) {
        final valor = control.text.trim();
        if (valor.isNotEmpty) {
          DatosDemo.domicilioActual[campo] = valor;
        }
      }
    }

    if (!_mismoTutor) {
      for (final MapEntry(key: campo, value: control)
          in _tutorControllers.entries) {
        final valor = control.text.trim();
        if (valor.isNotEmpty) {
          DatosDemo.datosTutor[campo] = valor;
        }
      }
    }

    if ((DatosDemo.datosPersonales['¿Trabajas?'] ?? 'No') == 'Sí') {
      DatosDemo.datosPersonales['Horario de trabajo'] =
          _horarioTrabajoController.text.trim();
      DatosDemo.datosPersonales['Datos del trabajo'] =
          _datosTrabajoController.text.trim();
    }

    setState(() {
      _paso = _Paso.adeudos;
    });
  }

  /// Mapa de documentos subidos dinámicamente: ID -> (nombreArchivo, estado)
  final Map<String, (String, EstadoTramite)> _documentosSubidos = {};

  List<Documento> _obtenerDocumentosActuales() {
    Documento crearDoc({
      required String id,
      required String nombre,
      required bool aplica,
      String? porQueNoAplica,
    }) {
      final subido = _documentosSubidos[id];
      final estado = subido != null ? subido.$2 : EstadoTramite.sinSubir;
      final nombreArchivo = subido?.$1;

      return Documento(
        id: id,
        nombre: nombre,
        estado: estado,
        aplica: aplica,
        porQueNoAplica: porQueNoAplica,
        nombreArchivo: nombreArchivo,
      );
    }

    final dictamenAplica = _tieneDictamenCosie ||
        _cargaReinscripcion == 'Debajo de la mínima';

    final docsDictamenes = dictamenAplica
        ? [
            for (final d in _dictamenesAgregados)
              crearDoc(
                id: d.id,
                nombre:
                    'Dictamen de COSIE (${d.tipo == 'CG' ? 'Consejo General - CG' : 'Consejo Técnico - CT'})${d.motivo.isNotEmpty ? ' · ${d.motivo}' : ''}',
                aplica: true,
              ),
          ]
        : [
            crearDoc(
              id: 'doc-dictamen-placeholder',
              nombre: 'Dictamen de COSIE (CT / CG)',
              aplica: false,
              porQueNoAplica:
                  'No aplica porque indicaste que no cuentas con dictamen COSIE y tu carga académica es igual o superior a la mínima.',
            ),
          ];

    return [
      crearDoc(
        id: 'doc-saes',
        nombre: 'Actualización de datos del SAES',
        aplica: true,
      ),
      crearDoc(
        id: 'doc-solicitud',
        nombre: 'Solicitud y comprobante de reinscripción',
        aplica: true,
      ),
      crearDoc(
        id: 'doc-donativo',
        nombre: 'Comprobante de donativo',
        aplica: true,
      ),
      crearDoc(
        id: 'doc-baja',
        nombre: 'Oficio de baja temporal',
        aplica: _provieneDeBaja,
        porQueNoAplica:
            'No aplica porque indicaste que no provienes de una baja.',
      ),
      crearDoc(
        id: 'doc-cambio-programa',
        nombre: 'Documento de cambio de programa académico',
        aplica: _provieneDeCambioPrograma,
        porQueNoAplica:
            'No aplica porque no provienes de otro programa académico.',
      ),
      ...docsDictamenes,
      crearDoc(
        id: 'doc-carga-minima',
        nombre: 'Oficio de inscripción por debajo de la carga mínima',
        aplica: _cargaReinscripcion == 'Debajo de la mínima',
        porQueNoAplica:
            'No aplica porque tu carga académica es igual o superior a la mínima.',
      ),
    ];
  }

  Tramite get _tramiteActual {
    return Tramite(
      id: _tramite.id,
      tipo: _tramite.tipo,
      estado: _tramite.estado,
      periodo: _tramite.periodo,
      creadoEl: _tramite.creadoEl,
      resumen: _tramite.resumen,
      documentos: _obtenerDocumentosActuales(),
    );
  }

  /// TODO(backend): la subida real. El selector ya pregunta qué archivo.
  Future<void> _subir(Documento doc) async {
    final archivo = await pedirArchivo(context, nombreDocumento: doc.nombre);
    if (archivo == null || !mounted) return;

    setState(() {
      _documentosSubidos[doc.id] = (archivo, EstadoTramite.enRevision);
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
    });
  }

  void _quitarAdeudo(Adeudo adeudo) {
    final posicion = _adeudos.indexOf(adeudo);
    setState(() {
      DatosDemo.adeudos.remove(adeudo);
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
          _paso = _Paso.documentos;
        });
      case _Paso.documentos:
        setState(() => _paso = _Paso.revisar);
      case _Paso.revisar:
        if (!_instruccionesAceptadas) return;
        _mostrarDialogoEnviado();
    }
  }

  void _mostrarDialogoEnviado() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Solicitud enviada',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu solicitud de reinscripción ha sido generada exitosamente y enviada '
              'al departamento de Gestión Escolar para su revisión.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.ink,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warningTint,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.print_rounded,
                    color: AppColors.guinda,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Expanded(
                    child: Text(
                      'Recuerda guardar el archivo PDF e imprimir 2 copias en hoja carta para entregarlas en ventanilla.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
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
            habilitado: !ultimo || _instruccionesAceptadas,
            etiqueta: switch (_paso) {
              _Paso.datos => (_editandoPersonales.isEmpty && !_editarDomicilio)
                  ? 'Todo sigue igual'
                  : 'Guardar y continuar',
              _Paso.revisar => 'Generar y enviar',
              _ => 'Continuar',
            },
            icono: switch (_paso) {
              _Paso.datos when (_editandoPersonales.isEmpty && !_editarDomicilio) =>
                Icons.check_rounded,
              _Paso.revisar => Icons.send_rounded,
              _ => Icons.arrow_forward_rounded,
            },
            nota: (ultimo && !_instruccionesAceptadas)
                ? 'Marca la casilla de confirmación para habilitar'
                : null,
          ),
        ],
      ),
    );
  }

  // --- Paso 1: revisa y actualiza tus datos ---------------------------------

  Widget _pasoDatos() {
    final direccionResumen =
        '${DatosDemo.domicilioActual['Calle']} #${DatosDemo.domicilioActual['N° ext']}, '
        'Col. ${DatosDemo.domicilioActual['Colonia']}, C.P. ${DatosDemo.domicilioActual['C.P.']}, '
        '${DatosDemo.domicilioActual['Municipio']}, ${DatosDemo.domicilioActual['Estado']}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Intro(
          titulo: 'Revisión y actualización de datos',
          texto:
              'De un periodo a otro algunos datos pueden cambiar. Revisa tus '
              'datos personales y confirma si mantienes tu domicilio y tutor.',
        ),
        const SizedBox(height: AppSpacing.lg),

        // Perfil Header (basado en el diseño de referencia)
        GescoCard(
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: AppColors.guinda,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  size: 34,
                  color: AppColors.onGuinda,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DatosDemo.nombreAlumno,
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 15,
                              color: AppColors.inkSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DatosDemo.fechaNacimiento,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 15,
                              color: AppColors.inkSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${DatosDemo.domicilioActual['Municipio']}, ${DatosDemo.domicilioActual['Estado']}',
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _editarDomicilio = !_editarDomicilio;
                                  if (_editarDomicilio) {
                                    _inicializarDomicilioControllers();
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Text(
                                _editarDomicilio ? 'Cancelar' : '¿Editar?',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.guinda,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 1. Datos Personales
        GescoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TituloBloque(texto: 'Datos Personales'),
              const SizedBox(height: AppSpacing.md),
              for (final MapEntry(key: campo, value: valor)
                  in DatosDemo.datosPersonales.entries)
                if (campo == '¿Trabajas?') ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: OpcionSiNo(
                      label: '¿Trabajas actualmente?',
                      value:
                          (DatosDemo.datosPersonales['¿Trabajas?'] ?? 'No') ==
                              'Sí',
                      helperText:
                          'Si trabajas, la escuela lo considera para solicitudes de carga mínima o grupos.',
                      onChanged: (val) {
                        setState(() {
                          DatosDemo.datosPersonales['¿Trabajas?'] =
                              val ? 'Sí' : 'No';
                        });
                      },
                    ),
                  ),
                  if ((DatosDemo.datosPersonales['¿Trabajas?'] ?? 'No') ==
                      'Sí') ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.ground,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GescoTextField(
                            label: 'Horario de trabajo',
                            controller: _horarioTrabajoController,
                            hintText: 'Ej. Lunes a viernes, 15:00 a 21:00',
                            isRequired: true,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          GescoTextField(
                            label: 'Datos del trabajo',
                            controller: _datosTrabajoController,
                            hintText:
                                'Nombre de la empresa, dirección y teléfono',
                            helperText:
                                'Incluye el nombre de la empresa, dirección y teléfono.',
                            isRequired: true,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else if (campo != 'Horario de trabajo' &&
                    campo != 'Datos del trabajo')
                  _FilaDato(
                    campo: campo,
                    valor: valor,
                    control: _editandoPersonales[campo],
                    opciones: campo == 'Género'
                        ? const ['Femenino', 'Masculino', 'Otro']
                        : campo == 'Estado civil'
                            ? const [
                                'Soltero/a',
                                'Casado/a',
                                'Divorciado/a',
                                'Viudo/a',
                                'Unión libre',
                              ]
                            : null,
                    onCorregir: () => _corregirPersonal(campo, valor),
                    onCancelar: () => _cancelarCorreccionPersonal(campo),
                  ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 2. Domicilio Actual (Solo se muestra el formulario editable si el alumno presiona ¿Editar?)
        GescoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TituloBloque(
                texto: 'Domicilio Actual',
                accion: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _editarDomicilio = !_editarDomicilio;
                      if (_editarDomicilio) {
                        _inicializarDomicilioControllers();
                      }
                    });
                  },
                  icon: Icon(
                    _editarDomicilio
                        ? Icons.check_circle_outline_rounded
                        : Icons.edit_location_alt_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _editarDomicilio
                        ? 'Mismo domicilio'
                        : '¿Cambiaste de domicilio?',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!_editarDomicilio) ...[
                // Estado normal: resumen sin formulario editable
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.ground,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.home_outlined,
                        color: AppColors.guinda,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          direccionResumen,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successTint,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.successBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Vives en el mismo domicilio registrado.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.successInk,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Estado editando: formulario de domicilio con autocompletado por Código Postal
                Builder(
                  builder: (context) {
                    final cpVal = _domicilioControllers['C.P.']?.text ?? '';
                    final cpInfo =
                        cpVal.length == 5 ? CodigosPostales.buscar(cpVal) : null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ingresa tu código postal para autocompletar Estado, Municipio y Colonia:',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: GescoTextField(
                                label: 'C.P.',
                                controller: _domicilioControllers['C.P.'],
                                hintText: 'Ej. 98000',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(5),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (val) {
                                  if (val.length == 5) {
                                    final info = CodigosPostales.buscar(val);
                                    if (info != null) {
                                      setState(() {
                                        _domicilioControllers['Estado']?.text =
                                            info.estado;
                                        _domicilioControllers['Municipio']
                                            ?.text = info.municipio;
                                        if (info.colonias.isNotEmpty &&
                                            !info.colonias.contains(
                                                _domicilioControllers['Colonia']
                                                    ?.text)) {
                                          _domicilioControllers['Colonia']
                                              ?.text = info.primeraColonia;
                                        }
                                      });
                                    }
                                  } else {
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: GescoTextField(
                                label: 'Estado',
                                controller: _domicilioControllers['Estado'],
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: GescoTextField(
                                label: 'Municipio',
                                controller: _domicilioControllers['Municipio'],
                                isRequired: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GescoTextField(
                                label: 'Calle',
                                controller: _domicilioControllers['Calle'],
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              flex: 2,
                              child: (cpInfo != null &&
                                      cpInfo.colonias.isNotEmpty)
                                  ? GescoSelect<String>(
                                      label: 'Colonia',
                                      value: cpInfo.colonias.contains(
                                              _domicilioControllers['Colonia']
                                                  ?.text)
                                          ? _domicilioControllers['Colonia']
                                              ?.text
                                          : cpInfo.primeraColonia,
                                      opciones: cpInfo.colonias,
                                      isRequired: true,
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            _domicilioControllers['Colonia']
                                                ?.text = val;
                                          });
                                        }
                                      },
                                    )
                                  : GescoTextField(
                                      label: 'Colonia',
                                      controller:
                                          _domicilioControllers['Colonia'],
                                      isRequired: true,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: GescoTextField(
                                label: 'N° ext',
                                controller: _domicilioControllers['N° ext'],
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: GescoTextField(
                                label: 'N° int',
                                controller: _domicilioControllers['N° int'],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 3. Confirmación / Actualización del Tutor
        GescoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TituloBloque(texto: 'Datos del Tutor'),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.ground,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.supervisor_account_rounded,
                        color: AppColors.guinda,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DatosDemo.datosTutor['Nombre del tutor'] ??
                                'Tutor registrado',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DatosDemo.datosTutor['Parentesco']} · Tel: ${DatosDemo.datosTutor['Teléfono del tutor']}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OpcionSiNo(
                label: '¿Aún tienes registrado al mismo tutor?',
                value: _mismoTutor,
                etiquetaSi: 'Sí, es el mismo',
                etiquetaNo: 'No, cambiar tutor',
                onChanged: (val) {
                  setState(() {
                    _mismoTutor = val;
                    if (!val) _inicializarTutorControllers();
                  });
                },
              ),
              if (_mismoTutor) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successTint,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.successBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Expanded(
                        child: Text(
                          'Datos del tutor confirmados para esta reinscripción.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.successInk,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Ingresa los datos del nuevo tutor:',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.guinda,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // 1. Quién es
                Row(
                  children: [
                    Expanded(
                      child: GescoTextField(
                        label: 'Nombre(s)',
                        controller: _tutorControllers['Nombre(s)'],
                        isRequired: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GescoTextField(
                        label: 'Apellido paterno',
                        controller: _tutorControllers['Apellido paterno'],
                        isRequired: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GescoTextField(
                        label: 'Apellido materno',
                        controller: _tutorControllers['Apellido materno'],
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: GescoSelect<String>(
                        label: 'Parentesco',
                        value: _tutorParentesco,
                        opciones: Catalogos.parentesco,
                        isRequired: true,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _tutorParentesco = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GescoTextField(
                        label: 'Ocupación',
                        controller: _tutorControllers['Ocupación'],
                        isRequired: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // 2. Cómo localizarlo
                Row(
                  children: [
                    Expanded(
                      child: GescoTextField(
                        label: 'Teléfono celular',
                        controller: _tutorControllers['Teléfono celular'],
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GescoTextField(
                        label: 'Correo electrónico',
                        controller: _tutorControllers['Correo del tutor'],
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 3. Domicilio del tutor
                OpcionSiNo(
                  label: '¿El tutor vive en el mismo domicilio que tú?',
                  value: _tutorMismoDomicilio,
                  onChanged: (val) =>
                      setState(() => _tutorMismoDomicilio = val),
                ),

                if (!_tutorMismoDomicilio) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Builder(
                    builder: (context) {
                      final tutorCpVal =
                          _tutorControllers['C.P. Tutor']?.text ?? '';
                      final tutorCpInfo = tutorCpVal.length == 5
                          ? CodigosPostales.buscar(tutorCpVal)
                          : null;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GescoTextField(
                                  label: 'C.P. del tutor',
                                  controller: _tutorControllers['C.P. Tutor'],
                                  hintText: 'Ej. 98000',
                                  isRequired: true,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(5),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (val) {
                                    if (val.length == 5) {
                                      final info = CodigosPostales.buscar(val);
                                      if (info != null) {
                                        setState(() {
                                          _tutorControllers['Estado Tutor']
                                              ?.text = info.estado;
                                          _tutorControllers['Municipio Tutor']
                                              ?.text = info.municipio;
                                          if (info.colonias.isNotEmpty &&
                                              !info.colonias.contains(
                                                  _tutorControllers[
                                                          'Colonia Tutor']
                                                      ?.text)) {
                                            _tutorControllers['Colonia Tutor']
                                                ?.text = info.primeraColonia;
                                          }
                                        });
                                      }
                                    } else {
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: GescoTextField(
                                  label: 'Estado',
                                  controller:
                                      _tutorControllers['Estado Tutor'],
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: GescoTextField(
                                  label: 'Municipio',
                                  controller:
                                      _tutorControllers['Municipio Tutor'],
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: GescoTextField(
                                  label: 'Calle',
                                  controller: _tutorControllers['Calle Tutor'],
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 2,
                                child: (tutorCpInfo != null &&
                                        tutorCpInfo.colonias.isNotEmpty)
                                    ? GescoSelect<String>(
                                        label: 'Colonia',
                                        value: tutorCpInfo.colonias.contains(
                                                _tutorControllers[
                                                        'Colonia Tutor']
                                                    ?.text)
                                            ? _tutorControllers['Colonia Tutor']
                                                ?.text
                                            : tutorCpInfo.primeraColonia,
                                        opciones: tutorCpInfo.colonias,
                                        isRequired: true,
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _tutorControllers[
                                                      'Colonia Tutor']
                                                  ?.text = val;
                                            });
                                          }
                                        },
                                      )
                                    : GescoTextField(
                                        label: 'Colonia',
                                        controller: _tutorControllers[
                                            'Colonia Tutor'],
                                        isRequired: true,
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: GescoTextField(
                                  label: 'N° ext',
                                  controller:
                                      _tutorControllers['N° ext Tutor'],
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: GescoTextField(
                                  label: 'N° int',
                                  controller:
                                      _tutorControllers['N° int Tutor'],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- Paso 2: Situación académica ------------------------------------------

  Widget _pasoAdeudos() {
    final esDebajoMinima = _cargaReinscripcion == 'Debajo de la mínima';
    final desfasadas =
        _adeudos.where((a) => a.estaDesfasada(DatosDemo.periodoActual)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Intro(
          titulo: 'Situación académica',
          texto:
              'Ingresa tu situación académica actual para determinar tu tipo de '
              'inscripción, carga de materias y documentos requeridos.',
        ),
        const SizedBox(height: AppSpacing.lg),

        if (desfasadas.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.dangerTint,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.danger),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.gavel_rounded,
                  color: AppColors.guinda,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Materia desfasada detectada! (Requiere Dictamen de COSIE)',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.guinda,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tienes ${desfasadas.length} materia(s) desfasada(s) por exceder 1 año (2 periodos) sin acreditar '
                        '(${desfasadas.map((m) => m.unidadAprendizaje).join(', ')}). '
                        'Por reglamento del IPN es obligatorio contar con un Dictamen de COSIE para completar tu reinscripción.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.ink,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        if (DatosDemo.requiereExtensionDeTiempo) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.dangerTint,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.danger),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.history_toggle_off_rounded,
                  color: AppColors.guinda,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Límite de semestres excedido! (Requiere Dictamen de Extensión de Tiempo)',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.guinda,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Has cursado ${DatosDemo.semestresTranscurridos} semestres de los ${DatosDemo.semestresMaximosCarrera} máximos permitidos en ${DatosDemo.carrera}. '
                        'Por reglamento del IPN es obligatorio tramitar un Dictamen de Extensión de Tiempo ante el COSIE.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.ink,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 1. Estado y Dictamen
        GescoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TituloBloque(texto: 'Estado Académico'),
              const SizedBox(height: AppSpacing.md),

              // ¿Proviene de una baja?
              OpcionSiNo(
                label: '¿Provienes de una baja temporal?',
                value: _provieneDeBaja,
                onChanged: (val) => setState(() => _provieneDeBaja = val),
              ),
              if (_provieneDeBaja) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerTint,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.dangerBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.guinda,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Atención: Al provenir de una baja, necesitarás subir tu oficio de baja temporal en el siguiente paso.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // ¿Proviene de otro programa académico?
              OpcionSiNo(
                label: '¿Provienes de otro programa académico?',
                value: _provieneDeCambioPrograma,
                onChanged: (val) =>
                    setState(() => _provieneDeCambioPrograma = val),
              ),
              if (_provieneDeCambioPrograma) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerTint,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.dangerBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.guinda,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Atención: Al provenir de otro programa académico, necesitarás subir tu documento de cambio de programa académico en el siguiente paso.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Situación académica (Regular / Irregular)
              OpcionSiNo(
                label: 'Situación académica',
                value: !_esIrregular,
                etiquetaSi: 'Regular',
                etiquetaNo: 'Irregular',
                onChanged: (val) => setState(() => _esIrregular = !val),
              ),

              if (_esIrregular) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warningTint,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.warningBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.dorado,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Tipo de inscripción: Después de ETS',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Dictamen emitido por el COSIE
              OpcionSiNo(
                label: '¿Tienes dictamen emitido por el COSIE?',
                value: _tieneDictamenCosie,
                onChanged: (val) =>
                    setState(() => _tieneDictamenCosie = val),
              ),
              if (_tieneDictamenCosie || esDebajoMinima) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerTint,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.dangerBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.guinda,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Atención: Al contar con dictamen${esDebajoMinima ? ' o reinscribirte por debajo de la carga mínima' : ''}, '
                          'necesitarás subir en el siguiente paso tus dictámenes emitidos (ya sea de Consejo Técnico CT, Consejo General CG o ambos).',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 2. Semestre, Carga y Promedio SAES
        GescoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TituloBloque(texto: 'Inscripción y Carga Académica'),
              const SizedBox(height: AppSpacing.md),

              // Semestre a cursar
              GescoSelect<String>(
                label: 'Semestre a cursar',
                value: _semestreACursar,
                opciones: const [
                  '1ero',
                  '2do',
                  '3ero',
                  '4to',
                  '5to',
                  '6to',
                  '7mo',
                  '8vo',
                  '9no',
                  '10mo',
                ],
                helperText:
                    'Ojo: El semestre a cursar siempre es el semestre más alto que estás inscribiendo.',
                onChanged: (val) {
                  if (val != null) setState(() => _semestreACursar = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Carga con la que se reinscribe
              GescoSelect<String>(
                label: 'Carga académica con la que te reinscribes',
                value: _cargaReinscripcion,
                opciones: const [
                  'Debajo de la mínima',
                  'Mínima',
                  'Por encima de la mínima',
                  'Debajo de la media',
                  'Media',
                  'Por encima de la media',
                  'Máxima',
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _cargaReinscripcion = val);
                },
              ),

              // Banner de advertencia si la carga es por debajo de la mínima
              if (esDebajoMinima) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerTint,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.dangerBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.guinda,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Atención: Al reinscribirte por debajo de la carga mínima, '
                          'necesitarás subir el oficio de inscripción por debajo de la mínima '
                          'y el dictamen emitido por el COSIE o CT en el siguiente paso.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Promedio del SAES
              GescoTextField(
                label: 'Promedio del SAES',
                controller: _promedioSaesController,
                hintText: 'Ej. 8.75',
                isRequired: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                helperText:
                    'Ingresa tu promedio acumulado registrado en el SAES.',
              ),
            ],
          ),
        ),
        // 3. Adeudos / Materias adeudadas (Solo si la situación es Irregular)
        if (_esIrregular) ...[
          const SizedBox(height: AppSpacing.md),
          GescoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TituloBloque(texto: 'Materias adeudadas'),
                const SizedBox(height: AppSpacing.sm),
                BloqueAdeudos(
                  adeudos: _adeudos,
                  onAgregar: _agregarAdeudo,
                  onQuitar: _quitarAdeudo,
                  textoVacio:
                      'No debes ninguna materia registrada. Si reprobaste alguna '
                      'y no aparece aquí, agrégala antes de continuar.',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _mostrarDialogoAgregarDictamen() {
    String tipo = 'Consejo Técnico (CT)';
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar dictamen de COSIE'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecciona el órgano que emite el dictamen y el motivo o descripción (opcional).',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            StatefulBuilder(
              builder: (ctx, setDialogState) => GescoSelect<String>(
                label: 'Tipo de dictamen',
                value: tipo,
                opciones: const [
                  'Consejo Técnico (CT)',
                  'Consejo General (CG)',
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => tipo = val);
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GescoTextField(
              label: 'Motivo / Trámite (Opcional)',
              controller: motivoController,
              hintText: 'Ej. Carga mínima, Extensión de tiempo, Recurso',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.guinda,
              foregroundColor: AppColors.onGuinda,
            ),
            onPressed: () {
              final nuevoId =
                  'doc-dictamen-${DateTime.now().millisecondsSinceEpoch}';
              final nuevoTipo = tipo.contains('General') ? 'CG' : 'CT';
              final motivo = motivoController.text.trim();

              setState(() {
                _dictamenesAgregados.add(
                  _DictamenEntrada(
                    id: nuevoId,
                    tipo: nuevoTipo,
                    motivo: motivo.isNotEmpty
                        ? motivo
                        : (nuevoTipo == 'CG'
                            ? 'Consejo General'
                            : 'Consejo Técnico'),
                  ),
                );
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Agregar dictamen'),
          ),
        ],
      ),
    );
  }

  void _eliminarDictamen(String id) {
    if (_dictamenesAgregados.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes conservar al menos un dictamen.'),
        ),
      );
      return;
    }
    setState(() {
      _dictamenesAgregados.removeWhere((d) => d.id == id);
      _documentosSubidos.remove(id);
    });
  }

  // --- Paso 3: documentos ---------------------------------------------------

  Widget _pasoDocumentos() {
    final dictamenAplica = _tieneDictamenCosie ||
        _cargaReinscripcion == 'Debajo de la mínima';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Intro(
          titulo: 'Lo que tienes que entregar',
          texto: 'Solo los que te tocan según tu situación. Puedes adjuntar '
              'múltiples dictámenes de COSIE (CT / CG) si cuentas con más de uno.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _BloqueDocumentos(
          tramite: _tramiteActual,
          onSubir: _subir,
          onAgregarDictamen: _mostrarDialogoAgregarDictamen,
          onEliminarDictamen: _eliminarDictamen,
          dictamenAplica: dictamenAplica,
        ),
      ],
    );
  }

  // --- Paso 4: revisar y generar --------------------------------------------

  Widget _pasoRevisar(bool compacto) {
    final vistaPreviaWidget = _VistaPrevia(
      domicilio: _domicilioControllers,
      provieneDeBaja: _provieneDeBaja,
      provieneDeCambioPrograma: _provieneDeCambioPrograma,
      esIrregular: _esIrregular,
      tieneDictamenCosie: _tieneDictamenCosie,
      semestre: _semestreACursar,
      carga: _cargaReinscripcion,
      promedio: _promedioSaesController.text,
      trabaja: (DatosDemo.datosPersonales['¿Trabajas?'] ?? 'No') == 'Sí',
      horarioTrabajo: _horarioTrabajoController.text,
      datosTrabajo: _datosTrabajoController.text,
      tutorNombre: _mismoTutor
          ? (DatosDemo.datosTutor['Nombre del tutor'] ?? 'Tutor registrado')
          : '${_tutorControllers['Nombre(s)']?.text ?? ''} ${_tutorControllers['Apellido paterno']?.text ?? ''} ${_tutorControllers['Apellido materno']?.text ?? ''}',
      tutorParentesco: _mismoTutor
          ? (DatosDemo.datosTutor['Parentesco'] ?? 'MADRE')
          : _tutorParentesco,
      tutorTelefono: _mismoTutor
          ? (DatosDemo.datosTutor['Teléfono del tutor'] ?? '492 921 5544')
          : (_tutorControllers['Teléfono celular']?.text ?? '492 921 5544'),
      mismoTutor: _mismoTutor,
    );

    final instruccionesWidget = _InstruccionesImpresion(
      acepto: _instruccionesAceptadas,
      onChanged: (val) => setState(() => _instruccionesAceptadas = val),
    );

    if (compacto) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          vistaPreviaWidget,
          const SizedBox(height: AppSpacing.md),
          instruccionesWidget,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: vistaPreviaWidget),
        const SizedBox(width: AppSpacing.lg),
        Expanded(flex: 2, child: instruccionesWidget),
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
    this.opciones,
  });

  final String campo;
  final String valor;
  final TextEditingController? control;
  final VoidCallback onCorregir;
  final VoidCallback onCancelar;
  final List<String>? opciones;

  @override
  Widget build(BuildContext context) {
    final editando = control != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: editando
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (opciones != null && opciones!.isNotEmpty)
                  GescoSelect<String>(
                    label: campo,
                    value: control!.text.isNotEmpty ? control!.text : valor,
                    opciones: opciones!,
                    onChanged: (val) {
                      if (val != null) {
                        control!.text = val;
                      }
                    },
                    helperText: 'Antes: $valor',
                  )
                else
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

class _InstruccionesImpresion extends StatelessWidget {
  const _InstruccionesImpresion({
    required this.acepto,
    required this.onChanged,
  });

  final bool acepto;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      color: AppColors.surface,
      colorBorde: AppColors.guinda.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.guinda.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.print_rounded,
                  color: AppColors.guinda,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Instrucciones de revisión e impresión',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _PuntoInstruccion(
            numero: '1',
            titulo: 'Envío a revisión',
            texto:
                'Al generar tu solicitud, el documento será enviado automáticamente '
                'a revisión por el departamento de Gestión Escolar.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _PuntoInstruccion(
            numero: '2',
            titulo: 'Guarda tu archivo PDF',
            texto:
                'Es muy importante que guardes y conserves este archivo PDF en '
                'tu dispositivo para cualquier consulta o trámite futuro.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _PuntoInstruccion(
            numero: '3',
            titulo: 'Imprime 2 copias en hoja carta',
            texto:
                'Toda la solicitud de reinscripción cabe en 1 sola hoja de máquina (tamaño carta). '
                'Imprime 2 copias del documento: una copia es para la ventanilla de Gestión Escolar '
                'y la otra se queda como tu comprobante sellado.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _PuntoInstruccion(
            numero: '4',
            titulo: 'Entrega presencial',
            texto:
                'Entrega tus copias impresas en físico en ventanilla el día que te corresponda '
                'según el calendario de recepción de documentos.',
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.md),

          // Casilla de confirmación requerida
          InkWell(
            onTap: () => onChanged(!acepto),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: acepto ? AppColors.successTint : AppColors.ground,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: acepto ? AppColors.successBorder : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: acepto,
                    activeColor: AppColors.guinda,
                    onChanged: (val) => onChanged(val ?? false),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'He leído las instrucciones de impresión, verificado que mis datos son correctos y estoy enterado(a) del proceso.',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: acepto ? AppColors.successInk : AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PuntoInstruccion extends StatelessWidget {
  const _PuntoInstruccion({
    required this.numero,
    required this.titulo,
    required this.texto,
  });

  final String numero;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.guinda,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            numero,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onGuinda,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                texto,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.inkSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Los documentos del trámite, con el botón de subir aquí mismo.
///
/// Esto es lo que reemplaza la sección aparte de "Subir documentos" del GESCO
/// actual: en vez de ocho documentos sueltos en otra pestaña, los tres que te
/// tocan, junto al botón que genera el PDF.
class _BloqueDocumentos extends StatelessWidget {
  const _BloqueDocumentos({
    required this.tramite,
    required this.onSubir,
    this.onAgregarDictamen,
    this.onEliminarDictamen,
    this.dictamenAplica = false,
  });

  final Tramite tramite;
  final void Function(Documento) onSubir;
  final VoidCallback? onAgregarDictamen;
  final void Function(String)? onEliminarDictamen;
  final bool dictamenAplica;

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
            'Solo los que te tocan, según tu situación. Puedes adjuntar múltiples dictámenes de COSIE si cuentas con más de uno.',
            style: AppTypography.hint,
          ),
          const SizedBox(height: AppSpacing.md),

          for (final d in aplican) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: FilaDocumento(
                      documento: d,
                      onSubir: () => onSubir(d),
                      compacta: true,
                    ),
                  ),
                  if (d.id.startsWith('doc-dictamen-') &&
                      onEliminarDictamen != null &&
                      aplican.where((doc) => doc.id.startsWith('doc-dictamen-')).length > 1) ...[
                    const SizedBox(width: AppSpacing.xs),
                    IconButton(
                      tooltip: 'Eliminar dictamen',
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.danger, size: 20),
                      onPressed: () => onEliminarDictamen!(d.id),
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (dictamenAplica && onAgregarDictamen != null) ...[
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton.icon(
              onPressed: onAgregarDictamen,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Agregar otro dictamen de COSIE (CT / CG)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.guinda,
                side: const BorderSide(color: AppColors.guinda),
              ),
            ),
          ],

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
                        : 'Genera el PDF cuando todos los documentos requeridos estén cargados o aprobados.',
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
  const _VistaPrevia({
    required this.domicilio,
    required this.provieneDeBaja,
    required this.provieneDeCambioPrograma,
    required this.esIrregular,
    required this.tieneDictamenCosie,
    required this.semestre,
    required this.carga,
    required this.promedio,
    required this.trabaja,
    required this.horarioTrabajo,
    required this.datosTrabajo,
    required this.tutorNombre,
    required this.tutorParentesco,
    required this.tutorTelefono,
    required this.mismoTutor,
  });

  final Map<String, TextEditingController> domicilio;
  final bool provieneDeBaja;
  final bool provieneDeCambioPrograma;
  final bool esIrregular;
  final bool tieneDictamenCosie;
  final String semestre;
  final String carga;
  final String promedio;
  final bool trabaja;
  final String horarioTrabajo;
  final String datosTrabajo;
  final String tutorNombre;
  final String tutorParentesco;
  final String tutorTelefono;
  final bool mismoTutor;

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
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
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
            child: _HojaUnica(widget: this),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Página 1 de 1 · Documento oficial de reinscripción',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HojaUnica extends StatelessWidget {
  const _HojaUnica({required this.widget});

  final _VistaPrevia widget;

  @override
  Widget build(BuildContext context) {
    final calle = widget.domicilio['Calle']?.text.toUpperCase() ??
        DatosDemo.domicilioActual['Calle']?.toUpperCase() ??
        '';
    final noExt = widget.domicilio['N° ext']?.text.toUpperCase() ??
        DatosDemo.domicilioActual['N° ext']?.toUpperCase() ??
        '';
    final noInt = widget.domicilio['N° int']?.text.toUpperCase() ??
        DatosDemo.domicilioActual['N° int']?.toUpperCase() ??
        '';
    final colonia = widget.domicilio['Colonia']?.text.toUpperCase() ??
        DatosDemo.domicilioActual['Colonia']?.toUpperCase() ??
        '';
    final cp = widget.domicilio['C.P.']?.text.toUpperCase() ??
        DatosDemo.domicilioActual['C.P.']?.toUpperCase() ??
        '';
    final municipio = widget.domicilio['Municipio']?.text.toUpperCase() ??
        DatosDemo.domicilioActual['Municipio']?.toUpperCase() ??
        '';
    final estado = widget.domicilio['Estado']?.text.toUpperCase() ??
        DatosDemo.domicilioActual['Estado']?.toUpperCase() ??
        '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Encabezado
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IpnLogo(height: 38, onDark: false),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'INSTITUTO POLITÉCNICO NACIONAL\n'
                    'UNIDAD PROFESIONAL INTERDISCIPLINARIA DE INGENIERÍA\n'
                    'CAMPUS ZACATECAS',
                    textAlign: TextAlign.center,
                    style: _serif(8.5, peso: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Subdirección de Servicios Educativos e Integración Social\n'
                    'DEPARTAMENTO DE GESTIÓN ESCOLAR',
                    textAlign: TextAlign.center,
                    style: _serif(7, peso: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'SOLICITUD DE REINSCRIPCIÓN',
                    textAlign: TextAlign.center,
                    style: _serif(9, peso: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 48,
              height: 58,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF666666), width: 0.8),
                color: const Color(0xFFF5F5F5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 24,
                    color: Color(0xFF777777),
                  ),
                  Text(
                    'FOTO ALUMNO',
                    textAlign: TextAlign.center,
                    style: _serif(4.5, peso: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // 1. DATOS ESCOLARES DEL ALUMNO
        _CampoDoc(etiqueta: 'NO. DE BOLETA', valor: DatosDemo.boleta),
        _CampoDoc(
          etiqueta: 'PROGRAMA ACADÉMICO',
          valor: DatosDemo.carrera.toUpperCase(),
        ),
        Row(
          children: [
            Expanded(
              child: _CampoDoc(etiqueta: 'CURP', valor: 'MARA040908MDFRYS01'),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _CampoDoc(etiqueta: 'RFC', valor: 'MARA0409081H2'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _CampoDoc(etiqueta: 'GRUPO', valor: DatosDemo.grupo),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _CampoDoc(etiqueta: 'TURNO', valor: 'MATUTINO'),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: _CampoDoc(
                etiqueta: 'PERIODO LECTIVO',
                valor:
                    '${DatosDemo.periodoActual} (${DatosDemo.periodoLegible.toUpperCase()})',
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),
        Center(
          child: Text(
            'DATOS GENERALES DEL ALUMNO',
            style: _serif(8.5, peso: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 3),
        const _FilaCampos(
          valores: ['MARTÍNEZ', 'REYES', 'ANA'],
          etiquetas: ['APELLIDO PATERNO', 'APELLIDO MATERNO', 'NOMBRE(S)'],
        ),
        const SizedBox(height: 3),
        const _FilaCampos(
          valores: ['08 / 09 / 2004', 'ZACATECAS', 'FEMENINO', 'SOLTERO/A'],
          etiquetas: [
            'FECHA DE NACIMIENTO',
            'LUGAR DE NACIMIENTO',
            'GÉNERO',
            'ESTADO CIVIL'
          ],
          pesos: [2, 2, 2, 2],
        ),
        const SizedBox(height: 3),
        _FilaCampos(
          valores: [calle, noExt, noInt.isEmpty ? '-' : noInt, cp],
          etiquetas: ['CALLE', 'NO. EXT', 'NO. INT', 'C.P.'],
          pesos: [3, 1, 1, 1],
        ),
        const SizedBox(height: 3),
        _FilaCampos(
          valores: [colonia, municipio, estado],
          etiquetas: ['COLONIA', 'MUNICIPIO', 'ESTADO'],
          pesos: [2, 2, 2],
        ),
        const SizedBox(height: 3),
        _FilaCampos(
          valores: [
            '492 100 2030',
            '492 955 1010',
            'amartinez@ipn.mx',
          ],
          etiquetas: [
            'TELÉFONO CELULAR',
            'TELÉFONO FIJO',
            'CORREO INSTITUCIONAL'
          ],
          pesos: [2, 2, 3],
        ),
        const SizedBox(height: 3),
        _FilaCampos(
          valores: [
            widget.trabaja ? 'SÍ' : 'NO',
            widget.trabaja ? widget.horarioTrabajo.toUpperCase() : 'N/A',
            widget.trabaja ? widget.datosTrabajo.toUpperCase() : 'N/A',
          ],
          etiquetas: ['¿TRABAJA?', 'HORARIO DE TRABAJO', 'DATOS DEL EMPLEADOR'],
          pesos: [1, 2, 3],
        ),

        const SizedBox(height: 6),
        Center(
          child: Text(
            'SITUACIÓN ACADÉMICA Y CARGA',
            style: _serif(8.5, peso: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 3),
        _FilaCampos(
          valores: [
            widget.esIrregular ? 'IRREGULAR (DESPUÉS DE ETS)' : 'REGULAR',
            widget.provieneDeBaja ? 'SÍ' : 'NO',
            widget.provieneDeCambioPrograma ? 'SÍ' : 'NO',
            (widget.tieneDictamenCosie || widget.carga == 'Debajo de la mínima')
                ? 'SÍ'
                : 'NO',
          ],
          etiquetas: [
            'SITUACIÓN',
            '¿BAJA PREVIA?',
            '¿CAMBIO PROGRAMA?',
            '¿DICTAMEN COSIE?'
          ],
          pesos: [2, 1, 1, 1],
        ),
        const SizedBox(height: 3),
        _FilaCampos(
          valores: [
            widget.semestre.toUpperCase(),
            widget.carga.toUpperCase(),
            '30 CRÉDITOS',
            widget.promedio,
          ],
          etiquetas: ['SEMESTRE', 'CARGA', 'TOTAL CRÉDITOS', 'PROMEDIO SAES'],
          pesos: [1, 2, 1, 1],
        ),

        if (widget.esIrregular && DatosDemo.adeudos.isNotEmpty) ...[
          const SizedBox(height: 3),
          _FilaCampos(
            valores: [
              for (final a in DatosDemo.adeudos)
                '${a.unidadAprendizaje.toUpperCase()} (${a.estado})',
            ],
            etiquetas: [
              for (final a in DatosDemo.adeudos)
                'MATERIA ADEUDADA (${a.periodoReprobada})',
            ],
          ),
        ],

        const SizedBox(height: 6),
        Center(
          child: Text(
            'DATOS DEL TUTOR O REPRESENTANTE LEGAL',
            style: _serif(8.5, peso: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 3),
        _FilaCampos(
          valores: [
            widget.tutorNombre.toUpperCase(),
            widget.tutorParentesco.toUpperCase(),
            'HOGAR',
          ],
          etiquetas: ['NOMBRE DEL TUTOR', 'PARENTESCO', 'OCUPACIÓN'],
          pesos: [3, 2, 2],
        ),
        const SizedBox(height: 3),
        _FilaCampos(
          valores: [
            widget.tutorTelefono,
            '492 921 5544',
            'rosa.reyes@gmail.com',
          ],
          etiquetas: [
            'TELÉFONO CELULAR',
            'TELÉFONO FIJO/TRABAJO',
            'CORREO DEL TUTOR'
          ],
          pesos: [2, 2, 3],
        ),
        const SizedBox(height: 3),
        _FilaCampos(
          valores: [
            widget.mismoTutor
                ? 'SÍ, VIVE EN EL MISMO DOMICILIO QUE EL ALUMNO'
                : 'DOMICILIO REGISTRADO DEL TUTOR',
            'ZACATECAS',
          ],
          etiquetas: ['DOMICILIO DEL TUTOR', 'ESTADO/MUNICIPIO'],
          pesos: [4, 2],
        ),

        const SizedBox(height: AppSpacing.md),

        // Firmas y Sello Oficial
        Center(
          child: Text(
            'VALIDACIÓN Y RECEPCIÓN OFICIAL',
            style: _serif(8.5, peso: FontWeight.w800),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  Container(height: 0.8, color: const Color(0xFF444444)),
                  const SizedBox(height: 3),
                  Text(
                    'FIRMA DEL ALUMNO',
                    textAlign: TextAlign.center,
                    style: _serif(6.5, peso: FontWeight.w800),
                  ),
                  Text(
                    DatosDemo.nombreAlumno.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: _serif(5.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  Container(height: 0.8, color: const Color(0xFF444444)),
                  const SizedBox(height: 3),
                  Text(
                    'VO.BO. GESTIÓN ESCOLAR',
                    textAlign: TextAlign.center,
                    style: _serif(6.5, peso: FontWeight.w800),
                  ),
                  Text(
                    'VENTANILLA DE REINSCRIPCIONES',
                    textAlign: TextAlign.center,
                    style: _serif(5.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 105,
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF888888), width: 0.8),
                color: const Color(0xFFFAFAFA),
              ),
              padding: const EdgeInsets.all(3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 18,
                    color: Color(0xFF888888),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'SELLO OFICIAL VENTANILLA',
                    textAlign: TextAlign.center,
                    style: _serif(5, peso: FontWeight.w800),
                  ),
                  Text(
                    'GESTIÓN ESCOLAR UPIIZ',
                    textAlign: TextAlign.center,
                    style: _serif(4.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CampoDoc extends StatelessWidget {
  const _CampoDoc({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
