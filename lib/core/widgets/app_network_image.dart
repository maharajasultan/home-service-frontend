import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Isi seluruh ruang induknya (letakkan di dalam AspectRatio atau SizedBox).
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(this.url, {super.key, this.fit = BoxFit.cover, this.borderRadius, this.iconSize = 32});

  final String? url;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget box(IconData icon) => Container(
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(icon, color: scheme.onSurfaceVariant, size: iconSize),
        );

    final source = url;
    final Widget image = (source == null || source.isEmpty)
        ? box(Icons.image_outlined)
        : CachedNetworkImage(
            imageUrl: source,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            placeholder: (_, __) => box(Icons.image_outlined),
            errorWidget: (_, __, ___) => box(Icons.broken_image_outlined),
          );

    return borderRadius == null ? image : ClipRRect(borderRadius: borderRadius!, child: image);
  }
}