import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/status_pill.dart';
import '../data/datos_demo_admin.dart';
import '../models/revision.dart';

/// Revisar el expediente de un alumno.
///
/// Es la pantalla donde se decide todo, y la que peor está en el sistema
/// actual. Lo que cambia, en orden de gravedad:
///
/// 1. **Se ve el documento.** Hoy se aprueba o se rechaza sin poder abrirlo
///    desde aquí.
/// 2. **Nada viene decidido de antemano.** Hoy los ocho desplegables arrancan
///    en REGRESAR: un guardado distraído rebota el expediente completo.
/// 3. **Solo salen los que le tocan al alumno**, según el `¿Dirigido a?` del
///    catálogo. Los demás van plegados, no escondidos.
/// 4. **Se lee la descripción, no `pordebajominima`.** El catálogo ya tiene el
///    nombre legible y la pantalla actual no lo usa.
/// 5. **El comentario cabe.** Hoy es un input de una línea, y es lo único que
///    el alumno recibirá para saber qué corregir.
/// 6. **Se ve qué se dijo la vez pasada**, para no contradecirse.
class RevisarScreen extends StatefulWidget {
  const RevisarScreen({super.key, required this.expediente});

  final ExpedienteEnRevision expediente;

  @override
  State<RevisarScreen> createState() => _RevisarScreenState();
}

class _RevisarScreenState extends State<RevisarScreen> {
  late ExpedienteEnRevision _exp = widget.expediente;
  late final _comentarios = <String, TextEditingController>{};

  int _seleccionado = 0;

  @override
  void initState() {
    super.initState();
    for (final d in _exp.documentos) {
      _comentarios[d.id] = TextEditingController(text: d.comentario);
    }
  }

