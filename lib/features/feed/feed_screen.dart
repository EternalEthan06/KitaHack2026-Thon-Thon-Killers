import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/post_model.dart';
import '../../core/models/ngo_model.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/post_card.dart';
import 'story_bar.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedSdgFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: DatabaseService.watchCurrentUser(),
      builder: (context, userSnap) {
        final user = userSnap.data;
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppTheme.background,
                elevation: 0,
                title: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🌱', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  const Text('SDG Connect',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.5)),
                ]),
                actions: [
                  if (user != null)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.stars_rounded,
                            color: AppTheme.primary, size: 14),
                        const SizedBox(width: 4),
                        Text('${user.sdgScore}',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  IconButton(
                    icon: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppTheme.surfaceVariant,
                      backgroundImage:
                          (user != null && user.photoURL.isNotEmpty)
                              ? NetworkImage(user.photoURL)
                              : null,
                      child: (user == null || user.photoURL.isEmpty)
                          ? Text(
                              (user != null && user.displayName.isNotEmpty)
                                  ? user.displayName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary))
                          : null,
                    ),
                    onPressed: () =>
                        context.push('/profile/${AuthService.currentUserId}'),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(44),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: AppTheme.surfaceVariant, width: 0.5))),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppTheme.primary,
                      indicatorWeight: 2.5,
                      labelColor: AppTheme.onBackground,
                      unselectedLabelColor: AppTheme.onSurfaceMuted,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'For You'),
                        Tab(text: '🌱 SDG Posts')
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _ForYouTab(),
                _SdgPostList(
                    selectedFilter: _selectedSdgFilter,
                    onFilterChanged: (v) =>
                        setState(() => _selectedSdgFilter = v)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── For You Tab: stories + posts (left) + sidebar (right on wide screens) ─────
class _ForYouTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 720;
        if (isWide) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Posts + stories
            Expanded(child: _PostList(stream: DatabaseService.watchFeed())),
            // Sidebar
            SizedBox(width: 300, child: _FeedSidebar()),
          ]);
        }
        return _PostList(stream: DatabaseService.watchFeed());
      },
    );
  }
}

// ── SDG Post List ─────────────────────────────────────────────────────────────
class _SdgPostList extends StatelessWidget {
  final int? selectedFilter;
  final ValueChanged<int?> onFilterChanged;
  const _SdgPostList(
      {required this.selectedFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: DatabaseService.watchSdgFeed(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('❌ SDG Feed Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ),
            ],
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.primary)),
                ),
              ),
            ],
          );
        }
        final allPosts = snapshot.data ?? [];
        final posts = selectedFilter == null
            ? allPosts
            : allPosts
                .where((p) => p.sdgGoals.contains(selectedFilter))
                .toList();
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemCount: AppConstants.sdgGoals.length + 1,
                itemBuilder: (ctx, i) {
                  if (i == 0)
                    return _FilterChip(
                        label: 'All',
                        icon: '🌍',
                        color: AppTheme.primary,
                        selected: selectedFilter == null,
                        onTap: () => onFilterChanged(null));
                  final g = i;
                  final idx = g - 1;
                  final color = idx < AppTheme.sdgColors.length
                      ? AppTheme.sdgColors[idx]
                      : AppTheme.primary;
                  final icon = idx < AppConstants.sdgIcons.length
                      ? AppConstants.sdgIcons[idx]
                      : '🌱';
                  return _FilterChip(
                      label: 'SDG $g',
                      icon: icon,
                      color: color,
                      selected: selectedFilter == g,
                      onTap: () =>
                          onFilterChanged(selectedFilter == g ? null : g));
                },
              ),
            ),
          ),
          if (posts.isEmpty)
            SliverFillRemaining(
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  const Text('🌍', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                      selectedFilter == null
                          ? 'No SDG posts yet. Be the first!'
                          : 'No posts for SDG $selectedFilter yet.',
                      style: const TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 15)),
                ])))
          else
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (ctx, i) => PostCard(post: posts[i]),
                    childCount: posts.length)),
        ]);
      },
    );
  }
}

