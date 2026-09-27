import 'package:flutter/material.dart';

/// Las secciones del alumno.
///
/// Vive aparte de la pantalla del armazón para que cualquier pantalla pueda
/// pedir "llévame a documentos" sin importar el `HomeScreen` y armar un
/// círculo de imports.
enum Seccion {
  inicio('Inicio', Icons.home_rounded, Icons.home_outlined),
  expediente(
    'Mi expediente',
    Icons.person_rounded,
    Icons.person_outline_rounded,
    corto: 'Expediente',
  ),
  solicitudes(
    'Solicitudes',
    Icons.description_rounded,
    Icons.description_outlined,
  ),
  documentos(
    'Mis documentos',
    Icons.folder_rounded,
    Icons.folder_outlined,
    corto: 'Documentos',
  ),
  adeudos('Adeudos', Icons.bar_chart_rounded, Icons.bar_chart_outlined);

  const Seccion(this.titulo, this.iconoActivo, this.icono, {String? corto})
      : _corto = corto;

  final String titulo;
  final IconData iconoActivo;
  final IconData icono;
  final String? _corto;

  /// Lo que cabe en la barra inferior del celular.
  String get tituloCorto => _corto ?? titulo;
}

/// Lo que una pantalla usa para mandar al usuario a otra sección.
typedef IrASeccion = void Function(Seccion seccion);