  @override
  void dispose() {
    for (final c in _comentarios.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<DocumentoEnRevision> get _revisables => _exp.porDecidir;

  DocumentoEnRevision? get _actual {
    if (_revisables.isEmpty) return null;
    final i = _seleccionado.clamp(0, _revisables.length - 1);
    return _revisables[i];
  }

  void _cambiar(DocumentoEnRevision doc,
      {Decision? decision, String? comentario}) {
    setState(() {
      _exp = _exp.conDocumentos([
        for (final d in _exp.documentos)
          if (d.id == doc.id)
            d.copyWith(decision: decision, comentario: comentario)
          else
            d,
      ]);
    });
  }

  /// Pasa al siguiente sin decidir. Revisar es una fila, no un formulario.
  void _siguiente() {
    final i = _revisables.indexWhere(
      (d) => d.decision == Decision.pendiente,
    );
    setState(() {
      _seleccionado = i == -1
          ? (_seleccionado + 1).clamp(0, _revisables.length - 1)
          : i;
    });
  }

  Future<void> _enviar() async {
    final aprobados =
        _revisables.where((d) => d.decision == Decision.aprobar).toList();
    final regresados =
        _revisables.where((d) => d.decision == Decision.regresar).toList();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoConfirmar(
        alumno: _exp.nombre,
        aprobados: aprobados,
        regresados: regresados,
        sinDecidir: _exp.pendientes,
      ),
    );

    if (confirmado != true || !mounted) return;

    // TODO(backend): aquí se mandan las decisiones y se notifica al alumno.
    final nuevos = [
      for (final d in _exp.documentos)
        if (d.decision == Decision.aprobar)
          DocumentoEnRevision(
            id: d.id,
            nombreCorto: d.nombreCorto,
            descripcion: d.descripcion,
            dirigidoA: d.dirigidoA,
            estado: EstadoTramite.aprobado,
            nombreArchivo: d.nombreArchivo,
            bytes: d.bytes,
            subidoEl: d.subidoEl,
          )
        else if (d.decision == Decision.regresar)
          DocumentoEnRevision(
            id: d.id,
            nombreCorto: d.nombreCorto,
            descripcion: d.descripcion,
            dirigidoA: d.dirigidoA,
            estado: EstadoTramite.conObservaciones,
            nombreArchivo: d.nombreArchivo,
            bytes: d.bytes,
            subidoEl: d.subidoEl,
            observacionPrevia: d.comentario,
          )
        else
          d,
    ];

    DatosDemoAdmin.guardar(_exp.conDocumentos(nuevos));

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Listo: ${aprobados.length} aprobado'
          '${aprobados.length == 1 ? '' : 's'}'
          '${regresados.isEmpty ? '' : ' y ${regresados.length} regresado'
              '${regresados.length == 1 ? '' : 's'}'}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_exp.nombre),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.ink,
          fontSize: compacto ? 16 : 19,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: Padding(
            padding: EdgeInsets.only(
              left: compacto ? AppSpacing.md : AppSpacing.gutterDesktop,
              bottom: AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_exp.boleta} · ${_exp.carrera} · ${_exp.tipo.etiqueta}',
                style: AppTypography.hint.copyWith(color: AppColors.muted),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: compacto ? _vistaCompacta() : _vistaEscritorio(),
          ),
          _PieEnviar(
            decididos: _exp.decididos,
            total: _revisables.length,
            sinMotivo: _exp.regresadosSinMotivo.length,
            habilitado: _exp.sePuedeEnviar,
            onEnviar: _enviar,
          ),
        ],
      ),
    );
  }

  // --- Escritorio: lista a la izquierda, documento a la derecha -------------

  Widget _vistaEscritorio() {
    final actual = _actual;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 340,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _FichaAlumno(expediente: _exp),
              const SizedBox(height: AppSpacing.md),
              _ListaDocumentos(
                expediente: _exp,
                revisables: _revisables,
                seleccionado: _seleccionado,
                onSeleccionar: (i) => setState(() => _seleccionado = i),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1, color: AppColors.border),
        Expanded(
          child: actual == null
              ? const _NadaQueRevisar()
              : _DetalleDocumento(
                  key: ValueKey(actual.id),
                  documento: actual,
                  indice: _revisables.indexOf(actual) + 1,
                  total: _revisables.length,
                  control: _comentarios[actual.id]!,
                  onDecision: (d) => _cambiar(actual, decision: d),
                  onComentario: (t) => _cambiar(actual, comentario: t),
                  onSiguiente: _siguiente,
                ),
        ),
      ],
    );
  }

  // --- Celular: todo en una columna ----------------------------------------

  Widget _vistaCompacta() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.gutterMobile),
      children: [
        _FichaAlumno(expediente: _exp),
        const SizedBox(height: AppSpacing.md),
        if (_revisables.isEmpty)
          const _NadaQueRevisar()
        else
          for (var i = 0; i < _revisables.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _DetalleDocumento(
              key: ValueKey(_revisables[i].id),
              documento: _revisables[i],
              indice: i + 1,
              total: _revisables.length,
              control: _comentarios[_revisables[i].id]!,
              onDecision: (d) => _cambiar(_revisables[i], decision: d),
              onComentario: (t) => _cambiar(_revisables[i], comentario: t),
              onSiguiente: null,
              enTarjeta: true,
            ),
          ],
        const SizedBox(height: AppSpacing.md),
        _OtrosDocumentos(expediente: _exp),
      ],
    );
  }
}

/// Quién es el alumno y en qué situación llega.
class _FichaAlumno extends StatelessWidget {
  const _FichaAlumno({required this.expediente});

  final ExpedienteEnRevision expediente;

