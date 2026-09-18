import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/scribes_radius.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_colors.dart';
import '../audio/scribes_audio_player.dart';
import 'scribes_author_header.dart';
import 'scribes_image_resolver.dart';
import 'scribes_scripture_chip.dart';
import 'scribes_ornament_divider.dart';
import '../../features/posts/domain/post.dart';
import '../../features/posts/data/post_repository.dart';
import '../../features/passage/domain/passage_models.dart';

/// Presentation card specifically tailored for multi-panel Passage Decks.
/// Features an Instagram-style horizontal PageView carousel with page dots,
/// background audio playback (with mute control), and tap-to-expand details.
class ScribesPassageCard extends ConsumerStatefulWidget {
  final Post post;
  final int amenCount;
  final int insightCount;
  final int thoughtProvokingCount;
  final int commentCount;
  final String? userReactionType;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onComment;
  final void Function(String)? onReact;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onShare;

  const ScribesPassageCard({
    super.key,
    required this.post,
    this.amenCount = 0,
    this.insightCount = 0,
    this.thoughtProvokingCount = 0,
    this.commentCount = 0,
    this.userReactionType,
    this.isSaved = false,
    this.onTap,
    this.onAuthorTap,
    this.onComment,
    this.onReact,
    this.onSaveToggle,
    this.onShare,
  });

  @override
  ConsumerState<ScribesPassageCard> createState() => _ScribesPassageCardState();
}

class _ScribesPassageCardState extends ConsumerState<ScribesPassageCard> {
  late final PageController _pageController;
  int _currentPage = 0;
  final ScribesAudioPlayer _audioPlayer = ScribesAudioPlayer.instance;
  List<PassagePanel>? _hydratedPanels;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // If panels are not included in the feed payload, asynchronously hydrate them
    if (widget.post.panels.isEmpty && widget.post.postType == 'passage') {
      _hydratePanels();
    }

