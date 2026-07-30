# Optimistic UI & Message Bubble Fixes

This plan will address two issues:
1. **Network Latency when sending DMs:** Introduce an Optimistic UI architecture for real-time responsiveness.
2. **Reply Bubble Bug:** Ensure the original message text is displayed in the reply bubble instead of just 'replying'.

## User Review Required
None - this is a standard UX improvement.

## Open Questions
None.

## Proposed Changes

### Database Layer
#### [MODIFY] client/lib/core/storage/drift_database.dart
- Add TextColumn get status to Messages table with a default value of 'sent'.
- Bump schema version to 8 and add migration logic wait m.addColumn(messages, messages.status);.

### Domain Layer
#### [MODIFY] client/lib/features/messages/domain/message.dart
- Update Message Freezed model to include @Default('sent') String status.
- Run uild_runner to regenerate serializers and data classes.

### Data Layer
#### [MODIFY] client/lib/features/messages/data/message_repository.dart
- Refactor sendMessage to take String senderId.
- Generate a UUID for the pending message.
- Immediately insert a db.Message with status = 'pending' into the local database (this makes it instantly appear on the UI).
- Run the API call _api.sendMessage asynchronously.
  - On success: delete the pending UUID record and insert the real backend-confirmed message.
  - On error: update the pending message's status to 'error'.

#### [MODIFY] client/lib/features/messages/application/conversation_providers.dart
- Update sendMessage to read the current user's ID from uthProvider and pass it to MessageRepository.sendMessage().

### Presentation Layer
#### [MODIFY] client/lib/features/messages/presentation/conversation_screen.dart
- **Optimistic UI:** In _buildMessageBubble, check message.status. If 'pending', apply a slight opacity fade (0.7) and show a tiny clock icon next to the timestamp. If 'error', show a red warning icon.
- **Reply Bubbles:** We will look up the replied-to message from the existing list of messages (using eplyToId) and display a truncated preview of the original message body instead of hardcoding "replying".

## Verification Plan
### Automated Tests
- Run dart run build_runner build to regenerate models.
- Run lutter build apk to verify no compilation errors.

### Manual Verification
- Ask the user to send a message and observe the instant appearance and the clock icon.
- Ask the user to reply to a message and observe the original message's text appearing in the reply block.