  @override
  Widget build(BuildContext context) {
    final e = expediente;
    final cargaBaja = e.tipoCarga?.toUpperCase().contains('DEBAJO') ?? false;

    return GescoCard(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cómo llega', style: AppTypography.titleLarge.copyWith(
            fontSize: 15,
          )),
          const SizedBox(height: AppSpacing.sm),
          _Renglon(etiqueta: 'Situación', valor: e.situacionAcademica),
          if (e.creditos != null)
            _Renglon(
              etiqueta: 'Créditos',
              valor: e.creditos!.toStringAsFixed(
                e.creditos! % 1 == 0 ? 0 : 1,
              ),
            ),
          if (e.promedio != null)
            _Renglon(
              etiqueta: 'Promedio SAES',
              valor: e.promedio!.toStringAsFixed(2),
            ),
          if (e.tipoCarga != null)
            _Renglon(
              etiqueta: 'Tipo de carga',
              valor: e.tipoCarga!,
              alerta: cargaBaja,
            ),
          if (e.creditos != null || e.promedio != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Capturado por el alumno desde el SAES.',
              style: AppTypography.hint.copyWith(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _Renglon extends StatelessWidget {
  const _Renglon({
    required this.etiqueta,
    required this.valor,
    this.alerta = false,
  });

  final String etiqueta;
  final String valor;
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(etiqueta, style: AppTypography.hint),
          ),
          Expanded(
            child: Text(
              valor,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: alerta ? AppColors.warningInk : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// La lista lateral: qué documentos hay y cómo va cada uno.
class _ListaDocumentos extends StatelessWidget {
  const _ListaDocumentos({
    required this.expediente,
    required this.revisables,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  final ExpedienteEnRevision expediente;
  final List<DocumentoEnRevision> revisables;
  final int seleccionado;
  final ValueChanged<int> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    final yaAprobados =
        expediente.aplicables.where((d) => d.yaAprobado).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloBloque(
          texto: 'Por revisar',
          accion: Text(
            '${revisables.length}',
            style: AppTypography.titleLarge.copyWith(color: AppColors.guinda),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < revisables.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _ItemDocumento(
              documento: revisables[i],
              activo: i == seleccionado,
              onTap: () => onSeleccionar(i),
            ),
          ),
        if (expediente.sinSubir.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const TituloBloque(texto: 'Sin subir'),
          const SizedBox(height: AppSpacing.xs),
          for (final d in expediente.sinSubir)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: _ItemPasivo(
                texto: d.descripcion,
                icono: Icons.hourglass_empty_rounded,
              ),
            ),
        ],
        if (yaAprobados.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const TituloBloque(texto: 'Ya aprobados'),
          const SizedBox(height: AppSpacing.xs),
          for (final d in yaAprobados)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: _ItemPasivo(
                texto: d.descripcion,
                icono: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
            ),
        ],
        const SizedBox(height: AppSpacing.md),
        _OtrosDocumentos(expediente: expediente),
      ],
    );
  }
}

class _ItemDocumento extends StatelessWidget {
  const _ItemDocumento({
    required this.documento,
    required this.activo,
    required this.onTap,
  });

  final DocumentoEnRevision documento;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = documento;
    final (icono, color) = switch (d.decision) {
      Decision.aprobar => (Icons.check_circle_rounded, AppColors.success),
      Decision.regresar => (Icons.cancel_rounded, AppColors.guinda),
      Decision.pendiente => (Icons.circle_outlined, AppColors.placeholder),
    };

    return Material(
      color: activo ? AppColors.surfaceMuted : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: activo ? AppColors.guinda : AppColors.border,
              width: activo ? 2 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, size: 18, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.descripcion,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (d.observacionPrevia != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Ya se lo habías regresado',
                        style: AppTypography.hint
                            .copyWith(color: AppColors.guinda),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemPasivo extends StatelessWidget {
  const _ItemPasivo({
    required this.texto,
    required this.icono,
    this.color = AppColors.placeholder,
  });

  final String texto;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icono, size: 14, color: color),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            texto,
            style: AppTypography.hint.copyWith(color: AppColors.inkSecondary),
          ),
        ),
      ],
    );
  }
}

/// Los que el catálogo no le pide a este alumno.
class _OtrosDocumentos extends StatelessWidget {
  const _OtrosDocumentos({required this.expediente});

  final ExpedienteEnRevision expediente;

