// ignore_for_file: unnecessary_import, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';

class TicketPage extends StatefulWidget {
  final int pagoId;
  final int pedidoId;
  final double monto;
  final String metodoPago;
  final String estado;
  final String referencia;
  final String? cliente;
  final String? pescador;

  const TicketPage({
    super.key,
    required this.pagoId,
    required this.pedidoId,
    required this.monto,
    required this.metodoPago,
    required this.estado,
    required this.referencia,
    this.cliente,
    this.pescador,
  });

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  pw.Font? customFont;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _loading = false);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadFont() async {
    final fontData = await rootBundle.load("assets/Roboto-Regular.ttf");
    customFont = pw.Font.ttf(fontData);
  }

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();
    final logoData = await rootBundle.load('assets/logo.png');
    final logoBytes = logoData.buffer.asUint8List();

    final estadoColor = widget.estado.toUpperCase() == "APROBADO"
        ? PdfColors.green
        : (widget.estado.toUpperCase() == "RECHAZADO"
              ? PdfColors.red
              : PdfColors.orange);

    final qrData = jsonEncode({
      "pagoId": widget.pagoId,
      "pedidoId": widget.pedidoId,
      "cliente": widget.cliente ?? "",
      "pescador": widget.pescador ?? "",
      "monto": widget.monto,
      "metodoPago": widget.metodoPago,
      "estado": widget.estado,
      "referencia": widget.referencia,
    });

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.blue50,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  alignment: pw.Alignment.center,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    width: 120,
                    height: 120,
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  color: PdfColors.white,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Comprobante de Pago",
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        "Pago ID: ${widget.pagoId}",
                        style: pw.TextStyle(font: customFont),
                      ),
                      pw.Text(
                        "Pedido ID: ${widget.pedidoId}",
                        style: pw.TextStyle(font: customFont),
                      ),
                      if (widget.cliente != null)
                        pw.Text(
                          "Cliente: ${widget.cliente}",
                          style: pw.TextStyle(font: customFont),
                        ),
                      if (widget.pescador != null)
                        pw.Text(
                          "Pescador: ${widget.pescador}",
                          style: pw.TextStyle(font: customFont),
                        ),
                      pw.Text(
                        "Método: ${widget.metodoPago}",
                        style: pw.TextStyle(font: customFont),
                      ),
                      pw.Text(
                        "Monto: \$${widget.monto.toStringAsFixed(2)} COP",
                        style: pw.TextStyle(font: customFont),
                      ),
                      pw.Text(
                        "Estado: ${widget.estado}",
                        style: pw.TextStyle(
                          color: estadoColor,
                          font: customFont,
                        ),
                      ),
                      pw.Text(
                        "Referencia: ${widget.referencia}",
                        style: pw.TextStyle(font: customFont),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Center(
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrData,
                          width: 140,
                          height: 140,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _savePdf() async {
    try {
      final pdfBytes = await _buildPdf();
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/Recibo_Pago_${widget.pagoId}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF guardado temporalmente en: $filePath")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al generar PDF: $e")));
    }
  }

  Future<void> _sharePdf() async {
    try {
      final pdfBytes = await _buildPdf();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: "Recibo_Pago_${widget.pagoId}.pdf",
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al compartir PDF: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final estadoColor = widget.estado.toUpperCase() == "APROBADO"
        ? Colors.green
        : (widget.estado.toUpperCase() == "RECHAZADO"
              ? Colors.red
              : Colors.orange);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: AppColors.lightBlue,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text(
            "Ticket de Pago",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              heroTag: "btn1",
              backgroundColor: AppColors.primaryBlue,
              icon: const Icon(Icons.save),
              label: const Text("Guardar PDF"),
              onPressed: _savePdf,
            ),
            const SizedBox(width: 16),
            FloatingActionButton.extended(
              heroTag: "btn2",
              backgroundColor: Colors.green,
              icon: const Icon(Icons.share),
              label: const Text("Compartir"),
              onPressed: _sharePdf,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Image.asset(
                              'assets/logo.png',
                              width: constraints.maxWidth * 0.5,
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Comprobante de Pago",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildInfoTile(
                          Icons.confirmation_number,
                          "Pago ID",
                          "${widget.pagoId}",
                        ),
                        _buildInfoTile(
                          Icons.shopping_bag,
                          "Pedido ID",
                          "${widget.pedidoId}",
                        ),
                        if (widget.cliente != null)
                          _buildInfoTile(
                            Icons.person,
                            "Cliente",
                            widget.cliente!,
                          ),
                        if (widget.pescador != null)
                          _buildInfoTile(
                            FontAwesomeIcons.fish,
                            "Pescador",
                            widget.pescador!,
                          ),
                        _buildInfoTile(
                          Icons.payment,
                          "Método",
                          widget.metodoPago,
                        ),
                        _buildInfoTile(
                          Icons.monetization_on,
                          "Monto",
                          "\$${widget.monto.toStringAsFixed(2)} COP",
                        ),
                        _buildInfoTile(
                          Icons.verified,
                          "Estado",
                          widget.estado,
                          color: estadoColor,
                          isBold: true,
                        ),
                        _buildInfoTile(
                          Icons.qr_code_2,
                          "Referencia",
                          widget.referencia,
                        ),
                        const SizedBox(height: 20),
                        QrImageView(
                          data: jsonEncode({
                            "pagoId": widget.pagoId,
                            "pedidoId": widget.pedidoId,
                            "monto": widget.monto,
                            "metodoPago": widget.metodoPago,
                            "estado": widget.estado,
                            "referencia": widget.referencia,
                            "cliente": widget.cliente,
                            "pescador": widget.pescador,
                          }),
                          size: 150,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Escanea este código para ver el Ticket",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: Text(
        value,
        style: GoogleFonts.poppins(
          color: color ?? Colors.black,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
