import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../storage/scribes_cache_manager.dart';
import '../../features/posts/domain/post.dart';

class ScribesImageResolver {
  /// Normalizes and resolves any image URL (absolute, relative, or local file).
  static String? resolveUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty || trimmed == 'null' || trimmed == 'undefined') {
      return null;
    }

    // Direct HTTP / HTTPS
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // Direct local file URI or data URI
    if (trimmed.startsWith('file://') || trimmed.startsWith('data:image')) {
      return trimmed;
    }

    // If it's a local absolute file path that exists on disk
    if (!trimmed.startsWith('/') || Platform.isAndroid || Platform.isIOS) {
      final file = File(trimmed);
      if (file.existsSync()) {
        return 'file://$trimmed';
      }
    }

    // Relative backend path (e.g. /media/uploads/..., uploads/...)
    final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080';
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$cleanBase$cleanPath';
  }

  /// Hierarchically extracts the first available image URL from a Post.
  static String? extractFirstImageUrl(Post post) {
    // 1. Direct top-level cover image on the Post model
    if (post.coverImageUrl != null && post.coverImageUrl!.trim().isNotEmpty) {
      final resolved = resolveUrl(post.coverImageUrl);
      if (resolved != null && resolved.isNotEmpty) return resolved;
    }

    final content = post.content;

    // 2. Direct top-level keys on content map
    for (final key in [
      'cover_image_url',
      'coverImageUrl',
      'image_url',
      'imageUrl',
      'image',
      'banner_url',
      'media_url',
      'mediaUrl',
      'url',
      'cover',
      'thumbnail',
      'thumbnail_url',
      'hero_image',
      'featured_image',
      'background_image_url',
    ]) {
      if (content.containsKey(key) && content[key] != null) {
        final url = content[key].toString().trim();
        final resolved = resolveUrl(url);
        if (resolved != null && resolved.isNotEmpty) {
          return resolved;
        }
      }
    }

    // Helper to scan Quill Delta operations
    String? scanOps(List<dynamic> ops) {
      for (final op in ops) {
        if (op is Map) {
          final insert = op['insert'];
          if (insert is Map) {
            final img = insert['image'] ?? insert['src'] ?? insert['url'];
            if (img != null) {
              final resolved = resolveUrl(img.toString());
              if (resolved != null) return resolved;
            }
          } else if (insert is String) {
            final match = RegExp(
              r'https?://[^\s<>"{}|\^~\[\]`]+\.(?:jpg|jpeg|png|webp|gif|svg)',
              caseSensitive: false,
            ).firstMatch(insert);
            if (match != null) {
              return match.group(0);
            }
          }
          final attributes = op['attributes'];
          if (attributes is Map) {
            final img =
                attributes['image'] ?? attributes['src'] ?? attributes['url'];
            if (img != null) {
              final resolved = resolveUrl(img.toString());
              if (resolved != null) return resolved;
            }
          }
        }
      }
      return null;
    }

    // 3. Inspect body (List, Map with ops, or String)
    final body = content['body'];
    if (body is List) {
      final img = scanOps(body);
      if (img != null) return img;
    } else if (body is Map && body['ops'] is List) {
      final img = scanOps(body['ops'] as List);
      if (img != null) return img;
    } else if (body is String && body.trim().isNotEmpty) {
      final trimmed = body.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          final img = scanOps(decoded);
          if (img != null) return img;
        } else if (decoded is Map && decoded['ops'] is List) {
          final img = scanOps(decoded['ops'] as List);
          if (img != null) return img;
        }
      } catch (_) {}

      // Check for markdown image format: ![alt](url)
      final mdMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(trimmed);
      if (mdMatch != null) {
        final resolved = resolveUrl(mdMatch.group(1));
        if (resolved != null) return resolved;
      }
    }

    // 4. Inspect root ops
    final ops = content['ops'];
    if (ops is List) {
      final img = scanOps(ops);
      if (img != null) return img;
    }

    // 5. Inspect passage panels
    final panels = content['panels'];
    if (panels is List) {
      for (final panel in panels) {
        if (panel is Map) {
          final mediaUrl =
              panel['media_url'] ??
              panel['background_image_url'] ??
              panel['image_url'] ??
              panel['imageUrl'] ??
              panel['url'];
          if (mediaUrl != null) {
            final resolved = resolveUrl(mediaUrl.toString());
            if (resolved != null) return resolved;
          }
        }
      }
    }

    // 6. Inspect media / attachments list
    for (final listKey in ['media', 'attachments', 'images']) {
      final list = content[listKey];
      if (list is List) {
        for (final item in list) {
          if (item is Map) {
            final url = item['url'] ?? item['media_url'] ?? item['src'];
            if (url != null) {
              final resolved = resolveUrl(url.toString());
              if (resolved != null) return resolved;
            }
          } else if (item is String) {
            final resolved = resolveUrl(item);
            if (resolved != null) return resolved;
          }
        }
      }
    }

    return null;
  }

  /// Builds a robust image widget supporting local files, cached remote assets, and fallback.
  static Widget buildImage({
    required String? imageUrl,
    BoxFit fit = BoxFit.cover,
    int? memCacheWidth = 800,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    Widget? fallback,
  }) {
    final resolved = resolveUrl(imageUrl);
    if (resolved == null || resolved.isEmpty) {
      return fallback ?? const SizedBox.shrink();
    }

    if (resolved.startsWith('file://')) {
      final filePath = resolved.replaceFirst('file://', '');
      final file = File(filePath);
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            fallback ?? const SizedBox.shrink(),
      );
    }

    return CachedNetworkImage(
      imageUrl: resolved,
      cacheManager: ScribesCacheManager.instance,
      httpHeaders: const {'ngrok-skip-browser-warning': 'true'},
      memCacheWidth: memCacheWidth,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget ??
          (context, url, error) => fallback ?? const SizedBox.shrink(),
    );
  }
}
