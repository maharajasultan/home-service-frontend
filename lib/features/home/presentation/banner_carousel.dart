import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:reaple_app/core/responsive/responsive.dart';
import 'package:reaple_app/core/widgets/app_network_image.dart';
import 'package:reaple_app/features/home/presentation/banner_controller.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.state});

  final BannerState state;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final banners = widget.state.items;
    final aspect = context.isCompact ? 12 / 5 : 3.0;

    if (widget.state.loading && banners.isEmpty) {
      return AspectRatio(
        aspectRatio: aspect,
        child: Container(
          decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
        ),
      );
    }

    // Banner bukan fitur kritis: jika kosong atau gagal, bagian ini disembunyikan.
    if (banners.isEmpty) return const SizedBox.shrink();

    final current = _index.clamp(0, banners.length - 1);

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            aspectRatio: aspect,
            viewportFraction: 1,
            autoPlay: banners.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            enableInfiniteScroll: banners.length > 1,
            onPageChanged: (i, _) => setState(() => _index = i),
          ),
          items: [
            for (final banner in banners)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(banner.imageUrl),
                      if (banner.title.isNotEmpty)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                            child: Text(
                              banner.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (banners.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < banners.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == current ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == current ? scheme.primary : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}