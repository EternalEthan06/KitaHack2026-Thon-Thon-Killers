import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/story_model.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/gemini_service.dart';
import '../../core/theme/app_theme.dart';
import 'story_viewer_screen.dart';

/// Horizontal story bar shown at the top of the feed
class StoryBar extends StatelessWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUserId ?? '';
    return StreamBuilder<List<StoryModel>>(
      stream: DatabaseService.watchStories(),
      builder: (ctx, snap) {
        if (snap.hasError) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Text('Story Error: ${snap.error}',
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 11)),
            ),
          );
        }
        final allStories = snap.data ?? [];

        // Group stories by userId
        final Map<String, List<StoryModel>> grouped = {};
        for (final s in allStories) {
          grouped.putIfAbsent(s.userId, () => []).add(s);
        }

        final userIds = grouped.keys.toList();

        // --- IMPROVEMENT: SORT TO SHOW CURRENT USER FIRST ---
        userIds.sort((a, b) {
          if (a == uid) return -1;
          if (b == uid) return 1;
          return 0;
        });

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: userIds.length + 1, // +1 for "Add Story"
            itemBuilder: (_, i) {
              if (i == 0) return _AddStoryButton(uid: uid);

              final targetUserId = userIds[i - 1];
              final userStories = grouped[targetUserId]!;
              final hasUnviewed =
                  userStories.any((s) => !s.viewedBy.contains(uid));

              return _StoryRing(
                stories: userStories,
                viewed: !hasUnviewed,
                uid: uid,
                allGroupedStories: grouped,
                initialUserIndex: i - 1,
              );
            },
          ),
        );
      },
    );
  }
}

