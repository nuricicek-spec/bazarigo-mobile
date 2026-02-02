// lib/bootstrap.dart (BOŞ - şimdilik)
class BootstrapException implements Exception {
  final String message;
  BootstrapException(this.message);
}

class BootstrapResult {
  final bool isDegradedMode;
  final Map<String, dynamic> metrics;
  final List<String> failedServices;
  final dynamic secureStorage;
  final dynamic environment;
  final dynamic appConfig;
  final dynamic remoteConfig;
  final dynamic sslPinningManager;
  
  BootstrapResult({
    required this.isDegradedMode,
    required this.metrics,
    required this.failedServices,
    this.secureStorage,
    this.environment,
    this.appConfig,
    this.remoteConfig,
    this.sslPinningManager,
  });
}

Future<BootstrapResult> bootstrapApp({bool enableSSL = true}) async {
  return BootstrapResult(
    isDegradedMode: false,
    metrics: {'total_duration': 0},
    failedServices: [],
  );
}
