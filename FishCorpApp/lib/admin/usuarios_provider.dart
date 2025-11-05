import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'usuarios_service.dart';

class UsuariosProvider extends ChangeNotifier {
  final UsuariosService _service = UsuariosService();

  List<dynamic> pescadores = [];
  List<dynamic> clientes = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadUsuarios(String rol) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _service.fetchUsuarios(rol);

      if (rol == "pescadores") {
        pescadores = data;
      } else if (rol == "clientes") {
        clientes = data;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> eliminarUsuario(int id, String rol) async {
    try {
      await _service.eliminarUsuario(id);
      await loadUsuarios(rol);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> cambiarRol(int id, String nuevoRol, String rol) async {
    try {
      await _service.cambiarRol(id, nuevoRol);
      await loadUsuarios(rol);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> actualizarPerfil(Map<String, dynamic> datos) async {
    try {
      await _service.actualizarPerfil(datos);

      final index = clientes.indexWhere((u) => u['id'] == datos['id']);
      if (index != -1) {
        clientes[index] = {...clientes[index], ...datos};
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Error al actualizar perfil: $e");
    }
  }

  Future<void> crearUsuario(
    String nombre,
    String email,
    String password,
    String rol,
  ) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/admin/usuarios');
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'password': password,
        'rol': rol,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error al crear usuario: ${res.body}');
    }
  }

  Future<void> actualizarUsuario(
    int id,
    String nombre,
    String email,
    String password,
    String rol,
  ) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/admin/usuarios/$id');
    final body = {'nombre': nombre, 'email': email, 'rol': rol};
    if (password.isNotEmpty) body['password'] = password;

    final res = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Error al actualizar usuario: ${res.body}');
    }
  }
}
