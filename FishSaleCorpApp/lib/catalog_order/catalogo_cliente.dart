import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/carrito/carrito_provider.dart';
import 'package:gestor_tareas_app/carrito/carrito_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;

class CatalogoCliente extends StatefulWidget {
  final AuthService authService;
  const CatalogoCliente({required this.authService, super.key});

  @override
  State<CatalogoCliente> createState() => _CatalogoClienteState();
}

class _CatalogoClienteState extends State<CatalogoCliente> {
  List productos = [];
  bool isLoading = true;
  String baseUrl = ApiConfig.baseUrl;
  String searchQuery = "";
  Map<int, int> cantidadesSeleccionadas = {};

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    setState(() => isLoading = true);
    final token = await widget.authService.getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/productos'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      setState(() => productos = (jsonRes is List) ? jsonRes : []);
    } else {
      setState(() => productos = []);
    }
    setState(() => isLoading = false);
  }

  List get filteredProductos {
    if (searchQuery.isEmpty) return productos;
    return productos.where((p) {
      final nombre = (p['nombre'] ?? "").toString().toLowerCase();
      final categoria = (p['categoria'] ?? "").toString().toLowerCase();
      return nombre.contains(searchQuery.toLowerCase()) ||
          categoria.contains(searchQuery.toLowerCase());
    }).toList();
  }

  void _verImagenGrande(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Vista previa")),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Catálogo de Productos"),
        actions: [
          Consumer<CarritoProvider>(
            builder: (_, carrito, __) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CarritoPage()),
                    );
                  },
                ),
                if (carrito.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        carrito.totalItems.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Buscar producto o categoría",
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) =>
                              setState(() => searchQuery = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => searchQuery = ""),
                        icon: const Icon(Icons.clear),
                        label: const Text("Limpiar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredProductos.isEmpty
                      ? const Center(
                          child: Text(
                            "No se encontraron productos",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView(
                          children: _buildCategoriaList(
                            Provider.of<CarritoProvider>(context),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildCategoriaList(CarritoProvider carrito) {
    final Map<String, List> productosPorCategoria = {};
    for (var producto in filteredProductos) {
      final categoria = producto['categoria'] ?? "Sin categoría";
      productosPorCategoria.putIfAbsent(categoria, () => []);
      productosPorCategoria[categoria]!.add(producto);
    }

    return productosPorCategoria.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                final producto = entry.value[index];
                final int productoId = producto['id'];
                final int stock = producto['cantidad'] ?? 0;
                final int cantidadSeleccionada =
                    cantidadesSeleccionadas[productoId] ?? 1;

                return Card(
                  color: Colors.white,
                  shadowColor: Colors.blueAccent.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:
                                (producto['imagen'] != null &&
                                    (producto['imagen'] as String).isNotEmpty)
                                ? GestureDetector(
                                    onTap: () =>
                                        _verImagenGrande(producto['imagen']),
                                    child: SizedBox(
                                      height: 120,
                                      child: Image.network(
                                        producto['imagen'],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          producto['nombre'] ?? "Sin nombre",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "💲 ${producto['precio'] ?? 0} COP",
                          style: const TextStyle(color: Colors.green),
                        ),
                        if ((producto['descuento'] ?? 0) > 0)
                          Text(
                            "Descuento: ${producto['descuento']}%",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          "📦 Stock: $stock",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (cantidadSeleccionada > 1) {
                                  setState(() {
                                    cantidadesSeleccionadas[productoId] =
                                        cantidadSeleccionada - 1;
                                  });
                                }
                              },
                            ),
                            Text(
                              cantidadSeleccionada.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                if (cantidadSeleccionada < stock) {
                                  setState(() {
                                    cantidadesSeleccionadas[productoId] =
                                        cantidadSeleccionada + 1;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: stock > 0
                              ? () async {
                                  carrito.agregarProducto({
                                    'id': productoId,
                                    'nombre': producto['nombre'],
                                    'precio': producto['precio'],
                                    'imagen': producto['imagen'] ?? "",
                                    'cantidad': cantidadSeleccionada,
                                    'descuento': producto['descuento'] ?? 0,
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Producto agregado al carrito",
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                  _playSound('assets/sounds/success.mp3');
                                  setState(() {
                                    cantidadesSeleccionadas[productoId] = 1;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text("Agregar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playSound(String assetPath) async {
    try {
      final bytes = await rootBundle.load(assetPath);
      final buffer = bytes.buffer.asUint8List();
      await _audioPlayer.play(BytesSource(buffer));
    } catch (e) {
      // ignora error en sonidos
    }
  }
}
