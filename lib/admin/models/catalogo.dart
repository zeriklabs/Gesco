import 'package:flutter/material.dart';

/// Qué clase de dato guarda una columna.
enum TipoCampo { texto, numero, seleccion, siNo }

/// Una columna de un catálogo.
class CampoCatalogo {
  const CampoCatalogo({
    required this.clave,
    required this.etiqueta,
    this.tipo = TipoCampo.texto,
    this.opciones = const [],
    this.opcionesDe,
    this.requerido = true,
    this.ayuda,
    this.enLista = true,
    this.sensible = false,
  });

  final String clave;
  final String etiqueta;
  final TipoCampo tipo;

  /// Para un desplegable con opciones fijas.
  final List<String> opciones;

  /// Para un desplegable que lee de otro catálogo: aquí va su id.
  ///
  /// Es lo que hace que "Grupos" no tenga una lista de carreras escrita a
  /// mano: la toma del catálogo de carreras, y si se agrega una, aparece sola.
  final String? opcionesDe;

  final bool requerido;
  final String? ayuda;

  /// Si se muestra en la tabla. Un campo largo estorba en la lista pero sirve
  /// en el detalle.
  final bool enLista;

  /// Dato que identifica a una persona. No se enseña hasta que alguien lo
  /// pide, y queda dicho quién lo pidió.
  final bool sensible;
}

/// La definición de un catálogo: qué guarda, para qué sirve y qué depende
/// de él.
class DefinicionCatalogo {
  const DefinicionCatalogo({
    required this.id,
    required this.nombre,
    required this.singular,
    required this.paraQue,
    required this.icono,
    required this.campos,
    this.soloLectura = false,
    this.dependen = const [],
    this.unicoActivo,
    this.nota,
  });

  final String id;
  final String nombre;

  /// Como se nombra un solo renglón: "una carrera", "un grupo".
  final String singular;

  /// Para qué sirve, en una línea.
  ///
  /// El menú actual son ocho palabras sueltas —"Niveles", "Equivalencias"—
  /// sin decir qué se rompe si les mueves. Quien entra nuevo no tiene forma
  /// de saberlo más que preguntando.
  final String paraQue;

  final IconData icono;
  final List<CampoCatalogo> campos;

  /// Los que no se editan desde aquí.
  final bool soloLectura;

  /// Los catálogos que apuntan a este. Sirve para avisar antes de borrar.
  final List<String> dependen;

  /// Si solo un renglón puede traer este campo en "sí" a la vez.
  ///
  /// Es el caso de Periodos: hoy "¿actual?" es un sí/no por renglón, así que
  /// nada impide dejar dos periodos activos —o ninguno— y que medio sistema
  /// se confunda.
  final String? unicoActivo;

  final String? nota;

  CampoCatalogo? campo(String clave) {
    for (final c in campos) {
      if (c.clave == clave) return c;
    }
    return null;
  }

  /// El primer campo de texto: con eso se nombra un renglón.
  String etiquetaDe(Map<String, String> fila) {
    for (final c in campos) {
      if (c.tipo == TipoCampo.texto && (fila[c.clave] ?? '').isNotEmpty) {
        return fila[c.clave]!;
      }
    }
    return fila.values.first;
  }
}
