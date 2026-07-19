import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/social/data/social_repository.dart';
import 'package:scribes/features/social/domain/comment_author.dart';

part 'user_lookup_provider.g.dart';

/// Fetches and caches a single user's public profile by UUID.
/// Used by comment tiles to resolve author_id → displayName + handle.
/// Uses keepAlive so repeated renders of the same author don't refetch.
@riverpod
Future<CommentAuthor> commentAuthor(ref, String userId) async {
  final repo = ref.watch(socialRepositoryProvider);
  final author = await repo.getUserProfile(userId);
  ref.keepAlive();
  return author;
}

/// Searches users by handle prefix for @mention autocomplete.
/// Debouncing should be handled at the UI layer, not here.
@riverpod
Future<List<CommentAuthor>> userSearch(ref, String query) async {
  if (query.isEmpty) return [];
  final repo = ref.watch(socialRepositoryProvider);
  return repo.searchUsers(query);
}
