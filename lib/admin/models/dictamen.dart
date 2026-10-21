/// Un periodo escolar, con la aritmética que el sistema actual hace a mano.
///
/// Los doce textos de dictamen traen el periodo **escrito adentro del
/// párrafo**: "EN EL PERIODO ESCOLAR 27/1", "E.T.S. DE ENERO 2027". Cada
/// semestre alguien tiene que entrar a editar los doce, y si se le pasa uno,
/// el dictamen sale impreso con el periodo del año pasado y nadie se entera
/// hasta que el alumno llega con el papel.
class Periodo {
  const Periodo(this.anio, this.mitad);

  /// Los dos dígitos: 27 en "27/1".
  final int anio;

  /// 1 = agosto–enero · 2 = febrero–julio.
  final int mitad;

  factory Periodo.deTexto(String texto) {
    final partes = texto.split('/');
    return Periodo(
      int.tryParse(partes.first.trim()) ?? 27,
      int.tryParse(partes.last.trim()) ?? 1,
    );
  }

  Periodo get siguiente =>
      mitad == 1 ? Periodo(anio, 2) : Periodo(anio + 1, 1);

  /// El año de calendario en que cae el E.T.S. de enero de este periodo.
  int get anioEtsEnero => mitad == 1 ? 2000 + anio : 2000 + anio + 1;

  int get anioEtsJulio => 2000 + anio;

  @override
  String toString() => '$anio/$mitad';
}

/// Uno de los doce textos que el Consejo imprime en un dictamen.
///
/// Aquí es una **plantilla**: el periodo entra como variable y se resuelve al
/// imprimir. El texto se escribe una vez y vale para siempre.
class TextoDictamen {
  const TextoDictamen({
    required this.id,
    required this.titulo,
    required this.plantilla,
  });

  final String id;

  /// Como lo nombra quien captura: "recursa y avanza carga media (2 p.e.)".
  final String titulo;

  /// El párrafo con variables entre llaves.
  final String plantilla;

  /// Las variables que acepta una plantilla, con lo que significan.
  static const variables = <String, String>{
    '{periodo}': 'El periodo activo, por ejemplo 27/1',
    '{periodo_sig}': 'El que sigue: 27/2',
    '{periodo_sig2}': 'El de después: 28/1',
    '{ets_enero}': 'El E.T.S. de enero con su año',
    '{ets_julio}': 'El E.T.S. de julio con su año',
  };

  /// Cambia las variables por sus valores del periodo activo.
  String resolver(Periodo periodo) {
    final sig = periodo.siguiente;
    final sig2 = sig.siguiente;

    return plantilla
        .replaceAll('{periodo}', periodo.toString())
        .replaceAll('{periodo_sig}', sig.toString())
        .replaceAll('{periodo_sig2}', sig2.toString())
        .replaceAll('{ets_enero}', 'ENERO ${periodo.anioEtsEnero}')
        .replaceAll('{ets_julio}', 'JULIO ${periodo.anioEtsJulio}');
  }

  /// Las variables que de verdad usa este texto.
  List<String> get variablesUsadas =>
      [for (final v in variables.keys) if (plantilla.contains(v)) v];

  TextoDictamen copyWith({String? titulo, String? plantilla}) {
    return TextoDictamen(
      id: id,
      titulo: titulo ?? this.titulo,
      plantilla: plantilla ?? this.plantilla,
    );
  }
}

/// En qué va un alumno dentro del proceso de dictamen.
enum EtapaPredictamen {
  solicito('Solicitó predictamen'),
  entregoDocumentos('Entregó documentos'),
  dictaminado('Con dictamen');

  const EtapaPredictamen(this.etiqueta);

  final String etiqueta;
}

/// Un alumno en el proceso del Consejo Técnico.
class CasoConsejo {
  const CasoConsejo({
    required this.boleta,
    required this.nombre,
    required this.carrera,
    required this.etapa,
    this.documentos = const [],
    this.materiasAdeudadas = const [],
    this.periodosEnDictamen = 1,
    this.textoId,
    this.nota3 = '',
    this.solicitadoEl,
  });

  final String boleta;
  final String nombre;
  final String carrera;
  final EtapaPredictamen etapa;

  /// Los cinco de COSIE que entregó, por nombre corto.
  final List<String> documentos;

  /// Lo que debe. Sale de su expediente: es lo que el revisor copia a mano en
  /// la nota 3 cada vez.
  final List<String> materiasAdeudadas;

  /// Cuántos periodos escolares lleva en dictamen. Es el "(1 p.e.)" y
  /// "(2 p.e.)" de los títulos de los textos.
  final int periodosEnDictamen;

  /// Cuál de los doce textos le tocó.
  final String? textoId;

  /// El texto libre que acompaña al dictamen, normalmente la lista de
  /// materias.
  final String nota3;

  final DateTime? solicitadoEl;

  bool get tieneDictamen => textoId != null;

  /// La nota 3 armada con lo que el sistema ya sabe.
  ///
  /// Hoy quien captura la escribe a mano, mirando el expediente en otra
  /// pantalla. Las materias ya están en la base.
  String get nota3Sugerida {
    if (materiasAdeudadas.isEmpty) return '';
    final cuales = materiasAdeudadas.join(', ');
    return periodosEnDictamen > 1
        ? 'SEGUNDO DICTAMEN POR: $cuales.'
        : 'PRIMER DICTAMEN POR: $cuales.';
  }

  CasoConsejo copyWith({
    EtapaPredictamen? etapa,
    String? textoId,
    String? nota3,
  }) {
    return CasoConsejo(
      boleta: boleta,
      nombre: nombre,
      carrera: carrera,
      etapa: etapa ?? this.etapa,
      documentos: documentos,
      materiasAdeudadas: materiasAdeudadas,
      periodosEnDictamen: periodosEnDictamen,
      textoId: textoId ?? this.textoId,
      nota3: nota3 ?? this.nota3,
      solicitadoEl: solicitadoEl,
    );
  }
}

/// Los datos de la sesión del consejo que se imprimen en cada dictamen.
class SesionConsejo {
  const SesionConsejo({
    required this.numeroConsejo,
    required this.fechaSesion,
    required this.numeroSesion,
    required this.numeroAbreviado,
    required this.presidente,
    required this.secretario,
  });

  final String numeroConsejo;
  final String fechaSesion;
  final String numeroSesion;
  final String numeroAbreviado;
  final String presidente;
  final String secretario;

  SesionConsejo copyWith({
    String? numeroConsejo,
    String? fechaSesion,
    String? numeroSesion,
    String? numeroAbreviado,
    String? presidente,
    String? secretario,
  }) {
    return SesionConsejo(
      numeroConsejo: numeroConsejo ?? this.numeroConsejo,
      fechaSesion: fechaSesion ?? this.fechaSesion,
      numeroSesion: numeroSesion ?? this.numeroSesion,
      numeroAbreviado: numeroAbreviado ?? this.numeroAbreviado,
      presidente: presidente ?? this.presidente,
      secretario: secretario ?? this.secretario,
    );
  }
}
