import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/scribes_radius.dart';
import '../../../../core/theme/scribes_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';

class FeedTopicChips extends ConsumerWidget {
  final String selectedTopic;
  final ValueChanged<String> onSelectTopic;

  const FeedTopicChips({
    super.key,
    required this.selectedTopic,
    required this.onSelectTopic,
  });

  static const List<String> topics = [
    'All',
    'Theology',
    'Devotional',
    'Exegesis',
    'Wisdom',
    'Church History',
    'Hebrew & Greek',
    'Prayer',
    'Gospel',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final isSelected = topic == selectedTopic;

          return InkWell(
            onTap: () => onSelectTopic(topic),
            borderRadius: BorderRadius.circular(ScribesRadius.chip),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? colors.primaryText : colors.surfaceRaised,
                borderRadius: BorderRadius.circular(ScribesRadius.chip),
                border: Border.all(
                  color: isSelected
                      ? colors.primaryText
                      : colors.border.withValues(alpha: 0.5),
                  width: isSelected ? 1.0 : 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  topic,
                  style: ScribesTextStyles.labelSm.copyWith(
                    color: isSelected
                        ? colors.background
                        : colors.secondaryText,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
