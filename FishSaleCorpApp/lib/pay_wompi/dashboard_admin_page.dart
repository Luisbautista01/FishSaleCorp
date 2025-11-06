// ignore_for_file: unnecessary_to_list_in_spreads, use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:gestor_tareas_app/services/guide_service.dart';
import 'package:gestor_tareas_app/pay_wompi/mis_pagos_page.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DashboardAdminPage extends StatefulWidget {
  final AuthService authService;

  const DashboardAdminPage({super.key, required this.authService});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  bool loading = true;
  String? errorMessage;

  final GlobalKey _resumenKey = GlobalKey();
  final GlobalKey _totalKey = GlobalKey();
  final GlobalKey _chartKey = GlobalKey();
  final GlobalKey _pescadoresKey = GlobalKey();

  List<Map<String, dynamic>> totales = [];
  List<Map<String, dynamic>> todosLosPagos = [];

  // Filtros
  String filtroEstado = 'TODOS';
  int? filtroPescadorId;

  int aprobados = 0;
  int pendientes = 0;
  int rechazados = 0;
  double totalVentasGeneral = 0.0;

  final formatoMoneda = NumberFormat.currency(
    locale: "es_CO",
    symbol: r"$",
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefsId = await widget.authService.getUserId();
      final userId =
          prefsId ??
          await widget.authService.getUserId() ??
          await widget.authService.getUserId() ??
          0;
      await GuideService.showOnFirstSignIn(
        context: context,
        userId: userId,
        keys: [_resumenKey, _totalKey, _chartKey, _pescadoresKey],
      );
    });
    _cargarDatosDashboard();
  }

  Future<void> _cargarDatosDashboard() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      final token = await widget.authService.getToken();
      final rol = await widget.authService.getRol();

      String pagosUrl;
      String totalesUrl = "${ApiConfig.baseUrl}/pagos/total-por-pescador";

      if (rol == 'CLIENTE') {
        pagosUrl = "${ApiConfig.baseUrl}/pagos/por-cliente";
      } else if (rol == 'PESCADOR') {
        pagosUrl = "${ApiConfig.baseUrl}/pagos/por-pescador";
      } else {
        pagosUrl = "${ApiConfig.baseUrl}/pagos";
      }

      final resPagos = await http.get(
        Uri.parse(pagosUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      final resTotales = await http.get(
        Uri.parse(totalesUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (resPagos.statusCode != 200) {
        throw Exception("Error al obtener pagos: ${resPagos.statusCode}");
      }

      if (resTotales.statusCode != 200) {
        throw Exception("Error al obtener totales: ${resTotales.statusCode}");
      }

      final List<dynamic> pagosData = resPagos.body.isNotEmpty
          ? jsonDecode(resPagos.body)
          : [];
      final List<dynamic> totalesData = resTotales.body.isNotEmpty
          ? jsonDecode(resTotales.body)
          : [];

      // Guardamos todos los pagos
      todosLosPagos = pagosData
          .map<Map<String, dynamic>>((p) => Map<String, dynamic>.from(p))
          .toList();

      totales = totalesData.map<Map<String, dynamic>>((t) {
        double total = (t["total"] ?? 0).toDouble();
        int cantidad = (t["cantidadVentas"] ?? 0).toInt();
        double promedio = cantidad > 0 ? total / cantidad : 0.0;
        return {
          "pescadorId": t["pescadorId"] ?? 0,
          "pescador": t["pescador"] ?? "Desconocido",
          "total": total,
          "cantidadVentas": cantidad,
          "promedio": promedio,
        };
      }).toList();

      _aplicarFiltros();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Dashboard actualizado correctamente"),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = "Error al cargar datos: $e";
      });
    }
  }

  void _aplicarFiltros() {
    List<Map<String, dynamic>> pagosFiltrados = List.from(todosLosPagos);

    if (filtroEstado != 'TODOS') {
      pagosFiltrados = pagosFiltrados
          .where((p) => p["estado"] == filtroEstado)
          .toList();
    }

    if (filtroPescadorId != null && filtroPescadorId != 0) {
      pagosFiltrados = pagosFiltrados
          .where((p) => p["pescadorId"] == filtroPescadorId)
          .toList();
    }

    aprobados = pagosFiltrados.where((p) => p["estado"] == "APROBADO").length;
    pendientes = pagosFiltrados.where((p) => p["estado"] == "PENDIENTE").length;
    rechazados = pagosFiltrados.where((p) => p["estado"] == "RECHAZADO").length;

    totalVentasGeneral = pagosFiltrados
        .where((p) => p["estado"] == "APROBADO")
        .fold(0.0, (s, p) => s + ((p["monto"] ?? 0) as num).toDouble());

    setState(() {
      loading = false;
    });
  }

  Widget _buildFiltros() {
    List<Map<String, dynamic>> pescadoresUnicos = [
      {"pescadorId": 0, "pescador": "Todos"},
    ];

    pescadoresUnicos.addAll([
      ...{
        for (var t in totales)
          {"pescadorId": t["pescadorId"], "pescador": t["pescador"]},
      },
    ]);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: filtroEstado,
            decoration: const InputDecoration(
              labelText: "Filtrar por estado",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
              DropdownMenuItem(value: 'APROBADO', child: Text('Aprobados')),
              DropdownMenuItem(value: 'PENDIENTE', child: Text('Pendientes')),
              DropdownMenuItem(value: 'RECHAZADO', child: Text('Rechazados')),
            ],
            onChanged: (value) {
              filtroEstado = value!;
              _aplicarFiltros();
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: filtroPescadorId ?? 0,
            decoration: const InputDecoration(
              labelText: "Filtrar por pescador",
              border: OutlineInputBorder(),
            ),
            items: pescadoresUnicos
                .where((p) => p["pescadorId"] != null && p["pescador"] != null)
                .map<DropdownMenuItem<int>>(
                  (p) => DropdownMenuItem<int>(
                    value: p["pescadorId"] as int,
                    child: Text(p["pescador"] as String),
                  ),
                )
                .toList(),
            onChanged: (value) {
              filtroPescadorId = value;
              _aplicarFiltros();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (aprobados + pendientes + rechazados == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("Sin datos para mostrar")),
      );
    }

    return SizedBox(
      height: 240,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 50,
          sectionsSpace: 3,
          borderData: FlBorderData(show: false),
          sections: [
            PieChartSectionData(
              color: Colors.greenAccent.shade400,
              value: aprobados.toDouble(),
              title: "Aprobados\n$aprobados",
              radius: 60,
              titleStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            PieChartSectionData(
              color: Colors.orangeAccent.shade400,
              value: pendientes.toDouble(),
              title: "Pendientes\n$pendientes",
              radius: 60,
              titleStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            PieChartSectionData(
              color: Colors.redAccent.shade400,
              value: rechazados.toDouble(),
              title: "Rechazados\n$rechazados",
              radius: 60,
              titleStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalesCard(Map<String, dynamic> t) {
    final pescador = t["pescador"] ?? "Desconocido";
    final total = (t["total"] ?? 0).toDouble();
    final cantidad = (t["cantidadVentas"] ?? 0).toInt();
    final promedio = (t["promedio"] ?? 0).toDouble();

    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          pescador,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.blue.shade900,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ventas: $cantidad", style: GoogleFonts.poppins(fontSize: 14)),
            Text(
              "Total: ${formatoMoneda.format(total)} COP",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            Text(
              "Promedio: ${formatoMoneda.format(promedio)}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        trailing: const Icon(Icons.bar_chart, color: Colors.blue, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
          "Panel Administrativo",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarDatosDashboard,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Showcase(
                    key: _resumenKey,
                    description:
                        'Resumen rápido: aprobados ✅, pendientes ⏳ y rechazados ❌.',
                    tooltipBackgroundColor: AppColors.primaryBlue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildResumenCard(
                          "Aprobados",
                          aprobados,
                          Colors.green,
                          Icons.check_circle,
                        ),
                        _buildResumenCard(
                          "Pendientes",
                          pendientes,
                          Colors.orange,
                          Icons.timelapse,
                        ),
                        _buildResumenCard(
                          "Rechazados",
                          rechazados,
                          Colors.red,
                          Icons.cancel,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Showcase(
                    key: _totalKey,
                    description:
                        'Total general de ventas 🧾 — acumulado de ventas aprobadas.',
                    tooltipBackgroundColor: AppColors.primaryBlue,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        color: Colors.green[50],
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: Colors.green,
                                size: 28,
                              ),
                              const Text(
                                "Total General:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                formatoMoneda.format(totalVentasGeneral),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Distribución de Pagos",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Divider(),
                  _buildFiltros(),
                  Divider(),
                  Showcase(
                    key: _chartKey,
                    description: 'Distribución de pagos 📊.',
                    tooltipBackgroundColor: AppColors.primaryBlue,
                    child: _buildChart(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Pescadores",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Showcase(
                    key: _pescadoresKey,
                    description:
                        'Lista de pescadores 🐟 — toca para ver ventas detalladas.',
                    tooltipBackgroundColor: AppColors.primaryBlue,
                    child: Column(
                      children: [...totales.map(_buildTotalesCard).toList()],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: Text(
                        "Ver Pagos Por Clientes",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MisPagosPage(
                              authService: widget.authService,
                              rol: 'ADMIN',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }

  Widget _buildResumenCard(
    String titulo,
    int cantidad,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            Text(
              "$cantidad",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: color,
              ),
            ),
            Text(
              titulo,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}
