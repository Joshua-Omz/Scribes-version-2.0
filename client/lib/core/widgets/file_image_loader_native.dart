import 'dart:io';
import 'package:flutter/widgets.dart';

Widget buildFileImage({
  required String filePath,
  BoxFit? fit,
  int? memCacheWidth,
  int? memCacheHeight,
  Widget? fallback,
}) {
  return Image.file(
    File(filePath),
    fit: fit,
    cacheWidth: memCacheWidth,
    cacheHeight: memCacheHeight,
    errorBuilder: (context, error, stackTrace) {
      debugPrint('[ScribesImageResolver] Failed to load local file $filePath: $error');
      return fallback ?? const SizedBox.shrink();
    },
  );
}
