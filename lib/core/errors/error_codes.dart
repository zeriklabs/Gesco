import 'package:flutter/foundation.dart';

/// Clasificación y análisis de errores estandarizados de GESCO.
class GescoErrorDetails {
  final String code;
  final String categoryName;
  final String title;
  final String userMessage;
  final String technicalMessage;
  final String? stackTrace;
  final DateTime timestamp;
  final String actionHint;

  GescoErrorDetails({
    required this.code,
    required this.categoryName,
    required this.title,
    required this.userMessage,
    required this.technicalMessage,
    this.stackTrace,
    DateTime? timestamp,
    required this.actionHint,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Genera un informe en texto plano listo para copiar al portapapeles.
  String get formattedReport {
    final buffer = StringBuffer();
    buffer.writeln('==================================================');
    buffer.writeln('        INFORME DE ERROR - GESCO UPIIZ            ');
    buffer.writeln('==================================================');
    buffer.writeln('Código de Error : $code');
    buffer.writeln('Categoría       : $categoryName');
    buffer.writeln('Fecha y Hora    : ${timestamp.toIso8601String()}');
    buffer.writeln('Plataforma      : ${defaultTargetPlatform.name}');
    buffer.writeln('--------------------------------------------------');
    buffer.writeln('TÍTULO / TIPO:');
    buffer.writeln(title);
    buffer.writeln('');
    buffer.writeln('MENSAJE DE ERROR TÉCNICO:');
    buffer.writeln(technicalMessage);
    if (stackTrace != null && stackTrace!.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('TRAZA DE PILA (STACKTRACE):');
      buffer.writeln(stackTrace);
    }
    buffer.writeln('==================================================');
    buffer.writeln('Por favor envía este informe al soporte técnico de GESCO.');
    return buffer.toString();
  }
}

/// Analizador automático de excepciones y errores de Flutter.
class GescoErrorAnalyzer {
  static GescoErrorDetails analyze(dynamic error, [StackTrace? stackTrace]) {
    final errorStr = error.toString();
    final stackStr = stackTrace?.toString();

    // 1. Interfaz y Renderizado (ER-01XX)
    if (errorStr.contains('RenderFlex overflowed') ||
        errorStr.contains('A RenderFlex overflowed') ||
        errorStr.contains('overflowed by')) {
      return GescoErrorDetails(
        code: 'ER-0101',
        categoryName: 'Interfaz y Renderizado',
        title: 'Desbordamiento de Pantalla (RenderFlex)',
        userMessage:
            'Los elementos visuales de esta pantalla exceden el espacio disponible. Se sugiere ajustar la ventana o recargar.',
        technicalMessage: errorStr,
        stackTrace: stackStr,
        actionHint: 'Te sugerimos recargar la pantalla o girar el dispositivo.',
      );
    }

    if (errorStr.contains('FlutterError') ||
        errorStr.contains('Widget') ||
        errorStr.contains('setState() called after dispose()') ||
        errorStr.contains('InheritedWidget')) {
      return GescoErrorDetails(
        code: 'ER-0102',
        categoryName: 'Interfaz y Renderizado',
        title: 'Error de Construcción de Interfaz',
        userMessage:
            'Ocurrió un inconveniente al dibujar los componentes en pantalla.',
        technicalMessage: errorStr,
        stackTrace: stackStr,
        actionHint: 'Intenta recargar la página o volver al menú principal.',
      );
    }

    // 2. Red y Conectividad (ER-02XX)
    if (errorStr.contains('SocketException') ||
        errorStr.contains('Failed host lookup') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('NetworkImageLoadException') ||
        errorStr.contains('No internet') ||
        errorStr.contains('connection failed')) {
      return GescoErrorDetails(
        code: 'ER-0201',
        categoryName: 'Red y Conectividad',
        title: 'Sin Conexión a la Red',
        userMessage:
            'No fue posible establecer comunicación con los servidores de GESCO. Comprueba tu conexión a Internet.',
        technicalMessage: errorStr,
        stackTrace: stackStr,
        actionHint:
            'Verifica tu conexión a Wi-Fi o datos móviles y presiona recargar.',
      );
    }

    if (errorStr.contains('TimeoutException') ||
        errorStr.contains('Connection timed out') ||
        errorStr.contains('timeout')) {
      return GescoErrorDetails(
        code: 'ER-0202',
        categoryName: 'Red y Conectividad',
        title: 'Tiempo de Espera Agotado',
        userMessage:
            'El servidor tardó demasiado en responder a la solicitud.',
        technicalMessage: errorStr,
        stackTrace: stackStr,
        actionHint:
            'Tu red o el servidor están lentos. Por favor reintenta en unos momentos.',
      );
    }

    // 3. Servidor y API (ER-03XX)
    if (errorStr.contains('500') ||
        errorStr.contains('Internal Server Error')) {
      return GescoErrorDetails(
        code: 'ER-0301',
        categoryName: 'Servidor y API',
        title: 'Error Interno del Servidor (500)',
        userMessage:
            'El servidor de GESCO detectó un fallo interno al procesar la información.',
        technicalMessage: errorStr,
        stackTrace: stackStr,
        actionHint:
            'Copia el código de error y contáctate con el desarrollador o administrador de GESCO.',
      );
    }

    if (errorStr.contains('503') ||
        errorStr.contains('Service Unavailable') ||
        errorStr.contains('502')) {
      return GescoErrorDetails(
        code: 'ER-0302',
        categoryName: 'Servidor y API',
        title: 'Servicio Temporalmente No Disponible (503)',
        userMessage:
            'El sistema GESCO se encuentra en mantenimiento temporal o saturado.',
        technicalMessage: errorStr,
        stackTrace: stackStr,
        actionHint:
            'Espera un par de minutos e intenta recargar nuevamente.',
      );
    }

    // 4. Datos y Estado (ER-04XX)
    if (errorStr.contains('Null check operator used on a null value') ||
        errorStr.contains('NoSuchMethodError') ||
        errorStr.contains('is not a subtype of type')) {
      return GescoErrorDetails(
        code: 'ER-0401',
        categoryName: 'Datos y Estado',
        title: 'Error de Lectura de Datos',
        userMessage:
            'Un valor requerido de información escolar venía incompleto o nulo.',
        technicalMessage: errorStr,
        stackTrace: stackStr,
        actionHint:
            'Copia el código de error para notificar al desarrollador.',
      );
    }

    if (errorStr.contains('FormatException') ||
        errorStr.contains('JSON') ||
        errorStr.contains('Unexpected character')) {
      return GescoErrorDetails(
        code: 'ER-0402',
        categoryName: 'Datos y Estado',
        title: 'Error en Formato de Respuesta',
        userMessage:
            'La estructura de los datos recibidos no coincide con el formato esperado.',
        technicalMessage: errorStr,
        stackTrace: stackStr,
        actionHint:
            'Prueba recargando. Si continúa el fallo, contacta al soporte técnico.',
      );
    }

    if (errorStr.contains('StateError') ||
        errorStr.contains('Bad state') ||
        errorStr.contains('Unhandled Exception')) {
      return GescoErrorDetails(
        code: 'ER-0403',
        categoryName: 'Datos y Estado',
        title: 'Estado Inconsistente del Sistema',
        userMessage:
            'Se produjo un cambio inesperado en el estado interno de la pantalla.',
        technicalMessage: errorStr,
        stackTrace: stackStr,
        actionHint: 'Presiona el botón de recargar para reiniciar el flujo.',
      );
    }

    // 5. Genérico / Desconocido (ER-0999)
    return GescoErrorDetails(
      code: 'ER-0999',
      categoryName: 'Excepción No Manejada',
      title: 'Inconveniente Inesperado',
      userMessage:
          'Se ha producido un error inesperado durante la ejecución de la aplicación.',
      technicalMessage: errorStr,
      stackTrace: stackStr,
      actionHint:
          'Te sugerimos copiar el reporte de error y contactar con el desarrollador.',
    );
  }
}
