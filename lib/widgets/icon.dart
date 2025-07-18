import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const AppIcon({
    Key? key,
    required this.icon,
    this.size = 40.0,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Icon(icon, size: size, color: color),
    );
  }
}