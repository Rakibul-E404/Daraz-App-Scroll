import 'package:flutter/material.dart';

class PromoChip extends StatelessWidget {
  final String text;
  final Color  color;

  const PromoChip(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: Colors.white30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color:      Colors.white,
          fontSize:   11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}