// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      print(
        "Respuesta del backend: ${response.statusCode} => ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = data['usuario'] ?? data;
        final token = data['token'];

        if (token == null || user['rol'] == null) {
          throw Exception(
            "Datos de sesión incompletos en la respuesta del servidor",
          );
        }

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', token);
        await prefs.setString('rol', user['rol'].toString().toUpperCase());

        await _saveUserData(prefs, user);

        print("Sesión guardada correctamente");
        return data;
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Credenciales inválidas');
      }
    } catch (e) {
      print("Error en login: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String nombre,
    required String email,
    required String password,
    required String rol,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre.trim(),
          'email': email.trim(),
          'password': password,
          'rol': rol.toUpperCase(),
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      print("Error en register: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("Sesión cerrada correctamente");
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token actual: $token");
    return token;
  }

  Future<String?> getRol() async =>
      (await SharedPreferences.getInstance()).getString('rol');

  Future<String?> getNombre() async =>
      (await SharedPreferences.getInstance()).getString('nombre');

  Future<String?> getEmail() async =>
      (await SharedPreferences.getInstance()).getString('email');

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final rol = prefs.getString('rol')?.toUpperCase();
    switch (rol) {
      case 'PESCADOR':
        return prefs.getInt('pescadorId');
      case 'CLIENTE':
        return prefs.getInt('clienteId');
      case 'ADMIN':
        return prefs.getInt('administradorId');
      default:
        return null;
    }
  }

  Future<void> _saveUserData(
    SharedPreferences prefs,
    Map<String, dynamic> data,
  ) async {
    if (data['nombre'] != null) {
      await prefs.setString('nombre', data['nombre']);
    }
    if (data['email'] != null) {
      await prefs.setString('email', data['email']);
    }

    if (data['id'] != null && data['rol'] != null) {
      final id = data['id'] is int
          ? data['id']
          : int.tryParse(data['id'].toString()) ?? 0;
      final rol = data['rol'].toString().toUpperCase();

      switch (rol) {
        case 'PESCADOR':
          await prefs.setInt('pescadorId', id);
          break;
        case 'CLIENTE':
          await prefs.setInt('clienteId', id);
          break;
        case 'ADMIN':
          await prefs.setInt('administradorId', id);
          break;
      }
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error: ${response.body}");
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error: ${response.body}");
    }
  }
}
