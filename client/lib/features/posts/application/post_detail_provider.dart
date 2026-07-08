import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/posts/data/post_repository.dart';
import 'package:scribes/features/posts/application/post_detail_state.dart';

part 'post_detail_provider.g.dart';

@riverpod
class PostDetailNotifier extends _$PostDetailNotifier {
  @override
  Future<PostDetailState> build(String postId) async {
    final postRepo = ref.watch(postRepositoryProvider);
    final post = await postRepo.getPost(postId);

    return PostDetailState(post: post);
  }

  Future<void> loadVersions() async {
    if (state.value == null) return;
    
    final postRepo = ref.read(postRepositoryProvider);
    final versions = await postRepo.getPostVersions(postId);
    
    state = AsyncData(state.value!.copyWith(versions: versions));
  }
}
