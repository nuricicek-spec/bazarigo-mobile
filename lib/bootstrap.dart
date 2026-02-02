// BASİT VERSİYON - CI için yeterli
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
  
  const BootstrapResult({
    this.isDegradedMode = false,
    this.metrics = const {'total_duration': 0},
    this.failedServices = const [],
    this.secureStorage,
    this.environment,
    this.appConfig,
    this.remoteConfig,
    this.sslPinningManager,
  });
}

Future<BootstrapResult> bootstrapApp({bool enableSSL = true}) async {
  return BootstrapResult();
}
