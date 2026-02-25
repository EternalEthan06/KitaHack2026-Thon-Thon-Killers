import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/daily_task_model.dart';
import '../../core/models/user_model.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/gemini_service.dart';
import '../../core/theme/app_theme.dart';

class DailyTaskWidget extends StatefulWidget {
  const DailyTaskWidget({super.key});

  @override
  State<DailyTaskWidget> createState() => _DailyTaskWidgetState();
}

class _DailyTaskWidgetState extends State<DailyTaskWidget> {
  DailyTaskModel? _task;
  bool _loading = true;
  bool _verifying = false;
  String? _aiFeedback;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    final task = await DatabaseService.getDailyTask();
    if (mounted) {
      setState(() {
        _task = task;
        _loading = false;
        _aiFeedback = null;
      });
    }
  }

  Future<void> _regenerate() async {
    setState(() => _loading = true);
    final task = await DatabaseService.regenerateDailyTask();
    if (mounted) {
      setState(() {
        _task = task;
        _loading = false;
        _aiFeedback = null;
      });
    }
  }

  Future<void> _pickAndVerify() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 50,
    );
    if (picked == null) return;

    setState(() {
      _verifying = true;
      _aiFeedback = '🤖 AI is checking your proof...';
    });

    try {
      final bytes = await picked.readAsBytes();
      final result = await GeminiService.instance.verifyDailyTask(
        taskDescription: _task!.description,
        imageBytes: bytes,
      );

      final isCorrect = result['isCorrect'] as bool? ?? false;
      final reason = result['reason'] as String? ?? 'AI verification failed.';

      if (isCorrect) {
        await DatabaseService.completeDailyTask(_task!);
        await _loadTask();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Mission Accomplished! Points awarded.'),
              backgroundColor: AppTheme.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _aiFeedback = '❌ $reason';
            _verifying = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiFeedback = '❌ Verification error. Try again.';
          _verifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_task == null) return const SizedBox();

    return StreamBuilder<UserModel?>(
      stream: DatabaseService.watchCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final streak = user?.streak ?? 0;
        final multiplier = DatabaseService.calculateMultiplier(streak);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _task!.isCompleted
                  ? [AppTheme.surface, AppTheme.surface]
                  : [
                      AppTheme.primary.withOpacity(0.12),
                      AppTheme.secondary.withOpacity(0.04)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _task!.isCompleted
                  ? AppTheme.surfaceVariant
                  : AppTheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _task!.isCompleted
                                ? Colors.grey.withOpacity(0.2)
                                : AppTheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '☀️ DAILY MISSION',
                            style: TextStyle(
                              color: _task!.isCompleted
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (multiplier > 1.0)
                          Text(
                            '🔥 x${multiplier.toStringAsFixed(1)} Bonus',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const Spacer(),
                        if (!_task!.isCompleted && !_verifying)
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded,
                                size: 18, color: AppTheme.onSurfaceMuted),
                            onPressed: _regenerate,
                            tooltip: 'Generate new task',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _task!.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _task!.description,
                      style: const TextStyle(
                        color: AppTheme.onSurfaceMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    if (_aiFeedback != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 14, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _aiFeedback!,
                                style: TextStyle(
                                  color: _aiFeedback!.startsWith('❌')
                                      ? Colors.redAccent
                                      : AppTheme.primary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Wrap(
                          spacing: 6,
                          children: _task!.sdgGoals.map((g) {
                            final idx = g - 1;
                            final color =
                                idx >= 0 && idx < AppTheme.sdgColors.length
                                    ? AppTheme.sdgColors[idx]
                                    : AppTheme.primary;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'SDG $g',
                                style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        ),
                        const Spacer(),
                        if (_task!.isCompleted)
                          const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: AppTheme.primary, size: 20),
                              SizedBox(width: 6),
                              Text('Done',
                                  style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: _verifying ? null : _pickAndVerify,
                            icon: _verifying
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.black))
                                : const Icon(Icons.camera_alt_rounded,
                                    size: 16),
                            label: Text(_verifying
                                ? 'Verifying...'
                                : 'Complete (+${(_task!.points * multiplier).round()} pts)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
