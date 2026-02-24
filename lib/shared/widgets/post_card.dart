import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/models/post_model.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.onSurfaceMuted)),
          ),
          TextButton(
            onPressed: () {
              DatabaseService.deletePost(widget.post.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final ctrl = TextEditingController(text: widget.post.caption);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Edit Caption'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter new caption...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.onSurfaceMuted)),
          ),
          TextButton(
            onPressed: () {
              DatabaseService.updatePostCaption(widget.post.id, ctrl.text);
              Navigator.pop(ctx);
            },
            child:
                const Text('Save', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(
        CurvedAnimation(parent: _heartController, curve: Curves.easeOut));
    _heartController.addStatusListener((s) {
      if (s == AnimationStatus.completed) setState(() => _showHeart = false);
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _doubleTapLike() {
    final uid = AuthService.currentUserId ?? '';
    final liked = widget.post.likedBy.contains(uid);
    if (!liked) DatabaseService.toggleLike(widget.post.id, uid);
    setState(() => _showHeart = true);
    _heartController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUserId ?? '';
    final liked = widget.post.likedBy.contains(uid);
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/${post.userId}'),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: AppTheme.surfaceVariant,
                        backgroundImage: post.userPhotoURL.isNotEmpty
                            ? CachedNetworkImageProvider(post.userPhotoURL)
                            : null,
                        child: post.userPhotoURL.isEmpty
                            ? Text(
                                post.userDisplayName.isNotEmpty
                                    ? post.userDisplayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(post.userDisplayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.onBackground)),
                        if (post.type == PostType.sdg) ...[
                          const SizedBox(width: 4),
                          const Text('✅', style: TextStyle(fontSize: 12)),
                        ],
                      ]),
                      Text(timeago.format(post.createdAt),
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.onSurfaceMuted)),
                    ],
                  ),
                ),
                if (post.type == PostType.sdg &&
                    post.status == PostStatus.scored)
                  _ScorePill(score: post.sdgScore),
                if (post.status == PostStatus.pending)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: AppTheme.warning)),
                      SizedBox(width: 6),
                      Text('AI Scoring...',
                          style: TextStyle(
                              color: AppTheme.warning,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                if (post.userId == uid)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz,
                        color: AppTheme.onSurfaceMuted, size: 22),
                    padding: EdgeInsets.zero,
                    color: AppTheme.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog();
                      } else if (value == 'delete') {
                        _showDeleteDialog();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Edit Caption'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text('Delete',
                              style: TextStyle(color: Colors.redAccent)),
                        ]),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Image carousel (up to 5 images) ─────────────────
          if (post.imageURLs.isNotEmpty)
            _ImageCarousel(
                images: post.imageURLs,
                onDoubleTap: _doubleTapLike,
                showHeart: _showHeart,
                heartScale: _heartScale,
                post: post)
          else if (post.mediaURL.isNotEmpty)
            GestureDetector(
              onDoubleTap: _doubleTapLike,
              onTap: () => context.push('/post/${post.id}'),
              child: Stack(alignment: Alignment.center, children: [
                CachedNetworkImage(
                    imageUrl: post.mediaURL,
                    width: double.infinity,
                    height: 340,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        height: 340,
                        color: AppTheme.surfaceVariant,
                        child: const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primary, strokeWidth: 2))),
                    errorWidget: (_, __, ___) => Container(
                        height: 340,
                        color: AppTheme.surfaceVariant,
                        child: const Icon(Icons.broken_image_rounded,
                            color: AppTheme.onSurfaceMuted, size: 40))),
                if (_showHeart)
                  AnimatedBuilder(
                      animation: _heartScale,
                      builder: (_, __) => Transform.scale(
                          scale: _heartScale.value,
                          child: const Icon(Icons.favorite_rounded,
                              color: Colors.white, size: 96))),
              ]),
            ),

          // ── Action Row (Instagram-style) ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Row(
              children: [
                _ActionBtn(
                  icon: liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color:
                      liked ? const Color(0xFFFF4D6A) : AppTheme.onSurfaceMuted,
                  onTap: () => DatabaseService.toggleLike(post.id, uid),
                ),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: AppTheme.onSurfaceMuted,
                  onTap: () => context.push('/post/${post.id}'),
                ),
                _ActionBtn(
                  icon: Icons.near_me_outlined,
                  color: AppTheme.onSurfaceMuted,
                  onTap: () {},
                ),
                const Spacer(),
                _ActionBtn(
                  icon: Icons.bookmark_border_rounded,
                  color: AppTheme.onSurfaceMuted,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ── Likes count ───────────────────────────────────
          if (post.likes > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                '${post.likes} ${post.likes == 1 ? 'like' : 'likes'}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.onBackground),
              ),
            ),

          // ── Caption ───────────────────────────────────────
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: '${post.userDisplayName} ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.onBackground),
                  ),
                  TextSpan(
                    text: post.caption,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.onSurface),
                  ),
                ]),
              ),
            ),

          // ── AI Reasoning ──────────────────────────────────
          if (post.aiReason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🤖 ', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Text(post.aiReason,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.onSurfaceMuted,
                                height: 1.4)),
                      ),
                    ]),
              ),
            ),

          const Divider(height: 1, color: Color(0xFF1E2535)),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int score;
  const _ScorePill({required this.score});

  Color get _color {
    if (score >= 80) return AppTheme.primary;
    if (score >= 50) return AppTheme.warning;
    return AppTheme.onSurfaceMuted;
  }

  String get _emoji {
    if (score >= 80) return '🌟';
    if (score >= 50) return '🌱';
    return '💬';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text('$_emoji +$score',
          style: TextStyle(
              color: _color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Multi-photo Carousel ──────────────────────────────────────────────────────
class _ImageCarousel extends StatefulWidget {
  final List<String> images;
  final VoidCallback onDoubleTap;
  final bool showHeart;
  final Animation<double> heartScale;
  final PostModel post;
  const _ImageCarousel({
    required this.images,
    required this.onDoubleTap,
    required this.showHeart,
    required this.heartScale,
    required this.post,
  });
  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.take(5).toList();
    final post = widget.post;

    return Column(children: [
      SizedBox(
        height: 340,
        child: Stack(children: [
          // PageView of images
          PageView.builder(
            controller: _pageCtrl,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (ctx, i) => GestureDetector(
              onDoubleTap: widget.onDoubleTap,
              onTap: () => context.push('/post/${post.id}'),
              child: CachedNetworkImage(
                imageUrl: images[i],
                width: double.infinity,
                height: 340,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                    height: 340,
                    color: AppTheme.surfaceVariant,
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary, strokeWidth: 2))),
                errorWidget: (_, __, ___) => Container(
                    height: 340,
                    color: AppTheme.surfaceVariant,
                    child: const Icon(Icons.broken_image_rounded,
                        color: AppTheme.onSurfaceMuted, size: 40)),
              ),
            ),
          ),
          // Image counter badge (top-right)
          if (images.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12)),
                child: Text('${_currentPage + 1}/${images.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          // SDG chips (bottom-left)
          if (post.sdgGoals.isNotEmpty)
            Positioned(
              bottom: 10,
              left: 12,
              child: Wrap(
                  spacing: 5,
                  children: post.sdgGoals.take(3).map((g) {
                    final idx = g - 1;
                    final color = idx >= 0 && idx < AppTheme.sdgColors.length
                        ? AppTheme.sdgColors[idx]
                        : AppTheme.primary;
                    final icon = idx >= 0 && idx < AppConstants.sdgIcons.length
                        ? AppConstants.sdgIcons[idx]
                        : '🌱';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: color.withOpacity(0.7), width: 1),
                      ),
                      child: Text('$icon SDG $g',
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    );
                  }).toList()),
            ),
          // Heart animation
          if (widget.showHeart)
            Center(
                child: AnimatedBuilder(
              animation: widget.heartScale,
              builder: (_, __) => Transform.scale(
                  scale: widget.heartScale.value,
                  child: const Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 96)),
            )),
        ]),
      ),
      // Page dots indicator
      if (images.length > 1)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _currentPage ? 18 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? AppTheme.primary
                            : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
          ),
        ),
    ]);
  }
}
