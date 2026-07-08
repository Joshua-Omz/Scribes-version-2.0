import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/presentation/auth_gate_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/test_widgets_screen.dart';
import '../../features/feed/presentation/feed_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/posts/presentation/post_detail_screen.dart';
part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState is AsyncLoading) {
        return null; // wait
      }
      
      final isAuth = authState.value != null;
      final isGoingToAuth = state.matchedLocation == '/auth';
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isExplore = state.matchedLocation == '/explore';
      final isPost = state.matchedLocation.startsWith('/posts/');
      
      // Allow unauthenticated access to splash, explore, and post detail
      if (!isAuth && !isGoingToSplash && !isGoingToAuth && !isExplore && !isPost) {
        return '/splash'; // will eventually go to auth after splash
      }

      // If authenticated and on auth or splash, go to onboarding (or feed later if onboarding is done)
      if (isAuth && (isGoingToAuth || isGoingToSplash)) {
        return '/onboarding'; 
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/test-widgets',
        builder: (context, state) => const TestWidgetsScreen(),
      ),
      GoRoute(
        path: '/posts/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailScreen(postId: id);
        },
      ),

    ],
  );
}
