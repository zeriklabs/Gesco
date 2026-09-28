import 'package:flutter/material.dart';

import '../../core/data/catalogos.dart';
import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/gesco_select.dart';
import '../../widgets/gesco_text_field.dart';
import 'nombre_oficial.dart';

/// Baja de la escuela: temporal o definitiva de la UPIIZ.
///
/// El cambio de fondo está al final de la pantalla. El formato actual tiene
/// **once preguntas de sí/no** para la documentación soporte —veintidós
/// controles para decir "ninguna"—, y todas piden lo mismo: marca lo que
/// aplique a tu caso. Aquí son once casillas y ya.
///
/// Lo demás que trae: el último nivel y el último grupo salen del expediente
/// en vez de volver a preguntarse, y el número de oficio solo aparece si el
/// alumno dice que ya tuvo una baja antes.
class BajaEscuelaScreen extends StatefulWidget {
  const BajaEscuelaScreen({super.key});

  @override
  State<BajaEscuelaScreen> createState() => _BajaEscuelaScreenState();
}

class _BajaEscuelaScreenState extends State<BajaEscuelaScreen> {
  final _form = GlobalKey<FormState>();
  final _motivo = TextEditingController();
  final _oficio = TextEditingController();

  /// `true` = temporal. Empieza en temporal porque es la que más se pide y la
  /// que se puede deshacer; la definitiva conviene que sea una decisión.
  bool _temporal = true;

  bool _tuvoBajaAntes = false;
  DateTime _fecha = DateTime.now();

  final _soportes = <String>{};

