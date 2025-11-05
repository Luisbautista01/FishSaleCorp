import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:http/http.dart' as http;

class AdminProblemasPage extends StatefulWidget {
  final AuthService authService;

  const AdminProblemasPage({super.key, required this.authService});

  @override
  State<AdminProblemasPage> createState() => _AdminProblemasPageState();
}

class _AdminProblemasPageState extends State<AdminProblemasPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _problemas = [];
  String? _clienteSeleccionado;

  @override
  void initState() {
    super.initState();
    _fetchProblemas();
  }

  Future<void> _fetchProblemas() async {
    setState(() => _loading = true);
    final token = await widget.authService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/problemas/pendientes"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _problemas = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        _showSnack(
          "Error al cargar problemas (${response.statusCode})",
          isError: true,
        );
      }
    } catch (e) {
      _showSnack("Error de conexión: $e", isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, double> _calcularEstadoPie(List<Map<String, dynamic>> lista) {
    final Map<String, int> conteo = {};
    for (var p in lista) {
      final estado = p['estado'] ?? 'Pendiente';
      conteo[estado] = (conteo[estado] ?? 0) + 1;
    }
    return conteo.map((key, value) => MapEntry(key, value.toDouble()));
  }

  List<String> get _clientesUnicos {
    final clientes = _problemas
        .map((p) => (p['nombreUsuario'] ?? '').toString())
        .toSet();
    return clientes.where((c) => c.isNotEmpty).toList();
  }

  List<Map<String, dynamic>> get _problemasFiltrados {
    if (_clienteSeleccionado == null) return _problemas;
    return _problemas
        .where((p) => p['nombreUsuario'] == _clienteSeleccionado)
        .toList();
  }

  Future<void> _resolverProblema(int index) async {
    final problema = _problemas[index];
    final token = await widget.authService.getToken();
    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/problemas/resolver/${problema["id"]}"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() => _problemas.removeAt(index));
        _showSnack("Problema marcado como resuelto.");
      } else {
        _showSnack(
          "Error al marcar como resuelto (${response.statusCode})",
          isError: true,
        );
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
    }
  }

  void _mostrarImagen(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              "${ApiConfig.baseUrl}$imageUrl",
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: const Text("No se pudo cargar la imagen"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final problemasFiltrados = _problemasFiltrados;
    final pieData = _calcularEstadoPie(problemasFiltrados);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightBlue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text(
                  "Reportes Pendientes",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.primaryBlue,
                elevation: 6,
                centerTitle: true,
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButton<String>(
                  value: _clienteSeleccionado,
                  hint: const Text("Filtrar por cliente"),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("Todos los clientes"),
                    ),
                    ..._clientesUnicos.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (val) =>
                      setState(() => _clienteSeleccionado = val),
                ),
              ),

              if (pieData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: pieData.entries.map((e) {
                          final color = e.key == 'Pendiente.'
                              ? Colors.orange
                              : e.key == 'Resuelto.'
                              ? Colors.green
                              : Colors.blue;
                          return PieChartSectionData(
                            value: e.value,
                            title:
                                '${e.key} ${(e.value / pieData.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%',
                            color: color,
                            radius: 50,
                            titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 0,
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : problemasFiltrados.isEmpty
                    ? Center(
                        child: Text(
                          "No hay problemas pendientes",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchProblemas,
                        color: AppColors.primaryBlue,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: problemasFiltrados.length,
                          itemBuilder: (context, index) {
                            final p = problemasFiltrados[index];
                            final descripcion =
                                p["descripcion"] ?? "Sin descripción";
                            final usuario =
                                p["nombreUsuario"] ?? "Usuario desconocido";
                            final imagenUrl = p["imagenUrl"];
                            final fecha =
                                p["fechaSolicitud"]?.toString().substring(
                                  0,
                                  10,
                                ) ??
                                "—";

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(0.3),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(
                                      0.15,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          color: AppColors.primaryBlue,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          usuario,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkBlue,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_rounded,
                                              size: 14,
                                              color: AppColors.secondaryBlue,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              fecha,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: AppColors.greyText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      descripcion,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: AppColors.darkText,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (imagenUrl != null &&
                                        imagenUrl.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 14),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: GestureDetector(
                                          onTap: () =>
                                              _mostrarImagen(imagenUrl),
                                          child: Hero(
                                            tag: imagenUrl,
                                            child: Image.network(
                                              "${ApiConfig.baseUrl}$imagenUrl",
                                              height: 160,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    height: 160,
                                                    color: AppColors.lightBlue,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "No se pudo cargar la imagen",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            color: AppColors
                                                                .greyText,
                                                          ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 14),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _resolverProblema(index),
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        label: Text(
                                          "Marcar como Resuelto",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.secondaryBlue,
                                          elevation: 4,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
