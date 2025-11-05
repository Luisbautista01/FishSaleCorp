import 'package:flutter/material.dart';

class CarritoProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _productos = [];

  List<Map<String, dynamic>> get productos => List.unmodifiable(_productos);

  int get totalItems => _productos.length;

  double get totalPrecio => _productos.fold(
    0,
    (sum, item) => sum + (item['cantidad'] * item['precio']),
  );

  void agregarProducto(Map<String, dynamic> producto) {
    final index = _productos.indexWhere((p) => p['id'] == producto['id']);
    if (index >= 0) {
      _productos[index]['cantidad'] += producto['cantidad'];
    } else {
      _productos.add(producto);
    }
    notifyListeners();
  }

  void incrementarProducto(int id, [int step = 1]) {
    final index = _productos.indexWhere((p) => p['id'] == id);
    if (index >= 0) {
      _productos[index]['cantidad'] =
          (_productos[index]['cantidad'] ?? 0) + step;
      notifyListeners();
    }
  }

  void decrementarProducto(int id, [int step = 1]) {
    final index = _productos.indexWhere((p) => p['id'] == id);
    if (index >= 0) {
      final current = (_productos[index]['cantidad'] ?? 0) as int;
      final updated = current - step;
      if (updated > 0) {
        _productos[index]['cantidad'] = updated;
      } else {
        _productos.removeAt(index);
      }
      notifyListeners();
    }
  }

  void setCantidad(int id, int cantidad) {
    final index = _productos.indexWhere((p) => p['id'] == id);
    if (index >= 0) {
      if (cantidad > 0) {
        _productos[index]['cantidad'] = cantidad;
      } else {
        _productos.removeAt(index);
      }
      notifyListeners();
    }
  }

  void eliminarProducto(int id) {
    _productos.removeWhere((p) => p['id'] == id);
    notifyListeners();
  }

  void vaciarCarrito() {
    _productos.clear();
    notifyListeners();
  }
}