  @override
  void dispose() {
    _motivo.dispose();
    _oficio.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(hoy.year - 1),
      lastDate: DateTime(hoy.year + 1),
      helpText: 'Fecha de la baja',
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  void _generar() {
    if (!(_form.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generando la solicitud de baja ${_temporal ? 'temporal' : 'definitiva'}…',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    final formulario = Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GescoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SeccionForm(titulo: 'Qué baja necesitas'),
                OpcionSiNo(
                  label: 'Tipo de baja',
                  value: _temporal,
                  etiquetaSi: 'Temporal',
                  etiquetaNo: 'Definitiva',
                  onChanged: (v) => setState(() => _temporal = v),
                  helperText: _temporal
                      ? 'Te vas por un tiempo y regresas. Al volver, tu '
                          'reinscripción te va a pedir el oficio de esta baja.'
                      : 'Dejas la UPIIZ. No hay regreso por esta vía: para '
                          'volver tendrías que hacer un nuevo ingreso.',
                ),
                const SizedBox(height: AppSpacing.md),
                _CampoFecha(fecha: _fecha, onTap: _elegirFecha),
                const SizedBox(height: AppSpacing.md),
                OpcionSiNo(
                  label: '¿Ya habías tramitado una baja antes?',
                  value: _tuvoBajaAntes,
                  onChanged: (v) => setState(() => _tuvoBajaAntes = v),
                ),
                // El campo del número de oficio solo tiene sentido si hubo una
                // baja previa. En el formato actual está siempre a la vista.
                if (_tuvoBajaAntes) ...[
                  const SizedBox(height: AppSpacing.md),
                  GescoTextField(
                    label: 'Número de oficio de esa baja',
                    controller: _oficio,
                    isRequired: true,
                    hintText: 'Viene en el oficio que te entregaron.',
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Escribe el número de oficio'
                        : null,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GescoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SeccionForm(titulo: 'Por qué'),
                GescoTextField(
                  label: 'Motivo de la solicitud',
                  controller: _motivo,
                  isRequired: true,
                  maxLines: 5,
                  hintText: 'Cuenta tu situación con tus palabras.',
                  helperText: 'Lo lee Gestión Escolar. Entre más claro, menos '
                      'vueltas.',
                  validator: (v) => (v == null || v.trim().length < 20)
                      ? 'Escribe al menos un par de renglones'
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                const SeccionForm(
                  titulo: 'Documentación que vas a entregar',
                  nota: 'Marca lo que aplique',
                ),
                Text(
                  'Marca lo que puedas comprobar. Si no marcas nada, la '
                  'solicitud se manda igual: no todos los casos traen papel.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.inkSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm + 2),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final m in Catalogos.motivosBajaEscuela)
                      _ChipSoporte(
                        texto: m,
                        marcado: _soportes.contains(m),
                        onTap: () => setState(() {
                          if (!_soportes.remove(m)) _soportes.add(m);
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final lateral = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TarjetaHistorial(),
        const SizedBox(height: AppSpacing.md),
        if (!_temporal)
          const BannerAviso(
            titulo: 'La baja definitiva no se deshace',
            mensaje: 'Si lo que necesitas es parar un tiempo y volver, la que '
                'te sirve es la temporal. Con la definitiva tendrías que '
                'entrar otra vez por nuevo ingreso.',
          )
        else
          const NombreOficial(
            nombre: 'Solicitud de baja de unidad académica',
            nota: '"Unidad académica" es como el IPN le dice a tu escuela.',
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Baja de la escuela'),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.onGuinda,
          fontSize: compacto ? 17 : 19,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        ),
        children: [
          if (compacto) ...[
            lateral,
            const SizedBox(height: AppSpacing.md),
            formulario,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: formulario),
                const SizedBox(width: AppSpacing.lg),
                Expanded(flex: 2, child: lateral),
              ],
            ),
        ],
      ),
      bottomNavigationBar: _PieBaja(
        temporal: _temporal,
        onGenerar: _generar,
      ),
    );
  }
}

/// La fecha, como campo con calendario.
class _CampoFecha extends StatelessWidget {
  const _CampoFecha({required this.fecha, required this.onTap});

  final DateTime fecha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Fecha de la baja',
            style: AppTypography.label,
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: AppColors.guinda)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              height: AppSize.fieldHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderStrong, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 17, color: AppColors.muted),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(_texto(fecha), style: AppTypography.input),
                  ),
                  const Icon(Icons.expand_more_rounded,
                      size: 20, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _texto(DateTime f) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${f.day} de ${meses[f.month - 1]} de ${f.year}';
  }
}

class _ChipSoporte extends StatelessWidget {
  const _ChipSoporte({
    required this.texto,
    required this.marcado,
    required this.onTap,
  });

  final String texto;
  final bool marcado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: marcado ? AppColors.dangerTint : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: marcado ? AppColors.guinda : AppColors.borderStrong,
              width: marcado ? 2 : 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                marcado
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 15,
                color: marcado ? AppColors.guinda : AppColors.placeholder,
              ),
              const SizedBox(width: 6),
              Text(
                texto,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: marcado ? FontWeight.w800 : FontWeight.w600,
                  color: marcado ? AppColors.guinda : AppColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Último nivel y último grupo, que ya están en el expediente.
class _TarjetaHistorial extends StatelessWidget {
  const _TarjetaHistorial();

  @override
  Widget build(BuildContext context) {
    const datos = [
      ('Último nivel', DatosDemo.ultimoNivel),
      ('Último grupo', DatosDemo.ultimoGrupo),
      ('Último periodo inscrito', DatosDemo.ultimoPeriodoInscrito),
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
          for (final (etiqueta, valor) in datos)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(child: Text(etiqueta, style: AppTypography.hint)),
                  Text(
                    valor,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
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

class _PieBaja extends StatelessWidget {
  const _PieBaja({required this.temporal, required this.onGenerar});

  final bool temporal;
  final VoidCallback onGenerar;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

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
              Expanded(
                child: Text(
                  temporal ? 'Baja temporal' : 'Baja definitiva',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: temporal ? AppColors.muted : AppColors.guinda,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: onGenerar,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('Generar solicitud'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
