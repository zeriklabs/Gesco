import '../models/codigo_postal_info.dart';
import 'codigos_postales_data.dart';

/// Servicio de búsqueda rápida de Códigos Postales de México.
abstract final class CodigosPostales {
  /// Busca el estado, municipio y colonias asociadas a un código postal de 5 dígitos.
  /// Devuelve `null` si el CP no existe en la base oficial.
  static CodigoPostalInfo? buscar(String? cp) {
    if (cp == null) return null;
    final cpLimpio = cp.trim().padLeft(5, '0');
    return CodigosPostalesData.cpMap[cpLimpio];
  }
}
