import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/models/story_model.dart';
import '../../core/theme/app_theme.dart';

class StoryViewerScreen extends StatefulWidget {
  final StoryModel story;
  const StoryViewerScreen({super.key, required this.story});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _progressController.forward();
    _progressController.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted)
        Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(children: [
          // Full screen image
          Positioned.fill(
            child: CachedNetworkImage(
                imageUrl: story.imageURL,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(color: Colors.white))),
          ),
          // Dark overlay at top & bottom
          Positioned.fill(
              child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          )),
          Positioned.fill(
              child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          )),
          // Progress bar
          Positioned(
            top: 48,
            left: 12,
            right: 12,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (_, __) => LinearProgressIndicator(
                value: _progressController.value,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 3,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // User info
          Positioned(
            top: 60,
            left: 16,
            right: 40,
            child: Row(children: [
              CircleAvatar(
                  radius: 18,
                  backgroundImage: story.userPhotoURL.isNotEmpty
                      ? CachedNetworkImageProvider(story.userPhotoURL)
                      : null,
                  child: story.userPhotoURL.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(story.userDisplayName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    Text(DateFormat('h:mm a').format(story.createdAt),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ])),
              IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop()),
            ]),
          ),
          // Bottom: caption + AI analysis
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // SDG chips
              if (story.sdgGoals.isNotEmpty)
                Wrap(
                    spacing: 6,
                    children: story.sdgGoals.map((g) {
                      final idx = g - 1;
                      final color = idx >= 0 && idx < AppTheme.sdgColors.length
                          ? AppTheme.sdgColors[idx]
                          : AppTheme.primary;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('SDG $g',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      );
                    }).toList()),
              const SizedBox(height: 8),
              if (story.caption.isNotEmpty)
                Text(story.caption,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.4)),
              const SizedBox(height: 12),
              // AI score chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🤖 AI awarded ',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('+${story.pointsAwarded} pts',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                  if (story.aiReason.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text('· ${story.aiReason}',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)),
                  ],
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
