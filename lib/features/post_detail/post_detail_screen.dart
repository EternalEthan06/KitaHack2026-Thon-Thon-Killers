import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/post_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: FutureBuilder<PostModel?>(
        future: FirestoreService.getPostById(postId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          final post = snap.data;
          if (post == null) return const Center(child: Text('Post not found.'));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full image
                if (post.mediaURL.isNotEmpty)
                  CachedNetworkImage(
                      imageUrl: post.mediaURL,
                      width: double.infinity,
                      fit: BoxFit.cover),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SDG Score
                      if (post.type == PostType.sdg &&
                          post.status == PostStatus.scored) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              AppTheme.primary.withOpacity(0.15),
                              AppTheme.secondary.withOpacity(0.08)
                            ]),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.primary.withOpacity(0.2)),
                          ),
                          child: Column(children: [
                            const Text('🌱 SDG Impact Score',
                                style: TextStyle(
                                    color: AppTheme.onSurfaceMuted,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('+${post.sdgScore} pts',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(color: AppTheme.primary)),
                            if (post.sdgGoals.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: post.sdgGoals.map((g) {
                                    final idx = g - 1;
                                    final color = idx >= 0 &&
                                            idx < AppTheme.sdgColors.length
                                        ? AppTheme.sdgColors[idx]
                                        : AppTheme.primary;
                                    final goalName = idx >= 0 &&
                                            idx < AppConstants.sdgGoals.length
                                        ? AppConstants.sdgGoals[idx]
                                        : 'SDG $g';
                                    final icon = idx >= 0 &&
                                            idx < AppConstants.sdgIcons.length
                                        ? AppConstants.sdgIcons[idx]
                                        : '🌱';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: color.withOpacity(0.3))),
                                      child: Text('$icon $goalName',
                                          style: TextStyle(
                                              color: color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    );
                                  }).toList()),
                            ],
                            if (post.aiReason.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('🤖 ',
                                        style: TextStyle(fontSize: 13)),
                                    Expanded(
                                        child: Text(post.aiReason,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: AppTheme.onSurface))),
                                  ]),
                            ],
                          ]),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Caption
                      Text(post.caption,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),

                      // Author
                      Row(children: [
                        CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.primary.withOpacity(0.2),
                            child: Text(
                                post.userDisplayName.isNotEmpty
                                    ? post.userDisplayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                        const SizedBox(width: 8),
                        Text(post.userDisplayName,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(fontSize: 13)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
