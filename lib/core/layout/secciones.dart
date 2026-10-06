import 'package:flutter/material.dart';

/// Las tres secciones principales del alumno.
///
/// 1. Inicio: Resumen del estado actual del alumno y notificaciones.
/// 2. Mi expediente: Datos personales, domicilio, contacto, escolares y gestión centralizada de adeudos.
/// 3. Solicitudes: Trámites activos, historial e inscripción.
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
  );

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
