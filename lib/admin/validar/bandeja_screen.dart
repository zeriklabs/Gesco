import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../data/datos_demo_admin.dart';
import '../models/revision.dart';
import 'revisar_screen.dart';

/// La bandeja de expedientes por validar.
///
/// El sistema actual pone las tres etapas como tres tablas apiladas en una
/// sola página: para ver la segunda hay que pasar de largo cuarenta y un
/// renglones de la primera. Aquí son tres pestañas, porque quien revisa
/// trabaja una cola a la vez.
///
/// Y se ordenan por **quién lleva más esperando**, no por boleta. El sistema
/// de hoy muestra la fecha de última actualización y ya; nadie puede ver de
/// un vistazo a quién se le está haciendo tarde.
class BandejaScreen extends StatefulWidget {
  const BandejaScreen({super.key});

  @override
  State<BandejaScreen> createState() => _BandejaScreenState();
}

class _BandejaScreenState extends State<BandejaScreen> {
  EtapaExpediente _etapa = EtapaExpediente.esperandoRevision;
  final _busqueda = TextEditingController();

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<ExpedienteEnRevision> _lista(EtapaExpediente etapa) {
    final texto = _busqueda.text.trim().toLowerCase();
    final lista = DatosDemoAdmin.porEtapa(etapa).where((e) {
      if (texto.isEmpty) return true;
      return e.boleta.contains(texto) ||
          e.nombre.toLowerCase().contains(texto) ||
          e.carrera.toLowerCase().contains(texto);
    }).toList();

    // El que lleva más esperando, primero.
    lista.sort((a, b) {
      final fa = a.actualizadoEl ?? DateTime.now();
      final fb = b.actualizadoEl ?? DateTime.now();
      return fa.compareTo(fb);
    });
    return lista;
  }

  Future<void> _revisar(ExpedienteEnRevision expediente) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RevisarScreen(expediente: expediente),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;
    final lista = _lista(_etapa);

    return ListView(
      padding: EdgeInsets.all(
        compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
      ),
      children: [
        CabeceraPantalla(
          contexto: 'Periodo ${DatosDemoAdmin.periodoActual} · '
              '${DatosDemoAdmin.periodoLegible}',
          titulo: 'Validar documentos',
        ),
        const SizedBox(height: AppSpacing.lg),
        _Pestanas(
          actual: _etapa,
          onCambiar: (e) => setState(() => _etapa = e),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _busqueda,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Buscar por boleta, nombre o carrera',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _busqueda.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar',
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => setState(_busqueda.clear),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (lista.isEmpty)
          _SinExpedientes(etapa: _etapa, buscando: _busqueda.text.isNotEmpty)
        else
          for (final e in lista)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _FilaExpediente(
                expediente: e,
                onRevisar: () => _revisar(e),
              ),
            ),
      ],
    );
  }
}

class _Pestanas extends StatelessWidget {
  const _Pestanas({required this.actual, required this.onCambiar});

  final EtapaExpediente actual;
  final ValueChanged<EtapaExpediente> onCambiar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final enColumna = constraints.maxWidth < 560;

        final botones = [
          for (final e in EtapaExpediente.values)
            _Pestana(
              etapa: e,
              cuantos: DatosDemoAdmin.porEtapa(e).length,
              activa: e == actual,
              onTap: () => onCambiar(e),
            ),
        ];

