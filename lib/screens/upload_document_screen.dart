import 'package:flutter/material.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  String _selectedDocType = 'Comprobante de Domicilio';
  bool _isFileSelected = false;

  final List<String> _docTypes = [
    'Comprobante de Domicilio',
    'Acta de Nacimiento',
    'Certificado de Bachillerato',
    'Dictamen / Oficio Académico',
    'Identificación Oficial (INE/Credencial)',
    'Otro Documento Oficial'
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGuinda = Color(0xFF731C24);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Documento Escolar'),
        backgroundColor: primaryGuinda,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione el tipo de documento a subir:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDocType,
                  isExpanded: true,
                  items: _docTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDocType = val!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Archivo del Documento (PDF o Imagen):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isFileSelected = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Archivo seleccionado: documento_oficial_ipn.pdf')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  color: primaryGuinda.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryGuinda.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isFileSelected ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                      size: 48,
                      color: _isFileSelected ? Colors.green : primaryGuinda,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isFileSelected ? 'documento_oficial_ipn.pdf (Listo)' : 'Toca aquí para seleccionar archivo PDF o Imagen',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _isFileSelected ? Colors.green : primaryGuinda,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isFileSelected ? 'Tamaño: 2.4 MB • Formato válido' : 'Máximo 10 MB • Formatos: PDF, JPG, PNG',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isFileSelected ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Documento subido y enviado a revisión escolar exitosamente.')),
                  );
                  Navigator.of(context).pop();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGuinda,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Enviar a Revisión Escolar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
