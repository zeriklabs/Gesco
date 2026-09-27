import 'package:flutter/material.dart';

import '../../core/data/datos_demo.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/models/documento.dart';
import '../../core/models/expediente.dart';
import '../../core/models/tramite.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/fila_documento.dart';
import '../../widgets/gesco_card.dart';
import '../../widgets/status_pill.dart';

/// La solicitud de reinscripción.
///
/// El hallazgo que ordenó todo el rediseño: **no tiene formulario**. El PDF se
/// arma completo con lo que ya está en el expediente — boleta, grupo, turno,
/// domicilio, situación académica, tutor. No hay una sola pregunta nueva.
///
/// Así que esta pantalla no es un formulario: es una vista previa con sus
/// documentos al lado, y los documentos se suben aquí mismo, junto al botón
/// que genera el PDF.
class ReinscripcionScreen extends StatefulWidget {
  const ReinscripcionScreen({super.key});

  @override
  State<ReinscripcionScreen> createState() => _ReinscripcionScreenState();
}

class _ReinscripcionScreenState extends State<ReinscripcionScreen> {
  late Tramite _tramite = DatosDemo.tramites.firstWhere(
    (t) => t.tipo == TipoTramite.reinscripcion,
  );

  /// Simula la subida de un archivo: pasa a "en revisión".
  ///
  /// TODO(backend): aquí va el selector de archivos y la subida real.
  void _subir(Documento doc) {
    setState(() {
      _tramite = Tramite(
        id: _tramite.id,
        tipo: _tramite.tipo,
        estado: _tramite.estado,
        periodo: _tramite.periodo,
        creadoEl: _tramite.creadoEl,
        resumen: _tramite.resumen,
        documentos: [
          for (final d in _tramite.documentos)
            if (d.id == doc.id)
              d.copyWith(estado: EstadoTramite.enRevision, observacion: '')
            else
              d,
        ],
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${doc.nombre}: enviado a revisión')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compacto = context.isCompact;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Solicitud de reinscripción'),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.onGuinda,
          fontSize: compacto ? 17 : 19,
        ),
        actions: [
          if (!compacto) ...[
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: const Text('Corregir datos'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onGuindaMuted,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _BotonGenerar(tramite: _tramite),
            const SizedBox(width: AppSpacing.md),
          ],
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.gutterMobile : AppSpacing.gutterDesktop,
        ),
        children: [
          const _AvisoSinFormulario(),
          const SizedBox(height: AppSpacing.md),

          if (compacto) ...[
            _BloqueDocumentos(tramite: _tramite, onSubir: _subir),
            const SizedBox(height: AppSpacing.md),
            const _BloqueOrigenDatos(),
            const SizedBox(height: AppSpacing.md),
            const _VistaPrevia(),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: _BotonGenerar(tramite: _tramite, ancho: true),
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 3, child: _VistaPrevia()),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const _BloqueOrigenDatos(),
                      const SizedBox(height: AppSpacing.md),
                      _BloqueDocumentos(tramite: _tramite, onSubir: _subir),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BotonGenerar extends StatelessWidget {
  const _BotonGenerar({required this.tramite, this.ancho = false});

  final Tramite tramite;
  final bool ancho;

  @override
  Widget build(BuildContext context) {
    final listo = tramite.listoParaGenerar;
    final faltan = tramite.documentosRequeridos - tramite.documentosAprobados;

    return Tooltip(
      message: listo
          ? 'Genera el PDF de tu solicitud'
          : 'Te faltan $faltan documentos aprobados',
      child: FilledButton.icon(
        onPressed: listo ? () {} : null,
        icon: const Icon(Icons.download_rounded, size: 18),
        label: const Text('Generar PDF'),
        style: FilledButton.styleFrom(
          backgroundColor: ancho ? AppColors.guinda : AppColors.onGuinda,
          foregroundColor: ancho ? AppColors.onGuinda : AppColors.guinda,
          disabledBackgroundColor:
              ancho ? AppColors.borderStrong : AppColors.overlayOnGuinda,
          disabledForegroundColor:
              ancho ? AppColors.placeholder : AppColors.onGuindaFaint,
          minimumSize: Size(0, ancho ? AppSize.buttonHeight : 42),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: AppTypography.button.copyWith(fontSize: 14.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm + 1),
          ),
        ),
      ),
    );
  }
}

class _AvisoSinFormulario extends StatelessWidget {
  const _AvisoSinFormulario();

  @override
  Widget build(BuildContext context) {
    return GescoCard(
      color: AppColors.dangerTint,
      colorBorde: AppColors.dangerBorder,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 19, color: AppColors.guinda),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Esta solicitud no te pide nada nuevo. ',
                style: const TextStyle(fontWeight: FontWeight.w800),
                children: [
                  TextSpan(
                    text: 'Se arma completa con lo que ya capturaste en tu '
                        'expediente. Revisa que todo esté bien antes de '
                        'generarla: si hay un dato falso, Gestión Escolar '
                        'cancela el trámite.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.inkSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.ink,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// De qué parte del expediente sale cada bloque del documento.
class _BloqueOrigenDatos extends StatelessWidget {
  const _BloqueOrigenDatos();

  static const _origen = {
    SeccionExpediente.personales: 'Encabezado, domicilio y contacto',
    SeccionExpediente.escolares: 'Situación académica y créditos',
    SeccionExpediente.tutor: 'Bloque de la página 2',
    SeccionExpediente.generales: '¿Trabajas? y visibilidad al tutor',
  };

  @override
  Widget build(BuildContext context) {
    final expediente = DatosDemo.expediente;

    return GescoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'De dónde salen los datos',
                  style: AppTypography.titleLarge,
                ),
              ),
              StatusPill(
                expediente.estaCompleto
                    ? EstadoTramite.aprobado
                    : EstadoTramite.enRevision,
                compacta: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final MapEntry(key: seccion, value: detalle) in _origen.entries)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    (expediente.secciones[seccion]?.completa ?? false)
                        ? Icons.check_circle_rounded
                        : Icons.pending_outlined,
                    size: 18,
                    color: (expediente.secciones[seccion]?.completa ?? false)
                        ? AppColors.success
                        : AppColors.dorado,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seccion.titulo,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(detalle, style: AppTypography.hint),
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

/// Los documentos del trámite, con el botón de subir aquí mismo.
///
/// Esto es lo que reemplaza la sección aparte de "Subir documentos" del GESCO
/// actual: en vez de ocho documentos sueltos en otra pestaña, los tres que te
/// tocan, junto al botón que genera el PDF.
class _BloqueDocumentos extends StatelessWidget {
  const _BloqueDocumentos({required this.tramite, required this.onSubir});

  final Tramite tramite;
  final void Function(Documento) onSubir;

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
            'Solo los que te tocan, según tu situación: carga por debajo de '
            'la mínima, sin dictamen, sin baja previa.',
            style: AppTypography.hint,
          ),
          const SizedBox(height: AppSpacing.md),

          for (final d in aplican)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: FilaDocumento(
                documento: d,
                onSubir: () => onSubir(d),
                compacta: true,
              ),
            ),

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
                        : 'Genera el PDF cuando los tres estén aprobados.',
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
  const _VistaPrevia();

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
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
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
            child: const _HojaDocumento(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: null,
                tooltip: 'Página anterior',
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                'Página 1 de 2',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSecondary,
                ),
              ),
              IconButton(
                onPressed: () {},
                tooltip: 'Página siguiente',
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HojaDocumento extends StatelessWidget {
  const _HojaDocumento();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IpnLogo(height: 34, onDark: false),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'INSTITUTO POLITÉCNICO NACIONAL\n'
                    'UNIDAD PROFESIONAL INTERDISCIPLINARIA DE INGENIERÍA\n'
                    'CAMPUS ZACATECAS',
                    textAlign: TextAlign.center,
                    style: _serif(9, peso: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Subdirección de Servicios Educativos e Integración Social',
                    textAlign: TextAlign.center,
                    style: _serif(7.5),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'DEPARTAMENTO DE GESTIÓN ESCOLAR\nSOLICITUD DE REINSCRIPCIÓN',
                    textAlign: TextAlign.center,
                    style: _serif(8.5, peso: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const UpiizLogo(size: 36),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        const _CampoDoc(etiqueta: 'NO. DE BOLETA', valor: DatosDemo.boleta),
        const _CampoDoc(
          etiqueta: 'PROGRAMA ACADÉMICO',
          valor: 'ING. EN SISTEMAS COMPUTACIONALES',
        ),
        const _CampoDoc(etiqueta: 'GRUPO', valor: DatosDemo.grupo),
        const _CampoDoc(
          etiqueta: 'PERIODO',
          valor: '27/1 (AGO 2026 – ENE 2027)',
        ),

        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            'DATOS GENERALES DEL ALUMNO',
            style: _serif(8.5, peso: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        const _FilaCampos(
          valores: ['GARCÍA', 'TORRES', 'GAEL'],
          etiquetas: ['APELLIDO PATERNO', 'APELLIDO MATERNO', 'NOMBRE(S)'],
        ),
        const SizedBox(height: 6),
        const _FilaCampos(
          valores: ['CANAL ESTEBAN RODRÍGUEZ', '4', 'PAMANES ESCOBEDO'],
          etiquetas: ['CALLE', 'No. EXT', 'COLONIA'],
          pesos: [3, 1, 2],
        ),

        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            'SITUACIÓN ACADÉMICA',
            style: _serif(8.5, peso: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Text('POR DEBAJO DE LA MÍNIMA', style: _serif(7, peso: FontWeight.w700)),
        const SizedBox(height: 4),
        const _CampoDoc(etiqueta: 'SEMESTRE', valor: '8VO'),
        const _CampoDoc(etiqueta: 'TOTAL DE CRÉDITOS', valor: '30'),
        const _CampoDoc(etiqueta: 'PROMEDIO SAES', valor: '8.47'),
      ],
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

class _CampoDoc extends StatelessWidget {
  const _CampoDoc({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
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
