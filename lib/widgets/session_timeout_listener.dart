import 'dart:async';
import 'package:flutter/material.dart';

/// Widget que detecta la inactividad del usuario por interacciones físicas
/// (toques, clics, desplazamientos, tecleo) o cuando la aplicación permanece
/// en segundo plano por más tiempo del permitido.
class SessionTimeoutListener extends StatefulWidget {
  final Widget child;

  /// Duración máxima permitida de inactividad antes de disparar [onTimeout].
  final Duration duration;

  /// Callback que se ejecuta cuando se detecta inactividad prolongada.
  final VoidCallback onTimeout;

  /// Controla si la verificación de tiempo de inactividad está activa.
  final bool enabled;

  const SessionTimeoutListener({
    super.key,
    required this.child,
    required this.duration,
    required this.onTimeout,
    this.enabled = true,
  });

  @override
  State<SessionTimeoutListener> createState() => _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState extends State<SessionTimeoutListener>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _lastBackgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enabled) {
      _resetTimer();
    }
  }

  @override
  void didUpdateWidget(covariant SessionTimeoutListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled || widget.duration != oldWidget.duration) {
      if (widget.enabled) {
        _resetTimer();
      } else {
        _timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    if (!widget.enabled) return;

    _timer = Timer(widget.duration, () {
      if (mounted && widget.enabled) {
        widget.onTimeout();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enabled) return;

    if (state == AppLifecycleState.paused) {
      _lastBackgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastBackgroundTime != null) {
        final timePassed = DateTime.now().difference(_lastBackgroundTime!);
        _lastBackgroundTime = null;
        if (timePassed >= widget.duration) {
          widget.onTimeout();
        } else {
          _resetTimer();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerHover: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
