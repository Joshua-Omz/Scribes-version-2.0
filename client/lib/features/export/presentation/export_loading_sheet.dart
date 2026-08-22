import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../posts/domain/post.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_button.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../application/post_export_service.dart';
import 'pdf/pdf_theme.dart';

class ExportLoadingSheet extends ConsumerStatefulWidget {
  final Post post;

  const ExportLoadingSheet({super.key, required this.post});

  static Future<void> show(BuildContext context, Post post) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ExportLoadingSheet(post: post),
    );
  }

  @override
  ConsumerState<ExportLoadingSheet> createState() => _ExportLoadingSheetState();
}

class _ExportLoadingSheetState extends ConsumerState<ExportLoadingSheet> {
  late ScribesTheme _selectedTheme;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _selectedTheme = ScribesTheme.parchment; // Default print-friendly theme
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    final colors = ref.read(themeProvider);

    try {
      final exportService = ref.read(postExportServiceProvider);
      await exportService.exportPost(
        post: widget.post,
        theme: _selectedTheme,
        preview: true,
      );

      if (mounted) {
        context.pop();
        ScribesToast.show(
          context,
          'Manuscript PDF generated',
          colors,
          icon: HugeIcons.strokeRoundedCheckmarkBadge01,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScribesToast.show(
          context,
          'Failed to export manuscript: $e',
          colors,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ScribesRadius.sheet),
        ),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.secondaryText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedFile02,
                    color: colors.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Manuscript',
                        style: ScribesTextStyles.displayMd.copyWith(
                          color: colors.primaryText,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Preserve reflection as an illuminated PDF document',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Theme Selection
            Text(
              'DOCUMENT PALETTE',
              style: ScribesTextStyles.labelSm.copyWith(
                color: colors.secondaryText,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildThemeCard('Parch', ScribesTheme.parchment, colors),
                const SizedBox(width: 8),
                _buildThemeCard('Night', ScribesTheme.night, colors),
                const SizedBox(width: 8),
                _buildThemeCard('Silver', ScribesTheme.silver, colors),
              ],
            ),
            const SizedBox(height: 28),

            // Action Button
            if (_isExporting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ScribesLoadingIndicator(),
                ),
              )
            else
              ScribesButton(
                text: 'Generate PDF Manuscript',
                onPressed: _handleExport,
                leadingIcon: HugeIcons.strokeRoundedPrinter,
                variant: ScribesButtonVariant.solid,
                isFullWidth: true,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    String label,
    ScribesTheme theme,
    dynamic colors,
  ) {
    final isSelected = _selectedTheme == theme;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTheme = theme),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.gold.withValues(alpha: 0.12)
                : colors.surface,
            borderRadius: BorderRadius.circular(ScribesRadius.button),
            border: Border.all(
              color: isSelected ? colors.gold : colors.border,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: ScribesTextStyles.labelLg.copyWith(
                  color: isSelected ? colors.gold : colors.primaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
