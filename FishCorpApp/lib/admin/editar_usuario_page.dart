// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestor_tareas_app/admin/usuarios_provider.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:provider/provider.dart';

class EditarUsuarioPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  final String rolActual;

  const EditarUsuarioPage({super.key, this.usuario, required this.rolActual});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;
  String? rolSeleccionado;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final usuario = widget.usuario;
    nombreCtrl = TextEditingController(text: usuario?['nombre'] ?? '');
    emailCtrl = TextEditingController(text: usuario?['email'] ?? '');
    passwordCtrl = TextEditingController();
    rolSeleccionado = usuario?['rol'] ?? widget.rolActual.toUpperCase();
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UsuariosProvider>();
    final nombre = nombreCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    final rol = rolSeleccionado ?? "CLIENTE";

    setState(() => _isSaving = true);

    try {
      if (widget.usuario == null) {
        await provider.crearUsuario(nombre, email, password, rol);
        _showSnack("Usuario creado correctamente", false);
      } else {
        await provider.actualizarUsuario(
          widget.usuario!['id'],
          nombre,
          email,
          password,
          rol,
        );
        _showSnack("Usuario actualizado correctamente", false);
      }
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack("Error: $e", true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: AppColors.darkBlue),
      prefixIcon: Icon(icon, color: AppColors.secondaryBlue),
      filled: true,
      fillColor: AppColors.lightBlue.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primaryBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.secondaryBlue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.usuario == null;
    final ancho = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: Text(
          esNuevo ? 'Crear Usuario' : 'Editar Usuario',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ancho > 600 ? 500 : double.infinity,
          ),
          margin: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            shadowColor: AppColors.primaryBlue.withOpacity(0.3),
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      esNuevo
                          ? "Completa los datos para registrar un nuevo usuario"
                          : "Edita los datos del usuario seleccionado",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.darkBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),

                    TextFormField(
                      controller: nombreCtrl,
                      decoration: _inputStyle('Nombre', Icons.person),
                      validator: (v) => v!.isEmpty ? 'Ingrese un nombre' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputStyle(
                        'Correo electrónico',
                        Icons.email,
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Ingrese un correo válido' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: _inputStyle(
                        esNuevo ? 'Contraseña' : 'Nueva contraseña (opcional)',
                        Icons.lock,
                      ),
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: rolSeleccionado,
                      decoration: _inputStyle('Rol', Icons.badge),
                      items: const [
                        DropdownMenuItem(
                          value: "CLIENTE",
                          child: Text("Cliente"),
                        ),
                        DropdownMenuItem(
                          value: "PESCADOR",
                          child: Text("Pescador"),
                        ),
                        DropdownMenuItem(
                          value: "ADMIN",
                          child: Text("Administrador"),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => rolSeleccionado = value),
                    ),
                    const SizedBox(height: 30),

                    _isSaving
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _guardarUsuario,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: Text(
                              esNuevo ? 'Crear Usuario' : 'Guardar Cambios',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 5,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
