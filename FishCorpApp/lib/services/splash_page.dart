// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/home/home_page.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/admin/user.dart';

class SplashPage extends StatefulWidget {
  final AuthService authService;
  const SplashPage({required this.authService, super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      final token = await widget.authService.getToken();
      final rol = await widget.authService.getRol();
      final nombre = await widget.authService.getNombre();

      if (token != null && rol != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              authService: widget.authService,
              user: User(nombre: nombre!, rol: rol),
            ),
          ),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (_) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
