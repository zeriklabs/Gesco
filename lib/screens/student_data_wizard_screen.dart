import 'package:flutter/material.dart';

class StudentDataWizardScreen extends StatefulWidget {
  const StudentDataWizardScreen({super.key});

  @override
  State<StudentDataWizardScreen> createState() => _StudentDataWizardScreenState();
}

class _StudentDataWizardScreenState extends State<StudentDataWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _showPreboletaCard = false;
  String _photoStatus = 'Fotografía oficial validada por UPIIZ';

  // 32 Estados de México para los dropdowns
  static const List<String> _estadosMexico = [
    'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche', 'Chiapas',
    'Chihuahua', 'Coahuila', 'Colima', 'Ciudad de México', 'Durango', 'Guanajuato',
    'Guerrero', 'Hidalgo', 'Jalisco', 'Estado de México', 'Michoacán', 'Morelos',
    'Nayarit', 'Nuevo León', 'Oaxaca', 'Puebla', 'Querétaro', 'Quintana Roo',
    'San Luis Potosí', 'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala',
    'Veracruz', 'Yucatán', 'Zacatecas'
  ];

  static const List<String> _opcionesParentesco = [
    'Padre', 'Madre', 'Tutor Legal', 'Abuelo/a', 'Tío/a', 'Hermano/a', 'Otro'
  ];

  // DATOS OFICIALES NO MODIFICABLES (Identidad Escolar IPN)
  final TextEditingController _nombreController = TextEditingController(text: 'Alejandro');
  final TextEditingController _apellidoPaternoController = TextEditingController(text: 'Hernández');
  final TextEditingController _apellidoMaternoController = TextEditingController(text: 'Pérez');
  final TextEditingController _boletaController = TextEditingController(text: '2024630001');
  final TextEditingController _curpController = TextEditingController(text: 'HEPA040125HDFRZR09');
  final TextEditingController _fechaNacimientoController = TextEditingController(text: '25/01/2004');
  final String _estadoNacimientoOficial = 'Ciudad de México';

  // DATOS MODIFICABLES (Contacto, Domicilio, Tutor, etc.)
  final TextEditingController _correoController = TextEditingController(text: 'ahernandezp2024@alumno.ipn.mx');
  final TextEditingController _celularController = TextEditingController(text: '55 1234 5678');
  final TextEditingController _telefonoFijoController = TextEditingController(text: '55 8765 4321');
  String _estadoCivilSeleccionado = 'Soltero(a)';
  String _trabajasSeleccionado = 'No';

  // Domicilio Actual Alumno (Modificable)
  final TextEditingController _calleController = TextEditingController(text: 'Av. Juan de Dios Bátiz s/n');
  final TextEditingController _numExtController = TextEditingController(text: '102');
  final TextEditingController _numIntController = TextEditingController(text: 'B-304');
  final TextEditingController _coloniaController = TextEditingController(text: 'Zacatenco');
  final TextEditingController _cpController = TextEditingController(text: '07738');
  String _estadoDomicilioSeleccionado = 'Ciudad de México';
  final TextEditingController _municipioDomicilioController = TextEditingController(text: 'Gustavo A. Madero');

  // Datos del Tutor (Modificable)
  final TextEditingController _tutorNombreController = TextEditingController(text: 'Roberto Hernández Gómez');
  String _tutorParentescoSeleccionado = 'Padre';
  final TextEditingController _tutorCelularController = TextEditingController(text: '55 9988 7766');
  final TextEditingController _tutorTelefonoFijoController = TextEditingController(text: '55 1122 3344');
  final TextEditingController _tutorTelefonoTrabajoController = TextEditingController(text: '55 5544 3322');

  // Domicilio Tutor (Modificable)
  final TextEditingController _tutorCalleController = TextEditingController(text: 'Calle Insurgentes Sur');
  final TextEditingController _tutorNumExtController = TextEditingController(text: '1500');
  final TextEditingController _tutorColoniaController = TextEditingController(text: 'Del Valle');
  final TextEditingController _tutorCpController = TextEditingController(text: '03100');
  String _tutorEstadoSeleccionado = 'Ciudad de México';
  final TextEditingController _tutorMunicipioController = TextEditingController(text: 'Benito Juárez');

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _boletaController.dispose();
    _curpController.dispose();
    _correoController.dispose();
    _celularController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoFijoController.dispose();
    _calleController.dispose();
    _numExtController.dispose();
    _numIntController.dispose();
    _coloniaController.dispose();
    _cpController.dispose();
    _tutorNombreController.dispose();
    _tutorCelularController.dispose();
    _tutorTelefonoFijoController.dispose();
    _tutorTelefonoTrabajoController.dispose();
    _tutorCalleController.dispose();
    _tutorNumExtController.dispose();
    _tutorColoniaController.dispose();
    _tutorCpController.dispose();
    _tutorMunicipioController.dispose();
    _municipioDomicilioController.dispose();
    super.dispose();
  }

  void _toggleEditOrSave() {
    setState(() {
      if (_isEditing) {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Datos modificables y fotografía actualizados con éxito!')),
          );
          _isEditing = false;
        }
      } else {
        _isEditing = true;
      }
    });
  }

  void _togglePreboletaCard() {
    setState(() {
      _showPreboletaCard = !_showPreboletaCard;
    });
    if (_showPreboletaCard) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memoria de preboleta mostrada abajo del número de boleta.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _changePhotoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.camera_enhance_rounded, color: Color(0xFF731C24)),
            SizedBox(width: 10),
            Text('Fotografía Escolar'),
          ],
        ),
        content: const Text(
          'Selecciona la fuente de tu fotografía institucional para la credencial digital y expediente GESCO:',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _photoStatus = 'Foto capturada por cámara (En validación)';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fotografía capturada correctamente.')),
              );
            },
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Cámara'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _photoStatus = 'Foto cargada desde galería (En validación)';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fotografía cargada correctamente.')),
              );
            },
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Galería'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF731C24),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGuinda = Color(0xFF731C24);
    const accentGold = Color(0xFFD49A2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Datos del Alumno'),
        backgroundColor: primaryGuinda,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleEditOrSave,
        backgroundColor: _isEditing ? Colors.green.shade700 : primaryGuinda,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded),
        label: Text(
          _isEditing ? 'Guardar Cambios' : 'Modificar Datos',
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Banner Superior con Gradiente Guinda y Foto de Perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF731C24), Color(0xFF4A1217)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: accentGold, width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 56, color: primaryGuinda),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Material(
                            color: accentGold,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(
                              onTap: _changePhotoDialog,
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Alejandro Hernández Pérez',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentGold.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentGold.withOpacity(0.6)),
                    ),
                    child: const Text(
                      'Boleta: 2024630001 • Ing. en Sistemas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _photoStatus,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Formulario en Tarjetas Paneles Estilizadas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Aviso institucional de edición
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isEditing ? Colors.amber.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isEditing ? Colors.amber.shade400 : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isEditing ? Icons.edit_note_rounded : Icons.info_outline_rounded,
                            color: _isEditing ? Colors.amber.shade800 : primaryGuinda,
                            size: 26,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _isEditing
                                  ? 'Modo Edición Activado: Actualiza tu contacto, domicilio o tutor y pulsa Guardar.'
                                  : 'Los datos de identidad (Nombre, Nacimiento, Boleta) son inmutables. Pulsa "Modificar Datos" para editar tu información.',
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF444444), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta 1: Identidad Oficial (Inmutable)
                    _buildPanelCard(
                      title: '1. Identidad Oficial (Inmutable)',
                      icon: Icons.lock_outline_rounded,
                      iconColor: Colors.blueGrey,
                      children: [
                        const Text(
                          'Datos oficiales registrados ante la Dirección de Administración Escolar (DAE).',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        // Fila 1: Nombre(s)
                        _buildTextField(_nombreController, 'Nombre(s)', Icons.person_outline, false),
                        const SizedBox(height: 14),
                        // Fila 2: Apellido Paterno y Apellido Materno
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_apellidoPaternoController, 'Apellido Paterno', Icons.person_outline, false)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(_apellidoMaternoController, 'Apellido Materno', Icons.person_outline, false)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Fila 3: Fecha de Nacimiento y Estado de Nacimiento
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_fechaNacimientoController, 'Fecha de Nacimiento', Icons.calendar_today_outlined, false)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(TextEditingController(text: _estadoNacimientoOficial), 'Estado de Nacimiento', Icons.map_outlined, false)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Fila 4: Número de Boleta (con readOnly y botón de preboleta) y CURP Oficial
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _boletaController,
                                readOnly: true,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Número de Boleta',
                                  prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 20, color: primaryGuinda),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPreboletaCard ? Icons.history_edu_rounded : Icons.history_edu_outlined,
                                      color: accentGold,
                                      size: 24,
                                    ),
                                    tooltip: _showPreboletaCard ? 'Ocultar Preboleta' : 'Recordar Preboleta',
                                    onPressed: _togglePreboletaCard,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F2F5),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF731C24), width: 1.5)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(_curpController, 'CURP Oficial', Icons.badge_outlined, false)),
                          ],
                        ),
                        // Banner condicional de Antigüedad y Admisión (Aparece ABAJO del número de boleta al presionar el botón)
                        if (_showPreboletaCard) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accentGold.withOpacity(0.22), primaryGuinda.withOpacity(0.08)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: accentGold.withOpacity(0.8), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryGuinda,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Iniciaste la carrera de Ing. en Sistemas Computacionales el 12 de Agosto de 2024 con la preboleta PB-2024-88492.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF222222),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                                  onPressed: () => setState(() => _showPreboletaCard = false),
                                  tooltip: 'Cerrar',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta 2: Datos de Contacto y Personales (Modificable)
                    _buildPanelCard(
                      title: '2. Datos de Contacto y Personales',
                      icon: Icons.contact_mail_rounded,
                      iconColor: primaryGuinda,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_correoController, 'Correo Institucional', Icons.email_outlined, _isEditing)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(_celularController, 'Teléfono Celular', Icons.phone_android_outlined, _isEditing)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_telefonoFijoController, 'Teléfono Fijo', Icons.phone_outlined, _isEditing)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _estadoCivilSeleccionado,
                                decoration: _inputDecoration('Estado Civil', Icons.favorite_border),
                                items: ['Soltero(a)', 'Casado(a)', 'Unión Libre', 'Divorciado(a)']
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: _isEditing ? (val) => setState(() => _estadoCivilSeleccionado = val!) : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _trabajasSeleccionado,
                          decoration: _inputDecoration('¿Actualmentes Trabajas?', Icons.work_outline),
                          items: ['Sí', 'No'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: _isEditing ? (val) => setState(() => _trabajasSeleccionado = val!) : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta 3: Domicilio Actual (Modificable)
                    _buildPanelCard(
                      title: '3. Domicilio Actual',
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF1976D2),
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 2, child: _buildTextField(_calleController, 'Calle', Icons.home_outlined, _isEditing)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField(_numExtController, 'No. Ext', Icons.numbers, _isEditing)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField(_numIntController, 'No. Int', Icons.tag, _isEditing)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_coloniaController, 'Colonia / Barrio', Icons.location_city_outlined, _isEditing)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(_cpController, 'Código Postal', Icons.markunread_mailbox_outlined, _isEditing)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _estadoDomicilioSeleccionado,
                                decoration: _inputDecoration('Estado', Icons.map_outlined),
                                items: _estadosMexico
                                    .map((est) => DropdownMenuItem(value: est, child: Text(est, overflow: TextOverflow.ellipsis)))
                                    .toList(),
                                onChanged: _isEditing ? (val) => setState(() => _estadoDomicilioSeleccionado = val!) : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(_municipioDomicilioController, 'Alcaldía / Municipio', Icons.location_pin, _isEditing)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta 4: Datos del Tutor y Familiar (Modificable)
                    _buildPanelCard(
                      title: '4. Datos del Tutor o Familiar',
                      icon: Icons.supervisor_account_rounded,
                      iconColor: const Color(0xFF00796B),
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 2, child: _buildTextField(_tutorNombreController, 'Nombre Completo del Tutor', Icons.person_outline, _isEditing)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _tutorParentescoSeleccionado,
                                decoration: _inputDecoration('Parentesco', Icons.family_restroom_outlined),
                                items: _opcionesParentesco
                                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                    .toList(),
                                onChanged: _isEditing ? (val) => setState(() => _tutorParentescoSeleccionado = val!) : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_tutorCelularController, 'Celular Tutor', Icons.phone_android_outlined, _isEditing)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(_tutorTelefonoFijoController, 'Teléfono Fijo', Icons.phone_outlined, _isEditing)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(_tutorTelefonoTrabajoController, 'Teléfono de Trabajo del Tutor', Icons.work_outline, _isEditing),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: _isEditing ? Colors.white : const Color(0xFFF8F9FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF731C24), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool enabled) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF0F2F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF731C24), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
