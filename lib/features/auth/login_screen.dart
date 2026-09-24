import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/gesco_text_field.dart';
import '../home/home_screen.dart';
import 'registro_screen.dart';

/// Entrada al sistema.
///
/// Un solo árbol de widgets para web y celular: lo que cambia con el ancho es
/// el layout (split de dos paneles vs. encabezado + hoja), nunca los colores
/// ni los estilos, que salen del tema.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _boleta = TextEditingController();
  final _password = TextEditingController();

  bool _cargando = false;
  bool _mantenerSesion = false;

  @override
  void dispose() {
    _boleta.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _cargando = true);
    // TODO(backend): aquí va la llamada real de autenticación.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _cargando = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _irARegistro() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistroScreen()),
    );
  }

  void _explicarBoleta() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Boleta y preboleta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Si ya estás inscrito', style: AppTypography.label),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Usa tu boleta definitiva, los 10 dígitos. Por ejemplo: 2023670029.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Si eres de nuevo ingreso', style: AppTypography.label),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Mientras no tengas boleta definitiva, entra con tu preboleta, '
              'con el guion incluido. Por ejemplo: PE-12345678.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: context.hasSidebar ? _construirEscritorio() : _construirCelular(),
    );
  }

  // --- Escritorio ----------------------------------------------------------

  Widget _construirEscritorio() {
    return Row(
      children: [
        // Proporción, no ancho fijo: con 600 px duros el formulario se quedaba
        // sin espacio en ventanas de ~1100 y las filas se desbordaban.
        const Expanded(flex: 5, child: _PanelMarca()),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl + AppSpacing.xs),
            child: Column(
              children: [
                // Wrap, no Row: si no cabe en una línea, baja el botón en vez
                // de desbordarse.
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '¿Eres del departamento?',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Acceso administrativo'),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSize.formMaxWidth,
                        ),
                        child: _formulario(compacto: false),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Celular -------------------------------------------------------------

  Widget _construirCelular() {
    return Container(
      color: AppColors.guinda,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutterMobile,
                AppSpacing.md,
                AppSpacing.gutterMobile,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(logoHeight: 32),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Tus trámites,\nsin dar ',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 36,
                      color: AppColors.onGuinda,
                      height: 1,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: Text(
                      'vueltas.',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 36,
                        color: AppColors.dorado,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sheet + 2),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutterMobile,
                    AppSpacing.xl,
                    AppSpacing.gutterMobile,
                    AppSpacing.xl,
                  ),
                  child: _formulario(compacto: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Compartido ----------------------------------------------------------

  Widget _formulario({required bool compacto}) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Iniciar sesión',
              style: compacto
                  ? AppTypography.displayMedium
                  : AppTypography.displayLarge.copyWith(fontSize: 42),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Con tu boleta del IPN.',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.xxl),

            GescoTextField(
              label: 'Boleta o preboleta',
              controller: _boleta,
              hintText: '2023670029',
              helperText: 'De nuevo ingreso: usa tu preboleta, '
                  'con guion incluido (PE-12345678).',
              isRequired: true,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                LengthLimitingTextInputFormatter(11),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z\-]')),
              ],
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              validator: Validators.boleta,
              trailingAction: TextButton.icon(
                onPressed: _explicarBoleta,
                icon: const Icon(Icons.help_outline_rounded, size: 16),
                label: const Text('¿Cuál es la mía?'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: AppTypography.hint.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            GescoPasswordField(
              label: 'Contraseña',
              controller: _password,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _entrar(),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Escribe tu contraseña'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Sin Spacer: el Spacer se come todo el ancho disponible y empuja
            // al botón fuera cuando el espacio es justo.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => _mantenerSesion = !_mantenerSesion),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _mantenerSesion,
                        onChanged: (v) =>
                            setState(() => _mantenerSesion = v ?? false),
                      ),
                      Text(
                        'Mantener sesión',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                  child: const Text('Olvidé mi contraseña'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cargando ? null : _entrar,
                child: _cargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.onGuinda,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Entrar'),
                          SizedBox(width: AppSpacing.xs),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            _TarjetaCrearCuenta(onPressed: _irARegistro, compacta: compacto),
          ],
        ),
      ),
    );
  }
}

/// El panel guinda de la izquierda en escritorio.
class _PanelMarca extends StatelessWidget {
  const _PanelMarca();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.guinda,
      // Scroll de seguridad: en una laptop de pantalla corta este panel no
      // cabe de alto, y sin esto se desborda por abajo.
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxl,
                    vertical: AppSpacing.xxxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandMark(
                        logoHeight: 44,
                        subtitulo: 'UPIIZ · Zacatecas',
                      ),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          text: 'Tus trámites,\nsin dar\n',
                          children: [
                            TextSpan(
                              text: 'vueltas.',
                              style: TextStyle(color: AppColors.dorado),
                            ),
                          ],
                        ),
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          height: 0.98,
                          color: AppColors.onGuinda,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Departamento de Gestión Escolar de la Unidad '
                        'Interdisciplinaria de Ingeniería.',
                        style: AppTypography.bodyLarge.copyWith(
                          height: 1.6,
                          color: AppColors.onGuindaMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const _Ventaja(
                        icono: Icons.description_outlined,
                        titulo: 'Genera tus solicitudes en línea',
                        detalle: 'Reinscripción, dictamen, bajas y GE-01.',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _Ventaja(
                        icono: Icons.upload_outlined,
                        titulo: 'Sube tus documentos desde el celular',
                        detalle: 'Y checa si ya te los aprobaron.',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _Ventaja(
                        icono: Icons.schedule_rounded,
                        titulo: 'Capturas tus datos una sola vez',
                        detalle: 'Todos los trámites los reutilizan.',
                      ),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'gescolar-upiiz@ipn.mx · 492 92 55 998 ext. 83514\n'
                        '© 2026 UPIIZ · Instituto Politécnico Nacional',
                        style: AppTypography.hint.copyWith(
                          color: AppColors.onGuindaFaint,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Ventaja extends StatelessWidget {
  const _Ventaja({
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.overlayOnGuinda,
            borderRadius: BorderRadius.circular(AppRadius.sm - 1),
          ),
          child: Icon(icono, size: 17, color: AppColors.dorado),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onGuinda,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detalle,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.onGuindaMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TarjetaCrearCuenta extends StatelessWidget {
  const _TarjetaCrearCuenta({required this.onPressed, required this.compacta});

  final VoidCallback onPressed;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final texto = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '¿Primera vez en GESCO?',
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Creas tu cuenta y llenas tus datos en un solo paso guiado.',
          style: AppTypography.bodySmall.copyWith(fontSize: 13),
        ),
      ],
    );

    final boton = OutlinedButton(
      onPressed: onPressed,
      child: const Text('Crear cuenta'),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      // No basta con mirar si estamos en celular: en escritorio esta tarjeta
      // también se queda sin ancho. Decide con el espacio real que le tocó.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cabeEnUnaFila = !compacta && constraints.maxWidth >= 400;
          if (cabeEnUnaFila) {
            return Row(
              children: [
                Expanded(child: texto),
                const SizedBox(width: AppSpacing.md),
                boton,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              texto,
              const SizedBox(height: AppSpacing.sm),
              boton,
            ],
          );
        },
      ),
    );
  }
}
