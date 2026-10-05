import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final v = rating - i;
        final icon = v >= 0.75
            ? Icons.star_rounded
            : v >= 0.25
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
        return Icon(icon, size: size, color: Colors.amber.shade600);
      }),
    );
  }
}