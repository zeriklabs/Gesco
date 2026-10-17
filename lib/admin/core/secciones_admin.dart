import 'package:flutter/material.dart';

/// Las secciones de Gestión Escolar.
///
/// Son las mismas cinco del sistema actual, con una diferencia de orden:
/// **Validar documentos va primero**. En el GESCO de hoy está hasta la
/// derecha, detrás de "Documentos digitales", aunque es lo que se hace todos
/// los días; los catálogos, que se tocan una vez por periodo, están primero.
enum SeccionAdmin {
  validar(
    'Validar documentos',
    Icons.fact_check_rounded,
    Icons.fact_check_outlined,
    corto: 'Validar',
  ),
  consejo(
    'Consejo Técnico',
    Icons.gavel_rounded,
    Icons.gavel_outlined,
    corto: 'Consejo',
  ),
  catalogos(
    'Catálogos',
    Icons.inventory_2_rounded,
    Icons.inventory_2_outlined,
  ),
  reportes(
    'Reportes',
    Icons.bar_chart_rounded,
    Icons.bar_chart_outlined,
  );

  const SeccionAdmin(this.titulo, this.iconoActivo, this.icono, {String? corto})
      : _corto = corto;

  final String titulo;
  final IconData iconoActivo;
  final IconData icono;
  final String? _corto;

  String get tituloCorto => _corto ?? titulo;
}

typedef IrASeccionAdmin = void Function(SeccionAdmin seccion);
