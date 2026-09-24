import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/scribes_colors.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_ornament_divider.dart';
import '../application/bible_providers.dart';
import '../application/verse_selection_provider.dart';
import '../domain/bible_models.dart';
import '../domain/verse_selection.dart';
import 'bible_search_sheet.dart';
import 'widgets/bible_selection_action_bar.dart';
import 'widgets/bible_translations_sheet.dart';

class BibleDrawerScreen extends ConsumerStatefulWidget {
  final String? initialBook;
  final int? initialChapter;

  const BibleDrawerScreen({super.key, this.initialBook, this.initialChapter});

  @override
  ConsumerState<BibleDrawerScreen> createState() => _BibleDrawerScreenState();
}

class _BibleDrawerScreenState extends ConsumerState<BibleDrawerScreen> {
  final ScrollController _verseScrollController = ScrollController();
  final Map<int, TapGestureRecognizer> _recognizers = {};
  String _bookSearchFilter = '';

  TapGestureRecognizer _getOrCreateRecognizer(
    String book,
    int chapter,
    int verse,
  ) {
    if (!_recognizers.containsKey(verse)) {
      _recognizers[verse] = TapGestureRecognizer()
        ..onTap = () {
          ref
              .read(verseSelectionProvider.notifier)
              .toggleVerse(book, chapter, verse);
        };
    }
    return _recognizers[verse]!;
  }

