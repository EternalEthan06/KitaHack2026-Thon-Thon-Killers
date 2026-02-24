import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/ngo_model.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});
  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  String? _selectedNgoFilter;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: StreamBuilder<UserModel?>(
        stream: DatabaseService.watchCurrentUser(),
        builder: (ctx, userSnap) {
          final user = userSnap.data;
          return StreamBuilder<List<DonationProject>>(
            stream: DatabaseService.watchDonationProjects(),
            builder: (ctx, snap) {
              final allProjects = snap.data ?? [];
              // Distinct NGO names for filter
              final ngoNames =
                  allProjects.map((p) => p.ngoName).toSet().toList()..sort();
              final filtered = _selectedNgoFilter == null
                  ? allProjects
                  : allProjects
                      .where((p) => p.ngoName == _selectedNgoFilter)
                      .toList();

              return CustomScrollView(
                controller: _scrollController,
                primary: false,
                slivers: [
                  // ── App Bar ─────────────────────────────────────────────
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: AppTheme.background,
                    expandedHeight: 120,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text('❤️ Donate',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFF4D6A).withOpacity(0.15),
                              AppTheme.background
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Impact header ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFFFF4D6A).withOpacity(0.1),
                          AppTheme.primary.withOpacity(0.08)
                        ]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFFF4D6A).withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        Expanded(
                            child: _stat('${allProjects.length}',
                                'Active\nProjects', const Color(0xFFFF4D6A))),
                        Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.surfaceVariant),
                        Expanded(
                            child: _stat('${user?.sdgScore ?? 0}',
                                'Your SDG\nPoints', AppTheme.primary)),
                        Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.surfaceVariant),
                        Expanded(
                            child: _stat(
                                '4', 'NGOs\nSupported', AppTheme.secondary)),
                      ]),
                    ),
                  ),

                  // ── NGO Filter chips ─────────────────────────────────────
                  if (ngoNames.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _FilterChip(
                                label: 'All',
                                selected: _selectedNgoFilter == null,
                                onTap: () =>
                                    setState(() => _selectedNgoFilter = null)),
                            ...ngoNames.map((name) => _FilterChip(
                                  label: name.split(' ').first, // short name
                                  selected: _selectedNgoFilter == name,
                                  onTap: () => setState(() =>
                                      _selectedNgoFilter =
                                          _selectedNgoFilter == name
                                              ? null
                                              : name),
                                )),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // ── Projects list ────────────────────────────────────────
                  if (snap.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFF4D6A))))
                  else if (filtered.isEmpty)
                    SliverFillRemaining(
                        child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('❤️', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No active projects',
                            style: TextStyle(
                                color: AppTheme.onSurfaceMuted, fontSize: 15)),
                      ]),
                    ))
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _ProjectCard(project: filtered[i], user: user),
                        childCount: filtered.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _stat(String value, String label, Color color) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 10),
            textAlign: TextAlign.center),
      ]);
}

