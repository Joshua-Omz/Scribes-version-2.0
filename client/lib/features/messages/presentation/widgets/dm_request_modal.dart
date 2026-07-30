import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/widgets/scribes_avatar.dart';
import 'package:scribes/features/social/application/user_lookup_provider.dart';
import 'package:scribes/features/messages/data/message_api.dart';
import 'package:scribes/core/widgets/scribes_toast.dart';
import 'package:scribes/core/widgets/scribes_bounce_button.dart';

class DmRequestModal extends ConsumerStatefulWidget {
  final String userId;

  const DmRequestModal({super.key, required this.userId});

  static Future<void> show(BuildContext context, String userId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DmRequestModal(userId: userId),
    );
  }

  @override
  ConsumerState<DmRequestModal> createState() => _DmRequestModalState();
}

class _DmRequestModalState extends ConsumerState<DmRequestModal> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final api = ref.read(messageApiProvider);
      await api.sendRequest(widget.userId, text);
      
      if (mounted) {
        context.pop();
        final colors = ref.read(themeProvider);
        ScribesToast.show(context, 'Message request sent', colors, isError: false);
      }
    } catch (e) {
      if (mounted) {
        final colors = ref.read(themeProvider);
        ScribesToast.show(context, 'Failed to send request', colors, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final authorState = ref.watch(commentAuthorProvider(widget.userId));

    return Container(
      margin: EdgeInsets.only(top: kToolbarHeight),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          authorState.when(
            data: (author) => Row(
              children: [
                ScribesAvatar(authorName: author.safeDisplayName, radius: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message Request',
                        style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                      ),
                      Text(
                        author.safeDisplayName,
                        style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText, fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(height: 48),
            error: (_, _) => const SizedBox(height: 48),
          ),
          
          const SizedBox(height: 24),
          
          TextField(
            controller: _controller,
            maxLines: 4,
            style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
            decoration: InputDecoration(
              hintText: 'Introduce yourself and start the conversation...',
              hintStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colors.gold),
              ),
              filled: true,
              fillColor: colors.surface,
            ),
          ),
          
          const SizedBox(height: 24),
          
          ScribesBounceButton(
            onTap: _isSending ? () {} : _sendRequest,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: colors.gold,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.gold.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Send Request',
                            style: ScribesTextStyles.bodyLg.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
