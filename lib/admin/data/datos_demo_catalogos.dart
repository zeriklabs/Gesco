import 'package:flutter/material.dart';

import '../models/catalogo.dart';

/// Los ocho catálogos de Gestión Escolar.
///
/// TODO(backend): las definiciones se quedan, los renglones salen de la API.
///
/// Las definiciones están copiadas del sistema real: los mismos campos, en el
/// mismo orden. Los renglones son de ejemplo —el sistema real tiene 463
/// materias y 4,481 usuarios— pero suficientes para ver cómo se comporta la
/// tabla con búsqueda y paginado.
abstract final class DatosDemoCatalogos {
  static const carreras = <String>[
    'ING. MECATRÓNICA',
    'ING. EN ALIMENTOS',
    'ING. EN SISTEMAS COMPUTACIONALES',
    'ING. AMBIENTAL',
    'ING. METALÚRGICA',
    'ING. EN INTELIGENCIA ARTIFICIAL',
  ];

  static const niveles = <String>[
    'NIVEL 1',
    'NIVEL 2',
    'NIVEL 3',
    'NIVEL 4',
    'NIVEL 5',
  ];

  /// La abreviatura de carrera que usan los grupos: 1**MM**1.
  static const _siglas = <String, String>{
    'ING. MECATRÓNICA': 'MM',
    'ING. EN ALIMENTOS': 'MA',
    'ING. EN SISTEMAS COMPUTACIONALES': 'CM',
    'ING. AMBIENTAL': 'MB',
    'ING. METALÚRGICA': 'MT',
    'ING. EN INTELIGENCIA ARTIFICIAL': 'IA',
  };

  // --- Definiciones --------------------------------------------------------

