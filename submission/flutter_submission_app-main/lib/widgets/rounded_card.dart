import 'package:flutter/material.dart';

class RoundedCard extends StatelessWidget {
  const RoundedCard(
      {super.key,
      required this.child,
      this.onTap,
      this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x140B0F1A), blurRadius: 12, offset: Offset(0, 6))
        ],
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;
    return InkWell(
        borderRadius: BorderRadius.circular(20), onTap: onTap, child: card);
  }
}
