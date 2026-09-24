import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/audio/scribes_audio_player.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../../core/widgets/scribes_bounce_button.dart';
import '../../../core/widgets/scribes_image_resolver.dart';
import '../../../core/widgets/scribes_ornament_divider.dart';
import '../../posts/data/post_repository.dart';
import '../../posts/domain/post.dart';
import '../../social/application/post_social_providers.dart';
import '../../bible/data/bible_repository.dart';

class PassageViewerScreen extends ConsumerStatefulWidget {
  final String postId;

  const PassageViewerScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<PassageViewerScreen> createState() =>
      _PassageViewerScreenState();
}

class _PassageViewerScreenState extends ConsumerState<PassageViewerScreen> {
  final PageController _pageController = PageController();
  final ScribesAudioPlayer _audioPlayer = ScribesAudioPlayer.instance;
  int _currentPage = 0;
  Post? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      final repo = ref.read(postRepositoryProvider);
      final post = await repo.getPost(widget.postId);
      if (mounted) {
        setState(() {
          _post = post;
          _isLoading = false;
        });

        // Start ambient sound if attached
        if (post.sound != null && post.sound!.audioUrl.isNotEmpty) {
          _audioPlayer.playLoop(post.sound!.audioUrl);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(int totalPages) {
    if (_currentPage < totalPages - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: colors.gold,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_error != null || _post == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load passage',
                style: ScribesTextStyles.displayMd.copyWith(
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Go Back', style: TextStyle(color: colors.gold)),
              ),
            ],
          ),
        ),
      );
    }

    final panels = _post!.panels;
    final totalPages = panels.length + 1; // +1 for the completion card

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Horizontal PageView
            PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                if (index < panels.length) {
                  return _buildPanelCard(panels[index], index, colors);
                } else {
                  return _buildCompletionCard(_post!, colors);
                }
              },
            ),

            // 2. Tap Left/Right Navigation overlay zones
            Positioned(
              left: 0,
              top: 80,
              bottom: 80,
              width: MediaQuery.of(context).size.width * 0.22,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _previousPage,
              ),
            ),
            Positioned(
              right: 0,
              top: 80,
              bottom: 80,
              width: MediaQuery.of(context).size.width * 0.22,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _nextPage(totalPages),
              ),
            ),

            // 3. Top Header Bar (Close, Progress Dashes, Sound Pill)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: colors.background.withValues(alpha: 0.85),
                child: Column(
                  children: [
                    // Segmented Progress Dashes
                    Row(
                      children: List.generate(totalPages, (i) {
                        final isPassed = i <= _currentPage;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            decoration: BoxDecoration(
                              color: isPassed
                                  ? colors.gold
                                  : colors.border.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),

                    // Actions Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: colors.primaryText,
                            size: 22,
                          ),
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),

                        // Ambient Sound Controller Pill
                        if (_post!.sound != null)
                          ValueListenableBuilder<bool>(
                            valueListenable: _audioPlayer.isMutedNotifier,
                            builder: (context, isMuted, _) {
                              return GestureDetector(
                                onTap: () => _audioPlayer.toggleMute(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(
                                      ScribesRadius.chip,
                                    ),
                                    border: Border.all(
                                      color: colors.gold.withValues(alpha: 0.4),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon: isMuted
                                            ? HugeIcons.strokeRoundedVolumeLow
                                            : HugeIcons
                                                .strokeRoundedMusicNote02,
                                        color: colors.gold,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _post!.sound!.title,
                                        style:
                                            ScribesTextStyles.caption.copyWith(
                                          color: colors.gold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelCard(
    dynamic panel,
    int index,
    dynamic colors,
  ) {
    final panelType = panel.panelType as String;
    final bgUrl = panel.backgroundImageUrl as String?;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 70, 20, 20),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image if present
            if (bgUrl != null && bgUrl.isNotEmpty) ...[
              Positioned.fill(
                child: Builder(builder: (context) {
                  final size = MediaQuery.sizeOf(context);
                  final cacheW = ScribesImageResolver.computeCacheWidth(context, size.width);
                  final cacheH = ScribesImageResolver.computeCacheHeight(context, size.height);
                  return ScribesImageResolver.buildImage(
                    imageUrl: bgUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: cacheW,
                    memCacheHeight: cacheH,
                  );
                }),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black38, Colors.black87],
                    ),
                  ),
                ),
              ),
            ],

            // Content Body
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Center(
                child: SingleChildScrollView(
                  child: _buildPanelContent(panel, panelType, bgUrl != null, colors),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelContent(
    dynamic panel,
    String type,
    bool hasBgImage,
    dynamic colors,
  ) {
    final content = panel.content is Map ? panel.content as Map : {};
    final textColor = hasBgImage ? Colors.white : colors.primaryText;
    final secondaryTextColor =
        hasBgImage ? Colors.white70 : colors.secondaryText;

    switch (type) {
      case 'text':
        final text = content['text']?.toString() ?? '';
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedQuillWrite02,
              color: colors.gold,
              size: 28,
            ),
            const SizedBox(height: 20),
            Text(
              text,
              textAlign: TextAlign.center,
              style: ScribesTextStyles.bodyLg.copyWith(
                color: textColor,
                fontSize: 20,
                height: 1.65,
              ),
            ),
          ],
        );

      case 'scripture':
        final refMap = panel.scriptureRef is Map ? panel.scriptureRef as Map : {};
        final book = refMap['book'] ?? 'Scripture';
        final chapter = refMap['chapter'] ?? '';
        final vStart = refMap['verse_start'] ?? '';
        final vEnd = refMap['verse_end'] != null ? '-${refMap['verse_end']}' : '';
        final verseRef = '$book $chapter:$vStart$vEnd';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(ScribesRadius.chip),
                border: Border.all(
                  color: colors.gold.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: Text(
                verseRef,
                style: ScribesTextStyles.caption.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildScriptureVerseText(
              content['text']?.toString(),
              book.toString(),
              chapter.toString(),
              vStart.toString(),
              vEnd.toString(),
              textColor,
              colors,
            ),
            const SizedBox(height: 20),
            Text(
              'Berean Standard Bible, public domain',
              style: ScribesTextStyles.caption.copyWith(
                color: secondaryTextColor,
                fontSize: 11,
              ),
            ),
          ],
        );

      case 'reflection':
        final prompt = content['text']?.toString() ?? '';
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedHelpCircle,
              color: colors.gold,
              size: 28,
            ),
            const SizedBox(height: 16),
            Text(
              'Contemplation',
              style: ScribesTextStyles.caption.copyWith(
                color: colors.gold,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              prompt,
              textAlign: TextAlign.center,
              style: ScribesTextStyles.displayMd.copyWith(
                color: textColor,
                fontSize: 22,
                fontStyle: FontStyle.italic,
                height: 1.55,
              ),
            ),
          ],
        );

      case 'image':
        final caption = content['caption']?.toString() ?? '';
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (caption.isNotEmpty)
              Text(
                caption,
                textAlign: TextAlign.center,
                style: ScribesTextStyles.bodyLg.copyWith(
                  color: textColor,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCompletionCard(Post post, dynamic colors) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 70, 20, 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.gold.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ScribesOrnamentDivider(),
              const SizedBox(height: 24),
              Text(
                'Devotional Complete',
                style: ScribesTextStyles.displayLg.copyWith(
                  color: colors.primaryText,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'May this scripture and contemplation bear fruit in your walk.',
                textAlign: TextAlign.center,
                style: ScribesTextStyles.bodyMd.copyWith(
                  color: colors.secondaryText,
                ),
              ),
              const SizedBox(height: 28),

              // Author Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScribesAvatar(
                    imageUrl: post.authorAvatarUrl,
                    authorName: post.authorName,
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '@${post.authorHandle}',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Liturgical Reaction Bar (Amen, Insightful, Thought-Provoking)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildReactionButton(
                    'Amen',
                    post.amenCount,
                    'amen',
                    HugeIcons.strokeRoundedFire,
                    colors,
                  ),
                  _buildReactionButton(
                    'Insight',
                    post.insightCount,
                    'insightful',
                    HugeIcons.strokeRoundedIdea01,
                    colors,
                  ),
                  _buildReactionButton(
                    'Deep',
                    post.thoughtProvokingCount,
                    'thought_provoking',
                    HugeIcons.strokeRoundedDroplet,
                    colors,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionButton(
    String label,
    int count,
    String type,
    dynamic iconData,
    dynamic colors,
  ) {
    return ScribesBounceButton(
      onTap: () async {
        await ref.read(postReactionsProvider(widget.postId).notifier).react(
              type,
              initialAmenCount: _post?.amenCount,
              initialInsightCount: _post?.insightCount,
              initialThoughtProvokingCount: _post?.thoughtProvokingCount,
            );
        _loadPost();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(ScribesRadius.button),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            HugeIcon(
              icon: iconData,
              color: colors.gold,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: ScribesTextStyles.caption.copyWith(
                color: colors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count',
              style: ScribesTextStyles.caption.copyWith(
                color: colors.secondaryText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScriptureVerseText(
    String? explicitText,
    String book,
    String chapter,
    String vStart,
    String vEnd,
    Color textColor,
    dynamic colors,
  ) {
    if (explicitText != null && explicitText.trim().isNotEmpty) {
      final cleanText = explicitText.trim().replaceAll(RegExp(r'^“|”$'), '');
      return Text(
        '“$cleanText”',
        textAlign: TextAlign.center,
        style: ScribesTextStyles.displayMd.copyWith(
          color: textColor,
          fontSize: 24,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      );
    }

    final chInt = int.tryParse(chapter);
    final vStartInt = int.tryParse(vStart);
    if (book.isNotEmpty &&
        book != 'Scripture' &&
        chInt != null &&
        vStartInt != null) {
      final rangeStr = vEnd.isNotEmpty ? '$vStartInt$vEnd' : '$vStartInt';
      return FutureBuilder(
        future: ref
            .read(bibleRepositoryProvider)
            .getVerseRange(book, chInt, rangeStr),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
              '“${snapshot.data!.fullText}”',
              textAlign: TextAlign.center,
              style: ScribesTextStyles.displayMd.copyWith(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            );
          }
          if (snapshot.hasError) {
            return Text(
              '“$book $chapter:$vStart$vEnd”',
              textAlign: TextAlign.center,
              style: ScribesTextStyles.displayMd.copyWith(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            );
          }
          return SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.gold,
            ),
          );
        },
      );
    }

    return Text(
      '“Thy word is a lamp unto my feet, and a light unto my path.”',
      textAlign: TextAlign.center,
      style: ScribesTextStyles.displayMd.copyWith(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
    );
  }
}