  static final definiciones = <DefinicionCatalogo>[
    const DefinicionCatalogo(
      id: 'documentos',
      singular: 'un documento',
      nombre: 'Documentos',
      paraQue: 'Lo que se pide en cada trámite.',
      icono: Icons.description_outlined,
      dependen: ['—'],
      campos: [
        CampoCatalogo(
          clave: 'nombre',
          etiqueta: 'Nombre corto',
          ayuda: 'Sin espacios ni acentos.',
        ),
        CampoCatalogo(
          clave: 'descripcion',
          etiqueta: 'Descripción',
          ayuda: 'Lo que ve el alumno.',
        ),
        CampoCatalogo(
          clave: 'dirigido',
          etiqueta: '¿Dirigido a?',
          tipo: TipoCampo.seleccion,
          opciones: ['Nuevo ingreso', 'Reinscripción', 'Ambos', 'COSIE'],
          ayuda: 'Decide a quién se le pide.',
        ),
      ],
    ),
    const DefinicionCatalogo(
      id: 'carreras',
      singular: 'una carrera',
      nombre: 'Carreras',
      paraQue: 'Los programas académicos de la unidad.',
      icono: Icons.school_outlined,
      dependen: ['niveles', 'grupos', 'materias', 'equivalencias'],
      campos: [
        CampoCatalogo(clave: 'nombre', etiqueta: 'Nombre'),
      ],
    ),
    const DefinicionCatalogo(
      id: 'niveles',
      singular: 'un nivel',
      nombre: 'Niveles',
      paraQue: 'Los cinco niveles de cada carrera.',
      icono: Icons.stairs_outlined,
      dependen: ['grupos', 'materias'],
      campos: [
        CampoCatalogo(clave: 'nombre', etiqueta: 'Nombre'),
        CampoCatalogo(
          clave: 'carrera',
          etiqueta: 'Carrera',
          tipo: TipoCampo.seleccion,
          opcionesDe: 'carreras',
        ),
      ],
    ),
    const DefinicionCatalogo(
      id: 'grupos',
      singular: 'un grupo',
      nombre: 'Grupos',
      paraQue: 'Los grupos que el alumno elige al inscribirse.',
      icono: Icons.groups_outlined,
      campos: [
        CampoCatalogo(
          clave: 'nombre',
          etiqueta: 'Nombre',
          ayuda: 'Patrón: nivel + siglas + número. 3CM1.',
        ),
        CampoCatalogo(
          clave: 'carrera',
          etiqueta: 'Carrera',
          tipo: TipoCampo.seleccion,
          opcionesDe: 'carreras',
        ),
        CampoCatalogo(
          clave: 'nivel',
          etiqueta: 'Nivel',
          tipo: TipoCampo.seleccion,
          opciones: niveles,
        ),
      ],
    ),
    const DefinicionCatalogo(
      id: 'materias',
      singular: 'una materia',
      nombre: 'Unidades de aprendizaje',
      paraQue: 'El plan de estudios y sus créditos.',
      icono: Icons.menu_book_outlined,
      dependen: ['equivalencias'],
      campos: [
        CampoCatalogo(clave: 'nombre', etiqueta: 'Nombre'),
        CampoCatalogo(
          clave: 'creditos',
          etiqueta: 'Créditos',
          tipo: TipoCampo.numero,
        ),
        CampoCatalogo(
          clave: 'carrera',
          etiqueta: 'Carrera',
          tipo: TipoCampo.seleccion,
          opcionesDe: 'carreras',
        ),
        CampoCatalogo(
          clave: 'nivel',
          etiqueta: 'Nivel',
          tipo: TipoCampo.seleccion,
          opciones: niveles,
        ),
      ],
    ),
    const DefinicionCatalogo(
      id: 'equivalencias',
      singular: 'una equivalencia',
      nombre: 'Equivalencias',
      paraQue: 'Qué materia de una carrera cuenta en otra.',
      icono: Icons.swap_horiz_rounded,
      campos: [
        CampoCatalogo(clave: 'materia', etiqueta: 'Unidad de aprendizaje'),
        CampoCatalogo(
          clave: 'carrera',
          etiqueta: 'Carrera',
          tipo: TipoCampo.seleccion,
          opcionesDe: 'carreras',
        ),
        CampoCatalogo(
          clave: 'equivalente',
          etiqueta: 'Equivalente en',
          tipo: TipoCampo.seleccion,
          opcionesDe: 'carreras',
        ),
      ],
    ),
    const DefinicionCatalogo(
      id: 'periodos',
      singular: 'un periodo',
      nombre: 'Periodos',
      paraQue: 'Los semestres. Uno activo a la vez.',
      icono: Icons.event_outlined,
      unicoActivo: 'actual',
      campos: [
        CampoCatalogo(
          clave: 'nombre',
          etiqueta: 'Nombre',
          ayuda: 'Por ejemplo: 27/1 (AGO 2026 - ENE 2027)',
        ),
        CampoCatalogo(
          clave: 'mitad',
          etiqueta: 'Periodo',
          tipo: TipoCampo.seleccion,
          opciones: ['1', '2'],
        ),
        CampoCatalogo(
          clave: 'actual',
          etiqueta: '¿Activo?',
          tipo: TipoCampo.siNo,
        ),
      ],
    ),
    const DefinicionCatalogo(
      id: 'usuarios',
      singular: 'un usuario',
      nombre: 'Usuarios',
      paraQue: 'Las cuentas de los alumnos.',
      icono: Icons.badge_outlined,
      soloLectura: true,
      campos: [
        CampoCatalogo(clave: 'boleta', etiqueta: 'Boleta'),
        CampoCatalogo(clave: 'correo', etiqueta: 'Correo'),
        CampoCatalogo(
          clave: 'curp',
          etiqueta: 'CURP',
          enLista: false,
          sensible: true,
        ),
        CampoCatalogo(clave: 'celular', etiqueta: 'Celular', enLista: false),
        CampoCatalogo(
          clave: 'seguro',
          etiqueta: 'Institución de seguro',
          enLista: false,
        ),
      ],
    ),
  ];

  static DefinicionCatalogo definicion(String id) =>
      definiciones.firstWhere((d) => d.id == id);

  // --- Renglones -----------------------------------------------------------

