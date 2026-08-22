import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/bible_data.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_text_field.dart';
import 'scribes_toast.dart';

enum _SelectorPhase { book, chapter, verse }

class ScribesScriptureSelector extends StatefulWidget {
  final bool isExplore;
  final dynamic colors;
  final Function(String book, int? chapter, int? verseStart, int? verseEnd)
  onSelected;

  const ScribesScriptureSelector({
    super.key,
    this.isExplore = false,
    required this.colors,
    required this.onSelected,
  });

  @override
  State<ScribesScriptureSelector> createState() =>
      _ScribesScriptureSelectorState();

  static Future<void> show(
    BuildContext context, {
    bool isExplore = false,
    required dynamic colors,
    required Function(String book, int? chapter, int? verseStart, int? verseEnd)
    onSelected,
  }) {
    // Unfocus background inputs before presenting sheet to prevent transition collision
    FocusManager.instance.primaryFocus?.unfocus();

    return showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ScribesScriptureSelector(
          isExplore: isExplore,
          colors: colors,
          onSelected: onSelected,
        );
      },
    );
  }
}

class _ScribesScriptureSelectorState extends State<ScribesScriptureSelector> {
  _SelectorPhase _phase = _SelectorPhase.book;
  String? _selectedBook;
  int? _selectedChapter;
  final _searchController = TextEditingController();
  final _verseStartController = TextEditingController();
  final _verseEndController = TextEditingController();

  String get _title {
    switch (_phase) {
      case _SelectorPhase.book:
        return 'Select Book';
      case _SelectorPhase.chapter:
        return 'Select Chapter';
      case _SelectorPhase.verse:
        return 'Select Verse';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _verseStartController.dispose();
    _verseEndController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_phase) {
      case _SelectorPhase.book:
        content = _buildBookSelection();
        break;
      case _SelectorPhase.chapter:
        content = _buildChapterSelection();
        break;
      case _SelectorPhase.verse:
        content = _buildVerseSelection();
        break;
    }

    final mediaQuery = MediaQuery.of(context);
    final viewInsetsBottom = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    // Stable, bounded height that adjusts dynamically with the keyboard transition
    final contentHeight = (screenHeight * 0.70 - viewInsetsBottom).clamp(
      220.0,
      screenHeight * 0.70,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: viewInsetsBottom + 12,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_phase != _SelectorPhase.book)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: widget.colors.primaryText,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_phase == _SelectorPhase.verse) {
                            _phase = _SelectorPhase.chapter;
                          } else {
                            _phase = _SelectorPhase.book;
                          }
                        });
                      },
                    ),
                  ),
                Text(
                  _title,
                  style: ScribesTextStyles.displayMd.copyWith(
                    color: widget.colors.primaryText,
                  ),
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: widget.colors.secondaryText,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: contentHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSelection() {
    final query = _searchController.text.trim().toLowerCase();

    final filteredOt = query.isEmpty
        ? oldTestamentBooks.keys.toList()
        : oldTestamentBooks.keys
            .where((b) => b.toLowerCase().contains(query))
            .toList();

    final filteredNt = query.isEmpty
        ? newTestamentBooks.keys.toList()
        : newTestamentBooks.keys
            .where((b) => b.toLowerCase().contains(query))
            .toList();

    return Column(
      key: const ValueKey('book'),
      children: [
        // Quick Search Bar
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: ScribesTextStyles.bodyMd.copyWith(
              color: widget.colors.primaryText,
            ),
            decoration: InputDecoration(
              hintText: 'Search books (e.g. Romans, Genesis)...',
              hintStyle: ScribesTextStyles.bodyMd.copyWith(
                color: widget.colors.secondaryText,
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: widget.colors.secondaryText,
                size: 18,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: widget.colors.secondaryText,
                        size: 16,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: widget.colors.surfaceRaised,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.colors.gold),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              if (filteredOt.isNotEmpty) ...[
                Text(
                  'Old Testament',
                  style: ScribesTextStyles.labelSm.copyWith(
                    color: widget.colors.secondaryText,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: filteredOt
                      .map((book) => _buildBookChip(book))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              if (filteredNt.isNotEmpty) ...[
                Text(
                  'New Testament',
                  style: ScribesTextStyles.labelSm.copyWith(
                    color: widget.colors.secondaryText,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: filteredNt
                      .map((book) => _buildBookChip(book))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              if (filteredOt.isEmpty && filteredNt.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'No matching books found.',
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: widget.colors.secondaryText,
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

  Widget _buildBookChip(String book) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _selectedBook = book;
          _phase = _SelectorPhase.chapter;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.colors.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.colors.border),
        ),
        child: Text(
          book,
          style: ScribesTextStyles.labelLg.copyWith(
            color: widget.colors.primaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildChapterSelection() {
    final maxChapters = allBibleBooks[_selectedBook!]!;
    return Column(
      key: const ValueKey('chapter'),
      children: [
        if (widget.isExplore)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by entire book?',
                  style: ScribesTextStyles.bodyMd.copyWith(
                    color: widget.colors.secondaryText,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colors.primaryText,
                    foregroundColor: widget.colors.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    widget.onSelected(_selectedBook!, null, null, null);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Any Chapter',
                    style: ScribesTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: GridView.builder(
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: maxChapters,
            itemBuilder: (context, index) {
              final chapter = index + 1;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedChapter = chapter;
                    if (widget.isExplore) {
                      widget.onSelected(
                        _selectedBook!,
                        _selectedChapter,
                        null,
                        null,
                      );
                      Navigator.pop(context);
                    } else {
                      _phase = _SelectorPhase.verse;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.colors.border),
                  ),
                  child: Text(
                    '$chapter',
                    style: ScribesTextStyles.displayMd.copyWith(
                      color: widget.colors.primaryText,
                      fontSize: 20,
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

  Widget _buildVerseSelection() {
    return SingleChildScrollView(
      key: const ValueKey('verse'),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.colors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  size: 18,
                  color: widget.colors.primaryText,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_selectedBook $_selectedChapter',
                  style: ScribesTextStyles.labelLg.copyWith(
                    color: widget.colors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ScribesTextField(
                  controller: _verseStartController,
                  keyboardType: TextInputType.number,
                  labelText: 'Verse Start',
                  autofocus: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '-',
                  style: ScribesTextStyles.displayMd.copyWith(
                    color: widget.colors.secondaryText,
                  ),
                ),
              ),
              Expanded(
                child: ScribesTextField(
                  controller: _verseEndController,
                  keyboardType: TextInputType.number,
                  labelText: 'Verse End (Opt)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colors.primaryText,
                foregroundColor: widget.colors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final start = int.tryParse(_verseStartController.text);
                final end = int.tryParse(_verseEndController.text);

                if (start == null) {
                  ScribesToast.show(
                    context,
                    'Please enter a valid start verse.',
                    widget.colors,
                    isError: true,
                  );
                  return;
                }

                if (end != null && end <= start) {
                  ScribesToast.show(
                    context,
                    'End verse must be greater than start verse.',
                    widget.colors,
                    isError: true,
                  );
                  return;
                }

                widget.onSelected(_selectedBook!, _selectedChapter, start, end);
                Navigator.pop(context);
              },
              child: Text(
                'Add Scripture Tag',
                style: ScribesTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
