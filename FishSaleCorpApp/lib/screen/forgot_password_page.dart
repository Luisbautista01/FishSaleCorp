// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gestor_tareas_app/particles/particles_background.dart';
import 'package:gestor_tareas_app/screen/reset_password_page.dart';
import 'package:gestor_tareas_app/services/auth_card.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  final AuthService authService;
  const ForgotPasswordPage({super.key, required this.authService});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _forgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await widget.authService.forgotPassword(_emailCtrl.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Correo enviado. Revisa tu bandeja de entrada (o carpeta de spam).',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(
              email: _emailCtrl.text.trim(),
              authService: widget.authService,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = "Ocurrió un error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: size.width > 800
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 2, child: _forgotForm(isDark)),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 1,
                          child: SvgPicture.asset(
                            'assets/forgot_password.svg',
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _forgotForm(isDark),
                        const SizedBox(height: 20),
                        SvgPicture.asset(
                          'assets/forgot_password.svg',
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forgotForm(bool isDark) {
    return AuthCard(
      title: "Recuperar contraseña",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: isDark ? Colors.tealAccent : Colors.teal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              ),
              validator: (v) {
                if (v == null || v.isEmpty)
                  return "Por favor ingresa tu correo electrónico";
                final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                if (!emailRegex.hasMatch(v))
                  return "El formato del correo no es válido";
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _forgotPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.tealAccent : Colors.teal,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Enviar instrucciones",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
