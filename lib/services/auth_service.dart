import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../utils/api_config.dart';
import 'firebase_messaging_service.dart';

class AuthService {
  final _firebaseMessagingService = FirebaseMessagingService();

  // Guardar token y datos de usuario
  Future<void> _saveAuthData(String token, Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('usuario', jsonEncode(usuario.toJson()));
  }

  // Obtener token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Obtener usuario guardado
  Future<Usuario?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');
    if (usuarioJson != null) {
      return Usuario.fromJson(jsonDecode(usuarioJson));
    }
    return null;
  }

  // Verificar si está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Login con FCM token de Firebase
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    try {
      // Obtener el token FCM actual de Firebase
      String? fcmToken = await _firebaseMessagingService.getToken();

      // Si no se puede obtener el token, usar uno temporal
      if (fcmToken == null) {
        fcmToken = 'temp_token_${DateTime.now().millisecondsSinceEpoch}';
        print('Advertencia: No se pudo obtener el token FCM, usando temporal');
      }

      print('Intentando login con correo: $correo');
      print('URL: ${ApiConfig.login}');

      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'Correo': correo,
          'Contrasena': contrasena,
          'fcmToken': fcmToken,
        }),
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      // Verificar si la respuesta está vacía o es null
      if (response.body.isEmpty || response.body == 'null') {
        return {
          'success': false,
          'message': 'El servidor no respondió correctamente. Verifica que el backend esté funcionando.',
        };
      }

      // Intentar decodificar la respuesta
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('Error al decodificar JSON: $e');
        return {
          'success': false,
          'message': 'Respuesta inválida del servidor: ${response.body}',
        };
      }

      // Verificar si data es null
      if (data == null) {
        return {
          'success': false,
          'message': 'El servidor respondió con datos nulos. Verifica las credenciales o el backend.',
        };
      }

      if (response.statusCode == 200) {
        // Verificar que existan los campos necesarios
        if (data['data'] == null || data['token'] == null) {
          return {
            'success': false,
            'message': 'Respuesta del servidor incompleta. Falta información de usuario o token.',
          };
        }

        final usuario = Usuario.fromJson(data['data']);
        await _saveAuthData(data['token'], usuario);

        return {
          'success': true,
          'message': data['message'] ?? 'Login exitoso',
          'usuario': usuario,
        };
      } else {
        // Error del servidor (400, 401, 500, etc.)
        return {
          'success': false,
          'message': data['message'] ?? 'Error al iniciar sesión. Código: ${response.statusCode}',
        };
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return {
        'success': false,
        'message': 'No se puede conectar al servidor. Verifica tu conexión a internet y que el backend esté corriendo.',
      };
    } on FormatException catch (e) {
      print('Error de formato: $e');
      return {
        'success': false,
        'message': 'El servidor respondió con un formato inválido.',
      };
    } catch (e) {
      print('Error inesperado: $e');
      return {
        'success': false,
        'message': 'Error inesperado: ${e.toString()}',
      };
    }
  }

  // Registro
  Future<Map<String, dynamic>> registro({
    required String nombres,
    required String apellidos,
    required String correo,
    required String celular,
    required String contrasena,
    required String ruc,
    required String razonSocial,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registro),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'Nombres': nombres,
          'Apellidos': apellidos,
          'Correo': correo,
          'Celular': celular,
          'Contrasena': contrasena,
          'RUC': ruc,
          'NombreTienda': razonSocial,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al registrarse',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Recuperar contraseña
  Future<Map<String, dynamic>> recuperarContrasena(String correo) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.recuperarContrasena),
        headers: ApiConfig.headers,
        body: jsonEncode({'Correo': correo}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al enviar código',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Restablecer contraseña
  Future<Map<String, dynamic>> restablecerContrasena(
      String correo,
      String codigo,
      String nuevaContrasena,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.restablecerContrasena),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'Correo': correo,
          'Codigo': codigo,
          'nuevaContrasena': nuevaContrasena,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al restablecer contraseña',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Verificar RUC
  Future<Map<String, dynamic>> verificarRuc(String ruc) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verificarRuc),
        headers: ApiConfig.headers,
        body: jsonEncode({'ruc': ruc}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'estado': data['estado'],
          'razonSocial': data['RazonSocial'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'RUC no válido',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al verificar RUC: ${e.toString()}',
      };
    }
  }

  // Verificar DNI
  Future<Map<String, dynamic>> verificarDni(String dni) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verificarDni),
        headers: ApiConfig.headers,
        body: jsonEncode({'dni': dni}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'estado': data['estado'],
          'nombreCompleto': data['nombreCompleto'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'DNI no válido',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al verificar DNI: ${e.toString()}',
      };
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    // Eliminar el token FCM del dispositivo
    await _firebaseMessagingService.deleteToken();

    // Eliminar datos de autenticación
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuario');
  }
}