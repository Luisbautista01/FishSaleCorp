// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/screen/login_page.dart';
import 'package:gestor_tareas_app/services/auth_card.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/particles/particles_background.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final AuthService authService;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.authService,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authService.resetPassword(
        widget.email,
        _passwordCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña restablecida con éxito'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));

        _passwordCtrl.clear();
        _confirmCtrl.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(authService: widget.authService),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Ocurrió un error: $e";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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
                        Expanded(flex: 2, child: _resetForm(isDark)),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              'assets/reset_password.png',
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _resetForm(isDark),
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/reset_password.png',
                          height: 120,
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

  Widget _resetForm(bool isDark) {
    return AuthCard(
      title: "Restablecer contraseña",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              "Actualiza tu contraseña para continuar usando FishSaleCorp",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 30),

            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: "Nueva contraseña",
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: isDark ? Colors.tealAccent : Colors.teal,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePass = !_obscurePass);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return "Por favor ingresa una contraseña";
                }
                if (v.length < 6) {
                  return "Debe tener al menos 6 caracteres";
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: "Confirmar contraseña",
                prefixIcon: Icon(
                  Icons.lock_person_outlined,
                  color: isDark ? Colors.tealAccent : Colors.teal,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              ),
              validator: (v) {
                if (v != _passwordCtrl.text) {
                  return "Las contraseñas no coinciden";
                }
                return null;
              },
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
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
                        "Restablecer contraseña",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginPage(authService: widget.authService),
                  ),
                );
              },
              child: const Text("Volver a iniciar sesión"),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