  @override
  Widget build(BuildContext context) {
    final otros = expediente.noAplicables;
    if (otros.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm + 2,
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(
            '${otros.length} no le tocan',
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.inkSecondary,
            ),
          ),
          subtitle: Text(
            'Por ser ${expediente.tipo.etiqueta.toLowerCase()}',
            style: AppTypography.hint,
          ),
          children: [
            for (final d in otros)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: _ItemPasivo(
                  texto: d.descripcion,
                  icono: Icons.remove_rounded,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// El documento en grande: se ve, se decide y se comenta.
class _DetalleDocumento extends StatelessWidget {
  const _DetalleDocumento({
    super.key,
    required this.documento,
    required this.indice,
    required this.total,
    required this.control,
    required this.onDecision,
    required this.onComentario,
    required this.onSiguiente,
    this.enTarjeta = false,
  });

  final DocumentoEnRevision documento;
  final int indice;
  final int total;
  final TextEditingController control;
  final ValueChanged<Decision> onDecision;
  final ValueChanged<String> onComentario;
  final VoidCallback? onSiguiente;
  final bool enTarjeta;

  @override
  Widget build(BuildContext context) {
    final d = documento;

    final cuerpo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOCUMENTO $indice DE $total',
                    style: AppTypography.overline
                        .copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(d.descripcion, style: AppTypography.displaySmall),
                  const SizedBox(height: 3),
                  Text(
                    'En la base: ${d.nombreCorto}',
                    style: AppTypography.hint,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusPill(d.estado, compacta: true),
          ],
        ),
        if (d.observacionPrevia != null) ...[
          const SizedBox(height: AppSpacing.md),
          _ObservacionPrevia(texto: d.observacionPrevia!),
        ],
        const SizedBox(height: AppSpacing.md),
        _Visor(documento: d),
        const SizedBox(height: AppSpacing.md),
        _Decision(decision: d.decision, onDecision: onDecision),
        if (d.decision == Decision.regresar) ...[
          const SizedBox(height: AppSpacing.md),
          _Comentario(
            control: control,
            onCambio: onComentario,
          ),
        ],
        if (onSiguiente != null && d.decision != Decision.pendiente) ...[
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onSiguiente,
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: const Text('Siguiente documento'),
              style: TextButton.styleFrom(foregroundColor: AppColors.guinda),
            ),
          ),
        ],
      ],
    );

    if (enTarjeta) return GescoCard(child: cuerpo);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.gutterDesktop),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: cuerpo,
        ),
      ),
    );
  }
}

class _ObservacionPrevia extends StatelessWidget {
  const _ObservacionPrevia({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.warningTint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.warningBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LO QUE LE DIJISTE LA VEZ PASADA',
            style: AppTypography.overline.copyWith(color: AppColors.warningInk),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            texto,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.inkSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// El documento, visible desde aquí mismo.
class _Visor extends StatelessWidget {
  const _Visor({required this.documento});

  final DocumentoEnRevision documento;

  @override
  Widget build(BuildContext context) {
    final d = documento;

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderMuted, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf_outlined,
              size: 38, color: AppColors.guinda),
          const SizedBox(height: AppSpacing.sm),
          Text(
            d.nombreArchivo ?? 'Sin archivo',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${d.pesoLegible} · subido el ${_fecha(d.subidoEl)}',
            style: AppTypography.hint,
          ),
          const SizedBox(height: AppSpacing.md),
          // TODO(backend): aquí va el visor del PDF. Es el cambio más
          // importante de esta pantalla: hoy se aprueba sin poder abrirlo.
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El visor se conecta cuando haya servidor.'),
              ),
            ),
            icon: const Icon(Icons.open_in_full_rounded, size: 17),
            label: const Text('Ver el documento'),
          ),
        ],
      ),
    );
  }

  static String _fecha(DateTime? f) {
    if (f == null) return '—';
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${f.day} ${meses[f.month - 1]}';
  }
}

/// Aprobar o regresar. Arranca sin nada elegido, a propósito.
class _Decision extends StatelessWidget {
  const _Decision({required this.decision, required this.onDecision});

  final Decision decision;
  final ValueChanged<Decision> onDecision;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BotonDecision(
            icono: Icons.check_rounded,
            texto: 'Aprobar',
            activo: decision == Decision.aprobar,
            color: AppColors.success,
            onTap: () => onDecision(
              decision == Decision.aprobar ? Decision.pendiente : Decision.aprobar,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _BotonDecision(
            icono: Icons.undo_rounded,
            texto: 'Regresar',
            activo: decision == Decision.regresar,
            color: AppColors.guinda,
            onTap: () => onDecision(
              decision == Decision.regresar
                  ? Decision.pendiente
                  : Decision.regresar,
            ),
          ),
        ),
      ],
    );
  }
}

class _BotonDecision extends StatelessWidget {
  const _BotonDecision({
    required this.icono,
    required this.texto,
    required this.activo,
    required this.color,
    required this.onTap,
  });

