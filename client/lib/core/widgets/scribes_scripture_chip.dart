import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_radius.dart';
import 'scribes_loading_indicator.dart';
import '../../features/bible/application/bible_providers.dart';

class ScribesScriptureChip extends ConsumerStatefulWidget {
  final String reference;
  final VoidCallback? onTap;

  const ScribesScriptureChip({super.key, required this.reference, this.onTap});

  @override
  ConsumerState<ScribesScriptureChip> createState() =>
      _ScribesScriptureChipState();
}

class _ScribesScriptureChipState extends ConsumerState<ScribesScriptureChip> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!();
              } else {
                setState(() => _isExpanded = !_isExpanded);
              }
            },
            borderRadius: BorderRadius.circular(ScribesRadius.chip),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isExpanded ? colors.primaryText : colors.surfaceRaised,
                borderRadius: BorderRadius.circular(ScribesRadius.chip),
                border: Border.all(
                  color: _isExpanded ? colors.primaryText : colors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedBookOpen01,
                    size: 14,
                    color: _isExpanded
                        ? colors.background
                        : colors.secondaryText,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.reference,
                      style: ScribesTextStyles.labelSm.copyWith(
                        color: _isExpanded
                            ? colors.background
                            : colors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 14,
                    color: _isExpanded
                        ? colors.background
                        : colors.secondaryText,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            _buildExpandedVerseBox(colors),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedVerseBox(dynamic colors) {
    final verseAsync = ref.watch(verseLookupProvider(widget.reference));

    return ClipRRect(
      borderRadius: BorderRadius.circular(ScribesRadius.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: colors.glassBlur,
          sigmaY: colors.glassBlur,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.glassFill,
            borderRadius: BorderRadius.circular(ScribesRadius.card),
            border: Border.all(color: colors.border, width: 1.0),
          ),
          child: verseAsync.when(
            data: (result) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.fullText,
                  style: ScribesTextStyles.bodyLg.copyWith(
                    color: colors.primaryText,
                    fontFamily: 'CormorantGaramond',
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Berean Standard Bible, public domain',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.secondaryText,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final match = RegExp(
                          r'^(.+?)\s+(\d+):',
                        ).firstMatch(widget.reference);
                        if (match != null) {
                          final book = match.group(1)!;
                          final chapter = int.tryParse(match.group(2)!) ?? 1;
                          ref
                              .read(bibleNavigationProvider.notifier)
                              .navigateTo(book, chapter);
                          context.push('/bible');
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Read full chapter',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.primaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: colors.primaryText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(child: ScribesLoadingIndicator(size: 20)),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Scripture text unavailable offline',
                style: ScribesTextStyles.caption.copyWith(
                  color: colors.secondaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
