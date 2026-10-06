import 'package:flutter/material.dart';

import '../../core/data/catalogos.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/brand_mark.dart';
import '../home/home_screen.dart';
import 'pasos/paso_correo.dart';
import 'pasos/paso_cuenta.dart';
import 'pasos/paso_escolares.dart';
import 'pasos/paso_foto.dart';
import 'pasos/paso_generales.dart';
import 'pasos/paso_personales.dart';
import 'pasos/paso_tutor.dart';
import 'registro_datos.dart';

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
  foto('Fotografía', 'Sube tu foto oficial de perfil'),
  escolares('Datos escolares', 'Carrera, grupo y carga');

  const PasoRegistro(this.titulo, this.descripcion);

  final String titulo;
  final String descripcion;

  int get numero => index + 1;
  bool get esUltimo => index == PasoRegistro.values.length - 1;

  static int get total => PasoRegistro.values.length;
}

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _datos = RegistroDatos();

  /// Un Form por paso: así cada uno valida lo suyo y nada más.
  late final _formKeys = {
    for (final paso in PasoRegistro.values) paso: GlobalKey<FormState>(),
  };

  PasoRegistro _paso = PasoRegistro.cuenta;

  @override
  void dispose() {
    _datos.dispose();
    super.dispose();
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Reglas que no caben en el validador de un solo campo.
  String? _reglaExtra(PasoRegistro paso) {
    return switch (paso) {
      PasoRegistro.cuenta =>
        _datos.aceptaAviso ? null : 'Falta aceptar el aviso de privacidad',
      PasoRegistro.correo => _datos.codigo.text.length == 6
          ? null
          : 'Escribe los 6 dígitos del código',
      _ => null,
    };
  }

  void _continuar() {
    final form = _formKeys[_paso]!.currentState;
    if (form != null && !form.validate()) return;

    final problema = _reglaExtra(_paso);
    if (problema != null) {
      _avisar(problema);
      return;
    }

    // El domicilio del tutor se copia al salir de datos personales, para que
    // el paso del tutor ya lo muestre resuelto.
    if (_paso == PasoRegistro.personales) {
      _datos.sincronizarDomicilioTutor();
      if (Catalogos.municipiosDe(_datos.estadoNacimientoDerivado).isEmpty) {
        _datos.municipioNacimiento = _datos.municipioNacimientoTextController.text;
      }
    }

    if (_paso.esUltimo) {
      _terminar();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _paso = PasoRegistro.values[_paso.index + 1]);
  }

  void _terminar() {
    // TODO(backend): aquí se manda el alta completa.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: const RouteSettings(name: '/home'),
      ),
      (_) => false,
    );
  }

  void _regresar() {
    if (_paso.index == 0) {
      Navigator.of(context).pop();
      return;
    }
    FocusScope.of(context).unfocus();
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl + AppSpacing.xs,
                    AppSpacing.lg,
                    AppSpacing.xxl + AppSpacing.xs,
                    AppSpacing.xxl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PASO ${_paso.numero} DE ${PasoRegistro.total}',
                            style: AppTypography.overline
                                .copyWith(color: AppColors.guinda),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(_paso.titulo, style: AppTypography.displayLarge),
                          const SizedBox(height: AppSpacing.md),
                          _contenidoPaso(),
                        ],
                      ),
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
                AppSpacing.md,
                AppSpacing.xs,
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
            child: _contenidoPaso(),
          ),
        ),
        _barraInferior(compacta: true),
      ],
    );
  }

  // --- Contenido -----------------------------------------------------------

  Widget _contenidoPaso() {
    final key = _formKeys[_paso]!;
    // La key del widget fuerza a que cada paso se reconstruya limpio cuando se
    // cambia de paso, en vez de heredar el estado del anterior.
    return KeyedSubtree(
      key: ValueKey(_paso),
      child: switch (_paso) {
        PasoRegistro.cuenta => PasoCuenta(datos: _datos, formKey: key),
        PasoRegistro.correo => PasoCorreo(datos: _datos, formKey: key),
        PasoRegistro.personales => PasoPersonales(datos: _datos, formKey: key),
        PasoRegistro.tutor => PasoTutor(datos: _datos, formKey: key),
        PasoRegistro.generales => PasoGenerales(datos: _datos, formKey: key),
        PasoRegistro.foto => PasoFoto(datos: _datos, formKey: key),
        PasoRegistro.escolares => PasoEscolares(datos: _datos, formKey: key),
      },
    );
  }

  Widget _barraInferior({required bool compacta}) {
    final textoBoton = _paso.esUltimo ? 'Terminar registro' : 'Continuar';
    final icono = _paso.esUltimo
        ? Icons.check_rounded
        : Icons.arrow_forward_rounded;

    return Container(
      padding: EdgeInsets.fromLTRB(
        compacta ? AppSpacing.gutterMobile : AppSpacing.xxl + AppSpacing.xs,
        AppSpacing.md,
        compacta ? AppSpacing.gutterMobile : AppSpacing.xxl + AppSpacing.xs,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: compacta
            ? Column(
                children: [
                  const _AvisoGuardado(),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _continuar,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(textoBoton),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(icono, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Si no hay ancho, lo primero que se va es la barra de
                  // progreso: los botones no se pueden perder.
                  final cabeLaBarra = constraints.maxWidth >= 640;
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
                            constraints: const BoxConstraints(maxWidth: 280),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(textoBoton),
                            const SizedBox(width: AppSpacing.xs),
                            Icon(icono, size: 18),
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

class _AvisoGuardado extends StatelessWidget {
  const _AvisoGuardado();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.save_outlined, size: 14, color: AppColors.muted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Se guarda solo: puedes salir y volver después',
            style: AppTypography.hint,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
                  child: _contenido(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _contenido() {
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
                  Expanded(
                    child: Text(
                      'Toma unos 8 minutos',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onGuinda,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Puedes salir cuando quieras: se guarda solo y regresas donde '
                'te quedaste.',
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
                    style: AppTypography.hint
                        .copyWith(color: AppColors.onGuindaFaint),
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