  final IconData icono;
  final String texto;
  final bool activo;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? color : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: AppSize.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: activo ? color : AppColors.borderStrong,
              width: activo ? 2 : 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                size: 19,
                color: activo ? AppColors.onGuinda : color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                texto,
                style: AppTypography.button.copyWith(
                  fontSize: 14.5,
                  color: activo ? AppColors.onGuinda : AppColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// El comentario que le va a llegar al alumno.
class _Comentario extends StatelessWidget {
  const _Comentario({required this.control, required this.onCambio});

  final TextEditingController control;
  final ValueChanged<String> onCambio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Qué tiene que corregir', style: AppTypography.label),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Es lo que va a leer el alumno.',
          style: AppTypography.hint.copyWith(height: 1.4),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: control,
          onChanged: onCambio,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Qué está mal y qué tiene que hacer.',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Lo que se repite se elige, no se teclea. Mismo principio que los
        // doce textos del dictamen que ya usa el Consejo Técnico.
        Text('Frecuentes:', style: AppTypography.hint),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final frase in DatosDemoAdmin.comentariosFrecuentes)
              _ChipComentario(
                texto: frase,
                onTap: () {
                  control.text = frase;
                  onCambio(frase);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _ChipComentario extends StatelessWidget {
  const _ChipComentario({required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.borderStrong, width: 1.5),
          ),
          child: Text(
            texto,
            style: AppTypography.hint.copyWith(
              color: AppColors.inkSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _NadaQueRevisar extends StatelessWidget {
  const _NadaQueRevisar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 38, color: AppColors.success),
            const SizedBox(height: AppSpacing.sm),
            Text('Nada por revisar', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Este expediente no tiene documentos nuevos esperando decisión.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// El pie: cuántos llevas y el botón de mandar.
class _PieEnviar extends StatelessWidget {
  const _PieEnviar({
    required this.decididos,
    required this.total,
    required this.sinMotivo,
    required this.habilitado,
    required this.onEnviar,
  });

  final int decididos;
  final int total;
  final int sinMotivo;
  final bool habilitado;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    final nota = sinMotivo > 0
        ? 'Falta decir por qué regresas $sinMotivo documento'
            '${sinMotivo == 1 ? '' : 's'}'
        : decididos == 0
            ? 'Todavía no decides ninguno'
            : '$decididos de $total decididos';

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
                  nota,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: sinMotivo > 0 ? AppColors.guinda : AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: habilitado ? onEnviar : null,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Enviar al alumno'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lo que va a pasar, antes de que pase.
///
/// En el sistema actual el botón dice "Guardar y enviar comentarios" y no
/// avisa nada: se entera uno después, y el alumno también.
class _DialogoConfirmar extends StatelessWidget {
  const _DialogoConfirmar({
    required this.alumno,
    required this.aprobados,
    required this.regresados,
    required this.sinDecidir,
  });

  final String alumno;
  final List<DocumentoEnRevision> aprobados;
  final List<DocumentoEnRevision> regresados;
  final int sinDecidir;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      title: const Text('Esto le va a llegar'),
      titleTextStyle: AppTypography.displaySmall,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A $alumno, por correo y en su pantalla de inicio.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.md),
              if (aprobados.isNotEmpty) ...[
                _Bloque(
                  icono: Icons.check_circle_rounded,
                  color: AppColors.success,
                  titulo: '${aprobados.length} aprobado'
                      '${aprobados.length == 1 ? '' : 's'}',
                  lineas: [for (final d in aprobados) d.descripcion],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (regresados.isNotEmpty) ...[
                _Bloque(
                  icono: Icons.undo_rounded,
                  color: AppColors.guinda,
                  titulo: '${regresados.length} para corregir',
                  lineas: [
                    for (final d in regresados)
                      '${d.descripcion} — "${d.comentario.trim()}"',
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (sinDecidir > 0)
                Text(
                  'Quedan $sinDecidir sin decidir. Esos se guardan como '
                  'están y los puedes ver después.',
                  style: AppTypography.hint.copyWith(height: 1.45),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Todavía no'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Enviar'),
        ),
      ],
    );
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.lineas,
  });

  final IconData icono;
  final Color color;
  final String titulo;
  final List<String> lineas;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final l in lineas)
          Padding(
            padding: const EdgeInsets.only(left: 22, bottom: 4),
            child: Text(
              l,
              style: AppTypography.hint.copyWith(
                color: AppColors.inkSecondary,
                height: 1.45,
              ),
            ),
          ),
      ],
    );
  }
}
