import 'package:flutter/foundation.dart' show kIsWeb;

enum ApiEnvironment { emulator, genymotion, device }

class ApiConfig {
  // Detecta si corre en Web o en dispositivos
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web → usa localhost con /api
      return 'http://localhost:8080/fishcorp.unicartagena/api';
    }

    // Para apps móviles nativas
    const ApiEnvironment environment = ApiEnvironment.emulator;

    switch (environment) {
      case ApiEnvironment.emulator:
        return 'http://10.0.2.2:8080/fishcorp.unicartagena/api';
      case ApiEnvironment.genymotion:
        return 'http://10.0.3.2:8080/fishcorp.unicartagena/api';
      case ApiEnvironment.device:
        return 'http://10.228.239.251:8080/fishcorp.unicartagena/api';
    }
  }

  static String get authUrl => '$baseUrl/auth';
}
