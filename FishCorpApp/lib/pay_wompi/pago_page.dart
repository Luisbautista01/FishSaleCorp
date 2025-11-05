// ignore_for_file: use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/pay_wompi/mis_pagos_page.dart';
import 'package:gestor_tareas_app/pay_wompi/ticket_page.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;

class PagoPage extends StatefulWidget {
  final int pedidoId;
  final double total;
  final List<Map<String, dynamic>> productos;

  const PagoPage({
    super.key,
    required this.pedidoId,
    required this.total,
    required this.productos,
  });

  @override
  State<PagoPage> createState() => _PagoPageState();
}

class _PagoPageState extends State<PagoPage> {
  bool procesandoPago = false;
  String metodoPagoSeleccionado = "NEQUI";

  final formatoMoneda = NumberFormat.currency(
    locale: "es_CO",
    symbol: r"$",
    decimalDigits: 2,
  );

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playSound(String assetPath) async {
    try {
      final bytes = await rootBundle.load(assetPath);
      final buffer = bytes.buffer.asUint8List();
      await _audioPlayer.play(BytesSource(buffer));
    } catch (_) {}
  }

  Future<void> _simularPago() async {
    setState(() => procesandoPago = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      final body = {
        "pedidoId": widget.pedidoId,
        "monto": widget.total,
        "metodoPago": metodoPagoSeleccionado,
        "productos": widget.productos.map((p) {
          return {
            "productoId": p['id'],
            "nombre": p['nombre'],
            "precio": p['precio'],
            "cantidad": p['cantidad'],
          };
        }).toList(),
      };

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/pagos/simular"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      setState(() => procesandoPago = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final pagoId = data['id'] ?? 0;
        final pedidoId = data['pedidoId'] ?? widget.pedidoId;
        final monto = (data['monto'] is int)
            ? (data['monto'] as int).toDouble()
            : (data['monto'] ?? widget.total);
        final metodo = data['metodoPago'] ?? metodoPagoSeleccionado;
        final estado = data['estado'] ?? 'DESCONOCIDO';
        final referencia = data['referenciaWompi'] ?? '';
        final cliente = data['cliente'] ?? '';
        final pescador = data['pescador'] ?? '';

        await _playSound('assets/sounds/success.mp3');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TicketPage(
              pagoId: pagoId,
              pedidoId: pedidoId,
              monto: monto,
              metodoPago: metodo,
              estado: estado,
              referencia: referencia,
              cliente: cliente,
              pescador: pescador,
            ),
          ),
        ).then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MisPagosPage(authService: authService, rol: "CLIENTE"),
            ),
          );
        });
      } else {
        _mostrarError("Error al procesar el pago: ${response.body}");
      }
    } catch (e) {
      setState(() => procesandoPago = false);
      _mostrarError("Error de conexión: $e");
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "Pago Pedido #${widget.pedidoId}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- CARD DE RESUMEN ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.receipt_long,
                        color: AppColors.primaryBlue,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Resumen del Pedido",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...widget.productos.map((item) {
                    final precio = (item['precio'] ?? 0).toDouble();
                    final cantidad = item['cantidad'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${item['nombre']} x$cantidad",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Text(
                            formatoMoneda.format(precio * cantidad),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total a pagar",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatoMoneda.format(widget.total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- MÉTODO DE PAGO ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Selecciona tu método de pago",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: metodoPagoSeleccionado,
                    decoration: InputDecoration(
                      labelText: "Método de pago",
                      prefixIcon: const Icon(Icons.payment_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "CARD",
                        child: Text("Tarjeta de crédito"),
                      ),
                      DropdownMenuItem(value: "PSE", child: Text("PSE")),
                      DropdownMenuItem(value: "NEQUI", child: Text("Nequi")),
                      DropdownMenuItem(
                        value: "DAVIPLATA",
                        child: Text("Daviplata"),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => metodoPagoSeleccionado = v!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- BOTÓN DE PAGO ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: procesandoPago ? null : _simularPago,
                icon: procesandoPago
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.lock_open_rounded),
                label: Text(
                  procesandoPago ? "Procesando..." : "Pagar ahora",
                  style: const TextStyle(fontSize: 17),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primaryBlue.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
