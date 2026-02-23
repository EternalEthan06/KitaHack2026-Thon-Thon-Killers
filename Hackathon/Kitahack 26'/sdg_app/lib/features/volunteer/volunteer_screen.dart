import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/ngo_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});
  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen>
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
        title: const Text('🤝 Volunteer'),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceMuted,
          indicatorColor: AppTheme.primary,
          tabs: const [Tab(text: 'Events'), Tab(text: '📅 My Calendar')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        _EventsTab(uid: uid),
        _CalendarTab(uid: uid),
      ]),
    );
  }
}

// ── Events Tab ────────────────────────────────────────────────────────────────
class _EventsTab extends StatelessWidget {
  final String uid;
  const _EventsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VolunteerEventModel>>(
      stream: FirestoreService.watchVolunteerEvents(),
      builder: (ctx, snap) {
        if (!snap.hasData)
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        if (snap.data!.isEmpty)
          return const Center(
              child: Text('No upcoming events yet. Check back soon!',
                  style: TextStyle(color: AppTheme.onSurfaceMuted)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snap.data!.length,
          itemBuilder: (_, i) => _EventCard(event: snap.data![i], uid: uid),
        );
      },
    );
  }
}

// ── Event Card ────────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final VolunteerEventModel event;
  final String uid;
  const _EventCard({required this.event, required this.uid});

  @override
  Widget build(BuildContext context) {
    final registered = event.registeredUsers.contains(uid);
    final hasImage = event.imageURL.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image header
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: Stack(children: [
            if (hasImage)
              CachedNetworkImage(
                  imageUrl: event.imageURL,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _gradientHeader(),
                  errorWidget: (_, __, ___) => _gradientHeader())
            else
              _gradientHeader(),
            // NGO badge
            Positioned(
              top: 10,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(event.ngoName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            // Points badge
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('+${event.sdgPointsReward} pts on completion',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(event.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Text(event.description,
                style: const TextStyle(
                    color: AppTheme.onSurfaceMuted, fontSize: 13, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            _Detail(
                icon: Icons.calendar_today_rounded,
                text: DateFormat('EEE, d MMM yyyy').format(event.date)),
            const SizedBox(height: 4),
            _Detail(
                icon: Icons.location_on_rounded,
                text:
                    event.address.isNotEmpty ? event.address : 'Location TBA'),
            const SizedBox(height: 4),
            _Detail(
                icon: Icons.people_rounded,
                text: '${event.registeredUsers.length} registered'),
            const SizedBox(height: 10),
            // SDG Goal chips
            Wrap(
                spacing: 6,
                children: event.sdgGoals.map((g) {
                  final idx = g - 1;
                  final color = idx >= 0 && idx < AppTheme.sdgColors.length
                      ? AppTheme.sdgColors[idx]
                      : AppTheme.primary;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('SDG $g',
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  );
                }).toList()),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      registered ? AppTheme.surfaceVariant : AppTheme.primary,
                  foregroundColor:
                      registered ? AppTheme.onSurfaceMuted : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: registered ? null : () => _register(context),
                child: Text(registered
                    ? '✅ Registered — Pending Approval'
                    : 'Register to Volunteer'),
              ),
            ),
            if (!registered)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Center(
                    child: Text('Points awarded after attendance is confirmed',
                        style: const TextStyle(
                            color: AppTheme.onSurfaceMuted, fontSize: 11))),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _gradientHeader() => Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppTheme.secondary.withOpacity(0.5),
            AppTheme.primary.withOpacity(0.4)
          ]),
        ),
        child: const Center(child: Text('🤝', style: TextStyle(fontSize: 48))),
      );

  Future<void> _register(BuildContext context) async {
    final uid = AuthService.currentUserId;
    if (uid == null) return;
    // Record as pending_approval — NO points awarded yet
    await FirestoreService.registerForEvent(event.id, uid, event);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            '📋 Registration submitted! Pending NGO approval.\nPoints awarded after attendance is confirmed.'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
}

// ── My Calendar Tab ───────────────────────────────────────────────────────────
class _CalendarTab extends StatelessWidget {
  final String uid;
  const _CalendarTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty)
      return const Center(child: Text('Sign in to see your calendar'));
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.watchUserRegistrations(uid),
      builder: (ctx, snap) {
        if (!snap.hasData)
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        final registrations = snap.data!;
        if (registrations.isEmpty) return _emptyCalendar();

        // Group by month
        final grouped = <String, List<Map<String, dynamic>>>{};
        for (final r in registrations) {
          final ts = r['date'] as Timestamp?;
          final date = ts?.toDate() ?? DateTime.now();
          final key = DateFormat('MMMM yyyy').format(date);
          grouped.putIfAbsent(key, () => []).add(r);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: grouped.entries
              .map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 4),
                        child: Row(children: [
                          Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 8),
                          Text(entry.key,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                        ]),
                      ),
                      ...entry.value.map((r) => _CalendarItem(data: r)),
                      const SizedBox(height: 8),
                    ],
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _emptyCalendar() => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📅', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        const Text('No upcoming events',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('Register for events to see them here',
            style: TextStyle(color: AppTheme.onSurfaceMuted)),
      ]));
}

class _CalendarItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CalendarItem({required this.data});

  Color get _statusColor {
    switch (data['status']) {
      case 'confirmed':
        return AppTheme.primary;
      case 'completed':
        return Colors.green;
      default:
        return const Color(0xFFFFBB00);
    }
  }

  String get _statusLabel {
    switch (data['status']) {
      case 'confirmed':
        return 'Confirmed ✓';
      case 'completed':
        return 'Completed ✅';
      default:
        return 'Pending Approval ⏳';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = data['date'] as Timestamp?;
    final date = ts?.toDate() ?? DateTime.now();
    final goals = List<int>.from(data['sdgGoals'] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Date column
        Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.1),
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(DateFormat('d').format(date),
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _statusColor)),
            Text(DateFormat('MMM').format(date).toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor)),
          ]),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(data['eventTitle'] ?? '—',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(_statusLabel,
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.business_rounded,
                    size: 12, color: AppTheme.onSurfaceMuted),
                const SizedBox(width: 4),
                Text(data['ngoName'] ?? '—',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.onSurfaceMuted)),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.location_on_rounded,
                    size: 12, color: AppTheme.onSurfaceMuted),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(data['address'] ?? 'TBA',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.onSurfaceMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
              if (data['status'] == 'pending_approval') ...[
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.stars_rounded, size: 12, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text('+${data['sdgPointsReward'] ?? 0} pts on confirmation',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600)),
                ]),
              ],
              if (goals.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                    spacing: 4,
                    children: goals.take(3).map((g) {
                      final idx = g - 1;
                      final color = idx >= 0 && idx < AppTheme.sdgColors.length
                          ? AppTheme.sdgColors[idx]
                          : AppTheme.primary;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('SDG $g',
                            style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      );
                    }).toList()),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Detail({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 14, color: AppTheme.onSurfaceMuted),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.onSurfaceMuted))),
      ]);
}
