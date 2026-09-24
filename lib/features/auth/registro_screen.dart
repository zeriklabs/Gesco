import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/gesco_text_field.dart';

/// Los seis pasos del alta.
///
/// En el GESCO actual, crear la cuenta y llenar el expediente son dos procesos
/// desconectados: el alumno crea cuenta, entra, y ahí se entera de que todavía
/// le faltan cuatro pantallas de datos. Aquí es un solo recorrido.
enum PasoRegistro {
  cuenta('Crear tu cuenta', 'Boleta, correo y contraseña'),
  correo('Verificar tu correo', 'Te llega un código de 6 dígitos'),
  personales('Datos personales', 'CURP, domicilio y contacto'),
  tutor('Datos del tutor', 'Quién responde por ti'),
  generales('Datos generales', 'Una pregunta: ¿trabajas?'),
  escolares('Datos escolares', 'Carrera, grupo y carga');

  const PasoRegistro(this.titulo, this.descripcion);

  final String titulo;
  final String descripcion;

  int get numero => index + 1;
  static int get total => PasoRegistro.values.length;
}

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  PasoRegistro _paso = PasoRegistro.cuenta;

  final _formCuenta = GlobalKey<FormState>();
  final _boleta = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  bool _aceptaAviso = false;

  @override
  void dispose() {
    _boleta.dispose();
    _correo.dispose();
    _password.dispose();
    _password2.dispose();
    super.dispose();
  }

  void _continuar() {
    if (_paso == PasoRegistro.cuenta) {
      if (!_formCuenta.currentState!.validate()) return;
      if (!_aceptaAviso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falta aceptar el aviso de privacidad'),
          ),
        );
        return;
      }
    }

    final siguiente = _paso.index + 1;
    if (siguiente >= PasoRegistro.total) return;
    setState(() => _paso = PasoRegistro.values[siguiente]);
  }

  void _regresar() {
    if (_paso.index == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _paso = PasoRegistro.values[_paso.index - 1]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: context.hasSidebar ? _escritorio() : _celular(),
    );
  }

  // --- Escritorio ----------------------------------------------------------

  Widget _escritorio() {
    return Row(
      children: [
        // Proporción en vez de 420 px fijos, por lo mismo que el login.
        Expanded(flex: 4, child: _RielPasos(actual: _paso)),
        Expanded(
          flex: 7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl + AppSpacing.xs,
                  AppSpacing.xxl,
                  AppSpacing.xxl + AppSpacing.xs,
                  0,
                ),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta?',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl + AppSpacing.xs,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: _contenidoPaso(),
                    ),
                  ),
                ),
              ),
              _barraInferior(compacta: false),
            ],
          ),
        ),
      ],
    );
  }

  // --- Celular -------------------------------------------------------------

  Widget _celular() {
    return Column(
      children: [
        Container(
          color: AppColors.guinda,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _regresar,
                        tooltip: 'Volver',
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.onGuinda,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PASO ${_paso.numero} DE ${PasoRegistro.total}',
                              style: AppTypography.overline
                                  .copyWith(color: AppColors.dorado),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _paso.titulo,
                              style: AppTypography.displayMedium.copyWith(
                                fontSize: 21,
                                color: AppColors.onGuinda,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BarraProgreso(actual: _paso),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.gutterMobile),
            child: _contenidoPaso(compacto: true),
          ),
        ),
        _barraInferior(compacta: true),
      ],
    );
  }

  // --- Contenido -----------------------------------------------------------

  Widget _contenidoPaso({bool compacto = false}) {
    return switch (_paso) {
      PasoRegistro.cuenta => _pasoCuenta(compacto: compacto),
      _ => _PasoPendiente(paso: _paso),
    };
  }

  Widget _pasoCuenta({required bool compacto}) {
    return Form(
      key: _formCuenta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compacto) ...[
            Text(
              'PASO ${_paso.numero} DE ${PasoRegistro.total}',
              style: AppTypography.overline.copyWith(color: AppColors.guinda),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Crea tu cuenta', style: AppTypography.displayLarge),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            'Usa el correo que revisas de verdad: ahí te avisamos cuando '
            'Gestión Escolar apruebe o rechace algo.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),

          GescoTextField(
            label: 'Boleta o preboleta',
            controller: _boleta,
            hintText: '2023670029',
            helperText:
                'Si eres de nuevo ingreso usa tu preboleta con guion: PE-12345678.',
            isRequired: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(11),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z\-]')),
            ],
            textInputAction: TextInputAction.next,
            validator: Validators.boleta,
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoTextField(
            label: 'Correo electrónico',
            controller: _correo,
            hintText: 'tucorreo@gmail.com',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.correo,
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoPasswordField(
            label: 'Contraseña',
            controller: _password,
            validator: Validators.contrasena,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),

          GescoPasswordField(
            label: 'Confirmar contraseña',
            controller: _password2,
            validator: (v) =>
                Validators.confirmarContrasena(v, _password.text),
          ),
          const SizedBox(height: AppSpacing.md),

          _ReglasContrasena(valor: _password.text),
          const SizedBox(height: AppSpacing.lg),

          InkWell(
            onTap: () => setState(() => _aceptaAviso = !_aceptaAviso),
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _aceptaAviso,
                  onChanged: (v) => setState(() => _aceptaAviso = v ?? false),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 11),
                    child: Text.rich(
                      TextSpan(
                        text: 'Acepto que la UPIIZ trate mis datos para fines '
                            'de gestión escolar. ',
                        children: [
                          TextSpan(
                            text: 'Aviso de privacidad',
                            style: TextStyle(
                              color: AppColors.guinda,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      style: AppTypography.bodyMedium
                          .copyWith(fontSize: 13.5, height: 1.5),
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

  Widget _barraInferior({required bool compacta}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        compacta ? AppSpacing.gutterMobile : 56,
        AppSpacing.md,
        compacta ? AppSpacing.gutterMobile : 56,
        compacta ? AppSpacing.xl : AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: compacta
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continuar,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continuar'),
                      SizedBox(width: AppSpacing.xs),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  // La barra de progreso es lo primero que se sacrifica si no
                  // hay ancho: los botones no se pueden perder, ella sí.
                  final cabeLaBarra = constraints.maxWidth >= 620;
                  return Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _regresar,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Volver'),
                      ),
                      if (cabeLaBarra) ...[
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: _BarraProgreso(
                              actual: _paso,
                              sobreClaro: true,
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _continuar,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Continuar'),
                            SizedBox(width: AppSpacing.xs),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

/// El riel vertical de pasos, en escritorio.
class _RielPasos extends StatelessWidget {
  const _RielPasos({required this.actual});

  final PasoRegistro actual;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.guinda,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl + AppSpacing.xs,
                    vertical: AppSpacing.xxl + AppSpacing.xs,
                  ),
                  child: _contenidoRiel(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _contenidoRiel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          const BrandMark(logoHeight: 38),
          const SizedBox(height: AppSpacing.xxl + AppSpacing.xxs),
          for (final paso in PasoRegistro.values)
            _FilaPaso(
              paso: paso,
              actual: actual,
              esUltimo: paso == PasoRegistro.values.last,
            ),
          const Spacer(),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            decoration: BoxDecoration(
              color: AppColors.guindaDeep,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 16, color: AppColors.dorado),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Toma unos 8 minutos',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onGuinda,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Puedes salir cuando quieras: se guarda solo y regresas '
                  'donde te quedaste.',
                  style: AppTypography.hint
                      .copyWith(color: AppColors.onGuindaMuted, height: 1.5),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FilaPaso extends StatelessWidget {
  const _FilaPaso({
    required this.paso,
    required this.actual,
    required this.esUltimo,
  });

  final PasoRegistro paso;
  final PasoRegistro actual;
  final bool esUltimo;

  @override
  Widget build(BuildContext context) {
    final completado = paso.index < actual.index;
    final esActual = paso == actual;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: (completado || esActual)
                      ? AppColors.dorado
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: (completado || esActual)
                      ? null
                      : Border.all(
                          color: AppColors.overlayBorderOnGuinda,
                          width: 1.5,
                        ),
                ),
                alignment: Alignment.center,
                child: completado
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Color(0xFF3A2404))
                    : Text(
                        '${paso.numero}',
                        style: AppTypography.pill.copyWith(
                          fontSize: 12.5,
                          color: esActual
                              ? const Color(0xFF3A2404)
                              : AppColors.onGuindaFaint,
                        ),
                      ),
              ),
              if (!esUltimo)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: AppColors.overlayBorderOnGuinda,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md - 2),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: esUltimo ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paso.titulo,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: esActual
                          ? AppColors.onGuinda
                          : AppColors.onGuindaMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    paso.descripcion,
                    style: AppTypography.hint.copyWith(
                      color: AppColors.onGuindaFaint,
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

/// Barra segmentada de progreso: un tramo por paso.
class _BarraProgreso extends StatelessWidget {
  const _BarraProgreso({required this.actual, this.sobreClaro = false});

  final PasoRegistro actual;
  final bool sobreClaro;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final paso in PasoRegistro.values) ...[
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: paso.index <= actual.index
                    ? (sobreClaro ? AppColors.guinda : AppColors.dorado)
                    : (sobreClaro
                        ? AppColors.border
                        : AppColors.overlayOnGuinda),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          if (paso != PasoRegistro.values.last)
            const SizedBox(width: AppSpacing.xxs + 1),
        ],
      ],
    );
  }
}

class _ReglasContrasena extends StatelessWidget {
  const _ReglasContrasena({required this.valor});

  final String valor;

  @override
  Widget build(BuildContext context) {
    final reglas = <String, bool>{
      '8 caracteres': valor.length >= 8,
      'Una mayúscula': RegExp(r'[A-ZÁÉÍÓÚÑ]').hasMatch(valor),
      'Un número': RegExp(r'\d').hasMatch(valor),
    };

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.xs,
      children: [
        for (final MapEntry(key: texto, value: ok) in reglas.entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ok ? Icons.check_rounded : Icons.circle_outlined,
                size: 15,
                color: ok ? AppColors.success : AppColors.placeholder,
              ),
              const SizedBox(width: 6),
              Text(
                texto,
                style: AppTypography.hint.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ok ? AppColors.success : AppColors.placeholder,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Marcador para los pasos que todavía no se construyen.
class _PasoPendiente extends StatelessWidget {
  const _PasoPendiente({required this.paso});

  final PasoRegistro paso;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(paso.titulo, style: AppTypography.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${paso.descripcion}. Pantalla en construcción.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
