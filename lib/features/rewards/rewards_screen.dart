import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/ngo_model.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';

// ── T&C per reward type ───────────────────────────────────────────────────────
const _tnc = {
  'voucher': [
    '✅ Valid for 30 days from date of redemption',
    '✅ Single-use only — cannot be split or reused',
    '✅ Delivered to your registered email within 3 business days',
    '❌ Non-transferable and non-exchangeable for cash',
    '❌ Cannot be combined with other promotions',
    'ℹ️ Subject to availability. SDG Connect reserves the right to substitute with an equivalent voucher.',
  ],
  'tree': [
    '✅ Tree planted in Borneo within 14 days of redemption',
    '✅ Digital planting certificate emailed to you',
    '✅ GPS coordinates of your tree provided',
    'ℹ️ Species: Dipterocarp or Mangrove (subject to site conditions)',
    'ℹ️ Planted in partnership with certified reforestation NGOs',
    '❌ Physical tree cannot be claimed or relocated',
  ],
  'badge': [
    '✅ Badge unlocked immediately on your profile',
    '✅ Visible to all SDG Connect users',
    '✅ Permanently associated with your account',
    '❌ Non-transferable to other accounts',
    '❌ Cannot be resold or exchanged',
    'ℹ️ Badge appearance may be updated in future app versions',
  ],
};

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUserId ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 Rewards'),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceMuted,
          indicatorColor: AppTheme.primary,
          tabs: const [Tab(text: 'Browse'), Tab(text: 'My Rewards')],
        ),
      ),
      body: StreamBuilder<UserModel?>(
        stream: FirestoreService.watchCurrentUser(),
        builder: (ctx, userSnap) {
          final user = userSnap.data;
          return Column(children: [
            // Points balance bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.primary.withOpacity(0.15),
                  AppTheme.secondary.withOpacity(0.08)
                ]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
              ),
              child: Row(children: [
                const Icon(Icons.stars_rounded,
                    color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Text('Balance: ',
                    style: TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 13)),
                Text('${user?.sdgScore ?? 0} SDG pts',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('🌱 Earn by posting!',
                    style: TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 11)),
              ]),
            ),
            Expanded(
              child: TabBarView(controller: _tab, children: [
                _BrowseTab(user: user),
                _MyRewardsTab(uid: uid),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}

// ── Browse Tab ────────────────────────────────────────────────────────────────
class _BrowseTab extends StatelessWidget {
  final UserModel? user;
  const _BrowseTab({this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RewardModel>>(
      stream: FirestoreService.watchRewards(),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        final rewards = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: rewards.length,
          itemBuilder: (_, i) => _RewardCard(reward: rewards[i], user: user),
        );
      },
    );
  }
}

// ── Reward Card ───────────────────────────────────────────────────────────────
class _RewardCard extends StatelessWidget {
  final RewardModel reward;
  final UserModel? user;
  const _RewardCard({required this.reward, this.user});

  String get _emoji {
    switch (reward.type) {
      case 'tree':
        return '🌳';
      case 'badge':
        return '🏆';
      default:
        return '🎟️';
    }
  }

  Color get _accent {
    switch (reward.type) {
      case 'tree':
        return AppTheme.primary;
      case 'badge':
        return const Color(0xFFFFBB00);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = (user?.sdgScore ?? 0) >= reward.costInScore;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image / emoji square
        ClipRRect(
          borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(18)),
          child: SizedBox(
            width: 110,
            height: 110,
            child: reward.imageURL.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: reward.imageURL,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        color: AppTheme.surfaceVariant,
                        child: Center(
                            child: Text(_emoji,
                                style: const TextStyle(fontSize: 32)))),
                    errorWidget: (_, __, ___) => Container(
                        color: _accent.withOpacity(0.15),
                        child: Center(
                            child: Text(_emoji,
                                style: const TextStyle(fontSize: 32)))))
                : Container(
                    color: _accent.withOpacity(0.15),
                    child: Center(
                        child: Text(_emoji,
                            style: const TextStyle(fontSize: 36)))),
          ),
        ),
        // Details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(reward.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14))),
                // T&C button
                GestureDetector(
                  onTap: () => _showTnc(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.onSurfaceMuted.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('T&C',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.onSurfaceMuted)),
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Text(reward.description,
                  style: const TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 12,
                      height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('🌱 ${reward.costInScore} pts',
                      style: TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
                const Spacer(),
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canAfford ? _accent : AppTheme.surfaceVariant,
                      foregroundColor:
                          canAfford ? Colors.white : AppTheme.onSurfaceMuted,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    onPressed: canAfford ? () => _redeem(context) : null,
                    child: Text(canAfford ? 'Redeem' : 'Need more pts'),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }

  void _showTnc(BuildContext context) {
    final terms = _tnc[reward.type] ?? _tnc['voucher']!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Terms & Conditions — ${reward.title}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 14),
              ...terms.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(t,
                        style: const TextStyle(fontSize: 13, height: 1.4)),
                  )),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 6),
              const Text(
                  'By redeeming, you agree to these terms. SDG Connect reserves the right to amend these terms without prior notice.',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurfaceMuted,
                      height: 1.4)),
            ]),
      ),
    );
  }

  Future<void> _redeem(BuildContext context) async {
    final uid = AuthService.currentUserId;
    if (uid == null) return;
    final u = await FirestoreService.getUser(uid);
    if (u == null) return;
    final success =
        await FirestoreService.redeemReward(uid, reward, u.sdgScore);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? '🎉 Redeemed! Check your email for delivery.'
            : '❌ Not enough SDG points.'),
        backgroundColor: success ? AppTheme.primary : AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
}

// ── My Rewards Tab ────────────────────────────────────────────────────────────
class _MyRewardsTab extends StatelessWidget {
  final String uid;
  const _MyRewardsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty)
      return const Center(child: Text('Please sign in to view your rewards'));
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.watchUserRedemptions(uid),
      builder: (ctx, snap) {
        if (!snap.hasData)
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        final items = snap.data!;
        if (items.isEmpty) return _emptyState();
        final ongoing = items.where((r) => r['status'] == 'pending').toList();
        final history = items.where((r) => r['status'] != 'pending').toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (ongoing.isNotEmpty) ...[
              _sectionLabel('⏳ Processing'),
              ...ongoing.map((r) => _HistoryCard(data: r)),
              const SizedBox(height: 16),
            ],
            if (history.isNotEmpty) ...[
              _sectionLabel('✅ Delivered'),
              ...history.map((r) => _HistoryCard(data: r)),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.onSurfaceMuted)),
      );

  Widget _emptyState() => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎁', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        const Text('No rewards yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('Redeem your SDG points for rewards!',
            style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 13)),
      ]));
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _HistoryCard({required this.data});

  String get _emoji {
    switch (data['type']) {
      case 'tree':
        return '🌳';
      case 'badge':
        return '🏆';
      default:
        return '🎟️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = data['redeemedAt'] as Timestamp?;
    final date = ts?.toDate();
    final dateStr =
        date != null ? '${date.day}/${date.month}/${date.year}' : '—';
    final isPending = data['status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isPending
                ? AppTheme.primary.withOpacity(0.3)
                : AppTheme.surfaceVariant),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12)),
          child:
              Center(child: Text(_emoji, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data['title'] ?? '—',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 2),
          Text('Redeemed on $dateStr · ${data['costInScore'] ?? 0} pts',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.onSurfaceMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPending
                ? AppTheme.primary.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isPending ? 'Pending' : 'Delivered',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isPending ? AppTheme.primary : Colors.green),
          ),
        ),
      ]),
    );
  }
}
