import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../data/bible_repository.dart';
import '../domain/bible_models.dart';
import '../application/bible_providers.dart';

class BibleSearchSheet extends ConsumerStatefulWidget {
  final void Function(String book, int chapter, int verse)? onSelectVerse;

  const BibleSearchSheet({super.key, this.onSelectVerse});

  @override
  ConsumerState<BibleSearchSheet> createState() => _BibleSearchSheetState();
}

class _BibleSearchSheetState extends ConsumerState<BibleSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<BibleSearchResult> _results = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String _searchedQuery = '';

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _searchedQuery = '';
        _isLoading = false;
        _isOffline = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isOffline = false;
    });

    try {
      final repo = ref.read(bibleRepositoryProvider);
      final results = await repo.search(trimmed, limit: 30);
      if (mounted) {
        setState(() {
          _results = results;
          _searchedQuery = trimmed;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isOffline = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ScribesRadius.sheet),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Scripture',
                  style: ScribesTextStyles.displayMd.copyWith(
                    color: colors.primaryText,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.secondaryText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ScribesTextField(
              controller: _searchCtrl,
              hintText: 'Search words, phrases (e.g. steadfast love)...',
              prefixIcon: Icon(
                Icons.search,
                color: colors.secondaryText,
                size: 20,
              ),
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _performSearch,
            ),
          ),

          const SizedBox(height: 8),

          // Results / Loading / Empty / Offline State
          Expanded(
            child: _isLoading
                ? const Center(child: ScribesLoadingIndicator())
                : _isOffline
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: colors.goldMuted,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Search needs a connection.',
                            style: ScribesTextStyles.displayMd.copyWith(
                              color: colors.primaryText,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'All 66 books of the Bible are available offline for browsing.',
                            textAlign: TextAlign.center,
                            style: ScribesTextStyles.bodyMd.copyWith(
                              color: colors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colors.goldMuted),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(
                              Icons.menu_book,
                              size: 16,
                              color: colors.gold,
                            ),
                            label: Text(
                              'Browse by Book',
                              style: ScribesTextStyles.labelLg.copyWith(
                                color: colors.gold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              ref
                                  .read(bibleNavigationProvider.notifier)
                                  .toggleBookPicker();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : _searchedQuery.isEmpty
                ? Center(
                    child: Text(
                      'Type a phrase to search the Scriptures',
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  )
                : _results.isEmpty
                ? Center(
                    child: Text(
                      'No verses found matching "$_searchedQuery"',
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    itemCount: _results.length,
                    separatorBuilder: (_, _) =>
                        Divider(color: colors.border.withValues(alpha: 0.5)),
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      return InkWell(
                        onTap: () {
                          if (widget.onSelectVerse != null) {
                            widget.onSelectVerse!(
                              item.book,
                              item.chapter,
                              item.verse,
                            );
                          } else {
                            ref
                                .read(bibleNavigationProvider.notifier)
                                .navigateTo(item.book, item.chapter);
                            Navigator.of(context).pop();
                          }
                        },
                        borderRadius: BorderRadius.circular(
                          ScribesRadius.button,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.reference,
                                style: ScribesTextStyles.labelLg.copyWith(
                                  color: colors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.text,
                                style: ScribesTextStyles.bodyMd.copyWith(
                                  color: colors.primaryText,
                                  fontFamily: 'CormorantGaramond',
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
