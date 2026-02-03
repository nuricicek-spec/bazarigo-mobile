import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bootstrap exception for initialization failures
class BootstrapException implements Exception {
  /// Error message
  final String message;

  /// Failed service name
  final String? service;

  /// Original error
  final Object? originalError;

  /// Creates a bootstrap exception
  const BootstrapException(
    this.message, {
    this.service,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('BootstrapException: $message');
    if (service != null) {
      buffer.write(' (Service: $service)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// Result of bootstrap process
class BootstrapResult {
  /// Whether app is running in degraded mode
  final bool isDegradedMode;

  /// Bootstrap metrics
  final Map<String, dynamic> metrics;

  /// List of services that failed to initialize
  final List<String> failedServices;

  /// Secure storage instance (nullable)
  final dynamic secureStorage;

  /// Environment configuration
  final dynamic environment;

  /// App configuration
  final dynamic appConfig;

  /// Remote configuration
  final dynamic remoteConfig;

  /// SSL pinning manager
  final dynamic sslPinningManager;

  /// Creates a bootstrap result
  const BootstrapResult({
    this.isDegradedMode = false,
    this.metrics = const {},
    this.failedServices = const [],
    this.secureStorage,
    this.environment,
    this.appConfig,
    this.remoteConfig,
    this.sslPinningManager,
  });

  /// Whether bootstrap was fully successful
  bool get isFullySuccessful => 
      !isDegradedMode && failedServices.isEmpty;

  /// Total bootstrap duration in milliseconds
  int get totalDuration => 
      metrics['total_duration'] as int? ?? 0;
}

/// Bootstraps the application
/// 
/// Initializes all core services with graceful degradation.
/// Returns [BootstrapResult] with initialization status.
Future<BootstrapResult> bootstrapApp({
  bool enableSSL = true,
  bool enableCrashlytics = false,
}) async {
  final stopwatch = Stopwatch()..start();
  final metrics = <String, dynamic>{};
  final failedServices = <String>[];

  debugPrint('🚀 Starting app bootstrap...');

  try {
    // Phase 1: Core Services
    await _initializeCoreServices(
      metrics: metrics,
      failedServices: failedServices,
    );

    // Phase 2: Security
    if (enableSSL) {
      await _initializeSecurityServices(
        metrics: metrics,
        failedServices: failedServices,
      );
    }

    // Phase 3: Analytics (optional)
    if (enableCrashlytics) {
      await _initializeAnalytics(
        metrics: metrics,
        failedServices: failedServices,
      );
    }

    stopwatch.stop();
    metrics['total_duration'] = stopwatch.elapsedMilliseconds;

    final isDegraded = failedServices.isNotEmpty;

    debugPrint(
      '✅ Bootstrap completed in ${stopwatch.elapsedMilliseconds}ms '
      '(${isDegraded ? 'DEGRADED' : 'FULL'} mode)',
    );

    if (isDegraded) {
      debugPrint('⚠️  Failed services: ${failedServices.join(', ')}');
    }

    return BootstrapResult(
      isDegradedMode: isDegraded,
      metrics: metrics,
      failedServices: failedServices,
    );
  } catch (error, stackTrace) {
    stopwatch.stop();
    debugPrint('❌ Critical bootstrap failure: $error');
    debugPrint('Stack: $stackTrace');

    // Return minimal result
    return BootstrapResult(
      isDegradedMode: true,
      metrics: {
        'total_duration': stopwatch.elapsedMilliseconds,
        'critical_error': error.toString(),
      },
      failedServices: ['critical'],
    );
  }
}

/// Initialize core services
Future<void> _initializeCoreServices({
  required Map<String, dynamic> metrics,
  required List<String> failedServices,
}) async {
  debugPrint('📦 Initializing core services...');

  try {
    // Simulate core initialization
    await Future<void>.delayed(const Duration(milliseconds: 100));
    metrics['core_init_ms'] = 100;
    debugPrint('  ✓ Core services initialized');
  } catch (error) {
    debugPrint('  ✗ Core services failed: $error');
    failedServices.add('core');
  }
}

/// Initialize security services
Future<void> _initializeSecurityServices({
  required Map<String, dynamic> metrics,
  required List<String> failedServices,
}) async {
  debugPrint('🔒 Initializing security services...');

  try {
    // Simulate security initialization
    await Future<void>.delayed(const Duration(milliseconds: 50));
    metrics['security_init_ms'] = 50;
    debugPrint('  ✓ Security services initialized');
  } catch (error) {
    debugPrint('  ✗ Security services failed: $error');
    failedServices.add('security');
  }
}

/// Initialize analytics
Future<void> _initializeAnalytics({
  required Map<String, dynamic> metrics,
  required List<String> failedServices,
}) async {
  debugPrint('📊 Initializing analytics...');

  try {
    // Simulate analytics initialization
    await Future<void>.delayed(const Duration(milliseconds: 30));
    metrics['analytics_init_ms'] = 30;
    debugPrint('  ✓ Analytics initialized');
  } catch (error) {
    debugPrint('  ✗ Analytics failed: $error');
    failedServices.add('analytics');
  }
}
