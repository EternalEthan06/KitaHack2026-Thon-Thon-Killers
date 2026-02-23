import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/camera/camera_screen.dart';
import '../../features/post_detail/post_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/volunteer/volunteer_screen.dart';
import '../../features/donate/donate_screen.dart';
import '../../features/marketplace/marketplace_screen.dart';
import '../../features/feed/story_bar.dart';

import 'auth_listenable.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: AuthListenable(),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      // 🛑 CRITICAL: Don't redirect if we are simply "reloading" a sub-page.
      // This allows the /story/create URL to persist during a browser refresh.
      if (state.matchedLocation == '/story/create' ||
          state.matchedLocation == '/camera') {
        return null;
      }

      if (user == null && !loggingIn) {
        return '/login';
      }

      if (user != null && loggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/camera', builder: (c, s) => const CameraScreen()),
      GoRoute(
        path: '/story/create',
        builder: (c, s) => const StoryCreateScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (c, s) => PostDetailScreen(postId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (c, s) => ProfileScreen(userId: s.pathParameters['uid']!),
      ),
      GoRoute(path: '/rewards', builder: (c, s) => const RewardsScreen()),
      GoRoute(path: '/volunteer', builder: (c, s) => const VolunteerScreen()),
      GoRoute(path: '/donate', builder: (c, s) => const DonateScreen()),
      GoRoute(
          path: '/marketplace', builder: (c, s) => const MarketplaceScreen()),
    ],
  );
}
