import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_shimmer.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../posts/domain/sermon_source.dart';
import '../../posts/domain/scripture_ref.dart';
import '../application/compose_provider.dart';
import '../../explore/application/explore_notifier.dart';

class PublishMetadataScreen extends ConsumerWidget {
  const PublishMetadataScreen({super.key});

  void _showPublishConfirmation(BuildContext context, WidgetRef ref) {
    final colors = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Publish Post?',
                style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 16),
              Text(
                'Publishing creates a public post that cannot be erased. It will be permanently added to your scroll and visible to your followers.',
                textAlign: TextAlign.center,
                style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Not yet', style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.gold,
                        foregroundColor: colors.surfaceRaised,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(composeProvider.notifier).publishToCloud().then((_) {
                          if (context.mounted) {
                            ScribesToast.show(context, 'Post published!', colors, icon: LucideIcons.check_circle);
                            context.go('/');
                          }
                        }).catchError((err) {
                          if (context.mounted) {
                            ScribesToast.show(context, 'Error publishing: $err', colors, isError: true);
                          }
                        });
                      },
                      child: Text('Publish', style: ScribesTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final composeState = ref.watch(composeProvider);
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left, color: colors.primaryText),
          onPressed: () {
            context.pop(); // Go back to Preview
          },
        ),
        title: Text(
          'Post Details',
          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (composeState.title.trim().isEmpty) {
                ScribesToast.show(context, 'Please add a title before publishing.', colors, isError: true);
                return;
              }
              if (composeState.contentDelta == null) {
                ScribesToast.show(context, 'Post body cannot be empty.', colors, isError: true);
                return;
              }
              if (composeState.scriptureRefs.length < 2) {
                ScribesToast.show(context, 'Please add between 2 and 3 scripture tags.', colors, isError: true);
                return;
              }
              _showPublishConfirmation(context, ref);
            },
            child: Text(
              'Publish',
              style: ScribesTextStyles.labelLg.copyWith(color: colors.orange),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: colors.background,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Area
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Context is everything.',
                      style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add optional metadata to help others discover your post.',
                      style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText, height: 1.5),
                    ),
                  ],
                ),
              ),
              
              // Form Area
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: colors.border)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scripture Tags Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scripture Tags',
                              style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add 2 to 3 scripture references.',
                              style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                        if (composeState.scriptureRefs.length < 3)
                          TextButton.icon(
                            icon: Icon(LucideIcons.plus, size: 16, color: colors.gold),
                            label: Text('Add', style: ScribesTextStyles.labelLg.copyWith(color: colors.gold)),
                            onPressed: () => _showAddScriptureSheet(context, ref, colors),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (composeState.scriptureRefs.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: composeState.scriptureRefs.map((refData) {
                          final refStr = refData.verseEnd != null
                              ? '${refData.book} ${refData.chapter}:${refData.verseStart}-${refData.verseEnd}'
                              : '${refData.book} ${refData.chapter}:${refData.verseStart}';
                          return InputChip(
                            label: Text(
                              refStr,
                              style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText),
                            ),
                            onDeleted: () => ref.read(composeProvider.notifier).removeScriptureRef(refData),
                            backgroundColor: colors.surfaceRaised,
                            deleteIconColor: colors.secondaryText,
                            side: BorderSide(color: colors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 40),

                    // Topics Section
                    Text(
                      'Topics',
                      style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select up to 3 topics to help others find your post.',
                      style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 12),
                    categoriesState.when(
                      data: (categories) {
                        if (categories.isEmpty) return const SizedBox.shrink();
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: categories.map((cat) {
                            final isSelected = composeState.categoryIds.contains(cat.id);
                            return FilterChip(
                              label: Text(
                                cat.name,
                                style: ScribesTextStyles.labelLg.copyWith(
                                  color: isSelected ? colors.surface : colors.primaryText,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                ref.read(composeProvider.notifier).toggleCategory(cat.id);
                              },
                              backgroundColor: colors.surfaceRaised,
                              selectedColor: colors.primaryText,
                              side: BorderSide(
                                color: isSelected ? colors.primaryText : colors.border,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => ScribesShimmer(
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: List.generate(
                            4,
                            (index) => Container(
                              width: 80.0 + (index % 3 * 20),
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: colors.surfaceRaised,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      error: (err, stack) => Text(
                        'Failed to load topics', 
                        style: ScribesTextStyles.caption.copyWith(color: colors.orange)
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Caption Field
                    Text(
                      'Caption',
                      style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    ScribesTextField(
                      initialValue: composeState.caption,
                      maxLines: 4,
                      minLines: 2,
                      hintText: 'Share a thought about this note...',
                      onChanged: (value) => ref.read(composeProvider.notifier).updateMetadata(caption: value),
                    ),
                    const SizedBox(height: 40),

                    // Sermon Details Section
                    Text(
                      'Sermon Details',
                      style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        children: [
                          _buildPremiumField(
                            label: 'Preacher',
                            icon: LucideIcons.user,
                            initialValue: composeState.sermonSource?.preacher,
                            colors: colors,
                            onChanged: (value) {
                              final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                              ref.read(composeProvider.notifier).updateMetadata(sermonSource: src.copyWith(preacher: value));
                            },
                          ),
                          Divider(height: 1, color: colors.border, indent: 48),
                          _buildPremiumField(
                            label: 'Church',
                            icon: LucideIcons.church,
                            initialValue: composeState.sermonSource?.church,
                            colors: colors,
                            onChanged: (value) {
                              final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                              ref.read(composeProvider.notifier).updateMetadata(sermonSource: src.copyWith(church: value));
                            },
                          ),
                          Divider(height: 1, color: colors.border, indent: 48),
                          _buildPremiumField(
                            label: 'Series',
                            icon: LucideIcons.book_marked,
                            initialValue: composeState.sermonSource?.series,
                            colors: colors,
                            onChanged: (value) {
                              final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                              ref.read(composeProvider.notifier).updateMetadata(sermonSource: src.copyWith(series: value));
                            },
                          ),
                          Divider(height: 1, color: colors.border, indent: 48),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: colors.gold,
                                        onPrimary: colors.surfaceRaised,
                                        surface: colors.surface,
                                        onSurface: colors.primaryText,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                                ref.read(composeProvider.notifier).updateMetadata(
                                  sermonSource: src.copyWith(date: date.toIso8601String().split('T')[0]),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.calendar, size: 20, color: colors.secondaryText),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      composeState.sermonSource?.date ?? 'Date Preached',
                                      style: ScribesTextStyles.bodyMd.copyWith(
                                        color: composeState.sermonSource?.date == null 
                                          ? colors.secondaryText.withOpacity(0.5) 
                                          : colors.primaryText,
                                      ),
                                    ),
                                  ),
                                  Icon(LucideIcons.chevron_right, size: 20, color: colors.secondaryText.withOpacity(0.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumField({
    required String label,
    required IconData icon,
    required String? initialValue,
    required dynamic colors,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.secondaryText),
          const SizedBox(width: 16),
          Expanded(
            child: ScribesTextField(
              initialValue: initialValue,
              hintText: label,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddScriptureSheet(BuildContext context, WidgetRef ref, dynamic colors) {
    final bookController = TextEditingController();
    final chapterController = TextEditingController();
    final verseStartController = TextEditingController();
    final verseEndController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Scripture Tag', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
              const SizedBox(height: 16),
              ScribesTextField(
                controller: bookController,
                labelText: 'Book (e.g. John)',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ScribesTextField(
                      controller: chapterController,
                      keyboardType: TextInputType.number,
                      labelText: 'Chapter',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ScribesTextField(
                      controller: verseStartController,
                      keyboardType: TextInputType.number,
                      labelText: 'Verse Start',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ScribesTextField(
                      controller: verseEndController,
                      keyboardType: TextInputType.number,
                      labelText: 'Verse End',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.gold,
                      foregroundColor: colors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final book = bookController.text.trim();
                      final chapter = int.tryParse(chapterController.text.trim());
                      final verseStart = int.tryParse(verseStartController.text.trim());
                      final verseEnd = int.tryParse(verseEndController.text.trim());

                      if (book.isEmpty || chapter == null || verseStart == null) {
                        ScribesToast.show(context, 'Book, chapter, and verse start are required.', colors, isError: true);
                        return;
                      }

                      ref.read(composeProvider.notifier).addScriptureRef(
                        ScriptureRef(
                          book: book,
                          chapter: chapter,
                          verseStart: verseStart,
                          verseEnd: verseEnd,
                        )
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Add', style: ScribesTextStyles.labelLg),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
