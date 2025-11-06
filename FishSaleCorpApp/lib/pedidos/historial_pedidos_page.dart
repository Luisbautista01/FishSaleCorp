// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/pedidos/pedido_card.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';

int toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

class HistorialPedidosPage extends StatefulWidget {
  final AuthService authService;
  final bool esAdmin;
  final int? clienteId;
  final int? pescadorId;

  const HistorialPedidosPage({
    required this.authService,
    required this.esAdmin,
    this.clienteId,
    this.pescadorId,
    super.key,
  });

  @override
  State<HistorialPedidosPage> createState() => _HistorialPedidosPageState();
}

class _HistorialPedidosPageState extends State<HistorialPedidosPage> {
  List pedidos = [];
  bool loading = true;
  String? rolActual;
  int? userIdActual;

  final formatoMoneda = NumberFormat.currency(
    locale: "es_CO",
    symbol: r"$",
    decimalDigits: 2,
  );

  List<String> estados = [
    'TODOS',
    'PENDIENTE',
    'ENVIADO',
    'ENTREGADO',
    'CANCELADO',
  ];
  String estadoSeleccionado = 'TODOS';

  List get pedidosFiltrados {
    if (estadoSeleccionado == 'TODOS') return pedidos;
    return pedidos
        .where(
          (p) =>
              (p['estado'] ?? '').toString().toUpperCase() ==
              estadoSeleccionado,
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    setState(() => loading = true);
    try {
      final token = await widget.authService.getToken();
      rolActual = (await widget.authService.getRol())?.toUpperCase() ?? '';
      userIdActual = await widget.authService.getUserId();

      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pedidos'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List allPedidos = jsonDecode(res.body);
        List filtrados = [];

        if (widget.esAdmin) {
          filtrados = allPedidos;
        } else if (rolActual == "CLIENTE") {
          filtrados = allPedidos.where((p) {
            final idClientePedido = toInt(p['cliente']?['id']);
            return idClientePedido == userIdActual;
          }).toList();
        } else if (rolActual == "PESCADOR") {
          filtrados = allPedidos.where((p) {
            final idPescadorPedido = toInt(p['producto']?['pescador']?['id']);
            return idPescadorPedido == userIdActual;
          }).toList();
        }

        setState(() {
          pedidos = filtrados;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar pedidos (${res.statusCode})"),
          ),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _cambiarEstado(Map pedido, String nuevoEstado) async {
    try {
      final token = await widget.authService.getToken();
      final pedidoId = toInt(pedido['id']);

      if (rolActual == "PESCADOR" && nuevoEstado != "ENTREGADO") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Solo puedes marcar como ENTREGADO"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final res = await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/pedidos/estado/$pedidoId?estado=${nuevoEstado.toUpperCase()}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() => pedido['estado'] = nuevoEstado);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a $nuevoEstado'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (res.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No tienes permisos para cambiar el estado de este pedido",
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar estado (${res.statusCode})"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esAdmin ? "Historial de Pedidos" : "Mis Pedidos"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No hay pedidos registrados",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: estados.map((e) {
                      final selected = e == estadoSeleccionado;
                      Color color;
                      switch (e) {
                        case 'PENDIENTE':
                          color = Colors.orange;
                          break;
                        case 'ENVIADO':
                          color = Colors.blue;
                          break;
                        case 'ENTREGADO':
                          color = Colors.green;
                          break;
                        case 'CANCELADO':
                          color = Colors.red;
                          break;
                        default:
                          color = Colors.blueGrey;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            e,
                            style: TextStyle(
                              color: selected ? Colors.white : color,
                            ),
                          ),
                          selected: selected,
                          selectedColor: color,
                          backgroundColor: color.withOpacity(0.2),
                          onSelected: (_) {
                            setState(() => estadoSeleccionado = e);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: pedidosFiltrados.length,
                    itemBuilder: (_, i) {
                      final pedido = pedidosFiltrados[i];
                      final clienteNombre =
                          pedido['cliente']?['nombre'] ?? "Cliente desconocido";

                      return PedidoCard(
                        pedido: pedido,
                        extraInfo: widget.esAdmin
                            ? "Cliente: $clienteNombre"
                            : null,
                        onEstadoChange: (rolActual == "CLIENTE")
                            ? null
                            : (nuevoEstado) =>
                                  _cambiarEstado(pedido, nuevoEstado),
                        rolUsuario: rolActual ?? '',
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
