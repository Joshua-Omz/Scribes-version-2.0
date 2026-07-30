import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/widgets/scribes_avatar.dart';
import 'package:scribes/core/widgets/scribes_loading_indicator.dart';
import 'package:scribes/features/messages/application/conversation_providers.dart';
import 'package:scribes/features/messages/application/inbox_providers.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';
import 'package:scribes/features/social/application/user_lookup_provider.dart';
import 'package:scribes/core/widgets/scribes_author_header.dart';
import 'package:scribes/core/widgets/scribes_text_field.dart';
import 'package:scribes/features/messages/domain/message.dart';
import 'package:scribes/features/messages/application/last_read_provider.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ConversationScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  Message? _replyingTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastReadProvider.notifier).markAsRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      ref.read(conversationMessagesProvider(widget.conversationId).notifier).sendMessage(text, replyToId: _replyingTo?.id);
      _messageController.clear();
      setState(() {
        _replyingTo = null;
      });
    }
  }

  void _onSwipeToReply(Message message) {
    setState(() {
      _replyingTo = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final messagesStream = ref.watch(conversationMessagesProvider(widget.conversationId));
    final currentUser = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: _buildAppBarTitle(colors, currentUser?.id),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedMoreVerticalCircle01, color: colors.primaryText),
            onPressed: () {
              // Show options (Block, report, etc)
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: messagesStream.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hi!',
                      style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Show newest at the bottom
                  padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 100 + MediaQuery.of(context).padding.bottom),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.id;
                    return _buildMessageBubble(
                      message: message,
                      messages: messages,
                      isMe: isMe,
                      colors: colors,
                    );
                  },
                );
              },
              loading: () => const Center(child: ScribesLoadingIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildMessageInput(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required Message message,
    required List<Message> messages,
    required bool isMe,
    required dynamic colors,
  }) {
    final text = message.body;
    final timestamp = message.sentAt;
    
    Message? replyMessage;
    if (message.replyToId != null) {
      replyMessage = messages.where((m) => m.id == message.replyToId).firstOrNull;
    }
    
    Widget bubble = Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? colors.gold : colors.surfaceRaised,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: isMe ? null : Border.all(color: colors.border),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check if there is a reply
            if (replyMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white.withValues(alpha: 0.15) : colors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.reply, size: 14, color: isMe ? Colors.white70 : colors.gold),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        replyMessage.body,
                        style: ScribesTextStyles.labelLg.copyWith(
                          color: isMe ? Colors.white : colors.primaryText,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              text,
              style: ScribesTextStyles.bodyMd.copyWith(
                color: isMe ? Colors.white : colors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: ScribesTextStyles.caption.copyWith(
                color: isMe ? Colors.white70 : colors.secondaryText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );

    return Dismissible(
      key: ValueKey(message.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        _onSwipeToReply(message);
        return false; // Never actually dismiss
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: HugeIcon(icon: HugeIcons.strokeRoundedArrowTurnBackward, color: colors.gold),
      ),
      child: bubble,
    );
  }

  Widget _buildMessageInput(dynamic colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyingTo != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.reply_rounded, size: 20, color: colors.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Replying to message',
                        style: ScribesTextStyles.labelSm.copyWith(color: colors.gold),
                      ),
                      Text(
                        _replyingTo!.body,
                        style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 20, color: colors.secondaryText),
                  onPressed: () {
                    setState(() {
                      _replyingTo = null;
                    });
                  },
                ),
              ],
            ),
          ),
        Container(
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ScribesTextField(
                  controller: _messageController,
                  hintText: 'Type a message...',
                  isSearchPill: true,
                  minLines: 1,
                  maxLines: 5,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 2), // Align with text field
                decoration: BoxDecoration(
                  color: colors.gold,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedSent, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarTitle(dynamic colors, String? currentUserId) {
    final conversations = ref.watch(conversationsProvider).value ?? [];
    final conversation = conversations.where((c) => c.id == widget.conversationId).firstOrNull;
    
    if (conversation == null || currentUserId == null) {
      return Row(
        children: [
          const ScribesAvatar(authorName: 'U', radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Conversation',
              style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final otherUserId = conversation.userAId == currentUserId ? conversation.userBId : conversation.userAId;
    final authorState = ref.watch(commentAuthorProvider(otherUserId));

    return authorState.when(
      data: (author) => ScribesAuthorHeader(
        authorName: author.safeDisplayName,
        authorHandle: author.handle,
        onTap: () => context.push('/users/${author.id}'),
      ),
      loading: () => const Row(children: [CircleAvatar(radius: 18, backgroundColor: Colors.grey)]),
      error: (e, st) => Row(
        children: [
          const ScribesAvatar(authorName: 'Unknown', radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Unknown User',
              style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
