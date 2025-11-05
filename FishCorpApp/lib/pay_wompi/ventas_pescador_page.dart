// ignore_for_file: use_build_context_synchronously, unnecessary_to_list_in_spreads, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestor_tareas_app/pay_wompi/cliente_detalle_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';

class VentasPescadorPage extends StatefulWidget {
  final AuthService authService;
  final int? pescadorId;
  final String pescadorNombre;

  const VentasPescadorPage({
    super.key,
    required this.authService,
    required this.pescadorId,
    required this.pescadorNombre,
  });

  @override
  State<VentasPescadorPage> createState() => _VentasPescadorPageState();
}

class _VentasPescadorPageState extends State<VentasPescadorPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> ventas = [];
  List<Map<String, dynamic>> ventasFiltradas = [];
  List<String> clientes = [];
  String? clienteSeleccionado;

  double total = 0.0;
  int aprobados = 0;
  int pendientes = 0;
  int rechazados = 0;

  final formatoMoneda = NumberFormat.currency(
    locale: "es_CO",
    symbol: r"$",
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    setState(() => isLoading = true);

    try {
      final token = await widget.authService.getToken();
      final rol = await widget.authService.getRol();

      String url;

      if (rol != null && rol.toUpperCase() == "PESCADOR") {
        url = "${ApiConfig.baseUrl}/pagos/por-pescador";
      } else if (rol != null &&
          rol.toUpperCase() == "ADMIN" &&
          widget.pescadorId != null) {
        url = "${ApiConfig.baseUrl}/pagos/por-pescador/${widget.pescadorId}";
      } else {
        setState(() {
          ventas = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No tienes permiso para ver estas ventas"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          ventas = List<Map<String, dynamic>>.from(data);
          ventasFiltradas = List.from(ventas);

          print(data);

          clientes = [
            "Todos los clientes",
            ...{for (var v in ventas) v["cliente"] ?? "Cliente desconocido"},
          ];

          _calcularTotales(ventasFiltradas);
          isLoading = false;
        });
      } else {
        throw Exception("Error al obtener ventas: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        ventas = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cargar ventas: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _calcularTotales(List<Map<String, dynamic>> lista) {
    aprobados = lista.where((v) => v["estado"] == "APROBADO").length;
    pendientes = lista.where((v) => v["estado"] == "PENDIENTE").length;
    rechazados = lista.where((v) => v["estado"] == "RECHAZADO").length;
    total = lista
        .where((v) => (v["estado"] ?? "") == "APROBADO")
        .fold(0.0, (s, v) => s + ((v["monto"] ?? 0) as num).toDouble());
  }

  void _filtrarPorCliente(String? cliente) {
    setState(() {
      clienteSeleccionado = cliente;
      if (cliente == null || cliente == "Todos los clientes") {
        ventasFiltradas = List.from(ventas);
      } else {
        ventasFiltradas = ventas.where((v) => v["cliente"] == cliente).toList();
      }
      _calcularTotales(ventasFiltradas);
    });
  }

  Widget _buildChart() {
    if (aprobados + pendientes + rechazados == 0) {
      return const Center(
        child: Text("No hay datos suficientes para generar el gráfico."),
      );
    }

    return PieChart(
      PieChartData(
        centerSpaceRadius: 50,
        sectionsSpace: 4,
        sections: [
          PieChartSectionData(
            color: Colors.greenAccent.shade400,
            value: aprobados.toDouble(),
            title: "Aprobados\n$aprobados",
            radius: 60,
            titleStyle: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          PieChartSectionData(
            color: Colors.orangeAccent.shade400,
            value: pendientes.toDouble(),
            title: "Pendientes\n$pendientes",
            radius: 60,
            titleStyle: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          PieChartSectionData(
            color: Colors.redAccent.shade400,
            value: rechazados.toDouble(),
            title: "Rechazados\n$rechazados",
            radius: 60,
            titleStyle: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVentaCard(Map<String, dynamic> venta) {
    final monto = venta["monto"] ?? 0.0;
    final estado = venta["estado"] ?? "DESCONOCIDO";
    final fecha = venta["fechaCreacion"] ?? "Sin fecha";
    final cliente = venta["cliente"] ?? "Cliente desconocido";

    Color colorEstado;
    switch (estado) {
      case "APROBADO":
        colorEstado = Colors.green;
        break;
      case "PENDIENTE":
        colorEstado = Colors.orange;
        break;
      case "RECHAZADO":
        colorEstado = Colors.red;
        break;
      default:
        colorEstado = Colors.grey;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ClienteDetallePage(clienteNombre: cliente, datosVenta: venta),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colorEstado.withOpacity(0.2),
            child: Icon(Icons.payments, color: colorEstado),
          ),
          title: Text(
            formatoMoneda.format(monto),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            "Cliente: $cliente\nFecha: $fecha",
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorEstado.withOpacity(0.3)),
            ),
            child: Text(
              estado,
              style: GoogleFonts.poppins(
                color: colorEstado,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 20,
          ),
        ),
        Text(label, style: GoogleFonts.poppins(fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: Text(
          "Ventas de ${widget.pescadorNombre}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarVentas,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeOut,
                      tween: Tween(begin: 0, end: total),
                      builder: (context, value, _) => Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Total de Ventas",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatoMoneda.format(value),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildEstadoChip(
                                    "Aprobados",
                                    aprobados,
                                    Colors.green,
                                  ),
                                  _buildEstadoChip(
                                    "Pendientes",
                                    pendientes,
                                    Colors.orange,
                                  ),
                                  _buildEstadoChip(
                                    "Rechazados",
                                    rechazados,
                                    Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Filtrar por cliente",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.blueGrey,
                      ),
                      value: clienteSeleccionado ?? "Todos los clientes",
                      items: clientes
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: _filtrarPorCliente,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Gráfico de Ventas",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(height: 260, child: _buildChart()),
                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Detalle de Ventas",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...ventasFiltradas.map(_buildVentaCard).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
