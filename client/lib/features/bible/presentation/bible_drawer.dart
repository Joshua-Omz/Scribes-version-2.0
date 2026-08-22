import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/scribes_colors.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_ornament_divider.dart';
import '../application/bible_providers.dart';
import '../domain/bible_models.dart';
import 'bible_search_sheet.dart';

class BibleDrawerScreen extends ConsumerStatefulWidget {
  final String? initialBook;
  final int? initialChapter;

  const BibleDrawerScreen({super.key, this.initialBook, this.initialChapter});

  @override
  ConsumerState<BibleDrawerScreen> createState() => _BibleDrawerScreenState();
}

class _BibleDrawerScreenState extends ConsumerState<BibleDrawerScreen> {
  final ScrollController _verseScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialBook != null && widget.initialChapter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(bibleNavigationProvider.notifier)
            .navigateTo(widget.initialBook!, widget.initialChapter!);
      });
    }
  }

  @override
  void dispose() {
    _verseScrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_verseScrollController.hasClients) {
      _verseScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final navState = ref.watch(bibleNavigationProvider);
    final booksAsync = ref.watch(bibleBooksProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: GestureDetector(
          onTap: () =>
              ref.read(bibleNavigationProvider.notifier).toggleBookPicker(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                navState.currentBook,
                style: ScribesTextStyles.displayMd.copyWith(
                  color: colors.primaryText,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                navState.isBookPickerOpen
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
                color: colors.gold,
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.goldMuted.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ScribesRadius.chip),
              border: Border.all(
                color: colors.goldMuted.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'BSB',
              style: ScribesTextStyles.labelSm.copyWith(
                color: colors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: colors.secondaryText,
              size: 20,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const BibleSearchSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: colors.border.withValues(alpha: 0.4),
            height: 1,
          ),
        ),
      ),
      body: navState.isBookPickerOpen
          ? _buildBookPicker(context, colors, booksAsync)
          : _buildReader(context, colors, navState),
    );
  }

  Widget _buildBookPicker(
    BuildContext context,
    ScribesColors colors,
    AsyncValue<List<BibleBook>> booksAsync,
  ) {
    return booksAsync.when(
      data: (books) {
        final otBooks = books.where((b) => b.testament == 'old').toList();
        final ntBooks = books.where((b) => b.testament == 'new').toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildTestamentSection('Old Testament', otBooks, colors),
            const SizedBox(height: 24),
            _buildTestamentSection('New Testament', ntBooks, colors),
          ],
        );
      },
      loading: () => const Center(child: ScribesLoadingIndicator()),
      error: (e, _) => Center(child: Text('Failed to load books: $e')),
    );
  }

  Widget _buildTestamentSection(
    String title,
    List<BibleBook> books,
    ScribesColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            title.toUpperCase(),
            style: ScribesTextStyles.caption.copyWith(
              color: colors.goldMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: books.map((book) {
            final isSelected =
                ref.watch(bibleNavigationProvider).currentBook.toLowerCase() ==
                book.name.toLowerCase();
            return InkWell(
              onTap: () {
                ref.read(bibleNavigationProvider.notifier).selectBook(book);
                _scrollToTop();
              },
              borderRadius: BorderRadius.circular(ScribesRadius.chip),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colors.gold : colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(ScribesRadius.chip),
                  border: Border.all(
                    color: isSelected ? colors.gold : colors.border,
                  ),
                ),
                child: Text(
                  book.name,
                  style: ScribesTextStyles.labelLg.copyWith(
                    color: isSelected ? colors.background : colors.primaryText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReader(
    BuildContext context,
    ScribesColors colors,
    BibleNavigationState navState,
  ) {
    final chapterAsync = ref.watch(
      bibleChapterProvider(
        BibleChapterQuery(
          book: navState.currentBook,
          chapter: navState.currentChapter,
        ),
      ),
    );

    return Column(
      children: [
        // Chapter selector horizontal chips
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              bottom: BorderSide(color: colors.border.withValues(alpha: 0.3)),
            ),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: navState.totalChapters,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final chapterNum = index + 1;
              final isCurrent = chapterNum == navState.currentChapter;
              return InkWell(
                onTap: () {
                  ref
                      .read(bibleNavigationProvider.notifier)
                      .selectChapter(chapterNum);
                  _scrollToTop();
                },
                borderRadius: BorderRadius.circular(ScribesRadius.chip),
                child: Container(
                  width: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent ? colors.gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(ScribesRadius.chip),
                    border: Border.all(
                      color: isCurrent
                          ? colors.gold
                          : colors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    chapterNum.toString(),
                    style: ScribesTextStyles.labelSm.copyWith(
                      color: isCurrent
                          ? colors.background
                          : colors.secondaryText,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Chapter verse content
        Expanded(
          child: chapterAsync.when(
            data: (chapter) => SingleChildScrollView(
              controller: _verseScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter Header Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '${chapter.book} ${chapter.chapter}',
                          style: ScribesTextStyles.displayLg.copyWith(
                            color: colors.primaryText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const ScribesOrnamentDivider(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Classic Bible Verse Typesetting
                  RichText(
                    text: TextSpan(
                      children: chapter.verses.expand((verse) {
                        return [
                          TextSpan(
                            text: ' ${verse.verse} ',
                            style: TextStyle(
                              fontFamily: 'CormorantGaramond',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colors.gold,
                            ),
                          ),
                          TextSpan(
                            text: '${verse.text} ',
                            style: TextStyle(
                              fontFamily: 'CormorantGaramond',
                              fontSize: 19,
                              height: 1.8,
                              color: colors.primaryText,
                            ),
                          ),
                        ];
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 36),
                  const ScribesOrnamentDivider(),
                  const SizedBox(height: 16),

                  // Translation Attribution Footer
                  Center(
                    child: Text(
                      'Berean Standard Bible, public domain',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next / Previous Chapter Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (navState.currentChapter > 1)
                        TextButton.icon(
                          onPressed: () {
                            ref
                                .read(bibleNavigationProvider.notifier)
                                .previousChapter();
                            _scrollToTop();
                          },
                          icon: Icon(Icons.chevron_left, color: colors.gold),
                          label: Text(
                            'Chapter ${navState.currentChapter - 1}',
                            style: ScribesTextStyles.labelLg.copyWith(
                              color: colors.gold,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (navState.currentChapter < navState.totalChapters)
                        TextButton.icon(
                          onPressed: () {
                            ref
                                .read(bibleNavigationProvider.notifier)
                                .nextChapter();
                            _scrollToTop();
                          },
                          icon: Icon(Icons.chevron_right, color: colors.gold),
                          label: Text(
                            'Chapter ${navState.currentChapter + 1}',
                            style: ScribesTextStyles.labelLg.copyWith(
                              color: colors.gold,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            loading: () => const Center(child: ScribesLoadingIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Could not load chapter: $e',
                  style: TextStyle(color: colors.secondaryText),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
