abstract class ShareInterface {
  Future<void> exportAndShareFile({
    required String content,
    required String filename,
    required String mimeType,
    String? subject,
  });

  Future<void> shareText(String text);
}
