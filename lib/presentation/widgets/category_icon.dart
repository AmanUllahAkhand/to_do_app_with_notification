import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryIcon({required this.category,this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (category) {
      case 'home':
        color = Colors.green;
        icon = Icons.home;
        break;
      case 'shopping':
        color = Colors.orange;
        icon = Icons.shopping_cart;
        break;
    // Add more
      default:
        color = Colors.blue;
        icon = Icons.person;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
      ),
    );
  }
}