class _AddStoryButton extends StatelessWidget {
  final String uid;
  const _AddStoryButton({required this.uid});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/story/create'),
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceVariant,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.surfaceVariant,
                  backgroundImage:
                      (AuthService.currentUser?.photoURL ?? '').isNotEmpty
                          ? NetworkImage(AuthService.currentUser!.photoURL!)
                          : null,
                  child: (AuthService.currentUser?.photoURL ?? '').isEmpty
                      ? const Icon(Icons.person, color: AppTheme.onSurfaceMuted)
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary,
                      border: Border.all(color: Colors.black, width: 2)),
                  child: const Icon(Icons.add, color: Colors.black, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text('Your Story',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  final List<StoryModel> stories;
  final bool viewed;
  final String uid;
  final Map<String, List<StoryModel>> allGroupedStories;
  final int initialUserIndex;

  const _StoryRing({
    required this.stories,
    required this.viewed,
    required this.uid,
    required this.allGroupedStories,
    required this.initialUserIndex,
  });

  @override
  Widget build(BuildContext context) {
    final firstStory = stories.first;
    return GestureDetector(
      onTap: () {
        // Mark all stories in this group as viewed
        for (final s in stories) {
          DatabaseService.markStoryViewed(s.id, uid);
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StoryViewerScreen(
              allGroupedStories: allGroupedStories,
              initialUserIndex: initialUserIndex,
            ),
          ),
        );
      },
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: viewed
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF1DE9B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
              color: viewed ? AppTheme.surfaceVariant : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.surfaceVariant,
                backgroundImage: firstStory.userPhotoURL.isNotEmpty
                    ? CachedNetworkImageProvider(firstStory.userPhotoURL)
                    : null,
                child: firstStory.userPhotoURL.isEmpty
                    ? const Icon(Icons.person, color: AppTheme.onSurfaceMuted)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(firstStory.userDisplayName.split(' ').first,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color:
                      viewed ? AppTheme.onSurfaceMuted : AppTheme.onBackground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── Story Create Screen ───────────────────────────────────────────────────────
class StoryCreateScreen extends StatefulWidget {
  const StoryCreateScreen({super.key});

  @override
  State<StoryCreateScreen> createState() => _StoryCreateScreenState();
}

class _StoryCreateScreenState extends State<StoryCreateScreen> {
  Uint8List? _imageBytes;
  final TextEditingController _captionCtrl = TextEditingController();
  bool _analyzing = false;
  bool _uploading = false;
  Map<String, dynamic>? _analysis;
  bool _isFromCamera = false;
  String _uploadStatus = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tryRecoverStory();
  }

  Future<void> _tryRecoverStory() async {
    final prefs = await SharedPreferences.getInstance();
    final tempDocId = prefs.getString('temp_story_doc_id');
    final isActive = prefs.getBool('temp_story_active') ?? false;

    if (tempDocId != null && isActive && mounted) {
      print('♻️ RECOVERING FROM DATABASE CLIPBOARD...');
      setState(() => _uploading = true);
      final bytes = await DatabaseService.getTempImage(tempDocId);
      if (bytes != null && mounted) {
        setState(() {
          _imageBytes = bytes;
          _isFromCamera = true;
          _uploading = false;
        });
        await _analyzeImage(bytes);
      } else {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureWithCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 800);
    if (file == null) return;

    setState(() => _uploading = true);
    final bytes = await file.readAsBytes();

    // 🚚 OFF-LOAD TO DATABASE IMMEDIATELY
    final tempId = await DatabaseService.uploadTempImage(bytes);

    // 🩹 Save ID to disk to survive refresh
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_story_doc_id', tempId);
    await prefs.setBool('temp_story_active', true);

    if (mounted) {
      setState(() {
        _imageBytes = bytes;
        _uploading = false;
        _isFromCamera = true;
      });
      await _analyzeImage(bytes);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 30, maxWidth: 800);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _analysis = null;
      _isFromCamera = false;
    });
    await _analyzeImage(bytes);
  }

  Future<void> _analyzeImage(Uint8List bytes) async {
    if (!_isFromCamera) {
      setState(() {
        _analysis = {
          'score': 15,
          'sdg_goals': [],
          'reason': 'Gallery upload skipped AI analysis. 15 points awarded.'
        };
        _analyzing = false;
      });
      return;
    }
    setState(() => _analyzing = true);
    try {
      final result = await GeminiService.instance.scoreSdgPostFromBytes(bytes);
      setState(() {
        _analysis = result;
        _analyzing = false;
      });
    } catch (_) {
      setState(() {
        _analysis = {
          'score': 20,
          'sdg_goals': [],
          'reason': 'Could not analyze — 20 points awarded.'
        };
        _analyzing = false;
      });
    }
  }

  Future<void> _publishStory() async {
    final uid = AuthService.currentUserId;
    if (uid == null || _imageBytes == null || _analysis == null) {
      print(
          '⚠️ Story publish aborted: Missing data (uid: $uid, bytes: ${_imageBytes != null}, analysis: ${_analysis != null})');
      return;
    }

    setState(() => _uploading = true);
    print('📦 Attempting to publish story for user: $uid');

    try {
      final score = (_analysis!['score'] as num?)?.toInt() ?? 0;
      final goals = List<int>.from(_analysis!['sdg_goals'] ?? []);
      final reason = _analysis!['reason'] as String? ?? '';
      final points = (score * 0.7).round();

      print('🚀 Calling DatabaseService.createStory (points: $points)...');
      setState(() => _uploadStatus = '📂 Preparing upload...');
      await DatabaseService.createStory(
        userId: uid,
        userDisplayName: AuthService.currentUser?.displayName ?? 'You',
        userPhotoURL: AuthService.currentUser?.photoURL ?? '',
        imageBytes: _imageBytes!,
        caption: _captionCtrl.text.trim(),
        sdgGoals: goals,
        pointsAwarded: points,
        aiReason: reason,
        onStatusChanged: (status) => setState(() => _uploadStatus = status),
      );

      print('✅ Story published successfully!');

      // 🧼 CLEAN THE DISK & DATABASE
      final prefs = await SharedPreferences.getInstance();
      final tempId = prefs.getString('temp_story_doc_id');
      if (tempId != null) await DatabaseService.deleteTempImage(tempId);

      await prefs.remove('temp_story_doc_id');
      await prefs.remove('temp_story_caption');
      await prefs.remove('temp_story_active');
      await prefs.remove('temp_story_bytes');

      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🌟 Story published! +$points SDG points earned'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        context.go('/home');
      }
    } catch (e, stack) {
      print('❌ ERROR PUBLISHING STORY: $e');
      print(stack);
      if (mounted) {
        setState(() {
          _uploading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = (_analysis?['score'] as num?)?.toInt() ?? 0;
    final goals = List<int>.from(_analysis?['sdg_goals'] ?? []);
    final reason = _analysis?['reason'] as String?;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('📸 Create Story'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          if (_imageBytes != null && _analysis != null && !_uploading)
            TextButton(
                onPressed: _publishStory,
                child: const Text('Publish',
                    style: TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.w800))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Camera options
          if (_imageBytes == null) ...[
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.surfaceVariant, width: 1.5),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📸', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    const Text('Share your SDG impact moment',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                        'AI will analyze your photo and award\nSDG impact points!',
                        style: TextStyle(color: AppTheme.onSurfaceMuted),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton.icon(
                        onPressed: _captureWithCamera,
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: const Text('Open Camera'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library_rounded),
                        label: const Text('Gallery'),
                      ),
                    ]),
                  ]),
            ),
          ] else ...[
            // Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(_imageBytes!,
                  height: 280, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Row(children: [
              OutlinedButton.icon(
                  onPressed: _captureWithCamera,
                  icon: const Icon(Icons.camera_alt_rounded, size: 16),
                  label: const Text('Retake')),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_rounded, size: 16),
                  label: const Text('Change')),
            ]),
          ],
          const SizedBox(height: 20),

          // AI Analysis panel
          if (_analyzing) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16)),
              child: const Row(children: [
                SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primary)),
                SizedBox(width: 14),
                Text('🤖 AI is analyzing your impact...',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ),
          ] else if (_analysis != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.secondary.withOpacity(0.05)
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('🤖 AI Analysis',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('+${(score * 0.7).round()} pts',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    if (reason != null)
                      Text(reason,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.onSurfaceMuted,
                              height: 1.4)),
                    if (goals.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                          spacing: 6,
                          children: goals.map((g) {
                            final idx = g - 1;
                            final color =
                                idx >= 0 && idx < AppTheme.sdgColors.length
                                    ? AppTheme.sdgColors[idx]
                                    : AppTheme.primary;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text('SDG $g',
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            );
                          }).toList()),
                    ],
                  ]),
            ),
          ],
          const SizedBox(height: 16),

          // Caption
          if (_imageBytes != null) ...[
            TextField(
              controller: _captionCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Caption (optional) — describe your impact...',
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            if (_uploading)
              Column(children: [
                const CircularProgressIndicator(color: AppTheme.primary),
                const SizedBox(height: 12),
                Text(
                    _uploadStatus.isEmpty
                        ? 'Uploading your story...'
                        : _uploadStatus,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 8),
                const Text('This may take a moment on slower connections.',
                    style: TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 11)),
              ])
            else if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(children: [
                  const Text('🚨 Upload Failed',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontFamily: 'monospace')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _errorMessage = null);
                        _publishStory();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  )
                ]),
              )
            else if (_analysis != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _publishStory,
                  icon: const Icon(Icons.send_rounded),
                  label: Text('Publish Story (+${(score * 0.7).round()} pts)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
          ],
        ]),
      ),
    );
  }
}
