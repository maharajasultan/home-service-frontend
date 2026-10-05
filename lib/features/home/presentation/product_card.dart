import 'package:flutter/material.dart';
import 'package:reaple_app/core/utils/format.dart';
import 'package:reaple_app/core/widgets/app_network_image.dart';
import 'package:reaple_app/features/product/data/product_models.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = product;
    final price = p.startingPrice;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(p.thumbnail),
                  if (!p.inStock)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: const Text('Stok habis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            p.ratingCount > 0 ? '${p.ratingAvg.toStringAsFixed(1)} (${p.ratingCount})' : 'Belum ada ulasan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      p.options.inspectionOnly ? 'Biaya pengecekan' : 'Mulai dari',
                      style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    Text(
                      price == null ? 'Belum tersedia' : Fmt.rupiah(price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}