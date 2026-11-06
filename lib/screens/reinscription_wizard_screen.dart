import 'package:flutter/material.dart';

class ReinscriptionWizardScreen extends StatefulWidget {
  const ReinscriptionWizardScreen({super.key});

  @override
  State<ReinscriptionWizardScreen> createState() => _ReinscriptionWizardScreenState();
}

class _ReinscriptionWizardScreenState extends State<ReinscriptionWizardScreen> {
  int _currentStep = 0;

  // Controladores Paso 1: Alumno
  String _generoSeleccionado = 'Masculino';
  String _estadoCivilSeleccionado = 'Soltero(a)';
  final TextEditingController _telFijoController = TextEditingController(text: '55 8765 4321');
  final TextEditingController _celularController = TextEditingController(text: '55 1234 5678');
  String _trabajasSeleccionado = 'No';

  // Domicilio Alumno
  final TextEditingController _calleController = TextEditingController(text: 'Av. Juan de Dios Bátiz s/n');
  final TextEditingController _numExtController = TextEditingController(text: '102');
  final TextEditingController _numIntController = TextEditingController(text: 'B-304');
  final TextEditingController _coloniaController = TextEditingController(text: 'Zacatenco');
  final TextEditingController _cpController = TextEditingController(text: '07738');
  final String _estadoController = 'Ciudad de México';
  final TextEditingController _municipioController = TextEditingController(text: 'Gustavo A. Madero');

  // Controladores Paso 2: Tutor
  final TextEditingController _tutorNombreController = TextEditingController(text: 'Roberto');
  final TextEditingController _tutorApPaternoController = TextEditingController(text: 'Hernández');
  final TextEditingController _tutorApMaternoController = TextEditingController(text: 'Gómez');
  String _tutorParentesco = 'Padre';
  final TextEditingController _tutorTelFijoController = TextEditingController(text: '55 1122 3344');
  final TextEditingController _tutorCelularController = TextEditingController(text: '55 9988 7766');
  final TextEditingController _tutorTelTrabajoController = TextEditingController(text: '55 5544 3322');

  // Domicilio Tutor
  final TextEditingController _tutorCalleController = TextEditingController(text: 'Calle Insurgentes Sur');
  final TextEditingController _tutorNumExtController = TextEditingController(text: '1500');
  final TextEditingController _tutorNumIntController = TextEditingController(text: 'S/N');
  final TextEditingController _tutorColoniaController = TextEditingController(text: 'Del Valle');
  final TextEditingController _tutorCpController = TextEditingController(text: '03100');
  final String _tutorEstado = 'Ciudad de México';
  final TextEditingController _tutorMunicipio = TextEditingController(text: 'Benito Juárez');

