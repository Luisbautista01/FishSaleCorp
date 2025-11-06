// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/carrito/carrito_provider.dart';
import 'package:gestor_tareas_app/pay_wompi/pago_page.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:intl/intl.dart';

class CarritoPage extends StatelessWidget {
  const CarritoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);
    final formatoMoneda = NumberFormat.currency(
      locale: "es_CO",
      symbol: r"$",
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Carrito de compras"),
        backgroundColor: Colors.white,
      ),
      body: carrito.productos.isEmpty
          ? const Center(
              child: Text(
                "Tu carrito está vacío",
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: carrito.productos.length,
                    itemBuilder: (context, index) {
                      final item = carrito.productos[index];
                      final subtotal =
                          (item['precio'] ?? 0) * (item['cantidad'] ?? 0);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  (item['imagen'] != null &&
                                      item['imagen'].isNotEmpty)
                                  ? Image.network(
                                      item['imagen'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nombre'] ?? 'Producto',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue
                                              .withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              color: AppColors.primaryBlue,
                                              onPressed: () =>
                                                  carrito.decrementarProducto(
                                                    item['id'],
                                                  ),
                                            ),
                                            SizedBox(
                                              width: 36,
                                              child: Center(
                                                child: Text(
                                                  "${item['cantidad']}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              color: AppColors.primaryBlue,
                                              onPressed: () =>
                                                  carrito.incrementarProducto(
                                                    item['id'],
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        formatoMoneda.format(item['precio']),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatoMoneda.format(subtotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () =>
                                      carrito.eliminarProducto(item['id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatoMoneda.format(carrito.totalPrecio),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: carrito.productos.isEmpty
                              ? null
                              : () async {
                                  final token = await Provider.of<AuthService>(
                                    context,
                                    listen: false,
                                  ).getToken();
                                  String direccion = "";

                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Dirección de entrega"),
                                      content: TextField(
                                        decoration: const InputDecoration(
                                          labelText: "Ingresa tu dirección",
                                          hintText:
                                              "Ej: Carrera 5 #7-18, Barrio San José",
                                        ),
                                        onChanged: (value) => direccion = value,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancelar"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (direccion.trim().isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Por favor ingresa una dirección.",
                                                  ),
                                                ),
                                              );
                                            } else {
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: const Text("Aceptar"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (direccion.trim().isEmpty) return;

                                  try {
                                    final payload = {
                                      "productos": carrito.productos
                                          .map(
                                            (item) => {
                                              "productoId": item["id"],
                                              "cantidad": item["cantidad"],
                                            },
                                          )
                                          .toList(),
                                      "direccion": direccion,
                                    };

                                    final res = await http.post(
                                      Uri.parse(
                                        "${ApiConfig.baseUrl}/pedidos/compuesto",
                                      ),
                                      headers: {
                                        "Authorization": "Bearer $token",
                                        "Content-Type": "application/json",
                                      },
                                      body: jsonEncode(payload),
                                    );

                                    if (res.statusCode == 200 ||
                                        res.statusCode == 201) {
                                      final data =
                                          jsonDecode(res.body) as List<dynamic>;
                                      final primerPedidoId = data.isNotEmpty
                                          ? data.first['id']
                                          : 0;

                                      final total = carrito.totalPrecio;
                                      final productosSeleccionados =
                                          carrito.productos;

                                      carrito.vaciarCarrito();

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PagoPage(
                                            pedidoId: primerPedidoId,
                                            total: total,
                                            productos: productosSeleccionados,
                                          ),
                                        ),
                                      );
                                    } else {
                                      throw Exception(
                                        "Error al crear pedido: ${res.body}",
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Ocurrió un error: $e"),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Confirmar pedido",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
