// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/pedidos/pedido_detalle_page.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:intl/intl.dart';

class PedidoCard extends StatelessWidget {
  final Map pedido;
  final String? extraInfo;
  final Function(String)? onEstadoChange;
  final String rolUsuario;

  const PedidoCard({
    required this.pedido,
    this.extraInfo,
    this.onEstadoChange,
    required this.rolUsuario,
    super.key,
  });

  int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Color _estadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return Colors.orangeAccent;
      case 'ENVIADO':
        return AppColors.accent;
      case 'ENTREGADO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _estadoIcono(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return Icons.access_time;
      case 'ENVIADO':
        return Icons.local_shipping;
      case 'ENTREGADO':
        return Icons.check_circle;
      case 'CANCELADO':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final producto = pedido['producto'] ?? {};
    final cliente = pedido['cliente'] ?? {};
    final cantidad = toInt(pedido['cantidad']);
    final precio = toDouble(producto['precio']);
    final total = cantidad * precio;
    final estado = (pedido['estado'] ?? 'DESCONOCIDO').toString();
    final pescador = producto['pescador']?['nombre'] ?? "Desconocido";
    final direccion = pedido['direccion'] ?? 'Sin dirección';
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.lightBlue, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(3, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImage(producto),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto['nombre'] ?? "Producto",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoText(
                                  "Cliente",
                                  cliente['nombre'] ?? 'Desconocido',
                                ),
                                _infoText("Pescador", pescador),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _infoText("Cantidad", cantidad.toString()),
                              Text(
                                formatoMoneda.format(total),
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _infoText("Fecha", fecha)),
                          const SizedBox(width: 8),
                          _buildEstadoChip(estado),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primaryBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              direccion,
                              style: const TextStyle(
                                color: AppColors.darkText,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PedidoDetallePage(pedido: pedido),
                    ),
                  );
                },
                label: const Text("Ver Detalle"),
                icon: const Icon(Icons.arrow_forward_ios),
                backgroundColor: AppColors.primaryBlue,
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(Map producto) {
    final imagen = producto['imagen'];
    if (imagen == null || imagen.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        Image.network(
          imagen,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.25), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoChip(String estado) {
    List<String> opciones = [];

    if (rolUsuario.toUpperCase() == 'ADMIN') {
      opciones = ['PENDIENTE', 'ENVIADO', 'ENTREGADO', 'CANCELADO'];
    } else if (rolUsuario.toUpperCase() == 'PESCADOR') {
      opciones = ['ENTREGADO'];
    }

    return onEstadoChange != null && opciones.isNotEmpty
        ? PopupMenuButton<String>(
            onSelected: (e) => onEstadoChange!(e),
            itemBuilder: (_) => opciones
                .map(
                  (e) => PopupMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(color: _estadoColor(e))),
                  ),
                )
                .toList(),
            child: _estadoChipContent(estado),
          )
        : _estadoChipContent(estado);
  }

  Widget _estadoChipContent(String estado) {
    return Chip(
      avatar: Icon(_estadoIcono(estado), color: Colors.white, size: 18),
      label: Text(
        estado,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _estadoColor(estado),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    );
  }

  Widget _infoText(String label, String value) {
    return Text.rich(
      TextSpan(
        text: "$label: ",
        style: const TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.greyText,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