  static final _datos = <String, List<Map<String, String>>>{
    'documentos': [
      for (final d in const [
        ('donativo', 'Comprobante del donativo', 'Ambos'),
        ('pordebajominima',
            'Oficio de dirección · inscripción por debajo de la mínima',
            'Reinscripción'),
        ('DICTAMENCT', 'Dictamen de COSIE del CT', 'Reinscripción'),
        ('DictamenCG', 'Dictamen de COSIE del CG', 'Reinscripción'),
        ('bajatemporal', 'Oficio de baja temporal', 'Reinscripción'),
        ('horariosaes', 'Comprobante de horario del SAES', 'Reinscripción'),
        ('DatosSAES', 'Actualización de datos del SAES', 'Reinscripción'),
        ('cambio_programa_academico',
            'Documentos de cambio de programa académico', 'Reinscripción'),
        ('Inscripcion', 'Documento de inscripción', 'Nuevo ingreso'),
        ('Resultados', 'Hoja de resultados', 'Nuevo ingreso'),
        ('consindocumentos', 'Solicitud de inscripción con o sin documentos',
            'Nuevo ingreso'),
        ('curp', 'CURP', 'Nuevo ingreso'),
        ('oficio_cosie', 'Oficio para el consejo', 'COSIE'),
        ('solicitud_dictamen', 'Solicitud de dictamen', 'COSIE'),
        ('boleta saes', 'Boleta global', 'COSIE'),
        ('documentoscomprobatorios', 'Documentos comprobatorios', 'COSIE'),
        ('estado general SAES', 'Estado general del SAES', 'COSIE'),
      ])
        {'nombre': d.$1, 'descripcion': d.$2, 'dirigido': d.$3},
    ],
    'carreras': [for (final c in carreras) {'nombre': c}],
    'niveles': [
      for (final c in carreras)
        for (final n in niveles) {'nombre': n, 'carrera': c},
    ],
    'grupos': [
      for (final c in carreras)
        for (var nivel = 1; nivel <= 5; nivel++)
          for (var g = 1; g <= 4; g++)
            {
              'nombre': '$nivel${_siglas[c]}$g',
              'carrera': c,
              'nivel': 'NIVEL $nivel',
            },
    ],
    'materias': [
      for (final m in const [
        ('ÁLGEBRA LINEAL Y NÚMEROS COMPLEJOS', '9', 'NIVEL 1'),
        ('ANÁLISIS Y DISEÑO DE PROGRAMAS', '3', 'NIVEL 2'),
        ('CÁLCULO DIFERENCIAL E INTEGRAL', '9', 'NIVEL 1'),
        ('CÁLCULO VECTORIAL', '9', 'NIVEL 2'),
        ('CIRCUITOS ELÉCTRICOS', '4.5', 'NIVEL 1'),
        ('CIRCUITOS ELÉCTRICOS AVANZADOS', '7.5', 'NIVEL 2'),
        ('DIBUJO ASISTIDO POR COMPUTADORA', '3', 'NIVEL 1'),
        ('ECUACIONES DIFERENCIALES', '9', 'NIVEL 2'),
        ('ELECTRICIDAD Y MAGNETISMO', '9', 'NIVEL 2'),
        ('ESTRUCTURA Y PROPIEDADES DE LOS MATERIALES', '7.5', 'NIVEL 1'),
        ('FÍSICA DEL MOVIMIENTO APLICADA', '7.5', 'NIVEL 1'),
        ('MATEMÁTICAS DISCRETAS', '7.5', 'NIVEL 2'),
        ('PROBABILIDAD Y ESTADÍSTICA', '7.5', 'NIVEL 2'),
        ('TEORÍA DE LA COMPUTACIÓN', '7.5', 'NIVEL 3'),
      ])
        for (final c in const [
          'ING. MECATRÓNICA',
          'ING. EN SISTEMAS COMPUTACIONALES',
        ])
          {'nombre': m.$1, 'creditos': m.$2, 'carrera': c, 'nivel': m.$3},
    ],
    'equivalencias': [
      for (final e in const [
        ('CÁLCULO DIFERENCIAL E INTEGRAL', 'ING. AMBIENTAL',
            'ING. EN ALIMENTOS'),
        ('CÁLCULO DIFERENCIAL E INTEGRAL', 'ING. EN ALIMENTOS',
            'ING. EN SISTEMAS COMPUTACIONALES'),
        ('CÁLCULO DIFERENCIAL E INTEGRAL', 'ING. AMBIENTAL',
            'ING. MECATRÓNICA'),
        ('FÍSICA DEL MOVIMIENTO APLICADA', 'ING. AMBIENTAL',
            'ING. EN ALIMENTOS'),
        ('FÍSICA DEL MOVIMIENTO APLICADA', 'ING. AMBIENTAL',
            'ING. MECATRÓNICA'),
        ('PROBABILIDAD Y ESTADÍSTICA', 'ING. METALÚRGICA',
            'ING. EN SISTEMAS COMPUTACIONALES'),
      ])
        {'materia': e.$1, 'carrera': e.$2, 'equivalente': e.$3},
    ],
    'periodos': [
      {'nombre': '27/1 (AGO 2026 - ENE 2027)', 'mitad': '1', 'actual': 'Sí'},
      {'nombre': '26/2 (FEB - JUL 2026)', 'mitad': '2', 'actual': 'No'},
      {'nombre': '26/1 (AGO 2025 - ENE 2026)', 'mitad': '1', 'actual': 'No'},
      {'nombre': '25/2 (FEB - JUL 2025)', 'mitad': '2', 'actual': 'No'},
      {'nombre': '25/1 (AGO 2024 - ENE 2025)', 'mitad': '1', 'actual': 'No'},
    ],
    'usuarios': [
      for (var i = 1; i <= 24; i++)
        {
          'boleta': '20${20 + (i % 7)}6700${i.toString().padLeft(2, '0')}',
          'correo': 'alumno$i@example.com',
          'curp': 'XXXX000000XXXXXX00',
          'celular': 'Sin registrar',
          'seguro': i.isEven ? 'IMSS' : 'Sin registrar',
        },
    ],
  };

