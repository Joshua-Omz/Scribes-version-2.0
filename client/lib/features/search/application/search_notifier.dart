import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/posts/domain/post.dart';
import 'package:scribes/features/auth/domain/user.dart';
import '../data/search_repository.dart';

part 'search_notifier.g.dart';

class SearchState {
  final String query;
  final bool isLoading;
  final List<Post> posts;
  final List<User> authors;
  final String? error;
  final String? scriptureBook;
  final int? scriptureChapter;

  SearchState({
    this.query = '',
    this.isLoading = false,
    this.posts = const [],
    this.authors = const [],
    this.error,
    this.scriptureBook,
    this.scriptureChapter,
  });

  SearchState copyWith({
    String? query,
    bool? isLoading,
    List<Post>? posts,
    List<User>? authors,
    String? error,
    String? scriptureBook,
    int? scriptureChapter,
    bool clearScripture = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      authors: authors ?? this.authors,
      error: error, // Can be null to clear
      scriptureBook: clearScripture ? null : (scriptureBook ?? this.scriptureBook),
      scriptureChapter: clearScripture ? null : (scriptureChapter ?? this.scriptureChapter),
    );
  }
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  SearchState build() {
    return SearchState();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty && state.scriptureBook == null) {
      state = SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);

    try {
      final repo = ref.read(searchRepositoryProvider);
      
      // Fetch both simultaneously
      final results = await Future.wait([
        repo.searchPosts(
          query, 
          limit: 10,
          scriptureBook: state.scriptureBook,
          scriptureChapter: state.scriptureChapter,
        ),
        repo.searchAuthors(query, limit: 5),
      ]);

      final posts = results[0] as List<Post>;
      final authors = results[1] as List<User>;

      state = state.copyWith(
        isLoading: false,
        posts: posts,
        authors: authors,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setScriptureFilter(String book, int? chapter) {
    state = state.copyWith(scriptureBook: book, scriptureChapter: chapter);
    search(state.query);
  }

  void clearScriptureFilter() {
    state = state.copyWith(clearScripture: true);
    search(state.query);
  }

  void clear() {
    state = SearchState();
  }
}
