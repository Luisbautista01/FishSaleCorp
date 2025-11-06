import 'package:flutter/material.dart';

void mostrarErrorDialog(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}

void mostrarExitoDialog(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('Éxito', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}
