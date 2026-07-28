import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/widgets/scribes_tab_bar.dart';
import 'package:scribes/core/widgets/scribes_tab_bar_delegate.dart';
import 'package:scribes/core/widgets/scribes_avatar.dart';
import 'package:scribes/core/widgets/scribes_empty_state.dart';
import 'package:scribes/core/widgets/scribes_loading_indicator.dart';
import 'package:scribes/features/messages/application/inbox_providers.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';
import 'package:scribes/features/social/application/user_lookup_provider.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: colors.background,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
                onPressed: () => context.pop(),
              ),
              title: Text('Direct Messages', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: ScribesTabBarDelegate(
                child: ScribesTabBar(
                  selectedIndex: _tabController.index,
                  tabs: const ['Messages', 'Requests'],
                  onTabChanged: (index) {
                    _tabController.animateTo(index);
                    setState(() {});
                  },
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMessagesTab(),
            _buildRequestsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    final colors = ref.watch(themeProvider);
    final conversationsState = ref.watch(conversationsProvider);
    final currentUser = ref.watch(authProvider).value;

    return conversationsState.when(
      data: (conversations) {
        if (conversations.isEmpty) {
          return const Center(
            child: ScribesEmptyState(
              icon: HugeIcons.strokeRoundedMail01,
              title: 'No messages yet',
              subtitle: 'Start a conversation with another writer.',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.read(conversationsProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            separatorBuilder: (context, index) => Divider(color: colors.border.withValues(alpha: 0.5), height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final isUserA = conversation.userAId == currentUser?.id;
              final otherUserId = isUserA ? conversation.userBId : conversation.userAId;
              
              return _ConversationTile(
                conversation: conversation,
                otherUserId: otherUserId,
                colors: colors,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: ScribesLoadingIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildRequestsTab() {
    final colors = ref.watch(themeProvider);
    final requestsState = ref.watch(pendingRequestsProvider);

    return requestsState.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(
            child: ScribesEmptyState(
              icon: HugeIcons.strokeRoundedMailOpen01,
              title: 'No pending requests',
              subtitle: 'You have no new message requests.',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: requests.length,
          separatorBuilder: (context, index) => Divider(color: colors.border.withValues(alpha: 0.5), height: 1),
          itemBuilder: (context, index) {
            final request = requests[index];
            return _RequestTile(
              request: request,
              colors: colors,
              currentUserId: ref.watch(authProvider).value?.id,
            );
          },
        );
      },
      loading: () => const Center(child: ScribesLoadingIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final dynamic conversation;
  final String otherUserId;
  final dynamic colors;

  const _ConversationTile({
    required this.conversation,
    required this.otherUserId,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorState = ref.watch(commentAuthorProvider(otherUserId));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: authorState.when(
        data: (author) => ScribesAvatar(authorName: author.safeDisplayName, radius: 24),
        loading: () => const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
        error: (_, __) => const ScribesAvatar(authorName: 'Unknown', radius: 24),
      ),
      title: authorState.when(
        data: (author) => Text(
          author.safeDisplayName,
          style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        loading: () => Container(width: 100, height: 14, color: Colors.grey.withValues(alpha: 0.3)),
        error: (_, __) => Text('Unknown User', style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText, fontWeight: FontWeight.bold)),
      ),
      subtitle: Text(
        'Tap to view conversation',
        style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        context.push('/conversation/${conversation.id}');
      },
    );
  }
}

class _RequestTile extends ConsumerWidget {
  final dynamic request;
  final dynamic colors;
  final String? currentUserId;

  const _RequestTile({
    required this.request,
    required this.colors,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutgoing = request.fromUserId == currentUserId;
    final otherUserId = isOutgoing ? request.toUserId : request.fromUserId;
    final authorState = ref.watch(commentAuthorProvider(otherUserId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              authorState.when(
                data: (author) => ScribesAvatar(authorName: author.safeDisplayName, radius: 20),
                loading: () => const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                error: (_, __) => const ScribesAvatar(authorName: 'Unknown', radius: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: authorState.when(
                  data: (author) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOutgoing ? 'Sent request to' : 'Request from',
                        style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText),
                      ),
                      Text(
                        author.safeDisplayName,
                        style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  loading: () => Container(width: 100, height: 14, color: Colors.grey.withValues(alpha: 0.3)),
                  error: (_, __) => Text('Unknown User', style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              request.firstMessage,
              style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
            ),
          ),
          if (!isOutgoing) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryText,
                      side: BorderSide(color: colors.border),
                    ),
                    onPressed: () {
                      ref.read(pendingRequestsProvider.notifier).rejectRequest(request.id);
                    },
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.gold,
                      foregroundColor: colors.surface,
                    ),
                    onPressed: () {
                      ref.read(pendingRequestsProvider.notifier).approveRequest(request.id);
                    },
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Waiting for approval',
                style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

