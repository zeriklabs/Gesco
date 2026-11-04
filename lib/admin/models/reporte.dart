import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Cómo va un renglón del reporte.
///
/// Los reportes del sistema actual son listas planas: salen los que ya
/// cerraron y los que no, mezclados y sin distinguir. Pero quien pide el
/// reporte antes de que cierre el periodo no quiere saber quiénes son: quiere
/// saber **quiénes faltan**. Por eso cada renglón trae tono.
enum TonoFila {
  /// El alumno debe algo. Es lo que hay que perseguir.
  falta,

  /// Está en manos de Gestión Escolar o del consejo.
  enCurso,

  /// Cerrado.
  listo;

  Color get fondo => switch (this) {
        TonoFila.falta => AppColors.dangerTint,
        TonoFila.enCurso => AppColors.warningTint,
        TonoFila.listo => AppColors.successTint,
      };

  Color get tinta => switch (this) {
        TonoFila.falta => AppColors.guinda,
        TonoFila.enCurso => AppColors.warningInk,
        TonoFila.listo => AppColors.successInk,
      };
}

/// Una columna de reporte.
///
/// La `clave` sirve para el renglón en pantalla y para el encabezado del
/// archivo exportado: lo que se ve y lo que se descarga salen de la misma
/// lista, así no se desfasan cuando alguien agregue una columna.
class ColumnaReporte {
  const ColumnaReporte(
    this.clave,
    this.titulo, {
    this.flex = 3,
    this.pastilla = false,
    this.soloEscritorio = false,
  });

  final String clave;
  final String titulo;
  final int flex;

  /// Se pinta como pastilla de color en lugar de texto.
  final bool pastilla;

  /// En celular no cabe, así que no se pinta. En el archivo sí va.
  final bool soloEscritorio;
}

/// Un renglón armado, listo para pintarse y para exportarse.
class FilaReporte {
  const FilaReporte({
    required this.valores,
    required this.tono,
    required this.carrera,
  });

  final Map<String, String> valores;
  final TonoFila tono;

  /// Se guarda aparte porque es por lo que se filtra, aunque en algunos
  /// reportes no se pinte.
  final String carrera;

  String operator [](String clave) => valores[clave] ?? '';

  bool get cierra => tono == TonoFila.listo;

  /// Para el buscador: solo boleta y nombre, que es lo que dice el campo.
  /// Si buscara en todas las columnas, teclear "car" traería media carrera.
  bool coincide(String texto) {
    final t = texto.trim().toLowerCase();
    if (t.isEmpty) return true;
    return this['boleta'].toLowerCase().contains(t) ||
        this['alumno'].toLowerCase().contains(t);
  }
}

/// Los tres reportes del sistema.
///
/// Son los mismos tres nombres del GESCO actual. Lo que cambia es que ahora
/// traen el periodo activo puesto, se pueden filtrar por carrera y por "los
/// que no cierran", y lo que se ve en pantalla es lo mismo que se exporta.
enum Reporte {
  nuevoIngreso(
    'Nuevo ingreso',
    'Quién se está inscribiendo por primera vez y cómo va su expediente.',
    Icons.person_add_alt_1_outlined,
    sinCerrar: 'Expediente sin validar',
    columnas: [
      ColumnaReporte('boleta', 'Boleta', flex: 3),
      ColumnaReporte('alumno', 'Alumno', flex: 6),
      ColumnaReporte('carrera', 'Carrera', flex: 6, soloEscritorio: true),
      ColumnaReporte('documentos', 'Documentos', flex: 3),
      ColumnaReporte('etapa', 'Etapa', flex: 5, pastilla: true),
    ],
  ),
  reingreso(
    'Alumno de reingreso',
    'Quién se reinscribe, con qué carga y cómo va su expediente.',
    Icons.autorenew_rounded,
    sinCerrar: 'Expediente sin validar',
    columnas: [
      ColumnaReporte('boleta', 'Boleta', flex: 3),
      ColumnaReporte('alumno', 'Alumno', flex: 6),
      ColumnaReporte('carrera', 'Carrera', flex: 6, soloEscritorio: true),
      ColumnaReporte('carga', 'Tipo de carga', flex: 3, soloEscritorio: true),
      ColumnaReporte('documentos', 'Documentos', flex: 3),
      ColumnaReporte('etapa', 'Etapa', flex: 4, pastilla: true),
    ],
  ),
  dictamenes(
    'Dictámenes',
    'Quién pasó por el Consejo Técnico y qué se resolvió.',
    Icons.gavel_outlined,
    sinCerrar: 'Sin dictamen asignado',
    columnas: [
      ColumnaReporte('boleta', 'Boleta', flex: 3),
      ColumnaReporte('alumno', 'Alumno', flex: 6),
      ColumnaReporte('carrera', 'Carrera', flex: 4, soloEscritorio: true),
      ColumnaReporte('pe', 'P.E.', flex: 2),
      ColumnaReporte('dictamen', 'Dictamen', flex: 7),
      ColumnaReporte('etapa', 'Etapa', flex: 4, pastilla: true),
    ],
  );

  const Reporte(
    this.titulo,
    this.pregunta,
    this.icono, {
    required this.columnas,
    required this.sinCerrar,
  });

  final String titulo;

  /// Qué contesta, en una línea.
  final String pregunta;

  final IconData icono;
  final List<ColumnaReporte> columnas;

  /// Cómo se le dice aquí a un renglón que todavía no cierra.
  final String sinCerrar;

  /// Nombre del archivo que se descarga.
  String nombreArchivo(String periodo) {
    final limpio = titulo.toLowerCase().replaceAll(' ', '_');
    return 'gesco_${limpio}_${periodo.replaceAll('/', '-')}.csv';
  }
}
