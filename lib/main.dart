import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gesco/screens/login_screen.dart';

void main() {
  runApp(const SiGe());
}

class SiGe extends StatelessWidget {
  const SiGe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Integral de Gestión Escolar',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'MX'),
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('es', 'ES'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF731C24),
          primary: const Color(0xFF731C24),
        ),
        scaffoldBackgroundColor: const Color(0xFFEBEBEB),
      ),
      home: const LoginScreen(),
    );
  }
}
