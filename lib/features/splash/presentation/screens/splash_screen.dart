import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/gradient_background.dart';

/// Branded loading screen shown while the persisted session is restored.
///
/// The router holds navigation here while [AuthController.status] is
/// [AuthStatus.unknown]; once the session resolves it redirects to either the
/// login screen or the home dashboard. A gentle looping animation reassures the
/// child that the app is working.
class SplashScreen extends StatefulWidget {
  /// Creates the [SplashScreen].
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(
    begin: 0.94,
    end: 1.06,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: const AppLogo(size: 120),
          ),
        ),
      ),
    );
  }
}
