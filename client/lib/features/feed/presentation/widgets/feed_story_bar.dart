import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/scribes_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';

class FeedStoryItem {
  final String id;
  final String name;
  final String handle;
  final bool isChurch;
  final bool isLive;

  const FeedStoryItem({
    required this.id,
    required this.name,
    required this.handle,
    this.isChurch = false,
    this.isLive = false,
  });
}

class FeedStoryBar extends ConsumerWidget {
  const FeedStoryBar({super.key});

  static const List<FeedStoryItem> _curatedScribes = [
    FeedStoryItem(
      id: 'berean',
      name: 'Berean Guild',
      handle: '@berean',
      isChurch: true,
    ),
    FeedStoryItem(
      id: 'antioch',
      name: 'Antioch Church',
      handle: '@antioch',
      isChurch: true,
      isLive: true,
    ),
    FeedStoryItem(id: 'augustine', name: 'Augustine', handle: '@augustine'),
    FeedStoryItem(
      id: 'chrysostom',
      name: 'Chrysostom',
      handle: '@golden_mouth',
    ),
    FeedStoryItem(
      id: 'reformed',
      name: 'Geneva Study',
      handle: '@geneva',
      isChurch: true,
    ),
    FeedStoryItem(id: 'tyndale', name: 'W. Tyndale', handle: '@tyndale'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _curatedScribes.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Write / Compose Story Shortcut
            return InkWell(
              onTap: () => context.push('/compose'),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceRaised,
                      border: Border.all(color: colors.border, width: 1.5),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedQuillWrite02,
                        color: colors.primaryText,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Write',
                    style: ScribesTextStyles.caption.copyWith(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }

          final scribe = _curatedScribes[index - 1];
          return InkWell(
            onTap: () =>
                context.push('/search?q=${Uri.encodeComponent(scribe.name)}'),
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.primaryText,
                            colors.border.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surface,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          scribe.name[0],
                          style: ScribesTextStyles.labelLg.copyWith(
                            color: colors.primaryText,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'CormorantGaramond',
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    if (scribe.isChurch)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.background,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primaryText,
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 10,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 58,
                  child: Text(
                    scribe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: ScribesTextStyles.caption.copyWith(
                      color: colors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
