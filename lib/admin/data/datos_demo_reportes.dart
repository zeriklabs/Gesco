import '../models/dictamen.dart';
import '../models/reporte.dart';
import '../models/revision.dart';
import 'datos_demo_admin.dart';
import 'datos_demo_consejo.dart';

/// Los tres reportes, armados con lo que el sistema ya tiene.
///
/// No hay una base de datos de reportes: un reporte es una vista de los
/// expedientes y de los casos del consejo. Por eso se arma aquí en lugar de
/// guardarse, y por eso siempre cuadra con lo que se ve en Validar y en
/// Consejo — hoy, en el sistema viejo, son consultas aparte que pueden no
/// coincidir.
///
/// TODO(backend): esto lo contesta la API; aquí vive la misma transformación.
abstract final class DatosDemoReportes {
  static List<FilaReporte> filas(Reporte reporte) => switch (reporte) {
        Reporte.nuevoIngreso =>
          _deExpedientes(TipoTramiteAlumno.inscripcion, Reporte.nuevoIngreso),
        Reporte.reingreso =>
          _deExpedientes(TipoTramiteAlumno.reinscripcion, Reporte.reingreso),
        Reporte.dictamenes => _deCasos(),
      };

  static List<FilaReporte> _deExpedientes(
    TipoTramiteAlumno tipo,
    Reporte reporte,
  ) {
    final expedientes =
        DatosDemoAdmin.expedientes.where((e) => e.tipo == tipo).toList()
          ..sort((a, b) => a.boleta.compareTo(b.boleta));

    return [
      for (final e in expedientes)
        FilaReporte(
          carrera: e.carrera,
          tono: _tonoEtapa(e.etapa),
          valores: {
            'boleta': e.boleta,
            'alumno': e.nombre,
            'carrera': e.carrera,
            'carga': e.tipoCarga ?? '—',
            'documentos': '${e.aprobados}/${e.aplicables.length}',
            'etapa': e.etapa.corta,
          },
        ),
    ];
  }

  static List<FilaReporte> _deCasos() {
    final casos = [...DatosDemoConsejo.casos]
      ..sort((a, b) => a.boleta.compareTo(b.boleta));

    return [
      for (final c in casos)
        FilaReporte(
          carrera: c.carrera,
          tono: _tonoPredictamen(c.etapa),
          valores: {
            'boleta': c.boleta,
            'alumno': c.nombre,
            'carrera': c.carrera,
            'pe': '${c.periodosEnDictamen}',
            'dictamen': DatosDemoConsejo.texto(c.textoId)?.titulo ?? '—',
            'etapa': c.etapa.etiqueta,
          },
        ),
    ];
  }

  static TonoFila _tonoEtapa(EtapaExpediente etapa) => switch (etapa) {
        EtapaExpediente.corrigiendo => TonoFila.falta,
        EtapaExpediente.esperandoRevision => TonoFila.enCurso,
        EtapaExpediente.validado => TonoFila.listo,
      };

  static TonoFila _tonoPredictamen(EtapaPredictamen etapa) => switch (etapa) {
        EtapaPredictamen.solicito => TonoFila.falta,
        EtapaPredictamen.entregoDocumentos => TonoFila.enCurso,
        EtapaPredictamen.dictaminado => TonoFila.listo,
      };

  /// Las etapas del reporte con su cuenta, en el orden en que avanzan.
  ///
  /// Se recorren las etapas del enum, no las que aparecen en los datos: una
  /// etapa en cero también es información —"nadie está corrigiendo"— y si solo
  /// se listaran las que traen gente, el resumen cambiaría de forma cada vez.
  static List<(String, int, TonoFila)> resumen(Reporte reporte) {
    final filas = DatosDemoReportes.filas(reporte);

    // Se usa la etiqueta corta, la misma que va en la pastilla: si el resumen
    // dijera "corrigiendo observaciones" y el renglón "Corrigiendo", parecen
    // dos cosas distintas.
    final etapas = reporte == Reporte.dictamenes
        ? [
            for (final e in EtapaPredictamen.values)
              (e.etiqueta, _tonoPredictamen(e)),
          ]
        : [
            for (final e in EtapaExpediente.values)
              (e.corta, _tonoEtapa(e)),
          ];

    return [
      for (final (etiqueta, tono) in etapas)
        (etiqueta, filas.where((f) => f['etapa'] == etiqueta).length, tono),
    ];
  }

  /// Las carreras que de verdad aparecen en este reporte.
  static List<String> carreras(Reporte reporte) {
    final todas = {for (final f in filas(reporte)) f.carrera}.toList()..sort();
    return todas;
  }

  /// El reporte como CSV, con el encabezado que diga la columna.
  ///
  /// Se exporta lo mismo que se ve, incluidas las columnas que en celular no
  /// caben: el archivo no tiene por qué perder datos porque se pidió desde un
  /// teléfono.
  static String csv(Reporte reporte, List<FilaReporte> filas) {
    final lineas = <String>[
      [for (final c in reporte.columnas) _campo(c.titulo)].join(','),
      for (final f in filas)
        [for (final c in reporte.columnas) _campo(f[c.clave])].join(','),
    ];
    return lineas.join('\r\n');
  }

  static String _campo(String valor) {
    if (!valor.contains(',') && !valor.contains('"') && !valor.contains('\n')) {
      return valor;
    }
    return '"${valor.replaceAll('"', '""')}"';
  }
}
