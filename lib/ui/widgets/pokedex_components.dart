import 'package:flutter/material.dart';
import '../../core/pokedex_colors.dart';

class PokedexLens extends StatelessWidget {
  const PokedexLens({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle, 
        color: PokedexColors.blue,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))],
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.all(10), width: 15, height: 15,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class PokedexSmallLight extends StatelessWidget {
  final Color color;
  const PokedexSmallLight({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16, height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26, width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)],
      ),
    );
  }
}

class PokedexButton extends StatelessWidget {
  final String title;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const PokedexButton({
    super.key, required this.title, required this.color, required this.textColor, required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black87, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(0, 4))],
        ),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
    );
  }
}

class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const StatBar({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
          SizedBox(width: 30, child: Text(value.toString(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(5)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (value / 150.0).clamp(0.0, 1.0),
                child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
              ),
            ),
          )
        ],
      ),
    );
  }
}
