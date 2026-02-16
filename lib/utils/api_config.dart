class ApiConfig {
  // Cambia esta URL por la de tu servidor backend
  static const String baseUrl = 'http://10.0.2.2:3000';// 'http://10.0.2.2:3000' para desarrollo local emulador android

  // Endpoints de usuario
  static const String registro = '$baseUrl/usuario/registro';
  static const String login = '$baseUrl/usuario/login';
  static const String recuperarContrasena = '$baseUrl/usuario/recuperar';
  static const String restablecerContrasena = '$baseUrl/usuario/restablecer';
  static const String verificarRuc = '$baseUrl/usuario/verificarRuc';
  static const String verificarDni = '$baseUrl/usuario/verificarDni';

  // Headers comunes
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}