// ────────────────────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final DonationProject project;
  final UserModel? user;
  const _ProjectCard({required this.project, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(children: [
              CachedNetworkImage(
                imageUrl: project.imageURL,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(height: 170, color: AppTheme.surfaceVariant),
                errorWidget: (_, __, ___) => Container(
                    height: 170,
                    color: AppTheme.surfaceVariant,
                    child: const Center(
                        child: Text('🌱', style: TextStyle(fontSize: 48)))),
              ),
              // NGO badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(project.ngoName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              // SDG tags
              Positioned(
                bottom: 12,
                left: 12,
                child: Wrap(
                    spacing: 4,
                    children: project.sdgGoals.take(3).map((g) {
                      final idx = g - 1;
                      final color = idx < AppTheme.sdgColors.length
                          ? AppTheme.sdgColors[idx]
                          : AppTheme.primary;
                      final icon = idx < AppConstants.sdgIcons.length
                          ? AppConstants.sdgIcons[idx]
                          : '🌱';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withOpacity(0.8))),
                        child: Text('$icon $g',
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      );
                    }).toList()),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(project.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 6),
              Text(project.description,
                  style: const TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 13,
                      height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),

              const SizedBox(height: 12),

              // ── Needed items ─────────────────────────────────────────
              const Text('What\'s needed:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: project.neededItems
                      .map((item) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: AppTheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text('• $item',
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.onSurface)),
                          ))
                      .toList()),

              const SizedBox(height: 14),

              // ── Money progress ────────────────────────────────────────
              _ProgressBar(
                label: 'RM Fundraising',
                raised: project.raisedAmount,
                target: project.targetAmount,
                progress: project.moneyProgress,
                color: const Color(0xFFFF4D6A),
                formatRaised: 'RM ${project.raisedAmount.toStringAsFixed(0)}',
                formatTarget: 'RM ${project.targetAmount.toStringAsFixed(0)}',
              ),

              const SizedBox(height: 10),

              // ── Points progress ───────────────────────────────────────
              _ProgressBar(
                label: 'SDG Points',
                raised: project.raisedPoints.toDouble(),
                target: project.targetPoints.toDouble(),
                progress: project.pointsProgress,
                color: AppTheme.primary,
                formatRaised: '${project.raisedPoints} pts',
                formatTarget: '${project.targetPoints} pts',
              ),

              const SizedBox(height: 14),

              // ── Donate buttons ────────────────────────────────────────
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                  onPressed: () => _showDonateDialog(context, mode: 'points'),
                  icon: const Icon(Icons.stars_rounded, size: 16),
                  label: const Text('Donate Points'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                  onPressed: () => _showDonateDialog(context, mode: 'money'),
                  icon: const Icon(Icons.favorite_rounded, size: 16),
                  label: const Text('Donate RM'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D6A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                )),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  void _showDonateDialog(BuildContext context, {required String mode}) {
    final ctrl = TextEditingController();
    final msgCtrl = TextEditingController();
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
          builder: (ctx, setS) => Padding(
                padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                          child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: AppTheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 20),
                      Text(
                          mode == 'money'
                              ? '❤️ Donate Money'
                              : '⭐ Donate Points',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(project.title,
                          style: const TextStyle(
                              color: AppTheme.onSurfaceMuted, fontSize: 13)),
                      const SizedBox(height: 20),
                      if (mode == 'points' && user != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            const Icon(Icons.stars_rounded,
                                color: AppTheme.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                                'You have ${user!.sdgScore} SDG points available',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ]),
                        ),
                      if (mode == 'points' && user != null)
                        const SizedBox(height: 14),
                      TextField(
                        controller: ctrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: mode == 'money'
                              ? 'Amount (RM)'
                              : 'Points to donate',
                          prefixText: mode == 'money' ? 'RM ' : '',
                          suffixText: mode == 'points' ? 'pts' : '',
                          hintText: mode == 'money' ? 'e.g. 20.00' : 'e.g. 100',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (mode == 'money')
                        TextField(
                          controller: msgCtrl,
                          decoration: InputDecoration(
                            labelText: 'Message (optional)',
                            hintText: 'Leave a note of support...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      if (mode == 'money') const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () async {
                                  final uid = AuthService.currentUserId;
                                  if (uid == null) return;
                                  setS(() => loading = true);
                                  try {
                                    if (mode == 'money') {
                                      final amt = double.tryParse(ctrl.text);
                                      if (amt == null || amt <= 0) return;
                                      await DatabaseService
                                          .donateMoneyToProject(
                                              userId: uid,
                                              project: project,
                                              amount: amt,
                                              message: msgCtrl.text);
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                        _showThanks(context,
                                            'RM ${amt.toStringAsFixed(2)} donated! You earned ${(amt * 10).round().clamp(10, 100)} bonus SDG points. 🎉');
                                      }
                                    } else {
                                      final pts = int.tryParse(ctrl.text);
                                      if (pts == null || pts <= 0) return;
                                      final success = await DatabaseService
                                          .donatePointsToProject(
                                              userId: uid,
                                              project: project,
                                              points: pts,
                                              userCurrentScore:
                                                  user?.sdgScore ?? 0);
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                        _showThanks(
                                            context,
                                            success
                                                ? '$pts SDG points donated! Thank you! 🌱'
                                                : '❌ Not enough SDG points.');
                                      }
                                    }
                                  } finally {
                                    setS(() => loading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mode == 'money'
                                ? const Color(0xFFFF4D6A)
                                : AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            textStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text(mode == 'money'
                                  ? 'Donate Now ❤️'
                                  : 'Donate Points ⭐'),
                        ),
                      ),
                    ]),
              )),
    );
  }

  void _showThanks(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ));
  }
}

// ── Progress Bar Helper ──────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final String label;
  final double raised;
  final double target;
  final double progress;
  final Color color;
  final String formatRaised;
  final String formatTarget;

  const _ProgressBar(
      {required this.label,
      required this.raised,
      required this.target,
      required this.progress,
      required this.color,
      required this.formatRaised,
      required this.formatTarget});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceMuted)),
        const Spacer(),
        Text('$formatRaised / $formatTarget',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
        ),
      ),
      const SizedBox(height: 3),
      Text('${(progress * 100).toStringAsFixed(0)}% funded',
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ── Filter Chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF4D6A).withOpacity(0.15)
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? const Color(0xFFFF4D6A) : Colors.transparent,
              width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFFFF4D6A)
                    : AppTheme.onSurfaceMuted)),
      ),
    );
  }
}
