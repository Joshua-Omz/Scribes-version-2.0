import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/domain/post.dart';
import '../data/explore_repository.dart';

/// Fetches posts filtered by a hashtag (#tag).
/// Uses autoDispose so that when the user leaves the tag screen, the state is cleared.
final tagPostsProvider = FutureProvider.autoDispose.family<List<Post>, String>((
  ref,
  tag,
) async {
  final repository = ref.watch(exploreRepositoryProvider);
  final response = await repository.getExplore(tag: tag);
  return response.posts;
});
