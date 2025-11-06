// ignore_for_file: use_build_context_synchronously, prefer_conditional_assignment

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/admin/usuarios_service.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;

const Color fishCorpPrimary = Color(0xFF0288D1);
const Color fishCorpAccent = Color(0xFF00BCD4);
const Color fishCorpBackground = Color(0xFFF5F9FC);

InputDecoration _inputStyle(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: fishCorpPrimary),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: fishCorpPrimary, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: fishCorpAccent, width: 2),
    ),
  );
}

ButtonStyle _buttonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: fishCorpPrimary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );
}

class CatalogoAdminPescador extends StatefulWidget {
  final AuthService authService;
  final int? pescadorId;
  const CatalogoAdminPescador({
    required this.authService,
    this.pescadorId,
    super.key,
  });

  @override
  State<CatalogoAdminPescador> createState() => _CatalogoAdminPescadorState();
}

class _CatalogoAdminPescadorState extends State<CatalogoAdminPescador> {
  List productos = [];
  int? editingId;
  final nombreCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();
  final categoriaCtrl = TextEditingController();
  final imagenCtrl = TextEditingController();
  final descuentoCtrl = TextEditingController();
  String baseUrl = ApiConfig.baseUrl;
  bool isLoading = true;
  List<dynamic> pescadores = [];
  int? selectedPescadorId;
  String? userRole;

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _fetchUserRoleAndPescadores();
  }

  Future<void> _fetchUserRoleAndPescadores() async {
    try {
      final role = await widget.authService.getRol();
      setState(() => userRole = role);
      if (role != null && role.toUpperCase() == 'ADMIN') {
        final service = UsuariosService();
        final data = await service.fetchUsuarios('pescadores');
        setState(() => pescadores = data);
      }
    } catch (_) {
      // ignora errores
    }
  }

  Future<void> _loadProductos() async {
    setState(() => isLoading = true);
    final token = await widget.authService.getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/productos'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      productos = jsonDecode(res.body);
      if (widget.pescadorId != null) {
        productos = productos
            .where(
              (p) =>
                  p['pescador'] != null &&
                  p['pescador']['id'] == widget.pescadorId,
            )
            .toList();
      }
    } else {
      productos = [];
    }
    setState(() => isLoading = false);
  }

  Future<void> _crearActualizar() async {
    final bool wasNew = editingId == null;
    final token = await widget.authService.getToken();

    final nombre = nombreCtrl.text.trim();
    final precio = double.tryParse(precioCtrl.text) ?? 0;
    final cantidad = int.tryParse(cantidadCtrl.text) ?? 0;
    final categoria = categoriaCtrl.text.trim();
    final descuentoText = descuentoCtrl.text.trim();
    final descuento = descuentoText.isEmpty
        ? null
        : double.tryParse(descuentoText);

    if (nombre.isEmpty || precio <= 0 || cantidad < 0 || categoria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos correctamente'),
        ),
      );
      return;
    }

    if (imagenCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes subir una imagen o pegar la URL de la imagen'),
        ),
      );
      return;
    }

    String? urlImagen = imagenCtrl.text.trim();

    int? pescadorId = selectedPescadorId ?? widget.pescadorId;
    pescadorId ??= await widget.authService.getUserId();
    if (pescadorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: no se pudo determinar el pescador.'),
        ),
      );
      return;
    }

    final Map<String, dynamic> payload = {
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'categoria': categoria,
      'imagen': urlImagen,
      'pescadorId': pescadorId,
    };

    if (descuento != null) payload['descuento'] = descuento;

    final body = jsonEncode(payload);

    late http.Response res;
    if (editingId == null) {
      res = await http.post(
        Uri.parse('$baseUrl/productos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );
    } else {
      res = await http.put(
        Uri.parse('$baseUrl/productos/$editingId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      _resetForm();
      _loadProductos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasNew ? 'Producto creado' : 'Producto actualizado'),
        ),
      );
      _playSound('assets/sounds/success.mp3');
    } else {
      String message = 'Error al guardar el producto';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data['message'] != null) message = data['message'];
      } catch (_) {}
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _editar(Map p) {
    setState(() {
      editingId = p['id'];
      nombreCtrl.text = p['nombre'];
      precioCtrl.text = p['precio'].toString();
      cantidadCtrl.text = p['cantidad'].toString();
      categoriaCtrl.text = p['categoria'] ?? '';
      imagenCtrl.text = p['imagen'] ?? '';
    });
  }

  void _resetForm() {
    nombreCtrl.clear();
    precioCtrl.clear();
    cantidadCtrl.clear();
    categoriaCtrl.clear();
    imagenCtrl.clear();
    editingId = null;
  }

  Future<void> _eliminar(int id) async {
    final token = await widget.authService.getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/productos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      _loadProductos();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
      _playSound('assets/sounds/uncheck.mp3');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el producto')),
      );
    }
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catálogo del Pescador',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: fishCorpPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nombreCtrl,
                            decoration: _inputStyle('Nombre'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: precioCtrl,
                            decoration: _inputStyle('Precio'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cantidadCtrl,
                            decoration: _inputStyle('Cantidad'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: categoriaCtrl,
                            decoration: _inputStyle('Categoría'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imagenCtrl,
                      decoration: _inputStyle('URL de la Imagen'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descuentoCtrl,
                      decoration: _inputStyle('Descuento (opcional)'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (userRole != null && userRole!.toUpperCase() == 'ADMIN')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<int>(
                          value: selectedPescadorId,
                          decoration: _inputStyle(
                            'Asignar a pescador (opcional)',
                          ),
                          items: pescadores.map<DropdownMenuItem<int>>((p) {
                            return DropdownMenuItem<int>(
                              value: p['id'] as int?,
                              child: Text(p['nombre'] ?? 'Pescador ${p['id']}'),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => selectedPescadorId = v),
                        ),
                      ),
                    const SizedBox(height: 10),

                    if (imagenCtrl.text.isNotEmpty)
                      Center(
                        child: GestureDetector(
                          onTap: () => _verImagenGrande(imagenCtrl.text),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imagenCtrl.text,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: _crearActualizar,
                      icon: Icon(editingId == null ? Icons.add : Icons.update),
                      label: Text(
                        editingId == null
                            ? 'Agregar Producto'
                            : 'Actualizar Producto',
                      ),
                      style: _buttonStyle(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar producto o categoría',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            const Text(
              'Mis Productos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            filteredProductos.isEmpty
                ? const Center(
                    child: Text(
                      "No se encontraron productos",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Column(
                    children: filteredProductos.isEmpty
                        ? []
                        : _buildCategoriaGrid(),
                  ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoriaGrid() {
    final Map<String, List> productosPorCategoria = {};
    for (var p in filteredProductos) {
      final categoria = p['categoria'] ?? "Sin categoría";
      productosPorCategoria.putIfAbsent(categoria, () => []);
      productosPorCategoria[categoria]!.add(p);
    }

    return productosPorCategoria.entries.map((entry) {
      final categoria = entry.key;
      final productosCat = entry.value;

      return ExpansionTile(
        title: Text(
          categoria,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: fishCorpPrimary,
          ),
        ),
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: productosCat.length,
            itemBuilder: (_, i) {
              final p = productosCat[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: p['imagen'] != null && p['imagen'].isNotEmpty
                              ? GestureDetector(
                                  onTap: () => _verImagenGrande(p['imagen']),
                                  child: Image.network(
                                    p['imagen'],
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.image_not_supported, size: 80),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p['nombre'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "💲 ${p['precio']} COP",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Text(
                        "📦 ${p['cantidad']} kg",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Editar',
                            onPressed: () => _editar(p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Eliminar',
                            onPressed: () => _eliminar(p['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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
      // ignora errores
    }
  }
}
