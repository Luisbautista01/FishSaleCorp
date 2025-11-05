import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/report/mis_reportes_page.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportProblemPage extends StatefulWidget {
  final AuthService authService;

  const ReportProblemPage({super.key, required this.authService});

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  File? _imagenAdjunta;
  bool _isSending = false;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagenAdjunta = File(pickedFile.path));
      _showSnack("Imagen seleccionada correctamente");
    }
  }

  Future<void> _enviarReporte() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      final token = await widget.authService.getToken();
      final userId = await widget.authService.getUserId();
      if (token == null || userId == null) {
        _showSnack("Usuario no autenticado", isError: true);
        return;
      }

      var uri = Uri.parse('${ApiConfig.baseUrl}/problemas/reportes');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['usuarioId'] = userId.toString()
        ..fields['descripcion'] = _descripcionCtrl.text;

      if (_imagenAdjunta != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _imagenAdjunta!.path,
            filename: path.basename(_imagenAdjunta!.path),
          ),
        );
      }

      var response = await request.send();
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack("Reporte enviado correctamente");
        Navigator.pop(context);
      } else {
        final body = await response.stream.bytesToString();
        _showSnack("Error al enviar reporte: $body", isError: true);
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _mostrarPrevisualizacion() {
    if (!_formKey.currentState!.validate()) return;

    File? imagenTemporal = _imagenAdjunta;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.15),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Previsualización del reporte",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _descripcionCtrl.text,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (imagenTemporal != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        imagenTemporal,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Enviar",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() => _imagenAdjunta = imagenTemporal);
                          Navigator.pop(context);
                          _enviarReporte();
                        },
                      ),
                    ],
                  ),
                ],
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
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: Text(
          "Reportar un problema",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
            tooltip: "Mis reportes",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MisReportesPage(authService: widget.authService),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.9),
                    AppColors.lightBlue,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.95),
                shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Describe el problema que estás experimentando",
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descripcionCtrl,
                          validator: (v) => v!.isEmpty
                              ? "La descripción es obligatoria"
                              : null,
                          maxLines: 5,
                          style: GoogleFonts.poppins(color: AppColors.darkText),
                          decoration: InputDecoration(
                            hintText:
                                "Ej: No puedo realizar el pago, aparece error 500",
                            hintStyle: GoogleFonts.poppins(
                              color: AppColors.greyText,
                            ),
                            filled: true,
                            fillColor: AppColors.lightBlue.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(
                              Icons.report_problem,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _seleccionarImagen,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                              color: AppColors.lightBlue.withOpacity(0.3),
                              image: _imagenAdjunta != null
                                  ? DecorationImage(
                                      image: FileImage(_imagenAdjunta!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _imagenAdjunta == null
                                ? Center(
                                    child: Text(
                                      "Toca para adjuntar una captura (opcional)",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _isSending
                            ? const CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                              )
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.remove_red_eye_rounded),
                                label: Text(
                                  "Previsualizar y Enviar",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  minimumSize: const Size.fromHeight(55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _mostrarPrevisualizacion,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
