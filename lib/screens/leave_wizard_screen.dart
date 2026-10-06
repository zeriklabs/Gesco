import 'package:flutter/material.dart';

class LeaveWizardScreen extends StatefulWidget {
  const LeaveWizardScreen({super.key});

  @override
  State<LeaveWizardScreen> createState() => _LeaveWizardScreenState();
}

class _LeaveWizardScreenState extends State<LeaveWizardScreen> {
  String _selectedLeaveType = 'Temporal (1 Semestre)';
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _leaveTypes = [
    'Temporal (1 Semestre)',
    'Temporal (2 Semestres)',
    'Definitiva'
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGuinda = Color(0xFF731C24);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud de Baja Temporal / Definitiva'),
        backgroundColor: primaryGuinda,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Las solicitudes de baja están sujetas al Reglamento General de Estudios del IPN. Consulta los plazos estipulados en el calendario escolar.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seleccione el tipo de baja solicitada:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 12),
            ..._leaveTypes.map((type) => RadioListTile<String>(
                  title: Text(type, style: const TextStyle(fontWeight: FontWeight.w600)),
                  value: type,
                  groupValue: _selectedLeaveType,
                  activeColor: primaryGuinda,
                  onChanged: (val) {
                    setState(() {
                      _selectedLeaveType = val!;
                    });
                  },
                )),
            const SizedBox(height: 20),
            const Text(
              'Motivo de la Solicitud:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describa brevemente el motivo de su solicitud (motivos personales, médicos, económicos, etc.)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Confirmar Solicitud de Baja'),
                      content: Text('¿Está seguro de enviar su solicitud de baja tipo: $_selectedLeaveType? Esta acción será evaluada por el comité académico.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryGuinda, foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Solicitud de baja enviada con éxito. Folio de seguimiento: #BJ-2026-991')),
                            );
                          },
                          child: const Text('Confirmar y Enviar'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGuinda,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Enviar Solicitud al Comité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
