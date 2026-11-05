import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/errors/app_error_screen.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'widgets/session_timeout_listener.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool _dialogoExpiradoAbierto = false;

class AuthRouteObserver extends NavigatorObserver {
  static bool isOnAuthScreen = true;

  void _update(Route<dynamic>? route) {
    if (route != null) {
      final name = route.settings.name;
      isOnAuthScreen = name == '/login' || name == '/registro' || name == null;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _update(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _update(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _update(newRoute);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar la barra de estado con fondo transparente e íconos oscuros por defecto
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Reemplazar la pantalla de error predeterminada de Flutter por AppErrorScreen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return AppErrorScreen(flutterErrorDetails: details);
  };

  // Manejo de errores no capturados del framework
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Manejo de errores asíncronos y de plataforma
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Excepción no manejada en PlatformDispatcher: $error');
    return true;
  };

  runApp(const GescoApp());
}

class GescoApp extends StatelessWidget {
  const GescoApp({super.key});

  void _manejadorSesionExpirada() {
    if (_dialogoExpiradoAbierto) return;
    if (AuthRouteObserver.isOnAuthScreen) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    _dialogoExpiradoAbierto = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.timer_off_rounded, color: AppColors.guinda),
            SizedBox(width: 8),
            Text('Sesión inactiva'),
          ],
        ),
        content: const Text(
          'Tu sesión ha expirado por inactividad. Por favor, vuelve a iniciar sesión para continuar.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.guinda,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _dialogoExpiradoAbierto = false;
              Navigator.of(dialogContext).pop();
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                  settings: const RouteSettings(name: '/login'),
                ),
                (route) => false,
              );
            },
            child: const Text('Entrar de nuevo'),
          ),
        ],
      ),
    ).then((_) {
      _dialogoExpiradoAbierto = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SessionTimeoutListener(
      duration: const Duration(minutes: 15),
      onTimeout: _manejadorSesionExpirada,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [AuthRouteObserver()],
        title: 'GESCO · Gestión Escolar UPIIZ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('es', 'MX'),
        supportedLocales: const [Locale('es', 'MX'), Locale('es', 'ES')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        onGenerateRoute: (settings) {
          if (settings.name == '/' || settings.name == '/login') {
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
              settings: const RouteSettings(name: '/login'),
            );
          }
          return null;
        },
        home: const LoginScreen(
          key: ValueKey('login-screen-home'),
        ),
      ),
    );
  }
}
