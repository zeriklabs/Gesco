/// Información de dirección asociada a un Código Postal.
class CodigoPostalInfo {
  const CodigoPostalInfo({
    required this.estado,
    required this.municipio,
    required this.colonias,
  });

  final String estado;
  final String municipio;
  final List<String> colonias;

  /// La colonia principal o primera en la lista.
  String get primeraColonia => colonias.isNotEmpty ? colonias.first : '';
}
