import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestor_tareas_app/pay_wompi/ticket_page.dart';
import 'package:intl/intl.dart';

class ClienteDetallePage extends StatelessWidget {
  final String clienteNombre;
  final Map<String, dynamic> datosVenta;

  const ClienteDetallePage({
    super.key,
    required this.clienteNombre,
    required this.datosVenta,
  });

  Color _colorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case "APROBADO":
        return Colors.green;
      case "PENDIENTE":
        return Colors.orange;
      case "RECHAZADO":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');

    final estado =
        datosVenta["estado"]?.toString().toUpperCase() ?? "DESCONOCIDO";

    final montoStr = datosVenta["monto"]?.toString() ?? "0";
    final monto =
        double.tryParse(montoStr.replaceAll(",", "").replaceAll("\$", "")) ??
        0.0;

    final metodoPago =
        datosVenta["metodoPago"]?.toString() ?? "No especificado";

    final pedidoId = int.tryParse("${datosVenta["pedidoId"] ?? 0}") ?? 0;
    final referencia = datosVenta["referenciaWompi"] ?? "Sin referencia";

    final pagoId = int.tryParse("${datosVenta["id"] ?? "0"}") ?? 0;
    final fecha = datosVenta["fechaCreacion"]?.toString() ?? "Sin fecha";
    final pescador =
        datosVenta["pescador"]?.toString() ?? "Tú (Pescador actual)";

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 3,
        centerTitle: true,
        title: Text(
          "Cliente: $clienteNombre",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: AppColors.white,
          elevation: 10,
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.person, color: AppColors.accent, size: 50),
                        const SizedBox(height: 8),
                        Text(
                          clienteNombre,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Pago realizado a $pescador",
                          style: GoogleFonts.poppins(
                            color: AppColors.greyText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32, thickness: 1),
                  _buildInfo("Pago ID", "$pagoId"),
                  _buildInfo("Pedido ID", "$pedidoId"),
                  _buildInfo("Fecha de pago", fecha),
                  _buildInfo("Método de Pago", metodoPago),
                  _buildInfo("Referencia", referencia),
                  _buildInfo("Monto", "${formatter.format(monto)} COP"),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Estado del Pago",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _colorEstado(estado).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _colorEstado(estado).withOpacity(0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            estado,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _colorEstado(estado),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(180, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: Text(
                        "Ver Ticket del Pago",
                        style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TicketPage(
                              pagoId: pagoId,
                              pedidoId: pedidoId,
                              monto: monto,
                              metodoPago: metodoPago,
                              estado: estado,
                              referencia: referencia,
                              cliente: clienteNombre,
                              pescador: pescador,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: GoogleFonts.poppins(
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
