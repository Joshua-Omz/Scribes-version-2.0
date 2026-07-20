import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Post published!')),
                            );
                            context.go('/');
                          }
                        }).catchError((err) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error publishing: $err')),
                            );
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
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add a title before publishing.')),
                );
                return;
              }
              if (composeState.contentDelta == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post body cannot be empty.')),
                );
                return;
              }
              if (composeState.scriptureRefs.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add between 2 and 3 scripture tags.')),
                );
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
                            icon: Icon(Icons.add, size: 16, color: colors.gold),
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
                      loading: () => Shimmer.fromColors(
                        baseColor: colors.surfaceRaised,
                        highlightColor: colors.border,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: List.generate(
                            4,
                            (index) => Container(
                              width: 80.0 + (index % 3 * 20),
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                    Container(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextFormField(
                        initialValue: composeState.caption,
                        style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
                        maxLines: 4,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Share a thought about this note...',
                          hintStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText.withOpacity(0.5)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (value) => ref.read(composeProvider.notifier).updateMetadata(caption: value),
                      ),
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
                            icon: Icons.person_outline,
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
                            icon: Icons.church_outlined,
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
                            icon: Icons.collections_bookmark_outlined,
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
                                  Icon(Icons.calendar_today_outlined, size: 20, color: colors.secondaryText),
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
                                  Icon(Icons.chevron_right, size: 20, color: colors.secondaryText.withOpacity(0.5)),
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
            child: TextFormField(
              initialValue: initialValue,
              style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText.withOpacity(0.5)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
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
              TextField(
                controller: bookController,
                decoration: InputDecoration(
                  labelText: 'Book (e.g. John)',
                  labelStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chapterController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Chapter',
                        labelStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                        filled: true,
                        fillColor: colors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: verseStartController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Verse Start',
                        labelStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                        filled: true,
                        fillColor: colors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: verseEndController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Verse End',
                        labelStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                        filled: true,
                        fillColor: colors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Book, chapter, and verse start are required.')),
                        );
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
