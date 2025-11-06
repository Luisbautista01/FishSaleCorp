import 'package:flutter/material.dart';
import 'fish_bot.dart';
import '../services/app_colors.dart';

class FishBotOverlay {
  static OverlayEntry? _overlayEntry;

  static void toggle(BuildContext context, String nombre, String rol) {
    if (_overlayEntry != null) {
      removeOverlay();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        right: 20,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => FishBot(nombre: nombre, rol: rol),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