  void _clearRecognizers() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();
  }

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
    _clearRecognizers();
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

  void _showAppearanceSheet(BuildContext context, ScribesColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _BibleAppearanceSheet(colors: colors),
    );
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
          visualDensity: VisualDensity.compact,
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: colors.primaryText,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: InkWell(
          onTap: () =>
              ref.read(bibleNavigationProvider.notifier).toggleBookPicker(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.6),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '${navState.currentBook} ${navState.currentChapter}',
                    style: ScribesTextStyles.displayMd.copyWith(
                      color: colors.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  navState.isBookPickerOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: colors.gold,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final selectedTranslation = ref.watch(selectedTranslationProvider);

              return InkWell(
                onTap: () => BibleTranslationsSheet.show(context, colors),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: colors.gold.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedTranslation,
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.gold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.keyboard_arrow_down, size: 12, color: colors.gold),
                    ],
                  ),
                ),
              );
            },
          ),

          // Appearance / Aa Settings Button
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedText,
              color: colors.primaryText,
              size: 20,
            ),
            tooltip: 'Reader Appearance',
            onPressed: () => _showAppearanceSheet(context, colors),
          ),

          // Search Button
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: colors.secondaryText,
              size: 20,
            ),
            tooltip: 'Search Scripture',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const BibleSearchSheet(),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: colors.border.withValues(alpha: 0.4),
            height: 1,
            thickness: 0.5,
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
        final filteredBooks = _bookSearchFilter.isEmpty
            ? books
            : books
                .where(
                  (b) => b.name.toLowerCase().contains(
                        _bookSearchFilter.toLowerCase(),
                      ),
                )
                .toList();

        final otBooks =
            filteredBooks.where((b) => b.testament == 'old').toList();
        final ntBooks =
            filteredBooks.where((b) => b.testament == 'new').toList();

        return Column(
          children: [
            // Search Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _bookSearchFilter = value),
                style: ScribesTextStyles.bodyMd.copyWith(
                  color: colors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: 'Search books of the Bible...',
                  hintStyle: ScribesTextStyles.bodyMd.copyWith(
                    color: colors.secondaryText.withValues(alpha: 0.6),
                  ),
                  prefixIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: colors.secondaryText,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: colors.surfaceRaised,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.border.withValues(alpha: 0.4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.gold, width: 1.0),
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  if (otBooks.isNotEmpty)
                    _buildTestamentSection('Old Testament', otBooks, colors),
                  if (otBooks.isNotEmpty && ntBooks.isNotEmpty)
                    const SizedBox(height: 24),
                  if (ntBooks.isNotEmpty)
                    _buildTestamentSection('New Testament', ntBooks, colors),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: ScribesLoadingIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Failed to load books: $e',
            style: TextStyle(color: colors.secondaryText),
          ),
        ),
      ),
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
          padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
          child: Text(
            title.toUpperCase(),
            style: ScribesTextStyles.caption.copyWith(
              color: colors.gold,
              fontWeight: FontWeight.w700,
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
                _clearRecognizers();
                ref.read(verseSelectionProvider.notifier).clear();
                ref.read(bibleNavigationProvider.notifier).selectBook(book);
                _scrollToTop();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.gold
                      : colors.surfaceRaised.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? colors.gold
                        : colors.border.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  book.name,
                  style: ScribesTextStyles.labelLg.copyWith(
                    color: isSelected ? colors.background : colors.primaryText,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
    final highlightsAsync = ref.watch(
      chapterHighlightsProvider(
        BibleChapterQuery(
          book: navState.currentBook,
          chapter: navState.currentChapter,
        ),
      ),
    );
    final highlightsMap = <int, String>{};
    highlightsAsync.whenData((list) {
      for (final h in list) {
        highlightsMap[h.verse] = h.colorHex;
      }
    });

    final settings = ref.watch(bibleReaderSettingsProvider);
    final selection = ref.watch(verseSelectionProvider);

    return Column(
      children: [
        // Modern Chapter Capsule Slider
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              bottom: BorderSide(
                color: colors.border.withValues(alpha: 0.3),
                width: 0.5,
              ),
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
                  _clearRecognizers();
                  ref.read(verseSelectionProvider.notifier).clear();
                  ref
                      .read(bibleNavigationProvider.notifier)
                      .selectChapter(chapterNum);
                  _scrollToTop();
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? colors.gold
                        : colors.surfaceRaised.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCurrent
                          ? colors.gold
                          : colors.border.withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    chapterNum.toString(),
                    style: ScribesTextStyles.labelSm.copyWith(
                      color: isCurrent
                          ? colors.background
                          : colors.secondaryText,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Chapter verse content with floating selection action bar
        Expanded(
          child: Stack(
            children: [
              chapterAsync.when(
                data: (chapter) => SingleChildScrollView(
                  controller: _verseScrollController,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    28,
                    24,
                    selection != null ? 140 : 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Illuminated Chapter Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              chapter.book.toUpperCase(),
                              style: ScribesTextStyles.caption.copyWith(
                                color: colors.gold,
                                letterSpacing: 4.0,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${chapter.chapter}',
                              style: settings.isSerif
                                  ? GoogleFonts.cormorantGaramond(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w300,
                                      color: colors.primaryText,
                                      height: 1.1,
                                    )
                                  : GoogleFonts.dmSans(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w300,
                                      color: colors.primaryText,
                                      height: 1.1,
                                    ),
                            ),
                            const SizedBox(height: 14),
                            const ScribesOrnamentDivider(),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),

                      // Scripture Reading Typesetting
                      if (settings.isVerseByVerse)
                        _buildVerseByVerse(
                          chapter,
                          colors,
                          settings,
                          selection,
                          highlightsMap,
                        )
                      else
                        _buildContinuousParagraphs(
                          chapter,
                          colors,
                          settings,
                          selection,
                          highlightsMap,
                        ),

                      const SizedBox(height: 48),
                      const ScribesOrnamentDivider(),
                      const SizedBox(height: 16),

                      // Translation Attribution Footer
                      Center(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final selectedTranslation = ref.watch(selectedTranslationProvider);
                            final translationsAsync = ref.watch(bibleTranslationsProvider);
                            final attribution = translationsAsync.maybeWhen(
                              data: (translations) {
                                final match = translations
                                    .where((t) => t.code.toUpperCase() == selectedTranslation.toUpperCase())
                                    .firstOrNull;
                                return match?.attributionText ?? '$selectedTranslation, public domain';
                              },
                              orElse: () => '$selectedTranslation, public domain',
                            );
                            return Text(
                              attribution,
                              style: ScribesTextStyles.caption.copyWith(
                                color: colors.secondaryText.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Modern Chapter Pagination Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (navState.currentChapter > 1)
                            InkWell(
                              onTap: () {
                                _clearRecognizers();
                                ref.read(verseSelectionProvider.notifier).clear();
                                ref
                                    .read(bibleNavigationProvider.notifier)
                                    .previousChapter();
                                _scrollToTop();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceRaised,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colors.border.withValues(alpha: 0.5),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedArrowLeft01,
                                      color: colors.gold,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Chapter ${navState.currentChapter - 1}',
                                      style: ScribesTextStyles.labelLg.copyWith(
                                        color: colors.primaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          if (navState.currentChapter < navState.totalChapters)
                            InkWell(
                              onTap: () {
                                _clearRecognizers();
                                ref.read(verseSelectionProvider.notifier).clear();
                                ref
                                    .read(bibleNavigationProvider.notifier)
                                    .nextChapter();
                                _scrollToTop();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.gold,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Chapter ${navState.currentChapter + 1}',
                                      style: ScribesTextStyles.labelLg.copyWith(
                                        color: colors.background,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedArrowRight01,
                                      color: colors.background,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 48),
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

              // Floating Contextual Glass Action Bar
              if (selection != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: BibleSelectionActionBar(
                      selection: selection,
                      chapter: chapterAsync.value,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Modern Continuous Paragraph Layout with Elevated Verse Numerals
  Widget _buildContinuousParagraphs(
    BibleChapter chapter,
    ScribesColors colors,
    BibleReaderSettings settings,
    VerseSelection? selection, [
    Map<int, String> highlights = const {},
  ]) {
    final fontSize = settings.fontSize;
    final lineHeight = settings.lineSpacing;
    final baseTextStyle = settings.isSerif
        ? GoogleFonts.cormorantGaramond(
            fontSize: fontSize,
            height: lineHeight,
            letterSpacing: 0.25,
            fontWeight: FontWeight.w600,
            color: colors.primaryText,
          )
        : GoogleFonts.dmSans(
            fontSize: fontSize,
            height: lineHeight,
            letterSpacing: 0.1,
            fontWeight: FontWeight.w500,
            color: colors.primaryText,
          );

    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: baseTextStyle,
        children: chapter.verses.expand((verse) {
          final cleanText = verse.text.trim();
          final isSelected = selection?.contains(verse.verse) ?? false;
          final userHighlightHex = highlights[verse.verse];
          final Color? highlightColor = userHighlightHex != null
              ? Color(int.parse(userHighlightHex.replaceFirst('#', '0xFF')))
              : null;

          final highlightBg = isSelected
              ? colors.gold.withValues(alpha: 0.25)
              : highlightColor != null
                  ? highlightColor.withValues(alpha: 0.22)
                  : Colors.transparent;

          return [
            // Elevated SuperScript Verse Numeral
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(verseSelectionProvider.notifier)
                      .toggleVerse(chapter.book, chapter.chapter, verse.verse);
                },
                child: Container(
                  color: highlightBg,
                  padding: const EdgeInsets.only(right: 5.0, left: 3.0),
                  child: Text(
                    '${verse.verse}',
                    style: GoogleFonts.dmSans(
                      fontSize: fontSize * 0.52,
                      fontWeight: FontWeight.w700,
                      color: colors.gold,
                    ),
                  ),
                ),
              ),
            ),
            TextSpan(
              text: '$cleanText ',
              style: TextStyle(
                backgroundColor: highlightBg,
              ),
              recognizer: _getOrCreateRecognizer(
                chapter.book,
                chapter.chapter,
                verse.verse,
              ),
            ),
          ];
        }).toList(),
      ),
    );
  }

  /// Modern Verse-by-Verse Layout for Clear Study & Exegesis
  Widget _buildVerseByVerse(
    BibleChapter chapter,
    ScribesColors colors,
    BibleReaderSettings settings,
    VerseSelection? selection, [
    Map<int, String> highlights = const {},
  ]) {
    final fontSize = settings.fontSize;
    final lineHeight = settings.lineSpacing;
    final verseTextStyle = settings.isSerif
        ? GoogleFonts.cormorantGaramond(
            fontSize: fontSize,
            height: lineHeight,
            letterSpacing: 0.25,
            color: colors.primaryText,
            fontWeight: FontWeight.w600,
          )
        : GoogleFonts.dmSans(
            fontSize: fontSize,
            height: lineHeight,
            letterSpacing: 0.1,
            color: colors.primaryText,
            fontWeight: FontWeight.w500,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: chapter.verses.map((verse) {
        final isSelected = selection?.contains(verse.verse) ?? false;
        final userHighlightHex = highlights[verse.verse];
        final Color? highlightColor = userHighlightHex != null
            ? Color(int.parse(userHighlightHex.replaceFirst('#', '0xFF')))
            : null;

        final itemBg = isSelected
            ? colors.gold.withValues(alpha: 0.18)
            : highlightColor != null
                ? highlightColor.withValues(alpha: 0.20)
                : Colors.transparent;

        return InkWell(
          onTap: () {
            ref
                .read(verseSelectionProvider.notifier)
                .toggleVerse(chapter.book, chapter.chapter, verse.verse);
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            margin: const EdgeInsets.only(bottom: 8.0),
            decoration: BoxDecoration(
              color: itemBg,
              borderRadius: BorderRadius.circular(8),
              border: highlightColor != null && !isSelected
                  ? Border.all(
                      color: highlightColor.withValues(alpha: 0.45),
                      width: 0.8,
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column Verse Numeral
                SizedBox(
                  width: 32,
                  child: Text(
                    '${verse.verse}',
                    style: GoogleFonts.dmSans(
                      fontSize: fontSize * 0.58,
                      fontWeight: FontWeight.w700,
                      color: colors.gold,
                    ),
                  ),
                ),
                // Right Column Verse Text
                Expanded(
                  child: Text(
                    verse.text.trim(),
                    style: verseTextStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Reader Appearance (Aa) Bottom Sheet
class _BibleAppearanceSheet extends ConsumerWidget {
  final ScribesColors colors;

  const _BibleAppearanceSheet({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(bibleReaderSettingsProvider);
    final notifier = ref.read(bibleReaderSettingsProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ScribesRadius.sheet),
        ),
        border: Border(
          top: BorderSide(
            color: colors.border.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pill Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.secondaryText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Text(
              'Reader Appearance',
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),

            // 1. Text Size Control
            Text(
              'TEXT SIZE',
              style: ScribesTextStyles.caption.copyWith(
                color: colors.secondaryText,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'A',
                  style: ScribesTextStyles.bodyMd.copyWith(
                    color: colors.secondaryText,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: settings.fontSize,
                    min: 17.0,
                    max: 29.0,
                    divisions: 6,
                    activeColor: colors.gold,
                    inactiveColor: colors.surfaceRaised,
                    onChanged: (val) => notifier.setFontSize(val),
                  ),
                ),
                Text(
                  'A',
                  style: ScribesTextStyles.displayMd.copyWith(
                    color: colors.primaryText,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: colors.border.withValues(alpha: 0.3), height: 1),
            const SizedBox(height: 18),

            // 2. Typeface Toggle (Serif vs Sans)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Typeface',
                      style: ScribesTextStyles.labelLg.copyWith(
                        color: colors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.isSerif ? 'Cormorant Garamond ' : 'DM Sans',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(
                        'Serif',
                        style: GoogleFonts.cormorantGaramond(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(
                        'Sans',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  selected: {settings.isSerif},
                  onSelectionChanged: (_) => notifier.toggleFontFamily(),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return colors.gold.withValues(alpha: 0.14);
                      }
                      return colors.surfaceRaised;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return colors.gold;
                      }
                      return colors.secondaryText;
                    }),
                    side: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return BorderSide(color: colors.goldEdgeActive, width: 1.0);
                      }
                      return BorderSide(color: colors.border.withValues(alpha: 0.5), width: 0.8);
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: colors.border.withValues(alpha: 0.3), height: 1),
            const SizedBox(height: 18),

            // 3. Layout Mode (Continuous vs Verse-by-Verse)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reading Layout',
                      style: ScribesTextStyles.labelLg.copyWith(
                        color: colors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.isVerseByVerse ? 'Verse-by-Verse (Study)' : 'Continuous Flow (Reader)',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: settings.isVerseByVerse,
                  activeThumbColor: colors.gold,
                  onChanged: (_) => notifier.toggleLayout(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
