import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/passage_models.dart';
import 'sound_api.dart';

part 'sound_repository.g.dart';

@riverpod
SoundRepository soundRepository(Ref ref) {
  return SoundRepository(ref.watch(soundApiProvider));
}

@riverpod
Future<List<SoundTrack>> soundsList(Ref ref) async {
  final repo = ref.watch(soundRepositoryProvider);
  return repo.listSounds();
}

class SoundRepository {
  final SoundApi _api;

  SoundRepository(this._api);

  Future<List<SoundTrack>> listSounds() async {
    return _api.listSounds();
  }
}
