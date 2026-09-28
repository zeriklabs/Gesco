/// Una materia del periodo.
///
/// En los formatos oficiales se llama **unidad de aprendizaje** (UAp). En la
/// interfaz le decimos materia, que es como le dice todo el mundo; el término
/// oficial aparece donde el alumno lo va a ver impreso.
class Materia {
  const Materia({
    required this.id,
    required this.nombre,
    required this.nivel,
    required this.creditos,
    this.grupo,
    this.semestre,
    this.estado = 'NORMAL',
  });

  final String id;
  final String nombre;
  final String nivel;
  final int creditos;
  final String? grupo;
  final String? semestre;

  /// NORMAL, RECURSAMIENTO, ETS… el mismo catálogo que los adeudos.
  final String estado;

  /// La línea corta que la identifica debajo del nombre.
  String get detalle {
    final partes = <String>[
      nivel,
      if (grupo != null) 'Grupo $grupo',
      '$creditos créditos',
    ];
    return partes.join(' · ');
  }
}
