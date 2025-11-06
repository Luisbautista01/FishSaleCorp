// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FishBot extends StatefulWidget {
  final String nombre;
  final String rol;

  const FishBot({super.key, required this.nombre, required this.rol});

  @override
  State<FishBot> createState() => _FishBotState();
}

class _FishBotState extends State<FishBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _mensajes = [];

  @override
  void initState() {
    super.initState();
    _agregarMensaje(
      "👋 ¡Hola ${widget.nombre.toUpperCase().split(' ')[0]}! Soy FishBot 🤖",
      false,
    );
    Future.delayed(const Duration(seconds: 1), () {
      _agregarMensaje(_mensajePorRol(widget.rol), false);
    });
  }

  String _mensajePorRol(String rol) {
    switch (rol.toUpperCase()) {
      case "CLIENTE":
        return "Puedo ayudarte a revisar tus pedidos 📦 o pagos 💳.";
      case "PESCADOR":
        return "¿Quieres ver tus ventas 🧾 o actualizar tu catálogo de productos 🐟?";
      case "ADMIN":
        return "¿Deseas consultar estadísticas 📊, ganancias 💰 o gestionar usuarios 👥?";
      default:
        return "¿En qué puedo ayudarte hoy?";
    }
  }

  void _agregarMensaje(String texto, bool esUsuario) {
    setState(() {
      _mensajes.add({"texto": texto, "esUsuario": esUsuario});
    });
  }

  Future<void> _preguntarSiguientePaso(String texto) async {
    if (texto.toLowerCase().contains("pago")) {
      _agregarMensaje(
        "¿Quieres ver tu historial de pagos 💳 o realizar uno nuevo?",
        false,
      );
    } else if (texto.toLowerCase().contains("pedido")) {
      _agregarMensaje(
        "¿Te gustaría revisar tus pedidos 📦 o crear uno nuevo?",
        false,
      );
    } else if (texto.toLowerCase().contains("producto") ||
        texto.toLowerCase().contains("catálogo")) {
      _agregarMensaje("¿Deseas actualizar o consultar tu catálogo 🐟?", false);
    } else {
      _agregarMensaje(
        "¿Quieres que te ayude con otra parte del sistema?",
        false,
      );
    }
  }

  void _navegarSegunTexto(String texto) {
    texto = texto.toLowerCase();
    final rol = widget.rol.toUpperCase();
    String? ruta;

    if (rol == "CLIENTE") {
      if (texto.contains("pedido"))
        ruta = '/pedidos';
      else if (texto.contains("pago"))
        ruta = '/entregados';
      else if (texto.contains("carrito"))
        ruta = '/carrito';
      else if (texto.contains("catálogo") || texto.contains("catalogo"))
        ruta = '/catalogo';
    } else if (rol == "PESCADOR") {
      if (texto.contains("venta") || texto.contains("pago"))
        ruta = '/entregados';
      else if (texto.contains("catálogo") ||
          texto.contains("catalogo") ||
          texto.contains("producto"))
        ruta = '/catalogo';
      else if (texto.contains("pedido"))
        ruta = '/pedidos';
    } else if (rol == "ADMIN") {
      if (texto.contains("usuario"))
        ruta = '/usuarios';
      else if (texto.contains("ganancia") || texto.contains("estadística"))
        ruta = '/ganancias';
      else if (texto.contains("pago"))
        ruta = '/entregados';
      else if (texto.contains("pedido"))
        ruta = '/pedidos';
    }

    // ✅ Verificar si la ruta existe en el Navigator
    if (ruta != null && Navigator.canPop(context)) {
      Navigator.pushNamed(context, ruta);
      _agregarMensaje("🚀 Abriendo la sección correspondiente...", false);
    } else if (ruta != null) {
      Navigator.pushNamed(context, ruta);
      _agregarMensaje("✅ Te llevo a la sección solicitada.", false);
    } else {
      _agregarMensaje(
        "❌ No encontré esa opción, intenta con 'pedidos', 'pagos' o 'catálogo'.",
        false,
      );
    }
  }

  void _responder(String texto) async {
    String respuesta = "🤖 Procesando tu mensaje...";
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService();

    if (texto.toLowerCase().contains("mi nombre")) {
      final nombre = await auth.getNombre() ?? prefs.getString('nombre');
      respuesta = "Tu nombre registrado es *$nombre*.";
    } else if (texto.toLowerCase().contains("mi rol")) {
      final rol = await auth.getRol() ?? widget.rol;
      respuesta = "Tu rol actual es *$rol*.";
    } else if (texto.toLowerCase().contains("token")) {
      final token = await auth.getToken();
      respuesta = token != null
          ? "🔐 Tienes un token activo y válido."
          : "⚠️ No se encontró un token guardado.";
    } else if (texto.toLowerCase().contains("ayuda")) {
      respuesta =
          "Puedo ayudarte con:\n- Pagos 💳\n- Pedidos 📦\n- Productos 🐟\n- Usuarios 👥\n- Estadísticas 📊\nDime qué quieres abrir.";
    } else if (texto.contains("abrir") ||
        texto.contains("ver") ||
        texto.contains("ir") ||
        texto.contains("mostrar")) {
      _navegarSegunTexto(texto);
      respuesta = "✨ Entendido, procesando tu solicitud...";
    } else {
      respuesta =
          "😅 No entendí bien eso. Intenta con algo como 'ver mis pedidos' o 'abrir pagos'.";
    }

    _agregarMensaje(respuesta, false);
    await _preguntarSiguientePaso(texto);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Center(
                child: Text(
                  "💬 FishBot Asistente",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _mensajes.length,
                itemBuilder: (context, index) {
                  final msg = _mensajes[index];
                  return Align(
                    alignment: msg["esUsuario"]
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: msg["esUsuario"]
                            ? AppColors.primaryBlue
                            : AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg["texto"],
                        style: TextStyle(
                          color: msg["esUsuario"]
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Escribe tu pregunta...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primaryBlue),
                    onPressed: () {
                      final texto = _controller.text.trim();
                      if (texto.isEmpty) return;
                      _agregarMensaje(texto, true);
                      _controller.clear();
                      Future.delayed(
                        const Duration(milliseconds: 500),
                        () => _responder(texto),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
