import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/presentation/auth_gate_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';

import '../../features/feed/presentation/feed_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/posts/presentation/post_detail_screen.dart';
import '../../features/compose/presentation/draft_editor_screen.dart';
import '../../features/compose/presentation/draft_preview_screen.dart';
import '../../features/compose/presentation/publish_metadata_screen.dart';
import '../../features/draft/presentation/drafts_list_screen.dart';
import '../../features/profile/presentation/private_profile_screen.dart';
import '../../features/profile/presentation/public_profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/social/presentation/follow_list_screen.dart';
import '../../features/notes/presentation/notes_list_screen.dart';
import '../../features/notes/presentation/note_editor_screen.dart';
import '../../features/notifications/presentation/notification_screen.dart';
import '../widgets/scribes_bottom_nav.dart';
import 'transitions.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState is AsyncLoading) {
        return null; // wait
      }
      
      final isAuth = authState.value != null;
      final isGoingToAuth = state.matchedLocation == '/auth';
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isExplore = state.matchedLocation == '/explore';
      final isFeed = state.matchedLocation == '/';
      final isPost = state.matchedLocation.startsWith('/posts/');
      
      // Allow unauthenticated access to splash, auth, explore, feed, and post detail
      if (!isAuth && !isGoingToSplash && !isGoingToAuth && !isExplore && !isFeed && !isPost) {
        return '/auth'; // Redirect directly to auth if trying to access protected routes
      }

      // If authenticated and on auth or splash, go to feed 
      if (isAuth && (isGoingToAuth || isGoingToSplash)) {
        return '/'; 
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/drafts',
                builder: (context, state) => const DraftsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) => const NotesListScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const AuthGateScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: '/compose',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const DraftEditorScreen()),
      ),
      GoRoute(
        path: '/compose/preview',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const DraftPreviewScreen()),
      ),
      GoRoute(
        path: '/compose/publish',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const PublishMetadataScreen()),
      ),
      GoRoute(
        path: '/posts/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return buildPageWithDefaultTransition(context: context, state: state, child: PostDetailScreen(postId: id));
        },
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const PrivateProfileScreen()),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const EditProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/users/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return buildPageWithDefaultTransition(context: context, state: state, child: PublicProfileScreen(userId: id));
        },
        routes: [
          GoRoute(
            path: 'connections',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              final tabIndex = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
              return buildPageWithDefaultTransition(context: context, state: state, child: FollowListScreen(userId: id, initialIndex: tabIndex));
            },
          ),
        ],
      ),
      GoRoute(
        path: '/notes/edit',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const NoteEditorScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const NotificationScreen()),
      ),
    ],
  );
}
