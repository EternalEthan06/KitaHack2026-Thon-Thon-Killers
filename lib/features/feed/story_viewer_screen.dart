import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/models/story_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';

class StoryViewerScreen extends StatefulWidget {
  final Map<String, List<StoryModel>> allGroupedStories;
  final int initialUserIndex;

  const StoryViewerScreen({
    super.key,
    required this.allGroupedStories,
    required this.initialUserIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController _userPageController;
  late int _currentUserIndex;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _userPageController = PageController(initialPage: _currentUserIndex);
  }

  @override
  void dispose() {
    _userPageController.dispose();
    super.dispose();
  }

  void _nextUser() {
    if (_currentUserIndex < widget.allGroupedStories.length - 1) {
      _userPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevUser() {
    if (_currentUserIndex > 0) {
      _userPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userIds = widget.allGroupedStories.keys.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _userPageController,
        itemCount: userIds.length,
        onPageChanged: (i) => setState(() => _currentUserIndex = i),
        itemBuilder: (ctx, userIdx) {
          final stories = widget.allGroupedStories[userIds[userIdx]]!;
          return _UserStoryGroup(
            stories: stories,
            onComplete: _nextUser,
            onPrevUser: _prevUser,
          );
        },
      ),
    );
  }
}

class _UserStoryGroup extends StatefulWidget {
  final List<StoryModel> stories;
  final VoidCallback onComplete;
  final VoidCallback onPrevUser;

  const _UserStoryGroup({
    required this.stories,
    required this.onComplete,
    required this.onPrevUser,
  });

  @override
  State<_UserStoryGroup> createState() => _UserStoryGroupState();
}

class _UserStoryGroupState extends State<_UserStoryGroup>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentStoryIdx = 0;

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _progressController.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        _nextStory();
      }
    });
    _startStory();
  }

  void _startStory() {
    _progressController.stop();
    _progressController.reset();
    _progressController.forward();
  }

  void _nextStory() {
    if (_currentStoryIdx < widget.stories.length - 1) {
      setState(() {
        _currentStoryIdx++;
        _startStory();
      });
    } else {
      widget.onComplete();
    }
  }

  void _prevStory() {
    if (_currentStoryIdx > 0) {
      setState(() {
        _currentStoryIdx--;
        _startStory();
      });
    } else {
      widget.onPrevUser();
    }
  }

  void _showDeleteStoryDialog(String storyId) {
    _progressController.stop();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Story?'),
        content: const Text('This will remove your story for everyone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _progressController.forward();
            },
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.onSurfaceMuted)),
          ),
          TextButton(
            onPressed: () {
              DatabaseService.deleteStory(storyId);
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close story viewer
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentStoryIdx];
    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 3) {
          _prevStory();
        } else {
          _nextStory();
        }
      },
      child: Stack(children: [
        // Full screen image
        Positioned.fill(
          child: CachedNetworkImage(
              imageUrl: story.imageURL,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: Colors.white))),
        ),
        // Dark overlays
        Positioned.fill(
            child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black54,
                Colors.transparent,
                Colors.transparent,
                Colors.black87
              ],
              stops: [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        )),
        // Progress bars (segmented)
        Positioned(
          top: 48,
          left: 8,
          right: 8,
          child: Row(
            children: List.generate(widget.stories.length, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: i < _currentStoryIdx
                          ? 1.0
                          : (i == _currentStoryIdx ? null : 0.0),
                      backgroundColor: Colors.white30,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 2.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Custom animation builder for the CURRENT segment
        Positioned(
          top: 48,
          left: 8,
          right: 8,
          child: Row(
            children: List.generate(widget.stories.length, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: i == _currentStoryIdx
                      ? AnimatedBuilder(
                          animation: _progressController,
                          builder: (ctx, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              backgroundColor: Colors.transparent,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 2.5,
                            ),
                          ),
                        )
                      : const SizedBox(height: 2.5),
                ),
              );
            }).toList(),
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
                  Text(timeago.format(story.createdAt),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11)),
                ])),
            IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop()),
            if (story.userId == AuthService.currentUserId)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: AppTheme.surface,
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteStoryDialog(story.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ]),
                  ),
                ],
              ),
          ]),
        ),
        // Bottom: caption + AI analysis
        Positioned(
          bottom: 48,
          left: 16,
          right: 16,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            const SizedBox(height: 10),
            if (story.caption.isNotEmpty)
              Text(story.caption,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
