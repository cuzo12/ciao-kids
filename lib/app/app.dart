import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/lessons/presentation/controllers/learning_controller.dart';
import '../features/player/presentation/controllers/player_controller.dart';
import 'di/service_locator.dart';

/// Root widget of Ciao Kids.
///
/// Responsibilities:
///  * Provide the singleton [AuthController] to the widget tree (via
///    `provider`), reusing the same instance held by the service locator.
///  * Kick off session restore exactly once ([AuthController.appStarted]).
///  * Build the auth-aware [AppRouter] and hand it to [MaterialApp.router].
///  * Apply the light/dark themes and follow the system brightness.
class CiaoKidsApp extends StatefulWidget {
  /// Creates the root app widget.
  const CiaoKidsApp({super.key});

  @override
  State<CiaoKidsApp> createState() => _CiaoKidsAppState();
}

class _CiaoKidsAppState extends State<CiaoKidsApp> {
  late final AuthController _authController = sl<AuthController>();
  late final AppRouter _router = AppRouter(_authController);

  @override
  void initState() {
    super.initState();
    // Restore any persisted session; the router shows the splash until done.
    _authController.appStarted();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: _authController),
        ChangeNotifierProvider<LearningController>.value(
          value: sl<LearningController>(),
        ),
        ChangeNotifierProvider<PlayerController>.value(
          value: sl<PlayerController>(),
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _router.config,
      ),
    );
  }
}
