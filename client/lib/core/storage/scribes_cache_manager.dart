import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ScribesCacheManager {
  static const key = 'scribes_image_cache';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 300,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
