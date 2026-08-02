import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/core/network/api_client.dart';
import 'package:scribes/features/posts/domain/post.dart';
import 'package:scribes/features/auth/domain/user.dart';
import 'search_api.dart';

part 'search_repository.g.dart';

class SearchRepository {
  final SearchApi _api;

  SearchRepository(this._api);

  Future<List<Post>> searchPosts(String query, {int limit = 20, int offset = 0}) async {
    final rawData = await _api.searchPosts(query, limit: limit, offset: offset);
    return rawData.map((json) => Post.fromJson(json)).toList();
  }

  Future<List<User>> searchAuthors(String query, {int limit = 20, int offset = 0}) async {
    final rawData = await _api.searchAuthors(query, limit: limit, offset: offset);
    return rawData.map((json) => User.fromJson(json)).toList();
  }

  Future<List<String>> suggestTags(String query) async {
    return _api.suggestTags(query);
  }
}

@riverpod
SearchRepository searchRepository(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return SearchRepository(SearchApi(dio));
}
