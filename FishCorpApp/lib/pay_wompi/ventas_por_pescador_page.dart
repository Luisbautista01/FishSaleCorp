// ignore_for_file: unnecessary_to_list_in_spreads

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'ventas_pescador_page.dart';

class VentasPorPescadoresPage extends StatefulWidget {
  final AuthService authService;

  const VentasPorPescadoresPage({super.key, required this.authService});

  @override
  State<VentasPorPescadoresPage> createState() =>
      _VentasPorPescadoresPageState();
}

class _VentasPorPescadoresPageState extends State<VentasPorPescadoresPage> {
  bool loading = true;
  String? errorMessage;
  List<Map<String, dynamic>> totales = [];
  List<Map<String, dynamic>> pagos = [];

  int aprobados = 0;
  int pendientes = 0;
  int rechazados = 0;
  double totalVentasGeneral = 0.0;

  int? pescadorSeleccionado;
  String estadoSeleccionado = "Todos";
  double totalPescador = 0.0;
  int ventasPescador = 0;

  final formatoMoneda = NumberFormat.currency(
    locale: "es_CO",
    symbol: r"$",
    decimalDigits: 2,
  );

  String? rolUsuario;
  int? pescadorIdUsuario;

  final List<String> estados = ['Todos', 'APROBADO', 'PENDIENTE', 'RECHAZADO'];

  @override
  void initState() {
    super.initState();
    _inicializarUsuario();
  }

