import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/audio/scribes_audio_player.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_bounce_button.dart';
import '../data/sound_repository.dart';
import '../domain/passage_models.dart';

class SoundPickerSheet extends ConsumerStatefulWidget {
  final SoundTrack? selectedSound;

  const SoundPickerSheet({
    super.key,
    this.selectedSound,
  });

  static Future<SoundTrack?> show(
    BuildContext context, {
    SoundTrack? initialSound,
  }) {
    return showModalBottomSheet<SoundTrack?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SoundPickerSheet(selectedSound: initialSound),
    );
  }

  @override
  ConsumerState<SoundPickerSheet> createState() => _SoundPickerSheetState();
}

class _SoundPickerSheetState extends ConsumerState<SoundPickerSheet> {
  SoundTrack? _chosenSound;
  String _selectedCategory = 'all';
  final _audioPlayer = ScribesAudioPlayer.instance;

  @override
  void initState() {
    super.initState();
    _chosenSound = widget.selectedSound;
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final soundsAsync = ref.watch(soundsListProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.94),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ScribesRadius.sheet),
          ),
          border: Border(
            top: BorderSide(
              color: colors.gold.withValues(alpha: 0.35),
              width: 1.0,
            ),
            left: BorderSide(
              color: colors.gold.withValues(alpha: 0.15),
              width: 0.5,
            ),
            right: BorderSide(
              color: colors.gold.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.secondaryText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ambient Sound',
                        style: ScribesTextStyles.displayMd.copyWith(
                          color: colors.primaryText,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Continuous sacred audio loop during reading',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  ScribesBounceButton(
                    onTap: () => Navigator.pop(context, _chosenSound),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.gold,
                        borderRadius:
                            BorderRadius.circular(ScribesRadius.button),
                      ),
                      child: Text(
                        'Done',
                        style: ScribesTextStyles.labelLg.copyWith(
                          color: colors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip('all', 'All', colors),
                  _buildCategoryChip('ambient', 'Ambient', colors),
                  _buildCategoryChip('choral', 'Choral', colors),
                  _buildCategoryChip('nature', 'Nature', colors),
                  _buildCategoryChip('liturgical', 'Liturgical', colors),
                  _buildCategoryChip('instrumental', 'Instrumental', colors),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Divider(
              color: colors.border.withValues(alpha: 0.5),
              height: 1,
            ),

            // Sound List
            Expanded(
              child: soundsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: colors.gold,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Failed to load sound catalogue',
                    style: ScribesTextStyles.bodyMd.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                ),
                data: (sounds) {
                  final filtered = _selectedCategory == 'all'
                      ? sounds
                      : sounds
                          .where((s) => s.category == _selectedCategory)
                          .toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // "No Sound" Option
                      _buildNoSoundTile(colors),

                      // Tracks
                      ...filtered.map((track) => _buildTrackTile(track, colors)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String key, String label, dynamic colors) {
    final isSelected = _selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.gold.withValues(alpha: 0.15)
                : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(ScribesRadius.chip),
            border: Border.all(
              color: isSelected
                  ? colors.gold
                  : colors.border.withValues(alpha: 0.4),
              width: isSelected ? 1.0 : 0.5,
            ),
          ),
          child: Text(
            label,
            style: ScribesTextStyles.caption.copyWith(
              color: isSelected ? colors.gold : colors.secondaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoSoundTile(dynamic colors) {
    final isSelected = _chosenSound == null;
    return ListTile(
      onTap: () {
        _audioPlayer.stop();
        setState(() => _chosenSound = null);
      },
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.border.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedVolumeLow,
          color: isSelected ? colors.gold : colors.secondaryText,
          size: 18,
        ),
      ),
      title: Text(
        'Silent Meditation',
        style: ScribesTextStyles.bodyMd.copyWith(
          color: isSelected ? colors.gold : colors.primaryText,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        'No background audio track',
        style: ScribesTextStyles.caption.copyWith(
          color: colors.secondaryText,
        ),
      ),
      trailing: isSelected
          ? HugeIcon(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              color: colors.gold,
              size: 22,
            )
          : null,
    );
  }

  Widget _buildTrackTile(SoundTrack track, dynamic colors) {
    final isSelected = _chosenSound?.id == track.id;

    return ValueListenableBuilder<String?>(
      valueListenable: _audioPlayer.currentTrackUrlNotifier,
      builder: (context, playingUrl, _) {
        final isAuditioning =
            playingUrl == track.audioUrl && _audioPlayer.isPlayingNotifier.value;

        return ListTile(
          onTap: () {
            setState(() => _chosenSound = track);
          },
          leading: GestureDetector(
            onTap: () => _audioPlayer.previewTrack(track.audioUrl),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isAuditioning
                    ? colors.gold
                    : colors.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.gold.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: HugeIcon(
                icon: isAuditioning
                    ? HugeIcons.strokeRoundedPause
                    : HugeIcons.strokeRoundedPlay,
                color: isAuditioning ? colors.background : colors.gold,
                size: 18,
              ),
            ),
          ),
          title: Text(
            track.title,
            style: ScribesTextStyles.bodyMd.copyWith(
              color: isSelected ? colors.gold : colors.primaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          subtitle: Text(
            '${track.category.toUpperCase()} · ${track.durationSeconds ~/ 60}:${(track.durationSeconds % 60).toString().padLeft(2, '0')}',
            style: ScribesTextStyles.caption.copyWith(
              color: colors.secondaryText,
              letterSpacing: 0.3,
            ),
          ),
          trailing: isSelected
              ? HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: colors.gold,
                  size: 22,
                )
              : null,
        );
      },
    );
  }
}
