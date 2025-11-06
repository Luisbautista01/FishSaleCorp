import 'dart:convert';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class UsuariosService {
  final AuthService _authService = AuthService();

  String get _baseUrl => "${ApiConfig.baseUrl}/admin/usuarios";

  Future<List<dynamic>> fetchUsuarios(String rol) async {
    final token = await _authService.getToken();
    final url = Uri.parse("$_baseUrl/$rol");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception("Error al cargar $rol: ${response.body}");
    }
  }

  Future<void> eliminarUsuario(int id) async {
    final token = await _authService.getToken();
    final url = Uri.parse("$_baseUrl/$id");

    final response = await http.delete(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        "Error al eliminar usuario (${response.statusCode}): ${response.body}",
      );
    }
  }

  Future<void> cambiarRol(int id, String nuevoRol) async {
    final token = await _authService.getToken();
    final url = Uri.parse("$_baseUrl/cambiar_rol/$id");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"nuevoRol": nuevoRol}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Error al cambiar rol (status: ${response.statusCode}): ${response.body}",
      );
    }
  }

  Future<void> actualizarPerfil(Map<String, dynamic> datos) async {
    final token = await _authService.getToken();
    final url = Uri.parse("${ApiConfig.baseUrl}/usuarios/${datos['id']}");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(datos),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar perfil: ${response.body}");
    }
  }
}
