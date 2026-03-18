import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria.dart';
import '../utils/api_config.dart';
import 'auth_service.dart';

class CategoriaService {
  final _authService = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return ApiConfig.getAuthHeaders(token ?? '');
  }

  // Listar categorías activas
  Future<Map<String, dynamic>> listarCategorias() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categoria/activos'),
        headers: await _authHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<Categoria> categorias = (data['data'] as List)
            .map((item) => Categoria.fromJson(item))
            .toList();
        return {'success': true, 'data': categorias};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al listar categorías',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString()}'};
    }
  }

  // Crear categoría (POST)
  Future<Map<String, dynamic>> crearCategoria({
    required String nombre,
    required String descripcion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/categoria/crear'),
        headers: await _authHeaders(),
        body: jsonEncode({'nombre': nombre, 'descripcion': descripcion}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Categoría creada',
          'data': Categoria.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al crear categoría',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString()}'};
    }
  }

  // Actualizar categoría (PUT)
  Future<Map<String, dynamic>> actualizarCategoria({
    required String id,
    required String nombre,
    required String descripcion,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/categoria/$id'),
        headers: await _authHeaders(),
        body: jsonEncode({'nombre': nombre, 'descripcion': descripcion}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Categoría actualizada',
          'data': Categoria.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar categoría',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString()}'};
    }
  }

  // Deshabilitar categoría (PATCH)
  Future<Map<String, dynamic>> deshabilitarCategoria(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/categoria/$id/disable'),
        headers: await _authHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Categoría deshabilitada',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al deshabilitar',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString()}'};
    }
  }

  // Habilitar categoría (PATCH)
  Future<Map<String, dynamic>> habilitarCategoria(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/categoria/$id/enable'),
        headers: await _authHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Categoría habilitada',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al habilitar',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString()}'};
    }
  }
}