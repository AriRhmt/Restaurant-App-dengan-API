import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton.primary(
      {super.key, required this.onPressed, required this.label})
      : variant = _Variant.primary;
  const CustomButton.secondary(
      {super.key, required this.onPressed, required this.label})
      : variant = _Variant.secondary;

  final VoidCallback onPressed;
  final String label;
  final _Variant variant;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case _Variant.primary:
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x330B0F1A),
                    blurRadius: 12,
                    offset: Offset(0, 6))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Center(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        );
      case _Variant.secondary:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF4F46E5)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: onPressed,
          child: Text(label,
              style: const TextStyle(
                  color: Color(0xFF4F46E5), fontWeight: FontWeight.w600)),
        );
    }
  }
}

enum _Variant { primary, secondary }
