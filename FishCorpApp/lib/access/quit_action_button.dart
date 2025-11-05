import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final bool isTablet;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.badgeCount,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 18 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.9),
              Colors.lightBlueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(icon, size: isTablet ? 36 : 28, color: Colors.white),
                if (badgeCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: CircleAvatar(
                      radius: isTablet ? 10 : 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        "$badgeCount",
                        style: TextStyle(
                          color: AppColors.lightBlue,
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
