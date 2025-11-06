// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, curly_braces_in_flow_control_structures
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/pedidos/pedido_card.dart';
import 'package:intl/intl.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:http/http.dart' as http;

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

class PedidosPescador extends StatefulWidget {
  final AuthService authService;

  const PedidosPescador({required this.authService, super.key});

  @override
  State<PedidosPescador> createState() => _PedidosPescadorState();
}

class _PedidosPescadorState extends State<PedidosPescador> {
  List pedidos = [];
  bool loading = true;
  int? pescadorId;
  double totalEntregado = 0.0;
  String? rolUsuario;
  final baseUrl = ApiConfig.baseUrl;

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
    _initData();
  }

  Future<void> _initData() async {
    pescadorId = await widget.authService.getUserId();
    rolUsuario = (await widget.authService.getRol())?.toUpperCase();
    await _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    if (pescadorId == null) return;
    setState(() => loading = true);

    try {
      final token = await widget.authService.getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/pedidos'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List allPedidos = jsonDecode(res.body);

        final filtrados = allPedidos
            .where(
              (p) => toInt(p['producto']?['pescador']?['id']) == pescadorId,
            )
            .toList();

        setState(() {
          pedidos = filtrados;
          loading = false;
        });

        _calcularTotalEntregado(filtrados);
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al cargar pedidos")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _calcularTotalEntregado(List pedidosList) {
    double nuevoTotal = 0;

    for (var p in pedidosList) {
      final estado = (p['estado'] ?? '').toString().toUpperCase();
      if (estado == 'ENTREGADO') {
        final producto = p['producto'];
        final precio = toDouble(producto?['precio'] ?? 0);
        final cantidad = toDouble(p['cantidad'] ?? 0);
        nuevoTotal += precio * cantidad;
      }
    }

    setState(() => totalEntregado = nuevoTotal);
  }

  Future<void> _actualizarEstadoPedido(int pedidoId, String nuevoEstado) async {
    try {
      final token = await widget.authService.getToken();
      final res = await http.put(
        Uri.parse(
          '$baseUrl/pedidos/estado/$pedidoId?estado=${nuevoEstado.toUpperCase()}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        await _loadPedidos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al actualizar estado")),
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
      appBar: AppBar(title: const Text("Pedidos del Pescador")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
          ? const Center(child: Text("No hay pedidos registrados"))
          : Column(
              children: [
                const SizedBox(height: 10),
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
                            _calcularTotalEntregado(pedidosFiltrados);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total entregado: ${formatoMoneda.format(totalEntregado)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieSections(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadPedidos,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: pedidosFiltrados.length,
                      itemBuilder: (_, i) {
                        final pedido = pedidosFiltrados[i];
                        return PedidoCard(
                          pedido: pedido,
                          onEstadoChange: (nuevoEstado) {
                            if (rolUsuario == "PESCADOR" &&
                                nuevoEstado.toUpperCase() != "ENTREGADO") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Solo puedes marcar el pedido como ENTREGADO",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            _actualizarEstadoPedido(
                              toInt(pedido['id']),
                              nuevoEstado,
                            );
                          },
                          rolUsuario: rolUsuario ?? '',
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final Map<String, int> conteo = {
      'PENDIENTE': 0,
      'ENVIADO': 0,
      'ENTREGADO': 0,
      'CANCELADO': 0,
    };

    for (var p in pedidos) {
      final estado = (p['estado'] ?? '').toString().toUpperCase();
      if (conteo.containsKey(estado)) conteo[estado] = conteo[estado]! + 1;
    }

    final total = conteo.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return [];

    final Map<String, Color> colores = {
      'PENDIENTE': Colors.orange,
      'ENVIADO': Colors.blue,
      'ENTREGADO': Colors.green,
      'CANCELADO': Colors.red,
    };

    return conteo.entries.map((entry) {
      final porcentaje = (entry.value / total) * 100;
      return PieChartSectionData(
        color: colores[entry.key],
        value: entry.value.toDouble(),
        title: "${entry.key}\n${porcentaje.toStringAsFixed(1)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
