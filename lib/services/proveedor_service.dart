import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/proveedor.dart';
import '../utils/api_config.dart';
import 'auth_service.dart';

class ProveedorService {
  final _authService = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return ApiConfig.getAuthHeaders(token ?? '');
  }

  // ── GET todos (activos + inactivos) ───────────────────────────────────────
  Future<Map<String, dynamic>> listarProveedores() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/proveedor/'),
        headers: await _authHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<Proveedor> proveedores = (data['data'] as List)
            .map((item) => Proveedor.fromJson(item))
            .toList();
        return {'success': true, 'data': proveedores};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al listar proveedores',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // ── GET buscar por documento o razonSocial ────────────────────────────────
  Future<Map<String, dynamic>> buscarProveedores({
    String? documento,
    String? razonSocial,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (documento != null && documento.isNotEmpty) {
        queryParams['documento'] = documento;
      }
      if (razonSocial != null && razonSocial.isNotEmpty) {
        queryParams['razonSocial'] = razonSocial;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/proveedor/buscar')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _authHeaders());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<Proveedor> proveedores = (data['data'] as List)
            .map((item) => Proveedor.fromJson(item))
            .toList();
        return {'success': true, 'data': proveedores};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'No se encontraron proveedores',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // ── POST registrar ────────────────────────────────────────────────────────
  // La respuesta exitosa devuelve { message, razonSocial } sin campo 'success'
  Future<Map<String, dynamic>> registrarProveedor({
    required String tipoProveedor,
    required String documento,
    required String razonSocial,
    required String telefono,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/proveedor/'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'tipoProveedor': tipoProveedor,
          'documento': documento,
          'razonSocial': razonSocial,
          'telefono': telefono,
        }),
      );

      final data = jsonDecode(response.body);

      // El backend responde 201 con { message, razonSocial } en éxito
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Proveedor registrado exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al registrar proveedor',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // ── PUT editar (solo razonSocial y telefono) ──────────────────────────────
  Future<Map<String, dynamic>> editarProveedor({
    required String id,
    required String razonSocial,
    required String telefono,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/proveedor/$id'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'razonSocial': razonSocial,
          'telefono': telefono,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Proveedor editado exitosamente',
          'data': Proveedor.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al editar proveedor',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // ── PATCH cambiar estado (habilitar / deshabilitar) ───────────────────────
  Future<Map<String, dynamic>> cambiarEstado({
    required String id,
    required bool nuevoEstado,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/proveedor/$id/estado'),
        headers: await _authHeaders(),
        body: jsonEncode({'estado': nuevoEstado}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Estado actualizado',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al cambiar estado',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }
}