  Future<void> _inicializarUsuario() async {
    rolUsuario = await widget.authService.getRol();
    pescadorIdUsuario = await widget.authService.getUserId();

    await _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => loading = true);
    try {
      final token = await widget.authService.getToken();

      final pagosUrl = "${ApiConfig.baseUrl}/pagos";
      final totalesUrl = "${ApiConfig.baseUrl}/pagos/total-por-pescador";

      final resPagos = await http.get(
        Uri.parse(pagosUrl),
        headers: {"Authorization": "Bearer $token"},
      );
      final resTotales = await http.get(
        Uri.parse(totalesUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      final List<dynamic> pagosData =
          (resPagos.statusCode == 200 && resPagos.body.isNotEmpty)
          ? jsonDecode(resPagos.body)
          : [];

      final List<dynamic> totalesData =
          (resTotales.statusCode == 200 && resTotales.body.isNotEmpty)
          ? jsonDecode(resTotales.body)
          : [];

      // Guardar pagos en memoria
      pagos = pagosData
          .map<Map<String, dynamic>>(
            (p) => {
              "pescadorId": p["pescadorId"],
              "estado": p["estado"],
              "monto": (p["monto"] ?? 0).toDouble(),
            },
          )
          .toList();

      totales = totalesData.map<Map<String, dynamic>>((t) {
        return {
          "pescadorId": t["pescadorId"],
          "pescador": t["pescador"] ?? "Desconocido",
          "total": (t["total"] ?? 0).toDouble(),
          "cantidadVentas": t["cantidadVentas"] ?? 0,
          "promedio": (t["promedio"] ?? 0).toDouble(),
        };
      }).toList();

      if (rolUsuario == "PESCADOR" && pescadorIdUsuario != null) {
        pescadorSeleccionado = pescadorIdUsuario;
      }

      _calcularTotalesFiltrados();

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        errorMessage = "Error al cargar datos: $e";
        loading = false;
      });
    }
  }

  int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  void _calcularTotalesFiltrados() {
    final pagosFiltrados = pagos.where((p) {
      final estadoMatch =
          estadoSeleccionado == "Todos" || p["estado"] == estadoSeleccionado;
      final pescadorMatch =
          pescadorSeleccionado == null ||
          toInt(p["pescadorId"]) == toInt(pescadorSeleccionado);
      return estadoMatch && pescadorMatch;
    }).toList();

    aprobados = pagosFiltrados.where((p) => p["estado"] == "APROBADO").length;
    pendientes = pagosFiltrados.where((p) => p["estado"] == "PENDIENTE").length;
    rechazados = pagosFiltrados.where((p) => p["estado"] == "RECHAZADO").length;

    totalVentasGeneral = pagosFiltrados
        .where((p) => p["estado"] == "APROBADO")
        .fold(0.0, (s, p) => s + (p["monto"] as double));

    totalPescador = pagosFiltrados
        .where((p) => p["estado"] == "APROBADO")
        .fold(0.0, (s, p) => s + (p["monto"] as double));

    ventasPescador = pagosFiltrados
        .where((p) => p["estado"] == "APROBADO")
        .length;
  }

  void _actualizarFiltro({int? pescadorId, String? estado}) {
    setState(() {
      if (pescadorId != null) pescadorSeleccionado = pescadorId;
      if (estado != null) estadoSeleccionado = estado;
      _calcularTotalesFiltrados();
    });
  }

  Widget _buildChart() {
    final Map<String, int> estadoCounts = {
      'APROBADO': aprobados,
      'PENDIENTE': pendientes,
      'RECHAZADO': rechazados,
    };

    final Map<String, Color> estadoColors = {
      'APROBADO': Colors.greenAccent.shade400,
      'PENDIENTE': Colors.orangeAccent.shade400,
      'RECHAZADO': Colors.redAccent.shade400,
    };

    final secciones = estadoCounts.entries
        .where((e) => e.value > 0)
        .map(
          (e) => PieChartSectionData(
            color: estadoColors[e.key],
            value: e.value.toDouble(),
            title: "${e.key}\n${e.value}",
            radius: 60,
            titleStyle: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        )
        .toList();

    if (secciones.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text("No hay datos suficientes para el gráfico")),
      );
    }

    return PieChart(
      PieChartData(
        centerSpaceRadius: 50,
        sectionsSpace: 3,
        borderData: FlBorderData(show: false),
        sections: secciones,
      ),
    );
  }

  Widget _buildTotalesCard(Map<String, dynamic> t) {
    final nombre = t["pescador"] ?? "Desconocido";
    final id = t["pescadorId"] ?? 0;
    final total = (t["total"] ?? 0).toDouble();
    final cantidad = t["cantidadVentas"] ?? 0;
    final promedio = (t["promedio"] ?? 0).toDouble();

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(
          nombre,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "Ventas: $cantidad\nTotal: ${formatoMoneda.format(total)}\nPromedio: ${formatoMoneda.format(promedio)}",
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VentasPescadorPage(
                authService: widget.authService,
                pescadorId: id,
                pescadorNombre: nombre,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
        title: Text(
          "Ventas por Pescadores",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.green.shade50,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.green,
                            size: 32,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rolUsuario == "PESCADOR"
                                    ? "Total de tus ventas"
                                    : "Total General",
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              Text(
                                formatoMoneda.format(
                                  rolUsuario == "PESCADOR"
                                      ? totalPescador
                                      : totalVentasGeneral,
                                ),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (rolUsuario == "ADMIN") ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              decoration: InputDecoration(
                                labelText: "Filtrar por Pescador",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                fillColor: Colors.blueGrey,
                              ),
                              value: pescadorSeleccionado,
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text("Todos los pescadores"),
                                ),
                                ...totales.map((t) {
                                  return DropdownMenuItem<int?>(
                                    value: t["pescadorId"],
                                    child: Text(t["pescador"]),
                                  );
                                }).toList(),
                              ],
                              onChanged: (id) =>
                                  _actualizarFiltro(pescadorId: id),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Filtrar por Estado",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                fillColor: Colors.blueGrey,
                              ),
                              value: estadoSeleccionado,
                              items: estados
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (estado) =>
                                  _actualizarFiltro(estado: estado),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 240, child: _buildChart()),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Text(
                        "Lista de Pescadores",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...totales.map(_buildTotalesCard).toList(),
                  ],

                  if (rolUsuario == "PESCADOR") ...[
                    SizedBox(height: 240, child: _buildChart()),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Resumen de tus ventas aprobadas: $ventasPescador",
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
