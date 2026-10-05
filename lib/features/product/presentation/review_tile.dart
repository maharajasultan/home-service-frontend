import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reaple_app/core/utils/format.dart';
import 'package:reaple_app/core/widgets/rating_stars.dart';
import 'package:reaple_app/features/product/data/product_models.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile(this.review, {super.key});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final avatar = review.userAvatarUrl;
    final comment = review.comment?.trim() ?? '';
    final reply = review.reply?.trim() ?? '';
    final initial = review.userName.isNotEmpty ? review.userName.substring(0, 1).toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: (avatar != null && avatar.isNotEmpty) ? CachedNetworkImageProvider(avatar) : null,
            onBackgroundImageError: (avatar != null && avatar.isNotEmpty) ? (_, __) {} : null,
            child: (avatar == null || avatar.isEmpty) ? Text(initial) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (review.createdAt != null)
                      Text(Fmt.date(review.createdAt!), style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 2),
                RatingStars(rating: review.rating.toDouble(), size: 14),
                if (comment.isNotEmpty) ...[const SizedBox(height: 6), Text(comment)],
                if (reply.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balasan', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(reply),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}