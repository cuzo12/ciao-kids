import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/service_locator.dart';

/// Application entry point.
///
/// Ensures the Flutter binding is ready, wires up the dependency graph, then
/// launches [CiaoKidsApp]. Keeping `main` this thin means startup logic is
/// testable and the app composition lives in well-defined layers.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const CiaoKidsApp());
}
