import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGuinda = Color(0xFF731C24);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Gestión Escolar'),
        backgroundColor: primaryGuinda,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido al Sistema de Gestión Escolar!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
