import 'package:flutter/widgets.dart';

Widget buildFileImage({
  required String filePath,
  BoxFit? fit,
  int? memCacheWidth,
  int? memCacheHeight,
  Widget? fallback,
}) {
  return fallback ?? const SizedBox.shrink();
}
