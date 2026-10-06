import 'package:flutter/material.dart';

class UapDropWizardScreen extends StatelessWidget {
  const UapDropWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGuinda = Color(0xFF731C24);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bajas de Unidades de Aprendizaje (UAp)'),
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
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_rounded, color: Colors.orange, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Historial de bajas de unidades de aprendizaje (materias) autorizadas durante tu trayectoria escolar.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'UAp Con Baja Autorizada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Programación Avanzada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Chip(
                          label: Text('Autorizada', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          backgroundColor: Color(0xFFFFF3E0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Clave UAp: 2451 • Créditos: 6.5', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Periodo: 2025-2 • Grupo: 5TM1', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 8),
                    const Text('Motivo: Ajuste de carga académica por dictamen.', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Solicitar Nueva Baja de UAp'),
                      content: const Text('¿Desea iniciar el proceso de baja ordinaria de una unidad de aprendizaje para el periodo actual? Asegúrate de cumplir con el porcentaje mínimo de avance.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryGuinda, foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Abriendo selector de materias para baja de UAp...')),
                            );
                          },
                          child: const Text('Continuar al Formulario'),
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
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Solicitar Baja de UAp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
