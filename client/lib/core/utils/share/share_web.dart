import 'dart:typed_data';
import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'share_interface.dart';

class ShareImpl implements ShareInterface {
  @override
  Future<void> exportAndShareFile({
    required String content,
    required String filename,
    required String mimeType,
    String? subject,
  }) async {
    final bytes = Uint8List.fromList(utf8.encode(content));
    
    // Map mime types to the simplified extension for FileSaver
    String ext = filename.split('.').last;
    MimeType saverMimeType = MimeType.text;
    if (ext == 'md') {
      saverMimeType = MimeType.text; // file_saver doesn't have a specific markdown one
    } else if (ext == 'txt') {
      saverMimeType = MimeType.text;
    }

    await FileSaver.instance.saveFile(
      name: filename.split('.').first,
      bytes: bytes,
      fileExtension: ext,
      mimeType: saverMimeType,
    );
  }

  @override
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}

ShareInterface getShareService() => ShareImpl();
