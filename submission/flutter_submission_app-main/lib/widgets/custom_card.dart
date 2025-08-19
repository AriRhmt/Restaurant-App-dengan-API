import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x140B0F1A),
                  blurRadius: 12,
                  offset: Offset(0, 6)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
