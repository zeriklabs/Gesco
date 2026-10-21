import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/gesco_text_field.dart';
import '../data/datos_demo_consejo.dart';

/// Los datos de la sesión del consejo que se imprimen en cada dictamen.
///
/// En el sistema actual es un formulario de seis campos sin contexto: no dice
/// dónde salen ni qué pasa si están mal. Salen en el encabezado y en las dos
/// firmas de un documento oficial, así que aquí van junto a la hoja.
class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  late final _consejo =
      TextEditingController(text: DatosDemoConsejo.sesion.numeroConsejo);
  late final _fecha =
      TextEditingController(text: DatosDemoConsejo.sesion.fechaSesion);
  late final _sesion =
      TextEditingController(text: DatosDemoConsejo.sesion.numeroSesion);
  late final _abreviado =
      TextEditingController(text: DatosDemoConsejo.sesion.numeroAbreviado);
  late final _presidente =
      TextEditingController(text: DatosDemoConsejo.sesion.presidente);
  late final _secretario =
      TextEditingController(text: DatosDemoConsejo.sesion.secretario);

  @override
  void dispose() {
    _consejo.dispose();
    _fecha.dispose();
    _sesion.dispose();
    _abreviado.dispose();
    _presidente.dispose();
    _secretario.dispose();
    super.dispose();
  }

  void _guardar() {
    DatosDemoConsejo.sesion = DatosDemoConsejo.sesion.copyWith(
      numeroConsejo: _consejo.text.trim(),
      fechaSesion: _fecha.text.trim(),
      numeroSesion: _sesion.text.trim(),
      numeroAbreviado: _abreviado.text.trim(),
      presidente: _presidente.text.trim(),
      secretario: _secretario.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos de la sesión actualizados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    final formulario = GescoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('La sesión', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Se imprime en todos los dictámenes de este periodo.',
            style: AppTypography.hint,
          ),
          const SizedBox(height: AppSpacing.md),
          GescoTextField(
            label: 'Número de consejo',
            controller: _consejo,
            isRequired: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          GescoTextField(
            label: 'Fecha de la sesión',
            controller: _fecha,
            onChanged: (_) => setState(() {}),
            helperText: 'Como quieres que salga escrita en el documento.',
          ),
          const SizedBox(height: AppSpacing.md),
          GescoTextField(
            label: 'Número de sesión',
            controller: _sesion,
            isRequired: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          GescoTextField(
            label: 'Número de sesión abreviado',
            controller: _abreviado,
            isRequired: true,
            onChanged: (_) => setState(() {}),
            helperText: 'El que cabe en el encabezado, por ejemplo 2DA. EXT.',
          ),
          const SizedBox(height: AppSpacing.md),
          GescoTextField(
            label: 'Presidente',
            controller: _presidente,
            isRequired: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          GescoTextField(
            label: 'Secretario',
            controller: _secretario,
            isRequired: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );

    final vista = _HojaEjemplo(
      consejo: _consejo.text,
      sesion: _sesion.text,
      fecha: _fecha.text,
      presidente: _presidente.text,
      secretario: _secretario.text,
    );

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        if (compacto) ...[
          formulario,
          const SizedBox(height: AppSpacing.md),
          vista,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: formulario),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 2, child: vista),
            ],
          ),
      ],
    );
  }
}

/// Dónde cae cada campo en la hoja impresa.
class _HojaEjemplo extends StatelessWidget {
  const _HojaEjemplo({
    required this.consejo,
    required this.sesion,
    required this.fecha,
    required this.presidente,
    required this.secretario,
  });

  final String consejo;
  final String sesion;
  final String fecha;
  final String presidente;
  final String secretario;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloBloque(texto: 'Dónde sale'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderStrong, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CONSEJO TÉCNICO CONSULTIVO ESCOLAR Nº '
                '${consejo.isEmpty ? '—' : consejo}',
                style: _serif(11.5, peso: FontWeight.w700),
              ),
              Text(
                '${sesion.isEmpty ? '—' : sesion} · '
                '${fecha.isEmpty ? '—' : fecha}',
                style: _serif(10.5, color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 7,
                width: 150,
                color: AppColors.surfaceMuted,
              ),
              const SizedBox(height: 6),
              Container(height: 7, color: AppColors.surfaceMuted),
              const SizedBox(height: 6),
              Container(height: 7, color: AppColors.surfaceMuted),
              const SizedBox(height: 6),
              Container(
                height: 7,
                width: 220,
                color: AppColors.surfaceMuted,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Divider(color: AppColors.borderStrong),
                        Text(
                          presidente.isEmpty ? '—' : presidente,
                          style: _serif(9.5),
                          textAlign: TextAlign.center,
                        ),
                        Text('PRESIDENTE',
                            style: _serif(8.5, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      children: [
                        const Divider(color: AppColors.borderStrong),
                        Text(
                          secretario.isEmpty ? '—' : secretario,
                          style: _serif(9.5),
                          textAlign: TextAlign.center,
                        ),
                        Text('SECRETARIO',
                            style: _serif(8.5, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Las barras grises son el dictamen de cada alumno, que cambia; lo '
          'demás es igual en todos.',
          style: AppTypography.hint.copyWith(height: 1.45),
        ),
      ],
    );
  }

  static TextStyle _serif(
    double size, {
    FontWeight peso = FontWeight.w500,
    Color color = AppColors.ink,
  }) {
    return TextStyle(
      fontFamily: 'Georgia',
      fontSize: size,
      fontWeight: peso,
      color: color,
    );
  }
}