// ── Post List (For You) ───────────────────────────────────────────────────────
class _PostList extends StatelessWidget {
  final Stream<List<PostModel>> stream;
  const _PostList({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: Text('❌ Stream Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.primary)),
                ),
              ),
            ],
          );
        }
        final posts = snapshot.data ?? [];
        return CustomScrollView(primary: false, slivers: [
          // Stories bar
          const SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.only(top: 10), child: StoryBar())),
          const SliverToBoxAdapter(child: Divider(height: 12)),
          // Posts
          if (posts.isEmpty)
            SliverFillRemaining(
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  const Text('🌍', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  const Text('No posts yet. Be the first!',
                      style: TextStyle(
                          color: AppTheme.onSurfaceMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  const Text('Tap the 📷 button below to post',
                      style: TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 13)),
                ])))
          else
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (ctx, i) => PostCard(post: posts[i]),
                    childCount: posts.length)),
        ]);
      },
    );
  }
}

// ── Right Sidebar: Contributors + Top NGOs ────────────────────────────────────
class _FeedSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            left: BorderSide(color: AppTheme.surfaceVariant, width: 0.5)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Top Contributors ──────────────────────────────────
          _SidebarSection(
              title: '🏆 Top Contributors', child: _ContributorsList()),
          const SizedBox(height: 20),
          // ── Top NGOs ─────────────────────────────────────────
          _SidebarSection(title: '🌍 Most Active NGOs', child: _TopNGOsList()),
        ]),
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _SidebarSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: AppTheme.surfaceVariant, width: 0.5))),
          child: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ),
        const SizedBox(height: 10),
        child,
      ]);
}

class _ContributorsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService.watchTopContributors(),
      builder: (ctx, snap) {
        if (!snap.hasData)
          return const Center(
              child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.primary)));
        return Column(
          children: snap.data!.asMap().entries.map((e) {
            final rank = e.key + 1;
            final data = e.value;
            final name = data['displayName'] as String? ?? '—';
            final photo = data['photoURL'] as String? ?? '';
            final score = data['sdgScore'] as int? ?? 0;
            final uid = data['id'] as String? ?? '';
            String medal = '';
            Color rankColor = AppTheme.onSurfaceMuted;
            if (rank == 1) {
              medal = '🥇';
              rankColor = const Color(0xFFFFD700);
            } else if (rank == 2) {
              medal = '🥈';
              rankColor = const Color(0xFFC0C0C0);
            } else if (rank == 3) {
              medal = '🥉';
              rankColor = const Color(0xFFCD7F32);
            }
            return GestureDetector(
              onTap:
                  uid.isNotEmpty ? () => context.push('/profile/$uid') : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  SizedBox(
                      width: 20,
                      child: medal.isNotEmpty
                          ? Text(medal, style: const TextStyle(fontSize: 13))
                          : Text('$rank',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: rankColor))),
                  const SizedBox(width: 6),
                  CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.surfaceVariant,
                      backgroundImage:
                          photo.isNotEmpty ? NetworkImage(photo) : null,
                      child: photo.isEmpty
                          ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary))
                          : null),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis)),
                  Text('$score',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: rankColor)),
                  Text(' pts',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.onSurfaceMuted)),
                ]),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _TopNGOsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NGOModel>>(
      stream: DatabaseService.watchTopNGOs(),
      builder: (ctx, snap) {
        if (!snap.hasData)
          return const Center(
              child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.primary)));
        final ngos = snap.data!;
        return Column(
          children: ngos.asMap().entries.map((e) {
            final rank = e.key + 1;
            final ngo = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4)),
                  child: Center(
                      child: Text('$rank',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary))),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    image: ngo.logoURL.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(ngo.logoURL), fit: BoxFit.cover)
                        : null,
                  ),
                  child: ngo.logoURL.isEmpty
                      ? const Center(
                          child: Text('🏢', style: TextStyle(fontSize: 14)))
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(ngo.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                      Text(
                          ngo.sdgGoals.isNotEmpty
                              ? 'SDG ${ngo.sdgGoals.take(2).join(', ')}'
                              : 'NGO',
                          style: const TextStyle(
                              color: AppTheme.onSurfaceMuted, fontSize: 10)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text('Active',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
              ]),
            );
          }).toList(),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.icon,
      required this.color,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.2) : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? color : Colors.transparent, width: 1.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? color : AppTheme.onSurfaceMuted)),
          ]),
        ),
      );
}
