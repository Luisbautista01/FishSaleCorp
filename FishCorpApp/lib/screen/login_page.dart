// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestor_tareas_app/particles/particles_background.dart';
import 'package:gestor_tareas_app/home/home_page.dart';
import 'package:gestor_tareas_app/services/auth_card.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/admin/user.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;
  const LoginPage({super.key, required this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _rememberMe = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await widget.authService.login(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      final String rol = (user['rol'] ?? 'CLIENTE').toString().toUpperCase();
      final String nombre = user['nombre'] ?? _emailCtrl.text.trim();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            authService: widget.authService,
            user: User(nombre: nombre, rol: rol),
          ),
        ),
      );
    } catch (e) {
      final friendly = _friendlyLoginMessage(e);
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
      setState(() => _isLoading = false);
    }
  }

  String _friendlyLoginMessage(Object e) {
    var raw = e.toString();
    if (raw.startsWith('Exception: '))
      raw = raw.replaceFirst('Exception: ', '');
    final lower = raw.toLowerCase();

    if (lower.contains('usuario no encontrado') ||
        lower.contains('no encontrado')) {
      return 'Correo no registrado. ¿Quieres registrarte?';
    }
    if (lower.contains('credenciales')) {
      return 'Correo o contraseña incorrectos. Verifica e intenta de nuevo.';
    }
    if (lower.contains('unauthorized') || lower.contains('401')) {
      return 'No autorizado. Revisa tus credenciales.';
    }
    if (lower.contains('500')) {
      return 'Error del servidor. Por favor inténtalo más tarde.';
    }
    return 'Error al iniciar sesión: ${raw.replaceAll("\n", ' ')}';
  }

  void _openWhatsApp() async {
    final whatsappUrl = Uri.parse(
      "https://wa.me/573004569567?text=Hola%20FishSaleCorp,%20necesito%20ayuda%20con%20mi%20cuenta.",
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
      query: 'subject=Soporte FishSaleCorp&body=Hola, necesito ayuda con...',
    );
    if (await canLaunchUrl(email)) {
      await launchUrl(email);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No se pudo abrir Gmail.")));
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
                          Expanded(child: _loginForm(context, isDark)),
                          const SizedBox(width: 40),
                          Expanded(
                            child: SvgPicture.asset(
                              'assets/login.svg',
                              height: 400,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _loginForm(context, isDark),
                          const SizedBox(height: 20),
                          SvgPicture.asset('assets/login.svg', height: 200),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm(BuildContext context, bool isDark) {
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
        const Text(
          "Bienvenido de nuevo a tu tienda de peces online. \n ¿Necesitas ayuda? Comunicate con nuestro equipo de soporte: ",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _openWhatsApp,
              child: Image.asset('assets/whatsapp.png', height: 36),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _openGmail,
              child: Image.asset('assets/gmail.png', height: 36),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AuthCard(
          title: "Iniciar sesión",
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailCtrl,
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
                  controller: _passCtrl,
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
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Ingrese su contraseña" : null,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Recordar usuario'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  value: _rememberMe,
                  onChanged: (value) =>
                      setState(() => _rememberMe = value ?? false),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Ingresar",
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
                      Navigator.pushReplacementNamed(context, '/register'),
                  child: const Text(
                    "¿Nuevo en FishSaleCorp? \n¡Crea tu cuenta aquí!",
                    style: TextStyle(color: Colors.teal),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/forgot'),
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(color: Colors.teal),
                    textAlign: TextAlign.center,
                  ),
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
