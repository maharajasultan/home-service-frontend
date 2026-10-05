import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded }

/// Batas lebar layar (dp): HP < 600 <= tablet kecil < 1024 <= tablet besar / desktop.
class Breakpoints {
  Breakpoints._();

  static const double medium = 600;
  static const double expanded = 1024;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w >= Breakpoints.expanded) return ScreenSize.expanded;
    if (w >= Breakpoints.medium) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isExpanded => screenSize == ScreenSize.expanded;

  /// Jarak tepi halaman mengikuti ukuran layar.
  double get pagePadding => switch (screenSize) {
        ScreenSize.compact => 16,
        ScreenSize.medium => 24,
        ScreenSize.expanded => 32,
      };

  /// Jumlah kolom grid (dipakai daftar produk di F2).
  int get gridColumns => switch (screenSize) {
        ScreenSize.compact => 2,
        ScreenSize.medium => 3,
        ScreenSize.expanded => 4,
      };
}

/// Memusatkan konten dan membatasi lebar maksimalnya, supaya tidak melar di layar besar.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 1100, this.padding});

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: context.pagePadding),
          child: child,
        ),
      ),
    );
  }
}