import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/domain/post.dart';
import '../data/explore_repository.dart';

/// Immutable query parameter for family provider caching
class ScriptureQuery {
  final String book;
  final int chapter;

  const ScriptureQuery({
    required this.book,
    required this.chapter,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScriptureQuery &&
          runtimeType == other.runtimeType &&
          book.toLowerCase() == other.book.toLowerCase() &&
          chapter == other.chapter;

  @override
  int get hashCode => book.toLowerCase().hashCode ^ chapter.hashCode;
}

/// Fetches posts filtered by scripture book and chapter.
/// Uses autoDispose so that when the user leaves the screen, the state is cleared.
final scripturePostsProvider = FutureProvider.autoDispose
    .family<List<Post>, ScriptureQuery>((ref, query) async {
  final repository = ref.watch(exploreRepositoryProvider);
  final response = await repository.getExplore(
    scriptureBook: query.book,
    scriptureChapter: query.chapter,
  );
  return response.posts;
});
