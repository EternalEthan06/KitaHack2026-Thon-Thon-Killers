import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user_model.dart';
import '../../core/models/post_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/post_card.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  bool get _isOwn => userId == AuthService.currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserModel?>(
        stream: _isOwn
            ? DatabaseService.watchCurrentUser()
            : Stream.fromFuture(DatabaseService.getUser(userId)),
        builder: (context, userSnap) {
          final user = userSnap.data;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                title: Text(user?.displayName ?? 'Profile'),
                actions: [
                  if (_isOwn)
                    TextButton(
                      onPressed: () async {
                        print('🔌 PROFILE: Sign out sequence started...');
                        await AuthService.signOut();
                        print(
                            '🔌 PROFILE: Auth state cleared. Redirection starting...');
                        if (context.mounted) {
                          GoRouter.of(context).go('/login');
                        }
                      },
                      child: const Text('Sign Out',
                          style: TextStyle(color: AppTheme.error)),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: user == null
                      ? const SizedBox()
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [AppTheme.primary, AppTheme.background],
                            ),
                          ),
                          child: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppTheme.surfaceVariant,
                                  child: Text(
                                      user.displayName.isNotEmpty
                                          ? user.displayName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 30,
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 8),
                                Text(user.displayName,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _StatChip(
                                        label: 'SDG Score',
                                        value: '${user.sdgScore}',
                                        icon: '🌱'),
                                    const SizedBox(width: 12),
                                    _StatChip(
                                        label: 'Streak',
                                        value: '🔥 ${user.streak}d',
                                        icon: ''),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),

              // Badges
              if (user != null && user.badges.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      children: user.badges
                          .map((b) => Chip(
                              label: Text(b),
                              backgroundColor:
                                  AppTheme.primary.withOpacity(0.1),
                              side: BorderSide.none))
                          .toList(),
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Posts',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ),

              StreamBuilder<List<PostModel>>(
                stream: DatabaseService.watchUserPosts(userId),
                builder: (ctx, snap) {
                  final posts = snap.data ?? [];
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                          child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No posts yet.',
                                  style: TextStyle(
                                      color: AppTheme.onSurfaceMuted)))),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => PostCard(post: posts[i]),
                      childCount: posts.length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _StatChip(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.black26, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text('$icon $value',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }
}
