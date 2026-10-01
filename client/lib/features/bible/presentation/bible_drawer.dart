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
  final Map<String, TapGestureRecognizer> _recognizers = {};
  String _bookSearchFilter = '';
  BibleBook? _selectedBookForChapterPicker;
  List<int> _loadedChapters = [];
  String _loadedBook = '';

  TapGestureRecognizer _getOrCreateRecognizer(
    String book,
    int chapter,
    int verse,
  ) {
    final key = '${chapter}_$verse';
    if (!_recognizers.containsKey(key)) {
      _recognizers[key] = TapGestureRecognizer()
        ..onTap = () {
          ref
              .read(verseSelectionProvider.notifier)
              .toggleVerse(book, chapter, verse);
        };
    }
    return _recognizers[key]!;
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
    _verseScrollController.addListener(_onScroll);
    if (widget.initialBook != null && widget.initialChapter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(bibleNavigationProvider.notifier)
            .navigateTo(widget.initialBook!, widget.initialChapter!);
      });
    }
  }

  void _onScroll() {
    if (!_verseScrollController.hasClients) return;
    final pos = _verseScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 2500) {
      final navState = ref.read(bibleNavigationProvider);
      if (_loadedChapters.isNotEmpty && !navState.isBookPickerOpen) {
        final lastChapter = _loadedChapters.last;
        if (lastChapter < navState.totalChapters) {
          final next = lastChapter + 1;
          if (!_loadedChapters.contains(next)) {
            setState(() {
              _loadedChapters.add(next);
            });
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _clearRecognizers();
    _verseScrollController.removeListener(_onScroll);
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
    final settings = ref.watch(bibleReaderSettingsProvider);

    if (_loadedChapters.isEmpty ||
        _loadedBook != navState.currentBook ||
        !_loadedChapters.contains(navState.currentChapter)) {
      _loadedBook = navState.currentBook;
      _loadedChapters = [navState.currentChapter];
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors, navState),
      body: navState.isBookPickerOpen
          ? _buildBookPicker(context, colors, booksAsync)
          : _buildReader(context, ref, colors, settings, navState),
      bottomNavigationBar: navState.isBookPickerOpen
          ? null
          : _buildBottomNavBar(context, ref, colors, navState),
    );
  }

  Widget _buildReader(
    BuildContext context,
    WidgetRef ref,
    ScribesColors colors,
    BibleReaderSettings settings,
    BibleNavigationState navState,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _verseScrollController,
          cacheExtent: 2500,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            for (final chapNum in _loadedChapters)
              ..._buildChapterSlivers(context, ref, colors, settings, navState.currentBook, chapNum),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 140),
              sliver: SliverToBoxAdapter(
                child: _buildChapterFooter(context, ref, colors),
              ),
            ),
          ],
        ),
        Consumer(
          builder: (context, ref, child) {
            final selection = ref.watch(verseSelectionProvider);
            if (selection == null) return const SizedBox.shrink();
            final chapAsync = ref.watch(
              bibleChapterProvider(
                BibleChapterQuery(
                  book: navState.currentBook,
                  chapter: navState.currentChapter,
                ),
              ),
            );
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: BibleSelectionActionBar(
                  selection: selection,
                  chapter: chapAsync.value,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(
    BuildContext context,
    WidgetRef ref,
    ScribesColors colors,
    BibleNavigationState navState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.5), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous
              if (navState.currentChapter > 1)
                InkWell(
                  onTap: () {
                    _clearRecognizers();
                    ref.read(verseSelectionProvider.notifier).clear();
                    ref.read(bibleNavigationProvider.notifier).previousChapter();
                    _scrollToTop();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

              // Next
              if (navState.currentChapter < navState.totalChapters)
                InkWell(
                  onTap: () {
                    _clearRecognizers();
                    ref.read(verseSelectionProvider.notifier).clear();
                    ref.read(bibleNavigationProvider.notifier).nextChapter();
                    _scrollToTop();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.gold,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
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
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ScribesColors colors, BibleNavigationState navState) {
    return AppBar(
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
        onTap: () {
          if (navState.isBookPickerOpen) {
            setState(() => _selectedBookForChapterPicker = null);
          }
          ref.read(bibleNavigationProvider.notifier).toggleBookPicker();
        },
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
                    fontSize: 20,
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
    );
  }

  Widget _buildBookPicker(
    BuildContext context,
    ScribesColors colors,
    AsyncValue<List<BibleBook>> booksAsync,
  ) {
    if (_selectedBookForChapterPicker != null) {
      return _buildChapterPickerList(context, colors, _selectedBookForChapterPicker!);
    }
    return booksAsync.when(
      data: (books) => _buildBookPickerList(context, colors, books),
      loading: () => const Center(child: ScribesLoadingIndicator()),
      error: (e, _) {
        final fallbackBooks = ref.read(canonicalBibleBooksProvider);
        return _buildBookPickerList(context, colors, fallbackBooks);
      },
    );
  }

  Widget _buildBookPickerList(
    BuildContext context,
    ScribesColors colors,
    List<BibleBook> books,
  ) {
    final filteredBooks = _bookSearchFilter.isEmpty
        ? books
        : books
            .where(
              (b) => b.name.toLowerCase().contains(
                    _bookSearchFilter.toLowerCase(),
                  ),
            )
            .toList();

    final otBooks = filteredBooks.where((b) => b.isOldTestament).toList();
    final ntBooks = filteredBooks.where((b) => b.isNewTestament).toList();

    return Column(
      children: [
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              if (otBooks.isNotEmpty)
                _buildTestamentSection('Old Testament', otBooks, colors),
              if (otBooks.isNotEmpty && ntBooks.isNotEmpty)
                const SizedBox(height: 24),
              if (ntBooks.isNotEmpty)
                _buildTestamentSection('New Testament', ntBooks, colors),
              if (otBooks.isEmpty && ntBooks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No books found matching "$_bookSearchFilter"',
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
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
              height: 1.2
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
                setState(() => _selectedBookForChapterPicker = book);
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

  Widget _buildChapterPickerList(
    BuildContext context,
    ScribesColors colors,
    BibleBook book,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: colors.primaryText,
                  size: 22,
                ),
                onPressed: () => setState(() => _selectedBookForChapterPicker = null),
              ),
              const SizedBox(width: 8),
              Text(
                book.name,
                style: ScribesTextStyles.displayMd.copyWith(
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: book.chapterCount,
            itemBuilder: (context, index) {
              final chapterNum = index + 1;
              return InkWell(
                onTap: () {
                  _clearRecognizers();
                  ref.read(verseSelectionProvider.notifier).clear();
                  ref
                      .read(bibleNavigationProvider.notifier)
                      .navigateTo(book.name, chapterNum, totalChapters: book.chapterCount);
                  setState(() => _selectedBookForChapterPicker = null);
                  _scrollToTop();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    chapterNum.toString(),
                    style: ScribesTextStyles.labelLg.copyWith(
                      color: colors.primaryText,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChapterSlivers(
    BuildContext context,
    WidgetRef ref,
    ScribesColors colors,
    BibleReaderSettings settings,
    String book,
    int chapterNum,
  ) {
    final query = BibleChapterQuery(book: book, chapter: chapterNum);
    final chapterAsync = ref.watch(bibleChapterProvider(query));
    final highlightsAsync = ref.watch(chapterHighlightsProvider(query));
    final verseNotesAsync = ref.watch(chapterVerseNotesProvider(query));

    final highlightsMap = <int, String>{};
    highlightsAsync.whenData((list) {
      for (final h in list) {
        highlightsMap[h.verse] = h.colorHex;
      }
    });

    final notesMap = <int, String>{};
    verseNotesAsync.whenData((map) {
      notesMap.addAll(map);
    });

    return chapterAsync.when(
      data: (chapter) => [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          sliver: SliverToBoxAdapter(
            child: _buildChapterHeader(chapter, colors),
          ),
        ),
        if (settings.isVerseByVerse)
          _buildVerseByVerseSliver(
            chapter,
            colors,
            settings,
            highlightsMap,
            notesMap,
          )
        else
          _buildContinuousSliver(
            chapter,
            colors,
            settings,
            highlightsMap,
            notesMap,
          ),
      ],
      loading: () => [
        const SliverPadding(
          padding: EdgeInsets.all(40),
          sliver: SliverToBoxAdapter(child: Center(child: ScribesLoadingIndicator())),
        ),
      ],
      error: (e, _) => [
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: Text(
                'Could not load chapter: $e',
                style: TextStyle(color: colors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterHeader(
    BibleChapter chapter,
    ScribesColors colors,
  ) {
    return Center(
      child: Column(
        children: [
          Text(
            chapter.book,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: colors.primaryText,
              letterSpacing: 0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'CHAPTER ${chapter.chapter}',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.5,
              color: colors.gold,
            ),
          ),
          const SizedBox(height: 16),
          const ScribesOrnamentDivider(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildContinuousSliver(
    BibleChapter chapter,
    ScribesColors colors,
    BibleReaderSettings settings, [
    Map<int, String> highlights = const {},
    Map<int, String> notesMap = const {},
  ]) {
    final effectiveFontSize =
        settings.isSerif ? settings.fontSize * 1.12 : settings.fontSize;
    final lineHeight = settings.lineSpacing;
    final baseTextStyle = settings.isSerif
        ? GoogleFonts.cormorantGaramond(
            fontSize: effectiveFontSize,
            height: lineHeight,
            letterSpacing: 0.25,
            fontWeight: FontWeight.w600,
            color: colors.primaryText,
          )
        : GoogleFonts.dmSans(
            fontSize: effectiveFontSize,
            height: lineHeight,
            letterSpacing: 0.1,
            fontWeight: FontWeight.w500,
            color: colors.primaryText,
          );
    final numeralFontSize = (effectiveFontSize * 0.68).clamp(13.0, 16.0);

    // Chunk verses into logical paragraphs (e.g. 5 verses per chunk) to enable Sliver virtualization
    const chunkSize = 5;
    final chunks = <List<BibleVerse>>[];
    for (var i = 0; i < chapter.verses.length; i += chunkSize) {
      chunks.add(chapter.verses.sublist(
        i,
        i + chunkSize > chapter.verses.length ? chapter.verses.length : i + chunkSize,
      ));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final chunk = chunks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Consumer(
                builder: (context, ref, child) {
                  // Only rebuild this specific chunk if one of its verses is selected/deselected
                  ref.watch(
                    verseSelectionProvider.select((s) {
                      if (s == null) return '';
                      return chunk
                          .where((v) => s.contains(v.verse))
                          .map((v) => v.verse)
                          .join(',');
                    }),
                  );
                  final selection = ref.read(verseSelectionProvider);

                  return RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      style: baseTextStyle,
                      children: chunk.expand((verse) {
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
                          TextSpan(
                            text: ' ${verse.verse} ',
                            style: GoogleFonts.dmSans(
                              fontSize: numeralFontSize,
                              fontWeight: FontWeight.bold,
                              color: colors.gold,
                              backgroundColor: highlightBg,
                            ),
                            recognizer: _getOrCreateRecognizer(
                              chapter.book,
                              chapter.chapter,
                              verse.verse,
                            ),
                          ),
                          if (notesMap.containsKey(verse.verse))
                            TextSpan(
                              text: '✎ ',
                              style: GoogleFonts.dmSans(
                                fontSize: numeralFontSize * 0.9,
                                color: colors.orange,
                                backgroundColor: highlightBg,
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
                },
              ),
            );
          },
          childCount: chunks.length,
        ),
      ),
    );
  }

  Widget _buildChapterFooter(
    BuildContext context,
    WidgetRef ref,
    ScribesColors colors,
  ) {
    return Column(
      children: [
        const ScribesOrnamentDivider(),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVerseByVerseSliver(
    BibleChapter chapter,
    ScribesColors colors,
    BibleReaderSettings settings, [
    Map<int, String> highlights = const {},
    Map<int, String> notesMap = const {},
  ]) {
    final effectiveFontSize =
        settings.isSerif ? settings.fontSize * 1.12 : settings.fontSize;
    final lineHeight = settings.lineSpacing;
    final verseTextStyle = settings.isSerif
        ? GoogleFonts.cormorantGaramond(
            fontSize: effectiveFontSize,
            height: lineHeight,
            letterSpacing: 0.25,
            color: colors.primaryText,
            fontWeight: FontWeight.w600,
          )
        : GoogleFonts.dmSans(
            fontSize: effectiveFontSize,
            height: lineHeight,
            letterSpacing: 0.1,
            color: colors.primaryText,
            fontWeight: FontWeight.w500,
          );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final verse = chapter.verses[index];
            final userHighlightHex = highlights[verse.verse];
            final Color? highlightColor = userHighlightHex != null
                ? Color(int.parse(userHighlightHex.replaceFirst('#', '0xFF')))
                : null;

            return Consumer(
              builder: (context, ref, child) {
                // ONLY this specific verse will rebuild when it gets selected/deselected
                final isSelected = ref.watch(
                  verseSelectionProvider.select(
                    (s) => s?.contains(verse.verse) ?? false,
                  ),
                );

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                          width: 36,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${verse.verse}',
                                style: GoogleFonts.dmSans(
                                  fontSize:
                                      (effectiveFontSize * 0.72).clamp(14.0, 17.0),
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? colors.gold
                                      : colors.gold.withValues(alpha: 0.8),
                                ),
                              ),
                              if (notesMap.containsKey(verse.verse))
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Text(
                                    '✎',
                                    style: TextStyle(
                                      fontSize: (effectiveFontSize * 0.55).clamp(10.0, 13.0),
                                      color: colors.orange,
                                    ),
                                  ),
                                ),
                            ],
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
              },
            );
          },
          childCount: chapter.verses.length,
        ),
      ),
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
                    value: settings.fontSize.clamp(18.0, 32.0),
                    min: 18.0,
                    max: 32.0,
                    divisions: 7,
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
