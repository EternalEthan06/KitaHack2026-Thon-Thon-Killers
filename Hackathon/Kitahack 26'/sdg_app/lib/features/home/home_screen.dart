import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../feed/feed_screen.dart';
import '../volunteer/volunteer_screen.dart';
import '../rewards/rewards_screen.dart';
import '../donate/donate_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = [
    const FeedScreen(),
    const VolunteerScreen(),
    const SizedBox(), // placeholder for camera FAB
    const RewardsScreen(),
    const DonateScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: FirestoreService.watchCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex == 2 ? 0 : _currentIndex,
            children: _pages,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/camera'),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.black,
            elevation: 6,
            child: const Icon(Icons.add_a_photo_rounded, size: 28),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _BottomNav(
            currentIndex: _currentIndex == 2 ? 0 : _currentIndex,
            onTap: (i) {
              if (i == 2) {
                context.push('/camera');
              } else {
                setState(() => _currentIndex = i);
              }
            },
            streak: user?.streak ?? 0,
            score: user?.sdgScore ?? 0,
            onProfileTap: () =>
                context.push('/profile/${AuthService.currentUserId}'),
          ),
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int streak;
  final int score;
  final VoidCallback onProfileTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.streak,
    required this.score,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border:
            Border(top: BorderSide(color: AppTheme.surfaceVariant, width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score + streak bar
            if (streak > 0 || score > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.08),
                      AppTheme.secondary.withOpacity(0.05)
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: Colors.orangeAccent, size: 16),
                      const SizedBox(width: 4),
                      Text('$streak day streak',
                          style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ]),
                    Row(children: [
                      const Icon(Icons.stars_rounded,
                          color: AppTheme.primary, size: 16),
                      const SizedBox(width: 4),
                      Text('$score SDG pts',
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onProfileTap,
                        child: const Icon(Icons.person_rounded,
                            color: AppTheme.onSurfaceMuted, size: 20),
                      ),
                    ]),
                  ],
                ),
              ),
            // Nav items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Feed',
                    index: 0,
                    current: currentIndex,
                    onTap: onTap),
                _NavItem(
                    icon: Icons.volunteer_activism_rounded,
                    label: 'Volunteer',
                    index: 1,
                    current: currentIndex,
                    onTap: onTap),
                // Center FAB placeholder
                const SizedBox(width: 56),
                _NavItem(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Rewards',
                    index: 3,
                    current: currentIndex,
                    onTap: onTap),
                _NavItem(
                    icon: Icons.favorite_rounded,
                    label: 'Donate',
                    index: 4,
                    current: currentIndex,
                    onTap: onTap),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem(
      {required this.icon,
      required this.label,
      required this.index,
      required this.current,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: selected
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon,
                  color: selected ? AppTheme.primary : AppTheme.onSurfaceMuted,
                  size: 24),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color:
                        selected ? AppTheme.primary : AppTheme.onSurfaceMuted,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