  static List<Map<String, String>> filas(String id) => _datos[id] ?? [];

  static void agregar(String id, Map<String, String> fila) {
    _datos[id]?.add(fila);
    _aplicarUnicoActivo(id, fila);
  }

  static void reemplazar(String id, int indice, Map<String, String> fila) {
    final lista = _datos[id];
    if (lista == null || indice < 0 || indice >= lista.length) return;
    lista[indice] = fila;
    _aplicarUnicoActivo(id, fila);
  }

  static void quitar(String id, int indice) {
    final lista = _datos[id];
    if (lista == null || indice < 0 || indice >= lista.length) return;
    lista.removeAt(indice);
  }

  /// Deja un solo renglón marcado como activo.
  static void _aplicarUnicoActivo(String id, Map<String, String> fila) {
    final campo = definicion(id).unicoActivo;
    if (campo == null || fila[campo] != 'Sí') return;

    for (final otra in _datos[id]!) {
      if (!identical(otra, fila)) otra[campo] = 'No';
    }
  }

  /// Cuántos renglones de otros catálogos se quedarían colgando si se borra
  /// este valor.
  ///
  /// El sistema actual tiene una X roja por renglón y ya. Borrar una carrera
  /// deja sin padre a sus niveles, sus grupos y sus materias, y nadie avisa.
  static Map<String, int> dependientesDe(String id, Map<String, String> fila) {
    final def = definicion(id);
    final valor = fila[def.campos.first.clave];
    if (valor == null) return {};

    final cuenta = <String, int>{};
    for (final otra in definiciones) {
      if (otra.id == id) continue;
      final apunta = otra.campos.any((c) => c.opcionesDe == id);
      if (!apunta) continue;

      final clave = otra.campos.firstWhere((c) => c.opcionesDe == id).clave;
      final n = filas(otra.id).where((f) => f[clave] == valor).length;
      if (n > 0) cuenta[otra.nombre] = n;
    }
    return cuenta;
  }

  // --- El árbol: carrera → nivel → grupos y materias ----------------------

  static List<Map<String, String>> nivelesDe(String carrera) =>
      filas('niveles').where((f) => f['carrera'] == carrera).toList();

  static List<Map<String, String>> gruposDe(String carrera, String nivel) =>
      filas('grupos')
          .where((f) => f['carrera'] == carrera && f['nivel'] == nivel)
          .toList();

  static List<Map<String, String>> materiasDe(String carrera, String nivel) =>
      filas('materias')
          .where((f) => f['carrera'] == carrera && f['nivel'] == nivel)
          .toList();

  static List<Map<String, String>> equivalenciasDe(
    String materia,
    String carrera,
  ) =>
      filas('equivalencias')
          .where((f) => f['materia'] == materia && f['carrera'] == carrera)
          .toList();

  /// El índice real de un renglón, para poder editarlo o quitarlo.
  static int indiceDe(String idCatalogo, Map<String, String> fila) {
    final lista = filas(idCatalogo);
    for (var i = 0; i < lista.length; i++) {
      if (identical(lista[i], fila)) return i;
    }
    return -1;
  }

  /// Las opciones de un desplegable que lee de otro catálogo.
  static List<String> opcionesDe(String idCatalogo) {
    final def = definicion(idCatalogo);
    final clave = def.campos.first.clave;
    return [
      for (final f in filas(idCatalogo))
        if ((f[clave] ?? '').isNotEmpty) f[clave]!,
    ];
  }
}
