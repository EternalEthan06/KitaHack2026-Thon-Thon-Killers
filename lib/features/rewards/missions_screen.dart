import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/ngo_model.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../feed/daily_task_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── T&C per reward type ───────────────────────────────────────────────────────
const _tnc = {
  'voucher': [
    '✅ Valid for 30 days from date of redemption',
    '✅ Single-use only — cannot be split or reused',
    '✅ Delivered to your registered email within 3 business days',
    '❌ Non-transferable and non-exchangeable for cash',
    '❌ Cannot be combined with other promotions',
    'ℹ️ Subject to availability. EcoRise reserves the right to substitute with an equivalent voucher.',
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
    '✅ Visible to all EcoRise users',
    '✅ Permanently associated with your account',
    '❌ Non-transferable to other accounts',
    '❌ Cannot be resold or exchanged',
    'ℹ️ Badge appearance may be updated in future app versions',
  ],
};

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});
  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen>
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
        title: const Text('🎯 Missions & Rewards'),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceMuted,
          indicatorColor: AppTheme.primary,
          tabs: const [Tab(text: 'Missions'), Tab(text: 'My Items')],
        ),
      ),
      body: StreamBuilder<UserModel?>(
        stream: DatabaseService.watchCurrentUser(),
        builder: (ctx, userSnap) {
          final user = userSnap.data;
          return TabBarView(
            controller: _tab,
            children: [
              _MissionsTab(user: user),
              _MyRewardsTab(uid: uid),
            ],
          );
        },
      ),
    );
  }
}

class _MissionsTab extends StatelessWidget {
  final UserModel? user;
  const _MissionsTab({this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Daily Task Section
        const DailyTaskWidget(),

        // Points Balance
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceVariant),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars_rounded,
                  color: AppTheme.primary, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Balance',
                      style: TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 12)),
                  Text('${user?.sdgScore ?? 0} SDG points',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                ],
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('🎁 Redeem Rewards',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        // Rewards Section
        StreamBuilder<List<RewardModel>>(
          stream: DatabaseService.watchRewards(),
          builder: (context, snap) {
            if (!snap.hasData)
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator()));
            final rewards = snap.data!;
            return Column(
              children: rewards
                  .map((r) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _RewardCard(reward: r, user: user),
                      ))
                  .toList(),
            );
          },
        ),
      ],
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
        ClipRRect(
          borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(18)),
          child: SizedBox(
            width: 100,
            height: 100,
            child: reward.imageURL.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: reward.imageURL,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: _accent.withOpacity(0.15),
                    child: Center(
                        child: Text(_emoji,
                            style: const TextStyle(fontSize: 32)))),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(reward.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13))),
                  GestureDetector(
                    onTap: () => _showTnc(context),
                    child: const Icon(Icons.info_outline,
                        size: 16, color: AppTheme.onSurfaceMuted),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(reward.description,
                    style: const TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(children: [
                  Text('🌱 ${reward.costInScore} pts',
                      style: TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  const Spacer(),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: canAfford ? () => _redeem(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canAfford ? _accent : AppTheme.surfaceVariant,
                        foregroundColor:
                            canAfford ? Colors.white : AppTheme.onSurfaceMuted,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(canAfford ? 'Redeem' : 'Locked',
                          style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                ]),
              ],
            ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms & Conditions',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...terms.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $t', style: const TextStyle(fontSize: 13)))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _redeem(BuildContext context) async {
    final uid = AuthService.currentUserId;
    if (uid == null) return;
    final u = await DatabaseService.getUser(uid);
    if (u == null) return;
    final success = await DatabaseService.redeemReward(uid, reward, u.sdgScore);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            success ? '🎉 Redeemed! Status: Pending' : '❌ Not enough points'),
        backgroundColor: success ? AppTheme.primary : AppTheme.error,
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
    if (uid.isEmpty) return const Center(child: Text('Sign in to see rewards'));
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService.watchUserRedemptions(uid),
      builder: (ctx, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final items = snap.data!;
        if (items.isEmpty) return const Center(child: Text('No rewards yet'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, i) => _HistoryCard(data: items[i]),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _HistoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final val = data['redeemedAt'];
    DateTime? date;
    if (val is Timestamp)
      date = val.toDate();
    else if (val is int) date = DateTime.fromMillisecondsSinceEpoch(val);

    final dateStr =
        date != null ? '${date.day}/${date.month}/${date.year}' : '—';
    final isPending = data['status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceVariant)),
      child: Row(children: [
        const Text('🎁', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data['title'] ?? 'Reward',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(dateStr,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.onSurfaceMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: isPending
                  ? AppTheme.primary.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Text(isPending ? 'Pending' : 'Done',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isPending ? AppTheme.primary : Colors.green)),
        ),
      ]),
    );
  }
}
