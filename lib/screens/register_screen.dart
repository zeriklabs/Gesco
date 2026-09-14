import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1; // 1, 2, 3, 4, 5

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();
  final _formKeyStep5 = GlobalKey<FormState>();

  // Estado ver/ocultar contraseña
  bool _obscureContrasena = true;
  bool _obscureRepiteContrasena = true;

  // DICCIONARIO: 32 ESTADOS DE MÉXICO Y SUS MUNICIPIOS
  static const Map<String, List<String>> _estadosYMunicipiosMexico = {
    'Aguascalientes': ['Aguascalientes', 'Asientos', 'Calvillo', 'Cosío', 'Jesús María', 'Pabellón de Arteaga', 'Rincón de Romos', 'San José de Gracia', 'Tepezalá', 'El Llano', 'San Francisco de los Romo'],
    'Baja California': ['Ensenada', 'Mexicali', 'Tecate', 'Tijuana', 'Playas de Rosarito', 'San Quintín', 'San Felipe'],
    'Baja California Sur': ['Comondú', 'Mulegé', 'La Paz', 'Los Cabos', 'Loreto'],
    'Campeche': ['Campeche', 'Calkiní', 'Carmen', 'Champotón', 'Hecelchakán', 'Hopelchén', 'Palizada', 'Tenabo', 'Escárcega', 'Calakmul', 'Candelaria', 'Seybaplaya', 'Dzitbalché'],
    'Chiapas': ['Tuxtla Gutiérrez', 'Tapachula', 'San Cristóbal de las Casas', 'Comitán de Domínguez', 'Palenque', 'Chiapa de Corzo', 'Ocosingo', 'Tonalá', 'Villaflores', 'Jiquipilas'],
    'Chihuahua': ['Chihuahua', 'Juárez', 'Delicias', 'Cuauhtémoc', 'Parral', 'Nuevo Casas Grandes', 'Camargo', 'Jiménez', 'Ojinaga', 'Bocoyna', 'Guachochi'],
    'Coahuila': ['Saltillo', 'Torreón', 'Monclova', 'Piedras Negras', 'Acuña', 'Matamoros', 'San Pedro', 'Frontera', 'Ramos Arizpe', 'Parras', 'Sabinas'],
    'Colima': ['Colima', 'Manzanillo', 'Tecomán', 'Villa de Álvarez', 'Armería', 'Comala', 'Coquimatlán', 'Cuauhtémoc', 'Ixtlahuacán', 'Minatitlán'],
    'Ciudad de México': ['Álvaro Obregón', 'Azcapotzalco', 'Benito Juárez', 'Coyoacán', 'Cuajimalpa de Morelos', 'Cuauhtémoc', 'Gustavo A. Madero', 'Iztacalco', 'Iztapalapa', 'Magdalena Contreras', 'Miguel Hidalgo', 'Milpa Alta', 'Tláhuac', 'Tlalpan', 'Venustiano Carranza', 'Xochimilco'],
    'Durango': ['Durango', 'Gómez Palacio', 'Lerdo', 'Pueblo Nuevo', 'Santiago Papasquiaro', 'Vicente Guerrero', 'Guadalupe Victoria', 'Canatlán'],
    'Guanajuato': ['Guanajuato', 'León', 'Irapuato', 'Celaya', 'Salamanca', 'Silao', 'San Miguel de Allende', 'Dolores Hidalgo', 'Pénjamo', 'Cortazar', 'Acámbaro'],
    'Guerrero': ['Acapulco de Juárez', 'Chilpancingo de los Bravo', 'Ixtapa-Zihuatanejo', 'Iguala de la Independencia', 'Taxco de Alarcón', 'Chilapa de Álvarez', 'Atoyac de Álvarez'],
    'Hidalgo': ['Pachuca de Soto', 'Tulancingo de Bravo', 'Tula de Allende', 'Mineral de la Reforma', 'Huejutla de Reyes', 'Tizayuca', 'Tepeji del Río', 'Ixmiquilpan'],
    'Jalisco': ['Guadalajara', 'Zapopan', 'San Pedro Tlaquepaque', 'Tonalá', 'Tlajomulco de Zúñiga', 'Puerto Vallarta', 'Lagos de Moreno', 'Tepatitlán de Morelos', 'Ciudad Guzmán', 'Autlán de Navarro', 'Arandas'],
    'Estado de México': ['Toluca', 'Ecatepec de Morelos', 'Nezahualcóyotl', 'Naucalpan de Juárez', 'Tlalnepantla de Baz', 'Chimalhuacán', 'Cuautitlán Izcalli', 'Atizapán de Zaragoza', 'Ixtapaluca', 'Tecámac', 'Metepec', 'Texcoco'],
    'Michoacán': ['Morelia', 'Uruapan', 'Zamora', 'Lázaro Cárdenas', 'Jiquilpan', 'Apatzingán', 'Pátzcuaro', 'Zitácuaro', 'La Piedad', 'Hidalgo', 'Sahuayo'],
    'Morelos': ['Cuernavaca', 'Jiutepec', 'Cuautla', 'Temixco', 'Jojutla', 'Yautepec', 'Ayala', 'Emiliano Zapata'],
    'Nayarit': ['Tepic', 'Bahía de Banderas', 'Compostela', 'Ixtlán del Río', 'Santiago Ixcuintla', 'Acaponeta', 'Tuxpan', 'San Blas', 'Tecuala'],
    'Nuevo León': ['Monterrey', 'Guadalupe', 'San Pedro Garza García', 'San Nicolás de los Garza', 'Apodaca', 'General Escobedo', 'Santa Catarina', 'Juárez', 'Cadereyta Jiménez', 'García', 'Linares'],
    'Oaxaca': ['Oaxaca de Juárez', 'San Juan Bautista Tuxtepec', 'Juchitán de Zaragoza', 'Santa Cruz Xoxocotlán', 'Salina Cruz', 'Huajuapan de León', 'Santa Lucía del Camino', 'Puerto Escondido', 'Miahuatlán de Porfirio Díaz'],
    'Puebla': ['Puebla', 'Tehuacán', 'San Martín Texmelucan', 'San Pedro Cholula', 'San Andrés Cholula', 'Atlixco', 'Amozoc', 'Huauchinango', 'Teziutlán'],
    'Querétaro': ['Santiago de Querétaro', 'San Juan del Río', 'El Marqués', 'Corregidora', 'Tequisquiapan', 'Pedro Escobedo', 'Cadereyta de Montes', 'Jalpan de Serra'],
    'Quintana Roo': ['Cancún (Benito Juárez)', 'Chetumal (Othón P. Blanco)', 'Playa del Carmen (Solidaridad)', 'Cozumel', 'Felipe Carrillo Puerto', 'Tulum', 'Puerto Morelos', 'Isla Mujeres'],
    'San Luis Potosí': ['San Luis Potosí', 'Soledad de Graciano Sánchez', 'Ciudad Valles', 'Matehuala', 'Rioverde', 'Tamazunchale', 'Cárdenas', 'Cerritos'],
    'Sinaloa': ['Culiacán', 'Mazatlán', 'Ahome (Los Mochis)', 'Guasave', 'Navolato', 'Escuinapa', 'El Fuerte', 'Salvador Alvarado (Guamúchil)'],
    'Sonora': ['Hermosillo', 'Cajeme (Ciudad Obregón)', 'Nogales', 'San Luis Río Colorado', 'Navojoa', 'Guaymas', 'Puerto Peñasco', 'Agua Prieta'],
    'Tabasco': ['Villahermosa (Centro)', 'Cárdenas', 'Comalcalco', 'Huimanguillo', 'Macuspana', 'Cunduacán', 'Paraíso', 'Tenosique'],
    'Tamaulipas': ['Reynosa', 'Heroica Matamoros', 'Nuevo Laredo', 'Ciudad Victoria', 'Tampico', 'Ciudad Madero', 'Altamira', 'El Mante', 'Río Bravo'],
    'Tlaxcala': ['Tlaxcala', 'Apizaco', 'Huamantla', 'Chiautempan', 'San Pablo del Monte', 'Calpulalpan', 'Contla de Juan Cuamatzi'],
    'Veracruz': ['Xalapa', 'Veracruz', 'Coatzacoalcos', 'Córdoba', 'Poza Rica de Hidalgo', 'Orizaba', 'Minatitlán', 'Boca del Río', 'Tuxpan', 'Tuxtepec'],
    'Yucatán': ['Mérida', 'Kanasín', 'Valladolid', 'Tizimín', 'Progreso', 'Umán', 'Tekax', 'Ticul'],
    'Zacatecas': ['Zacatecas', 'Guadalupe', 'Fresnillo', 'Jerez', 'Rio Grande', 'Sombrerete', 'Calera', 'Ojocaliente', 'Loreto', 'Nochistlán de Mejía', 'Pinos', 'Tlaltenango de Sánchez Román', 'Valparaíso', 'Villanueva'],
  };

  // Controllers - PASO 1 (Creando una cuenta)
  final _nombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _boletaController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _repiteContrasenaController = TextEditingController();
  final _correoController = TextEditingController();
  final _celularController = TextEditingController();

  String? _estadoSeleccionado;
  String? _municipioSeleccionado;
  DateTime? _selectedDate;

  // Controllers & Dropdowns - PASO 2 (Inscripción - Datos Personales)
  String? _generoSeleccionado;
  String? _estadoCivilSeleccionado;
  final _telefonoFijoController = TextEditingController();
  String _trabajasSeleccionado = 'No';

  // Domicilio Actual Alumno
  final _calleController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _numExtController = TextEditingController();
  final _numIntController = TextEditingController();
  final _cpController = TextEditingController();

  String? _estadoDomicilioSeleccionado;
  String? _municipioDomicilioSeleccionado;

  // Opciones de Parentesco
  static const List<String> _opcionesParentesco = [
    'Padre',
    'Madre',
    'Tutor Legal',
    'Abuelo/a',
    'Tío/a',
    'Hermano/a',
    'Otro',
  ];

  // Controllers - PASO 3 (Tutor)
  final _tutorNombreController = TextEditingController();
  final _tutorAppaternoController = TextEditingController();
  final _tutorApmaternoController = TextEditingController();
  String? _tutorParentescoSeleccionado;
  final _tutorTelefonoFijoController = TextEditingController();
  final _tutorCelularController = TextEditingController();
  final _tutorTelefonoTrabajoController = TextEditingController();

  // Domicilio Tutor
  final _tutorCalleController = TextEditingController();
  final _tutorColoniaController = TextEditingController();
  final _tutorNumExtController = TextEditingController();
  final _tutorNumIntController = TextEditingController();
  final _tutorCpController = TextEditingController();

  String? _tutorEstadoSeleccionado;
  String? _tutorMunicipioSeleccionado;

  // PASO 4: Foto
  bool _hasUploadedPhoto = false;
  int _selectedNameIndex = 0;

  // PASO 5: Estado de descarga y finalización
  bool _canFinish = false;

  List<String> _getNombresList() {
    final rawName = _nombreController.text.trim();
    if (rawName.isEmpty) {
      return ['Alumno'];
    }
    final tokens = rawName.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (tokens.length <= 1) {
      return [rawName];
    }

    final List<String> list = [rawName];

    const particulas = {
      'de', 'del', 'd', 'da', 'do', 'dos', 'das',
      'a', 'al', 'en', 'por', 'para', 'con', 'sin', 'sobre',
      'y', 'e',
      'la', 'las', 'los', 'el', 'un', 'una', 'unos', 'unas',
      'san', 'santo', 'santa', 'santos', 'santas',
      'don', 'dona', 'doña', 'sor', 'fray',
      'van', 'von', 'der', 'den', 'ter', 'ten',
      'di', 'du', 'des', 'le', 'les', 'ben', 'bin', 'ibn', 'st'
    };

    for (final token in tokens) {
      final cleanToken = token.replaceAll(RegExp(r'[^\wáéíóúñÁÉÍÓÚÑ]'), '');
      final tokenLower = cleanToken.toLowerCase();
      if (!particulas.contains(tokenLower) && !list.contains(cleanToken) && cleanToken.isNotEmpty) {
        list.add(cleanToken);
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _contrasenaController.addListener(_onPasswordChanged);
    _repiteContrasenaController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (_repiteContrasenaController.text.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _contrasenaController.removeListener(_onPasswordChanged);
    _repiteContrasenaController.removeListener(_onPasswordChanged);

    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _fechaNacimientoController.dispose();
    _boletaController.dispose();
    _contrasenaController.dispose();
    _repiteContrasenaController.dispose();
    _correoController.dispose();
    _celularController.dispose();

    _telefonoFijoController.dispose();
    _calleController.dispose();
    _coloniaController.dispose();
    _numExtController.dispose();
    _numIntController.dispose();
    _cpController.dispose();

    _tutorNombreController.dispose();
    _tutorAppaternoController.dispose();
    _tutorApmaternoController.dispose();
    _tutorTelefonoFijoController.dispose();
    _tutorCelularController.dispose();
    _tutorTelefonoTrabajoController.dispose();

    _tutorCalleController.dispose();
    _tutorColoniaController.dispose();
    _tutorNumExtController.dispose();
    _tutorNumIntController.dispose();
    _tutorCpController.dispose();
    super.dispose();
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 0.0;
    if (s1 == s2) return 100.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    int distance = matrix[s1.length][s2.length];
    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    double similarity = (1.0 - (distance / maxLength)) * 100;
    return similarity.clamp(0.0, 100.0);
  }

  Widget _buildPasswordMatchIndicator({bool isMobile = false}) {
    final pass1 = _contrasenaController.text;
    final pass2 = _repiteContrasenaController.text;

    if (pass2.isEmpty) {
      return const SizedBox.shrink();
    }

    final matchPct = _calculateSimilarity(pass1, pass2);

    Color color;
    String statusText;
    IconData iconData;

    if (matchPct == 100.0) {
      color = const Color(0xFF2E7D32);
      statusText = 'Las contraseñas coinciden 100%';
      iconData = Icons.check_circle_outline;
    } else if (matchPct >= 70.0) {
      color = Colors.orange[800]!;
      statusText = 'Coincidencia: ${matchPct.toStringAsFixed(0)}%';
      iconData = Icons.error_outline;
    } else {
      color = Colors.red[700]!;
      statusText = 'Coincidencia: ${matchPct.toStringAsFixed(0)}%';
      iconData = Icons.cancel_outlined;
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 2.0,
        bottom: 12.0,
        left: isMobile ? 0 : 165.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: matchPct / 100.0,
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);
    final firstDate = DateTime(1940);
    final lastDate = now;

    final pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('es', 'MX'),
      initialDate: _selectedDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF731C24),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _fechaNacimientoController.text =
            '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
      });
    }
  }

  void _copiarDomicilioAlumnoATutor() {
    setState(() {
      _tutorCalleController.text = _calleController.text;
      _tutorColoniaController.text = _coloniaController.text;
      _tutorNumExtController.text = _numExtController.text;
      _tutorNumIntController.text = _numIntController.text;
      _tutorCpController.text = _cpController.text;
      _tutorEstadoSeleccionado = _estadoDomicilioSeleccionado;
      _tutorMunicipioSeleccionado = _municipioDomicilioSeleccionado;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Domicilio del alumno copiado correctamente.'),
        backgroundColor: Color(0xFF731C24),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSiguientePaso1() {
    if (_formKeyStep1.currentState!.validate()) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  void _handleContinuarPaso2() {
    if (_formKeyStep2.currentState!.validate()) {
      setState(() {
        _currentStep = 3;
      });
    }
  }

  void _handleContinuarPaso3() {
    if (_formKeyStep3.currentState!.validate()) {
      setState(() {
        _currentStep = 4;
      });
    }
  }

  void _handleContinuarPaso4() {
    setState(() {
      _currentStep = 5;
    });
  }

  void _showPrintInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.print_outlined,
                      color: Color(0xFF731C24),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Instrucciones de impresión',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Por favor toma en cuenta las siguientes indicaciones para imprimir tu formato de inscripción:',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPrintInstructionItem(
                  icon: Icons.palette_outlined,
                  title: 'Impresión a color:',
                  text: 'Imprimir 2 veces el formato a color (2 juegos completos).',
                ),
                const SizedBox(height: 12),
                _buildPrintInstructionItem(
                  icon: Icons.flip_outlined,
                  title: 'Impresión a doble cara:',
                  text:
                      'Cada juego debe estar impreso por ambos lados (frente y vuelta), ya que el formato consta de 2 páginas.',
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Cierra el diálogo
                      Navigator.of(context).pop();

                      // Documentación: Aquí se lanzaría la descarga del documento
                      // TODO: Implementar lógica de descarga real (PDF, etc.)

                      setState(() {
                        _canFinish = true;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Documento listo para descargar.'),
                          backgroundColor: Color(0xFF731C24),
                        ),
                      );
                    },
                    child: const Text(
                      'Hecho',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF731C24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrintInstructionItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: const Color(0xFF731C24)),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGuinda = Color(0xFF731C24);
    const backgroundGray = Color(0xFFEBEBEB);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              color: primaryGuinda,
              child: Row(
                children: [
                  SizedBox(
                    height: 38,
                    child: Image.asset(
                      'assets/images/logo_ipn.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isMobile)
                    const Expanded(
                      child: Text(
                        'Sistema Integral de Gestión Escolar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const Spacer(),
                  if (_currentStep >= 2 && _currentStep <= 4)
                    const Text(
                      'Creando una cuenta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (_currentStep == 5)
                    Row(
                      children: [
                        if (!isMobile)
                          const Text(
                            'Bienvenido, Usuario',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.account_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: _buildCurrentStepView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1: return _buildStep1View();
      case 2: return _buildStep2View();
      case 3: return _buildStep3View();
      case 4: return _buildStep4View();
      case 5: return _buildStep5View();
      default: return _buildStep1View();
    }
  }

  // ==========================================
  // PASO 1: CREANDO UNA CUENTA
  // ==========================================
  Widget _buildStep1View() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isWideScreen = width > 900;

    final municipiosStep1 = _estadoSeleccionado != null
        ? (_estadosYMunicipiosMexico[_estadoSeleccionado] ?? [])
        : <String>[];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 36.0,
        vertical: 28.0,
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKeyStep1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Creando una cuenta',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Para empezar llena este formulario',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 36),
              if (isWideScreen)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildLabeledField(
                            'Nombre',
                            _nombreController,
                            key: const ValueKey('step1_nombre'),
                            autofillHints: const [AutofillHints.givenName],
                          ),
                          _buildLabeledField(
                            'Apellido Paterno',
                            _apellidoPaternoController,
                            key: const ValueKey('step1_appaterno'),
                            autofillHints: const [AutofillHints.familyName],
                          ),
                          _buildLabeledField(
                            'Apellido Materno',
                            _apellidoMaternoController,
                            key: const ValueKey('step1_apmaterno'),
                          ),
                          _buildFechaNacimientoField(),
                          _buildLabeledDropdown(
                            label: 'Estado de nacimiento',
                            value: _estadoSeleccionado,
                            items: _estadosYMunicipiosMexico.keys.toList(),
                            hintText: 'Selecciona Estado',
                            onChanged: (val) {
                              setState(() {
                                _estadoSeleccionado = val;
                                _municipioSeleccionado = null;
                              });
                            },
                          ),
                          _buildLabeledDropdown(
                            label: 'Municipio de nacimiento',
                            value: _municipioSeleccionado,
                            items: municipiosStep1,
                            hintText: _estadoSeleccionado == null
                                ? 'Selecciona primero Estado'
                                : 'Selecciona Municipio',
                            onChanged: (val) {
                              setState(() {
                                _municipioSeleccionado = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabeledField(
                            'Boleta/preboleta',
                            _boletaController,
                            key: const ValueKey('step1_boleta'),
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Campo requerido';
                              }
                              if (val.trim().length != 10) {
                                return 'La boleta debe tener 10 caracteres';
                              }
                              return null;
                            },
                          ),
                          _buildLabeledField(
                            'Contraseña',
                            _contrasenaController,
                            key: const ValueKey('step1_pass'),
                            obscureText: _obscureContrasena,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureContrasena
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureContrasena = !_obscureContrasena;
                                });
                              },
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Campo requerido';
                              }
                              if (val.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          _buildLabeledField(
                            'Repite tu contraseña',
                            _repiteContrasenaController,
                            key: const ValueKey('step1_repass'),
                            obscureText: _obscureRepiteContrasena,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureRepiteContrasena
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureRepiteContrasena = !_obscureRepiteContrasena;
                                });
                              },
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Campo requerido';
                              }
                              if (val != _contrasenaController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          _buildPasswordMatchIndicator(isMobile: isMobile),
                          _buildLabeledField(
                            'Correo Electrónico',
                            _correoController,
                            key: const ValueKey('step1_correo'),
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Campo requerido';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          _buildLabeledField(
                            'Celular',
                            _celularController,
                            key: const ValueKey('step1_celular'),
                            keyboardType: TextInputType.phone,
                            autofillHints: const [AutofillHints.telephoneNumberDevice],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildLabeledField('Nombre', _nombreController, key: const ValueKey('step1_m_nombre')),
                    _buildLabeledField('Apellido Paterno', _apellidoPaternoController, key: const ValueKey('step1_m_appaterno')),
                    _buildLabeledField('Apellido Materno', _apellidoMaternoController, key: const ValueKey('step1_m_apmaterno')),
                    _buildFechaNacimientoField(),
                    _buildLabeledDropdown(
                      label: 'Estado de nacimiento',
                      value: _estadoSeleccionado,
                      items: _estadosYMunicipiosMexico.keys.toList(),
                      hintText: 'Selecciona Estado',
                      onChanged: (val) {
                        setState(() {
                          _estadoSeleccionado = val;
                          _municipioSeleccionado = null;
                        });
                      },
                    ),
                    _buildLabeledDropdown(
                      label: 'Municipio de nacimiento',
                      value: _municipioSeleccionado,
                      items: municipiosStep1,
                      hintText: _estadoSeleccionado == null ? 'Selecciona primero Estado' : 'Selecciona Municipio',
                      onChanged: (val) {
                        setState(() {
                          _municipioSeleccionado = val;
                        });
                      },
                    ),
                    _buildLabeledField(
                      'Boleta/preboleta',
                      _boletaController,
                      key: const ValueKey('step1_m_boleta'),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Campo requerido';
                        if (val.trim().length != 10) return 'Debe tener 10 caracteres';
                        return null;
                      },
                    ),
                    _buildLabeledField(
                      'Contraseña',
                      _contrasenaController,
                      key: const ValueKey('step1_m_pass'),
                      obscureText: _obscureContrasena,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _obscureContrasena = !_obscureContrasena),
                      ),
                    ),
                    _buildLabeledField(
                      'Repite tu contraseña',
                      _repiteContrasenaController,
                      key: const ValueKey('step1_m_repass'),
                      obscureText: _obscureRepiteContrasena,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureRepiteContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _obscureRepiteContrasena = !_obscureRepiteContrasena),
                      ),
                    ),
                    _buildPasswordMatchIndicator(isMobile: isMobile),
                    _buildLabeledField('Correo Electrónico', _correoController, key: const ValueKey('step1_m_correo'), keyboardType: TextInputType.emailAddress),
                    _buildLabeledField('Celular', _celularController, key: const ValueKey('step1_m_celular'), keyboardType: TextInputType.phone),
                  ],
                ),
              const SizedBox(height: 36),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 48,
                  width: isMobile ? double.infinity : 160,
                  child: ElevatedButton(
                    onPressed: _handleSiguientePaso1,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF731C24),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Siguiente', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PASO 2: INSCRIPCIÓN (Paso 1)
  // ==========================================
  Widget _buildStep2View() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isWideScreen = width > 900;

    final nombreCompleto = '${_nombreController.text.trim()} ${_apellidoPaternoController.text.trim()} ${_apellidoMaternoController.text.trim()}'.trim();
    final fechaNac = _fechaNacimientoController.text.trim().isNotEmpty ? _fechaNacimientoController.text.trim() : '08/Septiembre/2004';
    final lugarNac = (_municipioSeleccionado != null && _estadoSeleccionado != null) ? '${_municipioSeleccionado!}, ${_estadoSeleccionado!}' : 'Zacatecas, Zac';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 36.0, vertical: 28.0),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWideScreen)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildHeaderTitles('Inscripción', 'Paso 1: Completa tus datos')),
                  _buildHeaderButtons(onAtras: () => setState(() => _currentStep = 1), onContinuar: _handleContinuarPaso2),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderTitles('Inscripción', 'Paso 1: Completa tus datos'),
                  const SizedBox(height: 16),
                  _buildHeaderButtons(onAtras: () => setState(() => _currentStep = 1), onContinuar: _handleContinuarPaso2),
                ],
              ),
            const SizedBox(height: 28),
            if (isWideScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 72, height: 72, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 48)),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nombreCompleto.isNotEmpty ? nombreCompleto : 'Alumno', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text(fechaNac, style: const TextStyle(fontSize: 14)),
                                Text(lugarNac, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _buildLabeledDropdown(label: 'Género', value: _generoSeleccionado, items: const ['Masculino', 'Femenino', 'Otro'], onChanged: (val) => setState(() => _generoSeleccionado = val)),
                        _buildLabeledDropdown(label: 'Estado civil', value: _estadoCivilSeleccionado, items: const ['Soltero/a', 'Casado/a', 'Divorciado/a', 'Viudo/a'], onChanged: (val) => setState(() => _estadoCivilSeleccionado = val)),
                        _buildLabeledField('Teléfono fijo', _telefonoFijoController, isRequired: false, keyboardType: TextInputType.phone),
                        _buildLabeledField('Celular', _celularController, readOnly: true),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildLabelWidget('¿Trabajas?', isRequired: true, width: 165),
                            Row(
                              children: [
                                Radio<String>(value: 'Si', groupValue: _trabajasSeleccionado, activeColor: const Color(0xFF731C24), onChanged: (val) => setState(() => _trabajasSeleccionado = val!)),
                                const Text('Sí'),
                                const SizedBox(width: 20),
                                Radio<String>(value: 'No', groupValue: _trabajasSeleccionado, activeColor: const Color(0xFF731C24), onChanged: (val) => setState(() => _trabajasSeleccionado = val!)),
                                const Text('No'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(flex: 12, child: _buildDomicilioActualCard()),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Container(width: 56, height: 56, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 36)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nombreCompleto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('$fechaNac - $lugarNac', style: const TextStyle(fontSize: 13))])),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLabeledDropdown(label: 'Género', value: _generoSeleccionado, items: const ['Masculino', 'Femenino', 'Otro'], onChanged: (val) => setState(() => _generoSeleccionado = val)),
                  _buildLabeledDropdown(label: 'Estado civil', value: _estadoCivilSeleccionado, items: const ['Soltero/a', 'Casado/a', 'Divorciado/a', 'Viudo/a'], onChanged: (val) => setState(() => _estadoCivilSeleccionado = val)),
                  _buildLabeledField('Teléfono fijo', _telefonoFijoController, isRequired: false),
                  _buildLabeledField('Celular', _celularController, readOnly: true),
                  _buildLabeledDropdown(label: '¿Trabajas?', value: _trabajasSeleccionado, items: const ['Si', 'No'], onChanged: (val) => setState(() => _trabajasSeleccionado = val!)),
                  const SizedBox(height: 24),
                  _buildDomicilioActualCard(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomicilioActualCard() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final municipiosDomicilio = _estadoDomicilioSeleccionado != null ? (_estadosYMunicipiosMexico[_estadoDomicilioSeleccionado] ?? []) : <String>[];

    return Container(
      padding: EdgeInsets.all(isMobile ? 20.0 : 28.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.0), border: Border.all(color: Colors.grey[300]!, width: 1.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Domicilio Actual:', style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildInlineField('Calle:', _calleController),
          const SizedBox(height: 14),
          if (isMobile) ...[
            _buildInlineField('N° ext:', _numExtController),
            const SizedBox(height: 14),
            _buildInlineField('N° int:', _numIntController, isRequired: false),
          ] else
            Row(
              children: [
                Expanded(child: _buildInlineField('N° ext:', _numExtController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInlineField('N° int:', _numIntController, isRequired: false)),
              ],
            ),
          const SizedBox(height: 14),
          if (isMobile) ...[
            _buildInlineField('Colonia:', _coloniaController),
            const SizedBox(height: 14),
            _buildInlineField('C.P.:', _cpController, keyboardType: TextInputType.number),
          ] else
            Row(
              children: [
                Expanded(child: _buildInlineField('Colonia:', _coloniaController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInlineField('C.P.:', _cpController, keyboardType: TextInputType.number)),
              ],
            ),
          const SizedBox(height: 14),
          _buildInlineDropdown(
            label: 'Estado:',
            value: _estadoDomicilioSeleccionado,
            items: _estadosYMunicipiosMexico.keys.toList(),
            onChanged: (val) => setState(() { _estadoDomicilioSeleccionado = val; _municipioDomicilioSeleccionado = null; }),
          ),
          const SizedBox(height: 14),
          _buildInlineDropdown(
            label: 'Municipio:',
            value: _municipioDomicilioSeleccionado,
            items: municipiosDomicilio,
            onChanged: (val) => setState(() => _municipioDomicilioSeleccionado = val),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PASO 3: INSCRIPCIÓN (Paso 2)
  // ==========================================
  Widget _buildStep3View() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isWideScreen = width > 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 36.0, vertical: 28.0),
      child: Form(
        key: _formKeyStep3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWideScreen)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildHeaderTitles('Inscripción', 'Paso 2: Cuéntanos de tu tutor')),
                  _buildHeaderButtons(onAtras: () => setState(() => _currentStep = 2), onContinuar: _handleContinuarPaso3),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderTitles('Inscripción', 'Paso 2: Cuéntanos de tu tutor'),
                  const SizedBox(height: 16),
                  _buildHeaderButtons(onAtras: () => setState(() => _currentStep = 2), onContinuar: _handleContinuarPaso3),
                ],
              ),
            const SizedBox(height: 36),
            if (isWideScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: Column(
                      children: [
                        _buildLabeledField('Nombre', _tutorNombreController),
                        _buildLabeledField('Apellido paterno', _tutorAppaternoController),
                        _buildLabeledField('Apellido materno', _tutorApmaternoController),
                        _buildLabeledDropdown(label: 'Parentesco', value: _tutorParentescoSeleccionado, items: _opcionesParentesco, onChanged: (val) => setState(() => _tutorParentescoSeleccionado = val)),
                        _buildLabeledField('Teléfono fijo', _tutorTelefonoFijoController, isRequired: false, keyboardType: TextInputType.phone),
                        _buildLabeledField('Celular', _tutorCelularController, keyboardType: TextInputType.phone),
                        _buildLabeledField('Telefono de trabajo', _tutorTelefonoTrabajoController, isRequired: false, keyboardType: TextInputType.phone),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(flex: 12, child: _buildTutorDomicilioCard()),
                ],
              )
            else
              Column(
                children: [
                  _buildLabeledField('Nombre', _tutorNombreController),
                  _buildLabeledField('Apellido paterno', _tutorAppaternoController),
                  _buildLabeledField('Apellido materno', _tutorApmaternoController),
                  _buildLabeledDropdown(label: 'Parentesco', value: _tutorParentescoSeleccionado, items: _opcionesParentesco, onChanged: (val) => setState(() => _tutorParentescoSeleccionado = val)),
                  _buildLabeledField('Teléfono fijo', _tutorTelefonoFijoController, isRequired: false),
                  _buildLabeledField('Celular', _tutorCelularController),
                  _buildLabeledField('Telefono de trabajo', _tutorTelefonoTrabajoController, isRequired: false),
                  const SizedBox(height: 24),
                  _buildTutorDomicilioCard(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorDomicilioCard() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final municipiosTutor = _tutorEstadoSeleccionado != null ? (_estadosYMunicipiosMexico[_tutorEstadoSeleccionado] ?? []) : <String>[];

    return Container(
      padding: EdgeInsets.all(isMobile ? 20.0 : 28.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.0), border: Border.all(color: Colors.grey[300]!, width: 1.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Domicilio del tutor:', style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold))),
              TextButton.icon(
                onPressed: _copiarDomicilioAlumnoATutor,
                icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF731C24)),
                label: Text('Copiar', style: TextStyle(fontSize: isMobile ? 12 : 14, color: Color(0xFF731C24))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInlineField('Calle:', _tutorCalleController),
          const SizedBox(height: 14),
          if (isMobile) ...[
            _buildInlineField('N° ext:', _tutorNumExtController),
            const SizedBox(height: 14),
            _buildInlineField('N° int:', _tutorNumIntController, isRequired: false),
          ] else
            Row(
              children: [
                Expanded(child: _buildInlineField('N° ext:', _tutorNumExtController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInlineField('N° int:', _tutorNumIntController, isRequired: false)),
              ],
            ),
          const SizedBox(height: 14),
          if (isMobile) ...[
            _buildInlineField('Colonia:', _tutorColoniaController),
            const SizedBox(height: 14),
            _buildInlineField('C.P.:', _tutorCpController, keyboardType: TextInputType.number),
          ] else
            Row(
              children: [
                Expanded(child: _buildInlineField('Colonia:', _tutorColoniaController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInlineField('C.P.:', _tutorCpController, keyboardType: TextInputType.number)),
              ],
            ),
          const SizedBox(height: 14),
          _buildInlineDropdown(
            label: 'Estado:',
            value: _tutorEstadoSeleccionado,
            items: _estadosYMunicipiosMexico.keys.toList(),
            onChanged: (val) => setState(() { _tutorEstadoSeleccionado = val; _tutorMunicipioSeleccionado = null; }),
          ),
          const SizedBox(height: 14),
          _buildInlineDropdown(
            label: 'Municipio:',
            value: _tutorMunicipioSeleccionado,
            items: municipiosTutor,
            onChanged: (val) => setState(() => _tutorMunicipioSeleccionado = val),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PASO 4: CARGA TU FOTO
  // ==========================================
  Widget _buildStep4View() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isWideScreen = width > 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 36.0, vertical: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWideScreen)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildHeaderTitles('Inscripción', 'Carga tu foto (Tipo Infantil / Credencial)', titleFontSize: 32, subtitleFontSize: 22)),
                _buildHeaderButtons(onAtras: () => setState(() => _currentStep = 3), onContinuar: _handleContinuarPaso4),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderTitles('Inscripción', 'Carga tu foto', titleFontSize: 32, subtitleFontSize: 22),
                const SizedBox(height: 16),
                _buildHeaderButtons(onAtras: () => setState(() => _currentStep = 3), onContinuar: _handleContinuarPaso4),
              ],
            ),
          const SizedBox(height: 32),
          if (isMobile)
            Column(children: [_buildPhotoInstructionsCard(), const SizedBox(height: 32), _buildPhotoPreviewArea()])
          else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 5, child: _buildPhotoInstructionsCard()), const SizedBox(width: 48), Expanded(flex: 4, child: _buildPhotoPreviewArea())]),
        ],
      ),
    );
  }

  Widget _buildPhotoInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.0), border: Border.all(color: Colors.grey[300]!, width: 1.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Requisitos de tu fotografía:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          _buildInstructionBullet(icon: Icons.aspect_ratio, text: 'Proporción 3:4 (vertical tipo infantil).'),
          _buildInstructionBullet(icon: Icons.wb_sunny_outlined, text: 'Fondo blanco liso.'),
          _buildInstructionBullet(icon: Icons.face_outlined, text: 'De frente, cabeza a hombros.'),
          const SizedBox(height: 20),
          InkWell(
            onTap: () => setState(() => _hasUploadedPhoto = !_hasUploadedPhoto),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFF731C24).withAlpha(13), borderRadius: BorderRadius.circular(16.0), border: Border.all(color: const Color(0xFF731C24).withAlpha(76))),
              child: Center(child: Column(children: [Icon(_hasUploadedPhoto ? Icons.check_circle : Icons.cloud_upload_outlined, size: 44, color: const Color(0xFF731C24)), const SizedBox(height: 8), Text(_hasUploadedPhoto ? 'Foto cargada ✓' : 'Subir foto', style: const TextStyle(color: Color(0xFF731C24), fontWeight: FontWeight.bold))])),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreviewArea() {
    final nombresList = _getNombresList();
    final currentNombre = nombresList[_selectedNameIndex % nombresList.length];
    return Column(
      children: [
        Container(
          width: 210, height: 280,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[400]!, width: 2)),
          child: _hasUploadedPhoto ? const Icon(Icons.person_pin, color: Color(0xFF731C24), size: 140) : Icon(Icons.account_box_outlined, color: Colors.grey[400], size: 120),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: nombresList.length > 1 ? () => setState(() => _selectedNameIndex = (_selectedNameIndex + 1) % nombresList.length) : null,
          child: Row(mainAxisSize: MainAxisSize.min, children: [Text(currentNombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), if (nombresList.length > 1) const Icon(Icons.swap_horizontal_circle_outlined, size: 22, color: Color(0xFF731C24))]),
        ),
      ],
    );
  }

  Widget _buildInstructionBullet({required IconData icon, required String text}) {
    return Padding(padding: const EdgeInsets.only(bottom: 10.0), child: Row(children: [Icon(icon, size: 20, color: const Color(0xFF731C24)), const SizedBox(width: 10), Expanded(child: Text(text))]));
  }

  // ==========================================
  // PASO 5: VERIFICAR DATOS
  // ==========================================
  Widget _buildStep5View() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isWideScreen = width > 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 36.0, vertical: 28.0),
      child: Form(
        key: _formKeyStep5,
        child: Column(
          children: [
            Text('¡Ya esta!, solo queda un último paso', style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 28),
            if (isWideScreen)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 11, child: Column(children: _buildReviewFormFields())), const SizedBox(width: 48), Expanded(flex: 9, child: _buildFinalPhotoPreview())])
            else
              Column(children: [_buildFinalPhotoPreview(), const SizedBox(height: 24), ..._buildReviewFormFields()]),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showPrintInstructionsDialog(context),
                  child: const Text('Descargar', style: TextStyle(color: Color(0xFF731C24), fontSize: 18)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _canFinish
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Proceso de inscripción completado exitosamente.'),
                              backgroundColor: Color(0xFF731C24),
                            ),
                          );
                          Navigator.of(context).pop(); // Regresa al LoginScreen
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canFinish ? const Color(0xFF555555) : Colors.grey[400],
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Terminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReviewFormFields() {
    return [
      _buildLabeledField('Nombre', _nombreController),
      _buildLabeledField('Apellido paterno', _apellidoPaternoController),
      _buildLabeledField('Apellido materno', _apellidoMaternoController),
      _buildLabeledDropdown(label: 'Género', value: _generoSeleccionado, items: const ['Masculino', 'Femenino', 'Otro'], onChanged: (val) => setState(() => _generoSeleccionado = val)),
      _buildLabeledDropdown(label: 'Estado', value: _estadoSeleccionado, items: _estadosYMunicipiosMexico.keys.toList(), onChanged: (val) => setState(() => _estadoSeleccionado = val)),
      _buildLabeledField('Celular', _celularController),
    ];
  }

  Widget _buildFinalPhotoPreview() {
    return Container(width: 240, height: 240, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: Icon(_hasUploadedPhoto ? Icons.person_pin : Icons.person, color: Colors.white, size: 150));
  }

  // ==========================================
  // HELPERS DE INTERFAZ (DEFINED ONCE AT END)
  // ==========================================

  Widget _buildFechaNacimientoField() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final field = TextFormField(
      controller: _fechaNacimientoController,
      readOnly: true,
      onTap: () => _selectDateOfBirth(context),
      decoration: _inputDecoration(hintText: 'DD/MM/AAAA', suffixIcon: IconButton(icon: const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF731C24)), onPressed: () => _selectDateOfBirth(context))),
      validator: (val) => (val == null || val.isEmpty) ? 'Selecciona tu fecha de nacimiento' : null,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: isMobile ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabelWidget('Fecha de nacimiento'), const SizedBox(height: 6), field])
                      : Row(children: [_buildLabelWidget('Fecha de nacimiento', width: 165), Expanded(child: field)]),
    );
  }

  Widget _buildLabelWidget(String label, {bool isRequired = true, double? width}) {
    final richText = RichText(text: TextSpan(text: label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333)), children: isRequired ? [const TextSpan(text: ' *', style: TextStyle(color: Color(0xFF731C24), fontWeight: FontWeight.bold))] : []));
    return width != null ? SizedBox(width: width, child: richText) : richText;
  }

  Widget _buildLabeledField(String label, TextEditingController controller, {Key? key, bool isRequired = true, bool obscureText = false, bool readOnly = false, Widget? suffixIcon, TextInputType keyboardType = TextInputType.text, TextCapitalization textCapitalization = TextCapitalization.none, List<TextInputFormatter>? inputFormatters, Iterable<String>? autofillHints, FormFieldValidator<String>? validator}) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final field = TextFormField(
      key: key, controller: controller, readOnly: readOnly, obscureText: obscureText, keyboardType: keyboardType, textCapitalization: textCapitalization, inputFormatters: inputFormatters, autocorrect: false, autofillHints: autofillHints,
      decoration: _inputDecoration(suffixIcon: suffixIcon, fillColor: readOnly ? Colors.grey[100] : null),
      validator: validator ?? (val) => (isRequired && (val == null || val.trim().isEmpty)) ? 'Campo requerido' : null,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: isMobile ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabelWidget(label, isRequired: isRequired), const SizedBox(height: 6), field])
                      : Row(children: [_buildLabelWidget(label, isRequired: isRequired, width: 165), Expanded(child: field)]),
    );
  }

  Widget _buildInlineField(String label, TextEditingController controller, {Key? key, bool isRequired = true, TextInputType keyboardType = TextInputType.text}) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final field = TextFormField(key: key, controller: controller, keyboardType: keyboardType, decoration: _inputDecoration(), validator: (val) => (isRequired && (val == null || val.trim().isEmpty)) ? 'Campo requerido' : null);
    return isMobile ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabelWidget(label, isRequired: isRequired), const SizedBox(height: 6), field])
                    : Row(children: [_buildLabelWidget(label, isRequired: isRequired), const SizedBox(width: 8), Expanded(child: field)]);
  }

  Widget _buildInlineDropdown({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged, bool isRequired = true, String? hintText}) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final field = DropdownButtonFormField<String>(value: value, isExpanded: true, decoration: _inputDecoration(hintText: hintText), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis))).toList(), onChanged: onChanged, validator: (val) => (isRequired && (val == null || val.isEmpty)) ? 'Campo requerido' : null);
    return isMobile ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabelWidget(label, isRequired: isRequired), const SizedBox(height: 6), field])
                    : Row(children: [_buildLabelWidget(label, isRequired: isRequired), const SizedBox(width: 8), Expanded(child: field)]);
  }

  Widget _buildLabeledDropdown({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged, bool isRequired = true, String? hintText}) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final field = DropdownButtonFormField<String>(value: value, isExpanded: true, decoration: _inputDecoration(hintText: hintText), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis))).toList(), onChanged: onChanged, validator: (val) => (isRequired && (val == null || val.isEmpty)) ? 'Campo requerido' : null);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: isMobile ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabelWidget(label, isRequired: isRequired), const SizedBox(height: 6), field])
                      : Row(children: [_buildLabelWidget(label, isRequired: isRequired, width: 165), Expanded(child: field)]),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon, Color? fillColor}) {
    return InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), hintText: hintText, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14), filled: true, fillColor: fillColor ?? Colors.white, suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!, width: 1.2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF731C24), width: 1.8)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1.2)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1.8)),
    );
  }

  Widget _buildHeaderTitles(String title, String subtitle, {double titleFontSize = 32, double subtitleFontSize = 20}) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: isMobile ? 24 : titleFontSize, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(subtitle, style: TextStyle(fontSize: isMobile ? 16 : subtitleFontSize, color: Colors.grey[700]))]);
  }

  Widget _buildHeaderButtons({required VoidCallback onAtras, required VoidCallback onContinuar, String continuarLabel = 'Continuar'}) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      TextButton(onPressed: onAtras, child: Text('Atrás', style: TextStyle(color: const Color(0xFF731C24), fontSize: isMobile ? 16 : 18))),
      const SizedBox(width: 16),
      SizedBox(height: isMobile ? 40 : 44, width: isMobile ? 120 : 140, child: ElevatedButton(onPressed: onContinuar, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF731C24), foregroundColor: Colors.white, shape: const StadiumBorder()), child: Text(continuarLabel, style: const TextStyle(fontWeight: FontWeight.bold)))),
    ]);
  }
}
