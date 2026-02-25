import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/gemini_service.dart';
import '../../core/models/post_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/sdg_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? _selectedFile;
  Uint8List? _imageBytes;
  PostType _postType = PostType.sdg;
  final _captionCtrl = TextEditingController();
  bool _loading = false;
  String _status = '';
  bool _uploaded = false;
  Map<String, dynamic>? _scoreResult;
  bool _isFromCamera = false;

  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: source == ImageSource.camera ? 50 : 50,
      maxWidth: 1024,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _selectedFile = picked;
      _imageBytes = bytes;
      _scoreResult = null;
      _isFromCamera = source == ImageSource.camera;
    });
    if (_postType == PostType.sdg && _isFromCamera) {
      await _suggestCaption();
    }
  }

  Future<void> _suggestCaption() async {
    if (_imageBytes == null) return;
    final suggestion =
        await GeminiService.instance.suggestCaptionFromBytes(_imageBytes!);
    if (suggestion.isNotEmpty && mounted) {
      setState(() => _captionCtrl.text = suggestion);
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image first.')));
      return;
    }

    setState(() {
      _loading = true;
      _status = 'Uploading image...';
    });

    try {
      final uid = AuthService.currentUserId!;
      final userDoc = await DatabaseService.getUser(uid);
      if (userDoc == null) return;

      // 🛡️ UNIVERSAL SAFETY CHECK (All types, Camera & Gallery)
      setState(() => _status = 'Checking content safety...');
      final safe =
          await GeminiService.instance.isImageSafeFromBytes(_imageBytes!);
      if (!safe) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'This image is not appropriate for our family-friendly platform.')));
        }
        setState(() {
          _loading = false;
          _status = '';
        });
        return;
      }

      // 🧪 SDG Analysis (from both Camera and Gallery)
      setState(() => _status = '🤖 Analysing SDG impact with Gemini AI...');
      final authUser = AuthService.currentUser;
      final post = await DatabaseService.createPostFromBytes(
        imageBytes: _imageBytes!,
        fileName: _selectedFile!.name,
        caption: _captionCtrl.text,
        type: PostType.sdg,
        author: userDoc.copyWith(
          displayName: (authUser?.displayName != null &&
                  authUser!.displayName!.isNotEmpty)
              ? authUser.displayName
              : userDoc.displayName,
          photoURL:
              (authUser?.photoURL != null && authUser!.photoURL!.isNotEmpty)
                  ? authUser.photoURL
                  : userDoc.photoURL,
        ),
      );

      if (_isFromCamera) {
        final result =
            await GeminiService.instance.scoreSdgPostFromBytes(_imageBytes!);

        // We accept ALL valid posts as long as they are safe.
        // If it's not SDG related, they just get 0 points.

        await DatabaseService.updatePostScore(
          postId: post.id,
          userId: uid,
          score: result['score'] ?? 0,
          sdgGoals: List<int>.from(result['sdg_goals'] ?? []),
          aiReason: result['reason'] ?? '',
          isAccepted: true, // Always accept (let them see their post)
        );

        setState(() {
          _scoreResult = result;
        });
      } else {
        // Zero points for gallery upload
        await DatabaseService.updatePostScore(
          postId: post.id,
          userId: uid,
          score: 0,
          sdgGoals: [],
          aiReason: 'Gallery upload. No points awarded (Live proof required).',
          isAccepted: true,
        );
        setState(() {
          _scoreResult = {
            'score': 0,
            'reason':
                'Gallery upload. Points are only awarded for live camera captures to ensure authenticity.',
            'sdg_goals': [],
          };
        });
      }

      setState(() {
        _uploaded = true;
        _loading = false;
        _status = '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
      setState(() {
        _loading = false;
        _status = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: SafeArea(
        child: _uploaded ? _buildResult() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Text(
              _imageBytes != null && !_isFromCamera
                  ? '⚠️ Gallery uploads do not earn SDG points. Use the Live Camera for impact points!'
                  : '🤖 Gemini AI will analyse your photo and give you an SDG Impact Score!',
              style: TextStyle(
                  color: _imageBytes != null && !_isFromCamera
                      ? Colors.orangeAccent
                      : AppTheme.primary,
                  fontSize: 13,
                  fontWeight: _imageBytes != null && !_isFromCamera
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
          ),

          const SizedBox(height: 20),

          // Image picker
          GestureDetector(
            onTap: () => _showPickerSheet(),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3), width: 1.5),
              ),
              clipBehavior: Clip.hardEdge,
              child: _imageBytes == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_rounded,
                            size: 48, color: AppTheme.onSurfaceMuted),
                        const SizedBox(height: 8),
                        Text('Tap to add photo',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.onSurfaceMuted)),
                      ],
                    )
                  : Image.memory(_imageBytes!, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 16),

          // Caption
          TextField(
            controller: _captionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'Write a caption (Gemini will suggest one for SDG posts)...',
            ),
          ),

          const SizedBox(height: 24),

          if (_loading) ...[
            const LinearProgressIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.surfaceVariant),
            const SizedBox(height: 10),
            Center(
                child: Text(_status,
                    style: const TextStyle(
                        color: AppTheme.primary, fontSize: 13))),
            const SizedBox(height: 16),
          ],

          SdgButton.primary(
            label: _loading ? 'Posting...' : 'Post 🚀',
            onPressed: _loading ? null : _upload,
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final score = _scoreResult?['score'] ?? 0;
    final reason = _scoreResult?['reason'] ?? '';
    final sdgGoals = List<int>.from(_scoreResult?['sdg_goals'] ?? []);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Post Shared!',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            if (_postType == PostType.sdg && _scoreResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTheme.primary.withOpacity(0.2),
                    AppTheme.secondary.withOpacity(0.1)
                  ]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Column(children: [
                  Text('SDG Impact Score',
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 6),
                  Text('+$score pts',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: AppTheme.primary)),
                  if (sdgGoals.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: sdgGoals
                          .map((g) => Chip(
                                label: Text('SDG $g',
                                    style: const TextStyle(fontSize: 11)),
                                backgroundColor:
                                    AppTheme.primary.withOpacity(0.15),
                                side: BorderSide.none,
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  ],
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(reason,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center),
                  ],
                ]),
              ),
            ],
            const SizedBox(height: 24),
            SdgButton.primary(
                label: 'Back to Feed', onPressed: () => context.go('/home')),
          ],
        ),
      ),
    );
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppTheme.secondary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
