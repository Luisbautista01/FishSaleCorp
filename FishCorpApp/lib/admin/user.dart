class User {
  final String nombre;
  final String rol; // CLIENTE, PESCADOR, ADMIN
  final int? clienteId;
  final int? pescadorId;
  final int? administradorId;

  User({
    required this.nombre,
    required this.rol,
    this.clienteId,
    this.pescadorId,
    this.administradorId,
    int? id,
  });
}
