import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MisReportesPage extends StatefulWidget {
  final AuthService authService;

  const MisReportesPage({super.key, required this.authService});

  @override
  State<MisReportesPage> createState() => _MisReportesPageState();
}

class _MisReportesPageState extends State<MisReportesPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _reportes = [];

  @override
  void initState() {
    super.initState();
    _fetchMisReportes();
  }

  Future<void> _fetchMisReportes() async {
    setState(() => _loading = true);
    final token = await widget.authService.getToken();
    final userId = await widget.authService.getUserId();

    if (token == null || userId == null) {
      _showSnack(
        "Error: sesión no válida. Inicia sesión nuevamente.",
        isError: true,
      );
      setState(() => _loading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/problemas/usuario/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _reportes = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else if (response.statusCode == 401) {
        _showSnack(
          "Tu sesión ha expirado. Inicia sesión nuevamente.",
          isError: true,
        );
        await widget.authService.logout();
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnack(
          "Error al cargar tus reportes (${response.statusCode})",
          isError: true,
        );
      }
    } catch (e) {
      _showSnack("Error de conexión: $e", isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _mostrarImagen(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

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
                  "Mis Reportes",
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
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : _reportes.isEmpty
                    ? Center(
                        child: Text(
                          "No has reportado problemas",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchMisReportes,
                        color: AppColors.primaryBlue,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reportes.length,
                          itemBuilder: (context, index) {
                            final r = _reportes[index];
                            final descripcion =
                                r["descripcion"] ?? "Sin descripción";
                            final imagenUrl = r["imagenUrl"];
                            final fecha = r["fechaSolicitud"] ?? "—";
                            final resuelto = r["resolver"] == true;
                            final estadoColor = resuelto
                                ? Colors.green
                                : Colors.orange;
                            final estadoText = resuelto
                                ? "Resuelto"
                                : "Pendiente";

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: Colors.white,
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
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap:
                                      imagenUrl != null && imagenUrl.isNotEmpty
                                      ? () => _mostrarImagen(imagenUrl)
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 14,
                                                  color:
                                                      AppColors.secondaryBlue,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  fecha,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: AppColors.greyText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: estadoColor.withOpacity(
                                                  0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: estadoColor,
                                                ),
                                              ),
                                              child: Text(
                                                estadoText,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: estadoColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          descripcion,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: AppColors.darkBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (imagenUrl != null &&
                                            imagenUrl.isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 14,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
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
                                                      color:
                                                          AppColors.lightBlue,
                                                      alignment:
                                                          Alignment.center,
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
                                      ],
                                    ),
                                  ),
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