    // Auto-play ambient audio if present in the post
    final audioUrl = widget.post.sound?.audioUrl;
    if (audioUrl != null && audioUrl.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _audioPlayer.playLoop(audioUrl);
      });
    }
  }

  Future<void> _hydratePanels() async {
    try {
      final repo = ref.read(postRepositoryProvider);
      final fullPost = await repo.getPost(widget.post.id);
      if (mounted && fullPost.panels.isNotEmpty) {
        setState(() {
          _hydratedPanels = fullPost.panels;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Pause audio if this card was the one playing it
    final audioUrl = widget.post.sound?.audioUrl;
    if (audioUrl != null && _audioPlayer.currentUrl == audioUrl) {
      _audioPlayer.pause();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    final title = widget.post.content['title']?.toString().trim().isNotEmpty == true
        ? widget.post.content['title'].toString().trim()
        : 'Title';

    final excerpt = widget.post.plainTextBody.isNotEmpty
        ? widget.post.plainTextBody
        : (widget.post.content['excerpt']?.toString().trim() ?? '');

    final panels = _hydratedPanels ?? widget.post.panels;
    final totalPanels = panels.isNotEmpty ? panels.length : 1;
    final hasAudio = widget.post.sound != null || widget.post.soundId != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(ScribesRadius.card),
        border: Border.all(
          color: colors.goldEdge,
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Author Header
              ScribesAuthorHeader(
                authorName: widget.post.authorName,
                authorHandle: widget.post.authorHandle,
                avatarUrl: widget.post.authorAvatarUrl,
                publishedAt: widget.post.publishedAt,
                onTap: widget.onAuthorTap,
              ),

              const SizedBox(height: 12),

              // 2. Instagram-Style Carousel Deck (PageView)
              ClipRRect(
                borderRadius: BorderRadius.circular(ScribesRadius.card),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    children: [
                      // Carousel Slides
                      PageView.builder(
                        controller: _pageController,
                        itemCount: totalPanels,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          if (panels.isNotEmpty) {
                            return _buildPanelSlide(
                              panels[index],
                              index,
                              colors,
                            );
                          } else {
                            return _buildFallbackSlide(colors);
                          }
                        },
                      ),

                      // Top-Right Slide Indicator Pill (e.g. "1 / 4")
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.goldEdge,
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            '${_currentPage + 1} / $totalPanels',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),

                      // Top-Left Audio & Ambient Indicator
                      if (hasAudio)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _audioPlayer.isMutedNotifier,
                            builder: (context, isMuted, _) {
                              return GestureDetector(
                                onTap: () => _audioPlayer.toggleMute(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isMuted
                                          ? colors.border
                                          : colors.goldEdge,
                                      width: 0.6,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      HugeIcon(
                                        icon: isMuted
                                            ? HugeIcons.strokeRoundedVolumeMute01
                                            : HugeIcons.strokeRoundedVolumeHigh,
                                        color: isMuted
                                            ? colors.secondaryText
                                            : colors.gold,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isMuted ? 'Muted' : 'Audio Playing',
                                        style: ScribesTextStyles.caption.copyWith(
                                          color: isMuted
                                              ? colors.secondaryText
                                              : colors.gold,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Bottom-Right Tap Hint
                      Positioned(
                        bottom: 8,
                        right: 10,
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const HugeIcon(
                                  icon: HugeIcons.strokeRoundedBookOpen01,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap for details',
                                  style: ScribesTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 3. Instagram-Style Dot Indicators
              if (totalPanels > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPanels, (index) {
                      final isSelected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: isSelected ? 14 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.gold
                              : colors.border.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),

              const SizedBox(height: 6),

              // 4. Passage Title & Excerpt
              GestureDetector(
                onTap: widget.onTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ScribesTextStyles.displayMd.copyWith(
                        color: colors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (excerpt.isNotEmpty && excerpt != title) ...[
                      const SizedBox(height: 6),
                      Text(
                        excerpt,
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.secondaryText,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // 5. Scripture Tags (if any)
              if (widget.post.scriptureRefs.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.post.scriptureRefs.map((ref) {
                    final refStr = ref.verseEnd != null
                        ? '${ref.book} ${ref.chapter}:${ref.verseStart}-${ref.verseEnd}'
                        : '${ref.book} ${ref.chapter}:${ref.verseStart}';
                    return ScribesScriptureChip(reference: refStr);
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),
              const ScribesOrnamentDivider(),
              const SizedBox(height: 8),

              // 6. Multi-Reaction Row (Preserving distinct telemetry)
              Row(
                children: [
                  _buildReactionButton(
                    context,
                    colors,
                    label: 'Amen',
                    type: 'amen',
                    icon: HugeIcons.strokeRoundedFire,
                    count: widget.amenCount,
                    isSelected: widget.userReactionType == 'amen',
                  ),
                  const SizedBox(width: 8),
                  _buildReactionButton(
                    context,
                    colors,
                    label: 'Insightful',
                    type: 'insightful',
                    icon: HugeIcons.strokeRoundedIdea01,
                    count: widget.insightCount,
                    isSelected: widget.userReactionType == 'insightful',
                  ),
                  const SizedBox(width: 8),
                  _buildReactionButton(
                    context,
                    colors,
                    label: 'Ponder',
                    type: 'thought_provoking',
                    icon: HugeIcons.strokeRoundedDroplet,
                    count: widget.thoughtProvokingCount,
                    isSelected: widget.userReactionType == 'thought_provoking',
                  ),
                  const Spacer(),
                  // Comments
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedComment01,
                      color: colors.secondaryText,
                      size: 18,
                    ),
                    onPressed: widget.onComment,
                    tooltip: 'Comments (${widget.commentCount})',
                  ),
                  // Save
                  IconButton(
                    icon: HugeIcon(
                      icon: widget.isSaved
                          ? HugeIcons.strokeRoundedBookmark02
                          : HugeIcons.strokeRoundedBookmark01,
                      color: widget.isSaved ? colors.gold : colors.secondaryText,
                      size: 18,
                    ),
                    onPressed: widget.onSaveToggle,
                    tooltip: widget.isSaved ? 'Saved' : 'Save',
                  ),
                  // Share
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedShare01,
                      color: colors.secondaryText,
                      size: 18,
                    ),
                    onPressed: widget.onShare,
                    tooltip: 'Share',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelSlide(
    PassagePanel panel,
    int index,
    ScribesColors colors,
  ) {
    final bgUrl = panel.effectiveImageUrl ?? panel.backgroundImageUrl;
    final text = panel.content['text']?.toString() ??
        panel.content['body']?.toString() ??
        panel.content['quote']?.toString() ??
        '';

    return Builder(builder: (context) {
      final panelWidth = MediaQuery.sizeOf(context).width - 32; // 16px padding each side
      final cacheW = ScribesImageResolver.computeCacheWidth(context, panelWidth);

      return GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or solid surface
            if (bgUrl != null && bgUrl.isNotEmpty)
              ScribesImageResolver.buildImage(
                imageUrl: bgUrl,
                fit: BoxFit.cover,
                memCacheWidth: cacheW,
                placeholder: (context, url) => Container(
                  color: colors.surfaceRaised,
                ),
                fallback: Container(
                  color: colors.surfaceRaised,
                ),
              )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.surfaceRaised,
                    colors.surface,
                  ],
                ),
              ),
            ),

          // Gradient scrim
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),

          // Panel content overlay
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.glassFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colors.goldEdge,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      panel.panelType.toUpperCase(),
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                  if (text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      text,
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
          ),
        );
      });
  }

  Widget _buildFallbackSlide(ScribesColors colors) {
    final previewImageUrl = ScribesImageResolver.extractFirstImageUrl(widget.post);

    return Builder(builder: (context) {
      final panelWidth = MediaQuery.sizeOf(context).width - 32;
      final cacheW = ScribesImageResolver.computeCacheWidth(context, panelWidth);

      return GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (previewImageUrl != null && previewImageUrl.isNotEmpty)
              ScribesImageResolver.buildImage(
                imageUrl: previewImageUrl,
                fit: BoxFit.cover,
                memCacheWidth: cacheW,
                placeholder: (context, url) => Container(
                  color: colors.surfaceRaised,
                ),
                fallback: Container(
                  color: colors.surfaceRaised,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.surfaceRaised,
                      colors.surface,
                    ],
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            if (previewImageUrl == null || previewImageUrl.isEmpty)
              Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedLayers01,
                  color: colors.gold,
                  size: 36,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildReactionButton(
    BuildContext context,
    ScribesColors colors, {
    required String label,
    required String type,
    required dynamic icon,
    required int count,
    required bool isSelected,
  }) {
    final activeColor = colors.gold;
    final color = isSelected ? activeColor : colors.secondaryText;

    return InkWell(
      onTap: widget.onReact != null ? () => widget.onReact!(type) : null,
      borderRadius: BorderRadius.circular(ScribesRadius.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                color: colors.glassFill,
                borderRadius: BorderRadius.circular(ScribesRadius.chip),
                border: Border.all(color: colors.goldEdge, width: 0.8),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: icon,
              color: color,
              size: 15,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: ScribesTextStyles.caption.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
