import 'package:flutter/material.dart';

class CommonStyles {
  static const wrapper = EdgeInsets.all(16.0);
  static final card = BoxDecoration(
    color: const Color(0xFF2E3B4E).withOpacity(0.9), // Glassmorphism effect
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    border: Border.all(color: const Color(0xFF546E7A).withOpacity(0.5)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );
  static const buttonContainer = EdgeInsets.symmetric(vertical: 20.0);
  static const container = BoxDecoration(
    color: Color(0xFF1E2A3C),
  );
}