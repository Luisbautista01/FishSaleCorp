import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';

class PedidoDetallePage extends StatelessWidget {
  final Map pedido;

  const PedidoDetallePage({super.key, required this.pedido});

  double toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final producto = pedido['producto'] ?? {};
    final cliente = pedido['cliente'] ?? {};
    final pescador = producto['pescador'] ?? {};
    final cantidad = toInt(pedido['cantidad']);
    final precio = toDouble(producto['precio']);
    final total = cantidad * precio;
    final estado = (pedido['estado'] ?? 'Desconocido').toString();
    final direccion = pedido['direccion'] ?? "No especificada";
    final fecha = pedido['fechaCreacion'] != null
        ? DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(DateTime.parse(pedido['fechaCreacion']))
        : "Sin fecha";

    final formatoMoneda = NumberFormat.currency(
      locale: "es_CO",
      symbol: "\$ ",
      decimalDigits: 0,
    );

    Color estadoColor;
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        estadoColor = Colors.orange;
        break;
      case 'ENVIADO':
        estadoColor = Colors.blue;
        break;
      case 'ENTREGADO':
        estadoColor = Colors.green;
        break;
      case 'CANCELADO':
        estadoColor = Colors.red;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: Text(
          "Detalle del Pedido",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImage(producto['imagen']),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto['nombre'] ?? "Producto",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(
                            estado,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: estadoColor,
                        ),
                        Text(
                          fecha,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    _infoRow("Cliente", cliente['nombre'] ?? "Desconocido"),
                    _infoRow("Pescador", pescador['nombre'] ?? "Desconocido"),
                    _infoRow("Dirección", direccion),
                    _infoRow("Cantidad", "$cantidad unidades"),
                    _infoRow("Precio unitario", formatoMoneda.format(precio)),
                    _infoRow(
                      "Total del pedido",
                      formatoMoneda.format(total),
                      bold: true,
                      color: AppColors.primaryBlue,
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        label: const Text("Volver"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color ?? AppColors.greyText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey[200],
        child: const Icon(
          Icons.image_not_supported,
          size: 80,
          color: Colors.grey,
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        height: 220,
        width: double.infinity,
      ),
    );
  }
}
