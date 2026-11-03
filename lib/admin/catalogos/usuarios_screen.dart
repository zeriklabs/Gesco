import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_catalogos.dart';

/// Las cuentas de los alumnos.
///
/// Son miles. Nadie entra aquí a hojear: se entra buscando una boleta. Por eso
/// la pantalla arranca en el buscador y no lista nada hasta que hay algo que
/// buscar — y de paso, miles de correos y CURPs no quedan a la vista de
/// cualquiera que abra la sección.
class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _busqueda = TextEditingController();

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _resultados {
    final texto = _busqueda.text.trim().toLowerCase();
    if (texto.length < 3) return const [];
    return DatosDemoCatalogos.filas('usuarios')
        .where((u) => u.values.any((v) => v.toLowerCase().contains(texto)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final total = DatosDemoCatalogos.filas('usuarios').length;
    final texto = _busqueda.text.trim();
    final resultados = _resultados;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Usuarios'),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.ink,
          fontSize: compacto ? 16 : 19,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$total cuentas registradas. Solo consulta.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.inkSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _busqueda,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Boleta o correo',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: texto.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpiar',
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () =>
                                  setState(() => _busqueda.clear()),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (texto.length < 3)
                    _Mensaje(
                      icono: Icons.search_rounded,
                      titulo: 'Busca una cuenta',
                      detalle: 'Escribe al menos tres caracteres de la boleta '
                          'o del correo.',
                    )
                  else if (resultados.isEmpty)
                    _Mensaje(
                      icono: Icons.search_off_rounded,
                      titulo: 'Sin resultados',
                      detalle: 'Nada coincide con "$texto".',
                    )
                  else ...[
                    Text(
                      '${resultados.length} resultado'
                      '${resultados.length == 1 ? '' : 's'}',
                      style: AppTypography.hint,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final u in resultados)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: _Cuenta(usuario: u),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 32, color: AppColors.placeholder),
          const SizedBox(height: AppSpacing.sm),
          Text(titulo, style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            detalle,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Cuenta extends StatefulWidget {
  const _Cuenta({required this.usuario});

  final Map<String, String> usuario;

  @override
  State<_Cuenta> createState() => _CuentaState();
}

class _CuentaState extends State<_Cuenta> {
  bool _curpVisible = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.usuario;

    return GescoCard(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                u['boleta'] ?? '',
                style: AppTypography.titleLarge.copyWith(fontSize: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  u['correo'] ?? '',
                  style: AppTypography.hint,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          _Dato(etiqueta: 'Celular', valor: u['celular'] ?? '—'),
          _Dato(etiqueta: 'Seguro', valor: u['seguro'] ?? '—'),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: Text('CURP', style: AppTypography.hint),
              ),
              if (_curpVisible)
                Text(
                  u['curp'] ?? '—',
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () => setState(() => _curpVisible = true),
                  icon: const Icon(Icons.visibility_outlined, size: 15),
                  label: const Text('Mostrar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.guinda,
                    visualDensity: VisualDensity.compact,
                    textStyle: AppTypography.hint
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(etiqueta, style: AppTypography.hint),
          ),
          Expanded(
            child: Text(
              valor,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