  @override
  void dispose() {
    _telFijoController.dispose();
    _celularController.dispose();
    _calleController.dispose();
    _numExtController.dispose();
    _numIntController.dispose();
    _coloniaController.dispose();
    _cpController.dispose();
    _municipioController.dispose();
    _tutorNombreController.dispose();
    _tutorApPaternoController.dispose();
    _tutorApMaternoController.dispose();
    _tutorTelFijoController.dispose();
    _tutorCelularController.dispose();
    _tutorTelTrabajoController.dispose();
    _tutorCalleController.dispose();
    _tutorNumExtController.dispose();
    _tutorNumIntController.dispose();
    _tutorColoniaController.dispose();
    _tutorCpController.dispose();
    _tutorMunicipio.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Proceso de reinscripción concluido con éxito!')),
      );
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGuinda = Color(0xFF731C24);
    const accentGold = Color(0xFFD49A2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Reinscripción', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryGuinda,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentStep == 0
                      ? 'Paso 1: Actualiza tus datos'
                      : _currentStep == 1
                          ? 'Paso 2: Actualiza los datos de tu tutor'
                          : '¡Ya está!, solo queda un último paso',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
                Row(
                  children: [
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: _prevStep,
                        child: const Text('Atrás', style: TextStyle(color: primaryGuinda, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    if (_currentStep < 2) ...[
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGuinda,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Continuar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contenido según el paso actual
            if (_currentStep == 0) _buildStep1(),
            if (_currentStep == 1) _buildStep2(),
            if (_currentStep == 2) _buildStep3(primaryGuinda),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    const primaryGuinda = Color(0xFF731C24);
    const accentGold = Color(0xFFD49A2A);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna Izquierda: Datos Personales y Contacto en Tarjeta
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: accentGold, width: 3),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, size: 38, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alejandro Hernández Pérez',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey),
                              SizedBox(width: 6),
                              Text('25/Enero/2004', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 13, color: Colors.grey),
                              const SizedBox(width: 6),
                              const Text('Zacatecas, Zac.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Edición de datos generales habilitada.')),
                                  );
                                },
                                child: const Text('¿Editar?', style: TextStyle(fontSize: 12, color: primaryGuinda, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                const Text('Información General y Contacto', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
                const SizedBox(height: 16),
                _buildFieldStacked('Género', DropdownButtonFormField<String>(
                  initialValue: _generoSeleccionado,
                  decoration: _inputDecoration(),
                  items: ['Masculino', 'Femenino', 'Otro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _generoSeleccionado = val!),
                )),
                const SizedBox(height: 14),
                _buildFieldStacked('Estado civil', DropdownButtonFormField<String>(
                  initialValue: _estadoCivilSeleccionado,
                  decoration: _inputDecoration(),
                  items: ['Soltero(a)', 'Casado(a)', 'Unión Libre', 'Divorciado(a)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _estadoCivilSeleccionado = val!),
                )),
                const SizedBox(height: 14),
                _buildFieldStacked('Teléfono fijo', TextFormField(controller: _telFijoController, decoration: _inputDecoration())),
                const SizedBox(height: 14),
                _buildFieldStacked('Celular', TextFormField(controller: _celularController, decoration: _inputDecoration())),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('¿Trabajas?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF444444))),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Sí',
                          groupValue: _trabajasSeleccionado,
                          onChanged: (val) => setState(() => _trabajasSeleccionado = val!),
                          activeColor: primaryGuinda,
                        ),
                        const Text('Sí', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'No',
                          groupValue: _trabajasSeleccionado,
                          onChanged: (val) => setState(() => _trabajasSeleccionado = val!),
                          activeColor: primaryGuinda,
                        ),
                        const Text('No', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Columna Derecha: Tarjeta Domicilio Actual
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.home_outlined, size: 22, color: Color(0xFF731C24)),
                    SizedBox(width: 8),
                    Text('Domicilio Actual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildFieldStacked('Calle', TextFormField(controller: _calleController, decoration: _inputDecoration()))),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _buildFieldStacked('Colonia', TextFormField(controller: _coloniaController, decoration: _inputDecoration()))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildFieldStacked('N° ext', TextFormField(controller: _numExtController, decoration: _inputDecoration()))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFieldStacked('N° int', TextFormField(controller: _numIntController, decoration: _inputDecoration()))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFieldStacked('C.P.', TextFormField(controller: _cpController, decoration: _inputDecoration()))),
                  ],
                ),
                const SizedBox(height: 14),
                _buildFieldStacked('Estado', TextFormField(controller: TextEditingController(text: _estadoController), decoration: _inputDecoration())),
                const SizedBox(height: 14),
                _buildFieldStacked('Municipio', TextFormField(controller: _municipioController, decoration: _inputDecoration())),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    const primaryGuinda = Color(0xFF731C24);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna Izquierda: Tarjeta Datos del Tutor
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.supervisor_account_outlined, size: 22, color: Color(0xFF731C24)),
                    SizedBox(width: 8),
                    Text('Datos del Tutor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
                  ],
                ),
                const Divider(height: 24),
                _buildFieldStacked('Nombre(s)', TextFormField(controller: _tutorNombreController, decoration: _inputDecoration())),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildFieldStacked('Apellido paterno', TextFormField(controller: _tutorApPaternoController, decoration: _inputDecoration()))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFieldStacked('Apellido materno', TextFormField(controller: _tutorApMaternoController, decoration: _inputDecoration()))),
                  ],
                ),
                const SizedBox(height: 14),
                _buildFieldStacked('Parentesco', DropdownButtonFormField<String>(
                  initialValue: _tutorParentesco,
                  decoration: _inputDecoration(),
                  items: ['Padre', 'Madre', 'Tutor Legal', 'Abuelo/a', 'Tío/a', 'Otro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _tutorParentesco = val!),
                )),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildFieldStacked('Teléfono fijo', TextFormField(controller: _tutorTelFijoController, decoration: _inputDecoration()))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFieldStacked('Celular', TextFormField(controller: _tutorCelularController, decoration: _inputDecoration()))),
                  ],
                ),
                const SizedBox(height: 14),
                _buildFieldStacked('Teléfono de trabajo', TextFormField(controller: _tutorTelTrabajoController, decoration: _inputDecoration())),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Columna Derecha: Tarjeta Domicilio del Tutor
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.home_outlined, size: 22, color: Color(0xFF731C24)),
                    SizedBox(width: 8),
                    Text('Domicilio del Tutor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildFieldStacked('Calle', TextFormField(controller: _tutorCalleController, decoration: _inputDecoration()))),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _buildFieldStacked('Colonia', TextFormField(controller: _tutorColoniaController, decoration: _inputDecoration()))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildFieldStacked('N° ext', TextFormField(controller: _tutorNumExtController, decoration: _inputDecoration()))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFieldStacked('N° int', TextFormField(controller: _tutorNumIntController, decoration: _inputDecoration()))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFieldStacked('C.P.', TextFormField(controller: _tutorCpController, decoration: _inputDecoration()))),
                  ],
                ),
                const SizedBox(height: 14),
                _buildFieldStacked('Estado', TextFormField(controller: TextEditingController(text: _tutorEstado), decoration: _inputDecoration())),
                const SizedBox(height: 14),
                _buildFieldStacked('Municipio', TextFormField(controller: _tutorMunicipio, decoration: _inputDecoration())),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF731C24), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildFieldStacked(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF555555))),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildStep3(Color primaryGuinda) {
    const accentGold = Color(0xFFD49A2A);
    // Calculated semester (e.g. current 4 -> next 5)
    final int currentSem = 4;
    final int nextSem = currentSem + 1;
    final String reinscriptionPeriod = '2025-2';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Academic Info Banner Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGuinda, primaryGuinda.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: primaryGuinda.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Periodo de Reinscripción',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Semestre $reinscriptionPeriod',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: accentGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'CURSARÁ',
                      style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$nextSem° Semestre',
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Two Column Layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Summary Cards
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  // Personal & Contact Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFF731C24)),
                            SizedBox(width: 8),
                            Text('Datos Personales y de Contacto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow('Género:', _generoSeleccionado),
                        _buildSummaryRow('Estado civil:', _estadoCivilSeleccionado),
                        _buildSummaryRow('Teléfono fijo:', _telFijoController.text.isEmpty ? 'No especificado' : _telFijoController.text),
                        _buildSummaryRow('Celular:', _celularController.text.isEmpty ? 'No especificado' : _celularController.text),
                        _buildSummaryRow('Teléfono de trabajo:', 'No especificado'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Domicilio Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.home_outlined, size: 20, color: Color(0xFF731C24)),
                            SizedBox(width: 8),
                            Text('Domicilio Actual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          '${_calleController.text} #${_numExtController.text}${_numIntController.text.isNotEmpty ? ' Int. ${_numIntController.text}' : ''}, Col. ${_coloniaController.text}, C.P. ${_cpController.text}, ${_municipioController.text}, $_estadoController',
                          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tutor Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.supervisor_account_outlined, size: 20, color: Color(0xFF731C24)),
                            SizedBox(width: 8),
                            Text('Datos del Tutor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          '${_tutorNombreController.text} ${_tutorApPaternoController.text} ${_tutorApMaternoController.text}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Parentesco: $_tutorParentesco • Tel: ${_tutorCelularController.text.isNotEmpty ? _tutorCelularController.text : 'No especificado'}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Right Column: Profile & Actions Card
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: accentGold, width: 4),
                        boxShadow: [BoxShadow(color: accentGold.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, size: 75, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Alejandro Hernández Pérez',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1C1E)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Boleta: 2023630123',
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF731C24).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF731C24).withOpacity(0.15)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: Color(0xFF731C24), size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tus datos han sido validados correctamente para el proceso de reinscripción.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF731C24), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Descargando comprobante oficial de reinscripción en PDF...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF731C24),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Descargar Comprobante PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _nextStep,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF731C24),
                          side: const BorderSide(color: Color(0xFF731C24), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Terminar Proceso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF731C24), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildTextFieldLabel(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF444444))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF731C24), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF444444))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF731C24), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1C1E)))),
        ],
      ),
    );
  }
}
