import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../registro_datos.dart';

/// Verificación del correo con un código de 6 dígitos.
///
/// Sirve para dos cosas: que el correo exista de verdad (ahí van a llegar los
/// avisos de aprobación y rechazo) y que nadie dé de alta una boleta ajena.
class PasoCorreo extends StatefulWidget {
  const PasoCorreo({super.key, required this.datos, required this.formKey});

  final RegistroDatos datos;
  final GlobalKey<FormState> formKey;

  @override
  State<PasoCorreo> createState() => _PasoCorreoState();
}

class _PasoCorreoState extends State<PasoCorreo> {
  static const _segundosEspera = 45;

  final _campos = List.generate(6, (_) => TextEditingController());
  final _focos = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _restantes = _segundosEspera;

  @override
  void initState() {
    super.initState();
    _arrancarConteo();
    for (final f in _focos) {
      f.addListener(_alCambiarFoco);
    }
  }

  void _alCambiarFoco() => setState(() {});

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _campos) {
      c.dispose();
    }
    for (final f in _focos) {
      f.removeListener(_alCambiarFoco);
      f.dispose();
    }
    super.dispose();
  }

  void _arrancarConteo() {
    _timer?.cancel();
    setState(() => _restantes = _segundosEspera);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _restantes--);
      if (_restantes <= 0) t.cancel();
    });
  }

  void _alEscribir(int i, String valor) {
    // Pegar el código completo desde el correo: se reparte en las seis cajas.
    if (valor.length > 1) {
      final digitos = valor.replaceAll(RegExp(r'\D'), '');
      for (var j = 0; j < 6; j++) {
        _campos[j].text = j < digitos.length ? digitos[j] : '';
      }
      _focos[digitos.length.clamp(0, 5)].requestFocus();
      _guardar();
      return;
    }

    if (valor.isNotEmpty && i < 5) _focos[i + 1].requestFocus();
    if (valor.isEmpty && i > 0) _focos[i - 1].requestFocus();
    _guardar();
  }

  void _guardar() {
    widget.datos.codigo.text = _campos.map((c) => c.text).join();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final completo = widget.datos.codigo.text.length == 6;
    final correo = widget.datos.correo.text.isEmpty
        ? 'tu correo'
        : widget.datos.correo.text;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Mandamos un código de 6 dígitos a ',
              children: [
                TextSpan(
                  text: correo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const TextSpan(text: '. Revisa también el correo no deseado.'),
              ],
            ),
            style: AppTypography.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),

          LayoutBuilder(
            builder: (context, constraints) {
              // En pantallas angostas las seis cajas no caben a 56 px.
              final ancho = ((constraints.maxWidth - (5 * AppSpacing.xs)) / 6)
                  .clamp(38.0, 56.0)
                  .toDouble();
              return Row(
                children: [
                  for (var i = 0; i < 6; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.xs),
                    AnimatedScale(
                      scale: _focos[i].hasFocus ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        width: ancho,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _focos[i].hasFocus
                              ? AppColors.surface
                              : (completo
                                    ? AppColors.successTint
                                    : AppColors.ground),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: completo
                                ? AppColors.successBorder
                                : (_focos[i].hasFocus
                                      ? AppColors.guinda
                                      : (_campos[i].text.isNotEmpty
                                            ? AppColors.borderStrong
                                            : AppColors.border)),
                            width: _focos[i].hasFocus ? 2.0 : 1.5,
                          ),
                          boxShadow: _focos[i].hasFocus
                              ? [
                                  const BoxShadow(
                                    color: AppColors.focusGlow,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: _campos[i],
                            focusNode: _focos[i],
                            autofocus: i == 0,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AppTypography.numeral.copyWith(
                              fontSize: 26,
                              color: completo
                                  ? AppColors.successInk
                                  : AppColors.ink,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                            onChanged: (v) => _alEscribir(i, v),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: completo
                ? Row(
                    key: const ValueKey('completo'),
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 17,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Código completo',
                        style: AppTypography.hint.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey('incompleto'),
                    children: [
                      Expanded(
                        child: Text(
                          'Escribe los 6 dígitos. Puedes pegarlos de un jalón.',
                          style: AppTypography.hint,
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            decoration: BoxDecoration(
              color: AppColors.ground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _restantes > 0
                        ? '¿No te llegó? Puedes pedir otro en $_restantes s.'
                        : '¿No te llegó? Pide otro código.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: _restantes > 0
                      ? null
                      : () {
                          _arrancarConteo();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código reenviado')),
                          );
                        },
                  child: const Text('Reenviar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            '¿Te equivocaste de correo? Regresa al paso anterior y corrígelo.',
            style: AppTypography.hint,
          ),
        ],
      ),
    );
  }
}
