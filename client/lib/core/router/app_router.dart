import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/domain/user.dart';
import '../../features/auth/presentation/auth_gate_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import 'package:scribes/main.dart';

import '../../features/feed/presentation/feed_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/posts/presentation/post_detail_screen.dart';
import '../../features/compose/presentation/draft_editor_screen.dart';
import '../../features/compose/presentation/draft_preview_screen.dart';
import '../../features/compose/presentation/publish_metadata_screen.dart';
import '../../features/compose/presentation/reflection_composer.dart';
import '../../features/posts/presentation/revise_post_screen.dart';
import '../../features/posts/domain/post.dart';
import '../../features/posts/domain/scripture_ref.dart';
import '../../features/draft/presentation/drafts_list_screen.dart';
import '../../features/profile/presentation/private_profile_screen.dart';
import '../../features/profile/presentation/public_profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/social/presentation/follow_list_screen.dart';
import '../../features/notes/presentation/notes_list_screen.dart';
import '../../features/notes/presentation/note_editor_screen.dart';
import '../../features/search/presentation/search_screen.dart';

import '../../features/notifications/presentation/notification_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/email_password_screen.dart';
import '../../features/settings/presentation/notifications_settings_screen.dart';
import '../../features/social/presentation/bookmarks_screen.dart';
import '../../features/bible/presentation/bible_drawer.dart';
import '../../features/compose/presentation/passage_composer.dart';
import '../../features/passage/presentation/passage_viewer_screen.dart';
import '../../features/explore/presentation/tag_posts_screen.dart';
import 'transitions.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  // Use a ValueNotifier to trigger GoRouter redirects without recreating the entire GoRouter instance
  final authStateNotifier = ValueNotifier<AsyncValue<User?>>(
    ref.read(authProvider),
  );

  ref.listen<AsyncValue<User?>>(authProvider, (_, next) {
    authStateNotifier.value = next;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final authState = authStateNotifier.value;

      if (authState is AsyncLoading) {
        return null; // wait on splash until auth resolves
      }

      final isAuth = authState.value != null;
      final isGoingToAuth = state.matchedLocation == '/auth';
      final isGoingToSplash = state.matchedLocation == '/splash';

      final publicRoutes = [
        '/',
        '/explore',
        '/search',
        '/bible',
        '/notes',
        '/notes/edit',
        '/compose',
        '/compose/reflection',
        '/compose/passage',
        '/compose/preview',
        '/compose/publish',
        '/drafts',
      ];
      final isPublicRoute =
          publicRoutes.contains(state.matchedLocation) ||
          state.matchedLocation.startsWith('/posts/') ||
          state.matchedLocation.startsWith('/passage/') ||
          state.matchedLocation.startsWith('/tags/') ||
          state.matchedLocation.startsWith('/users/');

      // Redirect away from splash once auth state is resolved
      if (isGoingToSplash) {
        if (isAuth) {
          final user = authState.value!;
          final hasSeenOnboarding =
              sharedPrefs.getBool('has_seen_onboarding_${user.id}') ?? false;
          final needsOnboarding =
              user.selectedTags.isEmpty && !hasSeenOnboarding;
          if (needsOnboarding) {
            return '/onboarding';
          }
        }
        return '/';
      }

      // Redirect to auth if trying to access protected routes and not authenticated
      if (!isAuth && !isGoingToAuth && !isPublicRoute) {
        final redirect = Uri.encodeQueryComponent(state.uri.toString());
        return '/auth?redirect=$redirect';
      }

      if (isAuth) {
        final user = authState.value!;
        final hasSeenOnboarding =
            sharedPrefs.getBool('has_seen_onboarding_${user.id}') ?? false;
        final needsOnboarding = user.selectedTags.isEmpty && !hasSeenOnboarding;
        final isGoingToOnboarding = state.matchedLocation == '/onboarding';

        if (needsOnboarding && !isGoingToOnboarding) {
          return '/onboarding';
        }

        if (!needsOnboarding && isGoingToOnboarding) {
          return '/';
        }

        // If authenticated and on auth or splash, go to original route or feed
        if (isGoingToAuth || isGoingToSplash) {
          final redirect = state.uri.queryParameters['redirect'];
          if (redirect != null && redirect.isNotEmpty) {
            return redirect;
          }
          return '/';
        }
      }

      return null;
    },
    // Dedicated page routes — no shell, each screen owns its own Scaffold + bottom nav
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
        path: '/notes',
        builder: (context, state) => const NotesListScreen(),
      ),
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/bible',
        pageBuilder: (context, state) {
          final book = state.uri.queryParameters['book'];
          final chapterStr = state.uri.queryParameters['chapter'];
          final chapter = chapterStr != null ? int.tryParse(chapterStr) : null;
          return buildPageWithSlideRightTransition(
            context: context,
            state: state,
            child: BibleDrawerScreen(
              initialBook: book,
              initialChapter: chapter,
            ),
          );
        },
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const AuthGateScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/compose',
        pageBuilder: (context, state) => buildPageWithSlideUpTransition(
          context: context,
          state: state,
          child: const DraftEditorScreen(),
        ),
      ),
      GoRoute(
        path: '/compose/reflection',
        pageBuilder: (context, state) => buildPageWithSlideUpTransition(
          context: context,
          state: state,
          child: ReflectionComposerScreen(
            prefilledScriptureRef: state.extra as ScriptureRef?,
          ),
        ),
      ),
      GoRoute(
        path: '/compose/passage',
        pageBuilder: (context, state) => buildPageWithSlideUpTransition(
          context: context,
          state: state,
          child: const PassageComposerScreen(),
        ),
      ),
      GoRoute(
        path: '/compose/preview',
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          context: context,
          state: state,
          child: const DraftPreviewScreen(),
        ),
      ),
      GoRoute(
        path: '/compose/publish',
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          context: context,
          state: state,
          child: const PublishMetadataScreen(),
        ),
      ),
      GoRoute(
        path: '/compose/metadata',
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          context: context,
          state: state,
          child: const PublishMetadataScreen(),
        ),
      ),
      GoRoute(
        path: '/passage/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return buildPageWithSlideRightTransition(
            context: context,
            state: state,
            child: PassageViewerScreen(postId: id),
          );
        },
      ),
      GoRoute(
        path: '/posts/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return buildPageWithSlideRightTransition(
            context: context,
            state: state,
            child: PostDetailScreen(postId: id),
          );
        },
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (context, state) {
              final post = state.extra as Post;
              return buildPageWithSlideUpTransition(
                context: context,
                state: state,
                child: RevisePostScreen(post: post),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const PrivateProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (context, state) => buildPageWithSlideUpTransition(
              context: context,
              state: state,
              child: const EditProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'security',
            pageBuilder: (context, state) => buildPageWithSlideRightTransition(
              context: context,
              state: state,
              child: const EmailPasswordScreen(),
            ),
          ),
          GoRoute(
            path: 'notifications',
            pageBuilder: (context, state) => buildPageWithSlideRightTransition(
              context: context,
              state: state,
              child: const NotificationsSettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/bookmarks',
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          context: context,
          state: state,
          child: const BookmarksScreen(),
        ),
      ),
      GoRoute(
        path: '/users/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return buildPageWithSlideRightTransition(
            context: context,
            state: state,
            child: PublicProfileScreen(userId: id),
          );
        },
        routes: [
          GoRoute(
            path: 'connections',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              final tabIndex =
                  int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
              return buildPageWithSlideRightTransition(
                context: context,
                state: state,
                child: FollowListScreen(userId: id, initialIndex: tabIndex),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/notes/edit',
        pageBuilder: (context, state) => buildPageWithSlideUpTransition(
          context: context,
          state: state,
          child: const NoteEditorScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          context: context,
          state: state,
          child: const NotificationScreen(),
        ),
      ),
      GoRoute(
        path: '/drafts',
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          context: context,
          state: state,
          child: const DraftsListScreen(),
        ),
      ),
      GoRoute(
        path: '/tags/:tag',
        pageBuilder: (context, state) {
          final tag = state.pathParameters['tag']!;
          return buildPageWithSlideRightTransition(
            context: context,
            state: state,
            child: TagPostsScreen(tag: tag),
          );
        },
      ),
    ],
  );
}
