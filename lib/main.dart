import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap.dart';

/// Application entry point
/// Initializes core services and launches the app
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Bootstrap application with error handling
  try {
    final bootstrapResult = await bootstrapApp(
      enableSSL: true,
      enableCrashlytics: false, // Will be enabled in production
    );

    // Launch app with ProviderScope for Riverpod
    runApp(
      ProviderScope(
        child: BazarigoApp(
          bootstrapResult: bootstrapResult,
        ),
      ),
    );
  } catch (error, stackTrace) {
    // Fallback: Launch minimal app on bootstrap failure
    debugPrint('❌ Bootstrap failed: $error');
    debugPrint('Stack trace: $stackTrace');

    runApp(
      const ProviderScope(
        child: BazarigoApp(
          bootstrapResult: null,
        ),
      ),
    );
  }
}