        if (enColumna) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < botones.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.xs),
                botones[i],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < botones.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              Expanded(child: botones[i]),
            ],
          ],
        );
      },
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({
    required this.etapa,
    required this.cuantos,
    required this.activa,
    required this.onTap,
  });

  final EtapaExpediente etapa;
  final int cuantos;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activa ? AppColors.guinda : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: activa ? AppColors.guinda : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$cuantos',
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 19,
                  color: activa ? AppColors.onGuinda : AppColors.guinda,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  etapa.etiqueta,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: activa ? FontWeight.w800 : FontWeight.w600,
                    color: activa
                        ? AppColors.onGuindaMuted
                        : AppColors.inkSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaExpediente extends StatelessWidget {
  const _FilaExpediente({required this.expediente, required this.onRevisar});

  final ExpedienteEnRevision expediente;
  final VoidCallback onRevisar;

  @override
  Widget build(BuildContext context) {
    final e = expediente;
    final dias = _diasEsperando(e.actualizadoEl);
    final urgente = dias >= 5 && e.etapa != EtapaExpediente.validado;
    final conObservaciones = e.documentos
        .where((d) => d.observacionPrevia != null)
        .map((d) => d.descripcion)
        .toList();

    return GescoCard(
      onTap: onRevisar,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      bordeGrueso: urgente,
      colorBorde: urgente ? AppColors.dangerBorder : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.nombre,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${e.boleta} · ${e.carrera}',
                      style: AppTypography.hint,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ChipTipo(tipo: e.tipo),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Dato(
                icono: urgente
                    ? Icons.schedule_rounded
                    : Icons.calendar_today_rounded,
                texto: _textoEspera(dias, e.etapa),
                color: urgente ? AppColors.guinda : AppColors.muted,
                fuerte: urgente,
              ),
              _Dato(
                icono: Icons.description_outlined,
                texto: '${e.aprobados} de ${e.aplicables.length} aprobados',
                color: AppColors.muted,
              ),
              if (e.tipoCarga != null &&
                  e.tipoCarga!.toUpperCase().contains('DEBAJO'))
                _Dato(
                  icono: Icons.trending_down_rounded,
                  texto: 'Carga por debajo de la mínima',
                  color: AppColors.warningInk,
                ),
              if (e.etapa == EtapaExpediente.validado && e.entregoFisico)
                _Dato(
                  icono: Icons.inventory_rounded,
                  texto: 'Entregó físicos',
                  color: AppColors.successInk,
                ),
            ],
          ),
          if (conObservaciones.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.dangerTint,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'Le regresaste: ${conObservaciones.join(' · ')}',
                style: AppTypography.hint.copyWith(
                  color: AppColors.guinda,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static int _diasEsperando(DateTime? desde) {
    if (desde == null) return 0;
    return DateTime.now().difference(desde).inDays;
  }

  static String _textoEspera(int dias, EtapaExpediente etapa) {
    if (etapa == EtapaExpediente.validado) return 'Validado';
    if (dias <= 0) return 'Llegó hoy';
    if (dias == 1) return 'Esperando 1 día';
    return 'Esperando $dias días';
  }
}

class _ChipTipo extends StatelessWidget {
  const _ChipTipo({required this.tipo});

  final TipoTramiteAlumno tipo;

  @override
  Widget build(BuildContext context) {
    // En la tabla de hoy esto es una "I" o una "R" sueltas en una columna
    // llamada "Estatus". Nadie que entre nuevo sabe qué quieren decir.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        tipo.etiqueta,
        style: AppTypography.pill.copyWith(color: AppColors.inkSecondary),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.icono,
    required this.texto,
    required this.color,
    this.fuerte = false,
  });

  final IconData icono;
  final String texto;
  final Color color;
  final bool fuerte;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          texto,
          style: AppTypography.hint.copyWith(
            color: color,
            fontWeight: fuerte ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SinExpedientes extends StatelessWidget {
  const _SinExpedientes({required this.etapa, required this.buscando});

  final EtapaExpediente etapa;
  final bool buscando;

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            buscando ? Icons.search_off_rounded : Icons.check_circle_outline,
            size: 34,
            color: buscando ? AppColors.placeholder : AppColors.success,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            buscando ? 'Nadie con esa búsqueda' : 'Nada pendiente aquí',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            buscando
                ? 'Prueba con la boleta completa o con el apellido.'
                : 'No hay expedientes en "${etapa.etiqueta.toLowerCase()}".',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
