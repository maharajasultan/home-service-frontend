import 'package:flutter/material.dart';
import 'package:reaple_app/core/config/api_config.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 56, this.onDark = false, this.showName = true});

  final double size;
  final bool onDark;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: onDark ? Colors.white : scheme.primary,
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Icon(
            Icons.phone_iphone_rounded,
            size: size * 0.55,
            color: onDark ? scheme.primary : scheme.onPrimary,
          ),
        ),
        if (showName) ...[
          SizedBox(width: size * 0.22),
          Text(
            ApiConfig.appName,
            style: TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w800,
              color: onDark ? Colors.white : scheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}