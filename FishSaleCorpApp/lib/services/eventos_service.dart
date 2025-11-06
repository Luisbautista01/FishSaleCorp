// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class EventosService {
  final String baseUrl;

  EventosService({required this.baseUrl});

  Future<Map<DateTime, List<String>>> obtenerEventos({
    required String rol,
    required int? clienteId,
    required int? pescadorId,
    required String token,
  }) async {
    final Map<DateTime, List<String>> eventos = {};

    try {
      Uri pagosUrl;
      Uri pedidosUrl;

      if (rol == "CLIENTE") {
        pagosUrl = Uri.parse('$baseUrl/pagos/por-cliente');
        pedidosUrl = Uri.parse('$baseUrl/pedidos/cliente');
      } else if (rol == "PESCADOR") {
        pagosUrl = Uri.parse('$baseUrl/pagos/por-pescador/$pescadorId');
        pedidosUrl = Uri.parse('$baseUrl/pedidos');
      } else {
        pagosUrl = Uri.parse('$baseUrl/pagos');
        pedidosUrl = Uri.parse('$baseUrl/pedidos');
      }

      final pagosRes = await http.get(
        pagosUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (pagosRes.statusCode == 200) {
        final List<dynamic> pagosData = jsonDecode(pagosRes.body);
        for (var pago in pagosData) {
          try {
            final fecha = DateTime.parse(pago['fechaCreacion']);
            final key = DateTime(fecha.year, fecha.month, fecha.day);
            final estado = pago['estado'] ?? 'Desconocido';
            final monto = pago['monto'] ?? 0.0;

            eventos.putIfAbsent(key, () => []);
            eventos[key]!.add("💰 Pago: $estado - $monto \$");
          } catch (_) {}
        }
      } else {
        print("Error obteniendo pagos: ${pagosRes.statusCode}");
      }

      final pedidosRes = await http.get(
        pedidosUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (pedidosRes.statusCode == 200) {
        final dynamic body = jsonDecode(pedidosRes.body);

        final List<dynamic> pedidosData = body is List
            ? body
            : (body['content'] ?? []);

        for (var pedido in pedidosData) {
          try {
            final fecha = DateTime.parse(pedido['fechaCreacion']);
            final key = DateTime(fecha.year, fecha.month, fecha.day);
            final estado = pedido['estado'] ?? 'Desconocido';
            final cantidad = pedido['cantidad'] ?? 0;
            final producto = pedido['productoNombre'] ?? 'Producto';

            eventos.putIfAbsent(key, () => []);
            eventos[key]!.add("📦 Pedido: $producto x$cantidad - $estado");
          } catch (_) {}
        }
      } else {
        print("Error obteniendo pedidos: ${pedidosRes.statusCode}");
      }
    } catch (e) {
      print("Error cargando eventos: $e");
    }

    return eventos;
  }
}
