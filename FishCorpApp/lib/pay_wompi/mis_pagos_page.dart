// ignore_for_file: use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/pay_wompi/ticket_page.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class MisPagosPage extends StatefulWidget {
  final AuthService authService;
  final String rol;
  final int? clienteId;

  const MisPagosPage({
    super.key,
    required this.authService,
    required this.rol,
    this.clienteId,
  });

  @override
  State<MisPagosPage> createState() => _MisPagosPageState();
}

class _MisPagosPageState extends State<MisPagosPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> pagos = [];
  List<Map<String, dynamic>> pagosFiltrados = [];

  String? filtroPescador;
  List<String> pescadores = [];

  String? filtroEstado;
  final List<String> estados = ['Todos', 'APROBADO', 'PENDIENTE', 'RECHAZADO'];

  int aprobados = 0;
  int pendientes = 0;
  int rechazados = 0;
  double totalPagos = 0.0;

  final formatoMoneda = NumberFormat.currency(
    locale: "es_CO",
    symbol: r"$",
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    setState(() => isLoading = true);
    final token = await widget.authService.getToken();

    String url;
    final rolUpper = widget.rol.toUpperCase();

    if (rolUpper == 'CLIENTE') {
      url = '${ApiConfig.baseUrl}/pagos/por-cliente';
    } else if (rolUpper == 'PESCADOR') {
      url = '${ApiConfig.baseUrl}/pagos/por-pescador';
    } else {
      url = '${ApiConfig.baseUrl}/pagos';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        List<dynamic> data = [];

        if (body is List) {
          data = body;
        } else if (body is Map) {
          if (body.containsKey('content')) {
            data = body['content'];
          } else if (body.containsKey('data')) {
            data = body['data'];
          } else {
            data = body.values.firstWhere((v) => v is List, orElse: () => []);
          }
        }

        pagos = List<Map<String, dynamic>>.from(
          data.map((p) {
            final monto = double.tryParse(p['monto']?.toString() ?? '') ?? 0.0;
            return {
              'id': p['id'],
              'pedidoId': p['pedidoId'],
              'referenciaWompi': p['referenciaWompi'],
              'metodoPago': p['metodoPago'],
              'estado': p['estado'],
              'monto': monto,
              'cliente': p['cliente'],
              'pescador': p['pescador'],
              'fechaCreacion': p['fechaCreacion'],
              'producto': p['producto'],
            };
          }),
        );

        pescadores =
            pagos
                .map((p) => p['pescador']?.toString() ?? 'Desconocido')
                .toSet()
                .toList()
              ..sort();
        pescadores.insert(0, 'Todos');

        pagosFiltrados = List.from(pagos);
        _actualizarResumen(pagosFiltrados);
      } else {
        pagos = [];
        pagosFiltrados = [];
      }
    } catch (e) {
      pagos = [];
      pagosFiltrados = [];
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _actualizarResumen(List<Map<String, dynamic>> lista) {
    aprobados = lista.where((p) => p['estado'] == 'APROBADO').length;
    pendientes = lista.where((p) => p['estado'] == 'PENDIENTE').length;
    rechazados = lista.where((p) => p['estado'] == 'RECHAZADO').length;
    totalPagos = lista
        .where((p) => (p['estado'] ?? '') == 'APROBADO')
        .fold(0.0, (sum, p) => sum + (p['monto'] ?? 0));
  }

  void _filtrarPagos({String? pescador, String? estado}) {
    setState(() {
      if (pescador != null) filtroPescador = pescador;
      if (estado != null) filtroEstado = estado;

      pagosFiltrados = pagos.where((p) {
        final coincidentePescador =
            filtroPescador == null ||
            filtroPescador == 'Todos' ||
            p['pescador']?.toString() == filtroPescador;
        final coincidenteEstado =
            filtroEstado == null ||
            filtroEstado == 'Todos' ||
            p['estado'] == filtroEstado;
        return coincidentePescador && coincidenteEstado;
      }).toList();

      _actualizarResumen(pagosFiltrados);
    });
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
            const SizedBox(height: 6),
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

  Widget _buildTotalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_money,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Pagado",
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatoMoneda.format(totalPagos),
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final Map<String, int> estadoCounts = {
      'APROBADO': aprobados,
      'PENDIENTE': pendientes,
      'RECHAZADO': rechazados,
    };

    final total = estadoCounts.values.fold<int>(0, (a, b) => a + b);

    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("Sin datos para mostrar")),
      );
    }

    final Map<String, Color> estadoColors = {
      'APROBADO': Colors.greenAccent.shade400,
      'PENDIENTE': Colors.orangeAccent.shade400,
      'RECHAZADO': Colors.redAccent.shade400,
    };

    final secciones = estadoCounts.entries.where((e) => e.value > 0).map((e) {
      final porcentaje = (e.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: estadoColors[e.key],
        value: e.value.toDouble(),
        title: "${e.key}\n$porcentaje%",
        radius: 65,
        titleStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      );
    }).toList();

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sectionsSpace: 3,
          borderData: FlBorderData(show: false),
          sections: secciones,
        ),
      ),
    );
  }

  Widget _buildPagoCard(Map<String, dynamic> pago) {
    final estado = pago['estado'] ?? 'DESCONOCIDO';
    final metodo = pago['metodoPago'] ?? 'N/A';
    final monto = pago['monto'] ?? 0.0;
    final fecha = pago['fechaCreacion'] ?? '';
    final cliente = pago['cliente'] ?? 'Cliente desconocido';
    final pescador = pago['pescador'] ?? 'Pescador desconocido';

    Color colorEstado;
    switch (estado) {
      case 'APROBADO':
        colorEstado = Colors.green;
        break;
      case 'RECHAZADO':
        colorEstado = Colors.red;
        break;
      case 'PENDIENTE':
        colorEstado = Colors.orange;
        break;
      default:
        colorEstado = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatoMoneda.format(monto),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorEstado.withOpacity(0.25)),
                ),
                child: Text(
                  estado,
                  style: GoogleFonts.poppins(
                    color: colorEstado,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.person, size: 16, color: AppColors.greyText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Cliente: $cliente",
                  style: GoogleFonts.poppins(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.anchor, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Pescador: $pescador",
                  style: GoogleFonts.poppins(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.shopping_bag, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Producto: ${pago['producto'] ?? 'Desconocido'}",
                  style: GoogleFonts.poppins(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            "Método: $metodo",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
          Text(
            "Fecha: $fecha",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryBlue.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketPage(
                      pagoId: pago['id'] ?? 0,
                      pedidoId: pago['pedidoId'] ?? 0,
                      monto: monto,
                      metodoPago: metodo,
                      estado: estado,
                      referencia: pago['referenciaWompi'] ?? '',
                      cliente: cliente,
                      pescador: pescador,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.receipt_long,
                color: AppColors.primaryBlue,
              ),
              label: Text(
                "Ver Ticket",
                style: GoogleFonts.poppins(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = widget.rol.toUpperCase() == 'ADMIN';
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 6,
        centerTitle: true,
        title: Text(
          esAdmin ? "Pagos de Clientes" : "Mis Pagos",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarPagos,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  Row(
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
                  Divider(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Total pagado",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildTotalCard(),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Distribución de Pagos",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  _buildChart(),
                  const SizedBox(height: 20),

                  if (pescadores.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: filtroPescador ?? 'Todos',
                              items: pescadores
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => _filtrarPagos(pescador: v),
                              underline: Container(height: 0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: filtroEstado ?? 'Todos',
                              items: estados
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => _filtrarPagos(estado: v),
                              underline: Container(height: 0),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.clienteId != null
                          ? "Pagos de ${pagos.isNotEmpty ? pagos.first['cliente'] : ''}"
                          : "Pagos",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Historial de Pagos",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...pagosFiltrados.map(_buildPagoCard).toList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
