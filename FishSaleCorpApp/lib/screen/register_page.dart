// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestor_tareas_app/particles/particles_background.dart';
import 'package:gestor_tareas_app/services/auth_card.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  final AuthService authService;
  const RegisterPage({super.key, required this.authService});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final userCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? selectedRol = 'CLIENTE';

  bool _showPassword = false;
  bool _isRegistering = false;
  String? _errorMessage;

  void _openWhatsApp() async {
    final whatsappUrl = Uri.parse(
      "https://wa.me/573004569567?text=Hola%20FishSaleCorp,%20necesito%20ayuda%20para%20registrarme.",
    );
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir WhatsApp.")),
      );
    }
  }

  void _openGmail() async {
    final email = Uri(
      scheme: 'mailto',
      path: 'soporte@fishsalecorp.com',
      query:
          'subject=Soporte FishSaleCorp&body=Hola, necesito ayuda con mi registro...',
    );
    if (await canLaunchUrl(email)) {
      await launchUrl(email);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No se pudo abrir Gmail.")));
    }
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isRegistering = true);

    try {
      await widget.authService.register(
        nombre: userCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        rol: selectedRol ?? 'CLIENTE',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Bienvenido a FishSaleCorp'),
          backgroundColor: Colors.teal,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      final friendly = _friendlyRegisterMessage(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendly),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      setState(() => _errorMessage = friendly);
    } finally {
      setState(() => _isRegistering = false);
    }
  }

  String _friendlyRegisterMessage(Object e) {
    var raw = e.toString();
    if (raw.startsWith('Exception: '))
      raw = raw.replaceFirst('Exception: ', '');
    final lower = raw.toLowerCase();

    if (lower.contains('ya está registrado') || lower.contains('email ya')) {
      return 'El correo ya está registrado. Si olvidaste tu contraseña, recupérala.';
    }
    if (lower.contains('validación') || lower.contains('campo')) {
      return 'Datos inválidos. Revisa los campos e intenta de nuevo.';
    }
    if (lower.contains('500') || lower.contains('internal server error')) {
      return 'Error del servidor. Por favor inténtalo más tarde.';
    }
    return 'Error al registrar usuario: ${raw.replaceAll("\n", ' ')}';
  }

  @override
  void dispose() {
    userCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          const ParticlesBackground(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: size.width > 800
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _registerForm(context, isDark)),
                          const SizedBox(width: 40),
                          Expanded(
                            child: SvgPicture.asset(
                              'assets/signup.svg',
                              height: 400,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _registerForm(context, isDark),
                          const SizedBox(height: 20),
                          SvgPicture.asset('assets/signup.svg', height: 200),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "FishSaleCorp",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.tealAccent : Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tu mercado digital de peces frescos y exóticos. \n ¿Necesitas ayuda? Comunicate con nuestro equipo de soporte:",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _openWhatsApp,
              child: Image.asset('assets/whatsapp.png', height: 36, width: 36),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _openGmail,
              child: Image.asset('assets/gmail.png', height: 36, width: 36),
            ),
          ],
        ),
        const SizedBox(height: 20),

        AuthCard(
          title: "Crea tu cuenta",
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Únete a nuestra comunidad. \n"
                  "Compra, vende o intercambia peces únicos de manera segura.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: userCtrl,
                  decoration: InputDecoration(
                    labelText: "Nombre de usuario",
                    prefixIcon: const Icon(Icons.person, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Ingrese un nombre de usuario válido" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: const Icon(Icons.email, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Ingrese su correo";
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                    if (!emailRegex.hasMatch(v))
                      return "Formato de correo inválido";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: passCtrl,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "Ingrese una contraseña segura";
                    if (v.length < 6)
                      return "La contraseña debe tener al menos 6 caracteres";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedRol,
                  items: ['CLIENTE', 'PESCADOR']
                      .map(
                        (rol) => DropdownMenuItem(value: rol, child: Text(rol)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => selectedRol = value),
                  decoration: InputDecoration(
                    labelText: "Rol en la plataforma",
                    prefixIcon: const Icon(Icons.security, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRegistering ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isRegistering
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Registrarme ahora",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text("¿Ya tienes cuenta? Inicia sesión aquí"),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
