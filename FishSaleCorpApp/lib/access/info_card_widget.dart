import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String route;
  final bool isTablet;

  const InfoCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.route,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: isTablet ? 28 : 22,
              backgroundColor: Colors.blue.shade50,
              child: Icon(
                icon,
                size: isTablet ? 28 : 22,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 18 : 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 15 : 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
