import 'package:flutter/material.dart';

/// Las cuatro secciones del expediente, más los adeudos.
///
/// El expediente es el corazón del sistema: se captura una vez y los cinco
/// trámites lo leen. En el GESCO actual cada solicitud vuelve a pedir lo
/// mismo — los adeudos, por ejemplo, se recapturan en cuatro formularios.
enum SeccionExpediente {
  personales('Datos personales', Icons.person_outline_rounded, 21),
  tutor('Datos del tutor', Icons.people_outline_rounded, 14),
  generales('Datos generales', Icons.work_outline_rounded, 3),
  escolares('Datos escolares', Icons.school_outlined, 11);

  const SeccionExpediente(this.titulo, this.icono, this.totalCampos);

  final String titulo;
  final IconData icono;
  final int totalCampos;

  int get paso => index + 1;
}

/// Una unidad de aprendizaje reprobada.
///
/// Vive en el expediente, no dentro de cada solicitud. Ese es el cambio de
/// fondo: hoy este mismo formulario aparece dentro de la baja de UAp, el
/// dictamen, la baja de unidad académica y el GE-01, idéntico en los cuatro.
class Adeudo {
  const Adeudo({
    required this.unidadAprendizaje,
    required this.nivel,
    required this.periodoReprobada,
    this.semestreReprobada,
    this.estado = 'NORMAL',
  });

  final String unidadAprendizaje;
  final String nivel;
  final String periodoReprobada;
  final String? semestreReprobada;
  final String estado;
}

/// Extensión para calcular el desfase por tiempo de un adeudo (regla de 1 año / 2 periodos en IPN).
extension AdeudoCalculo on Adeudo {
  /// Convierte un periodo IPN (ej. '25/2' o '27/1') a un entero continuo para comparar.
  static int valorPeriodo(String p) {
    final partes = p.split('/');
    if (partes.length < 2) return 0;
    final anio = int.tryParse(partes[0]) ?? 0;
    final sem = int.tryParse(partes[1]) ?? 0;
    return anio * 2 + sem;
  }

  /// Calcula cuántos periodos escolares han pasado desde que la reprobó.
  int periodosTranscurridos(String periodoActual) {
    final vActual = valorPeriodo(periodoActual);
    final vRepro = valorPeriodo(periodoReprobada);
    if (vActual <= 0 || vRepro <= 0) return 0;
    return (vActual - vRepro).clamp(0, 99);
  }

  /// Indica si la materia ya superó los 2 periodos (1 año escolar) sin ser acreditada.
  bool estaDesfasada(String periodoActual) {
    return periodosTranscurridos(periodoActual) > 2;
  }

  /// Indica si la materia está en su segundo periodo (1 año exacto), límite reglamentario.
  bool enLimiteDictamen(String periodoActual) {
    return periodosTranscurridos(periodoActual) == 2;
  }
}

/// El estado del expediente de un alumno.
class Expediente {
  const Expediente({
    required this.secciones,
    required this.adeudos,
    this.actualizadoEl,
  });

  /// Cuántos campos lleva capturados de cada sección.
  final Map<SeccionExpediente, ResumenSeccion> secciones;

  final List<Adeudo> adeudos;
  final DateTime? actualizadoEl;

  int get seccionesCompletas =>
      secciones.values.where((s) => s.completa).length;

  int get totalSecciones => SeccionExpediente.values.length;

  bool get estaCompleto => seccionesCompletas == totalSecciones;

  /// Adeudos que superaron 1 año (2 periodos) sin acreditarse y requieren Dictamen.
  List<Adeudo> adeudosDesfasados(String periodoActual) =>
      adeudos.where((a) => a.estaDesfasada(periodoActual)).toList();

  /// Adeudos en el límite de 1 año (2 periodos).
  List<Adeudo> adeudosEnLimite(String periodoActual) =>
      adeudos.where((a) => a.enLimiteDictamen(periodoActual)).toList();

  /// Las que le faltan, en orden. Es lo que se le dice al alumno en el inicio.
  List<SeccionExpediente> get pendientes => [
        for (final s in SeccionExpediente.values)
          if (!(secciones[s]?.completa ?? false)) s,
      ];
}

/// Lo capturado en una sección.
class ResumenSeccion {
  const ResumenSeccion({
    required this.camposLlenos,
    required this.total,
    this.lineas = const [],
  });

  final int camposLlenos;
  final int total;

  /// Dos o tres datos representativos, para que el alumno reconozca la
  /// sección sin tener que entrar.
  final List<(String, String)> lineas;

  bool get completa => camposLlenos >= total;

  double get avance => total == 0 ? 0 : (camposLlenos / total).clamp(0, 1);
}
