import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../features/auth/domain/user.dart';
import '../../features/social/application/is_following_user_provider.dart';

class ScribesUserCard extends ConsumerWidget {
  final User user;

  const ScribesUserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final isFollowingState = ref.watch(isFollowingUserProvider(user.id));

    return InkWell(
      onTap: () => context.push('/users/${user.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ScribesAvatar(
              authorName: user.displayName,
              imageUrl: null,
              radius: 28,
            ),
            const SizedBox(height: 12),
            Text(
              user.displayName,
              style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              '@${user.handle}',
              style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: isFollowingState.when(
                data: (isFollowing) => OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: isFollowing ? Colors.transparent : colors.primaryText,
                    side: BorderSide(
                      color: isFollowing ? colors.border : colors.primaryText,
                    ),
                  ),
                  onPressed: () {
                    ref.read(isFollowingUserProvider(user.id).notifier).toggleFollow();
                  },
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: ScribesTextStyles.labelSm.copyWith(
                      color: isFollowing ? colors.primaryText : colors.background,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                loading: () => Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primaryText,
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
