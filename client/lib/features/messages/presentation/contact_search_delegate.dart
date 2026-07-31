import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/features/messages/data/message_repository.dart';
import 'package:scribes/features/messages/domain/contact.dart';
import 'package:scribes/core/widgets/scribes_avatar.dart';
import 'package:scribes/core/widgets/scribes_loading_indicator.dart';

final searchContactsProvider = FutureProvider.autoDispose.family<List<Contact>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repo = ref.watch(messageRepositoryProvider);
  return repo.searchContacts(query);
});

class ContactSearchDelegate extends SearchDelegate<Contact?> {
  final WidgetRef ref;

  ContactSearchDelegate(this.ref) : super(
    searchFieldLabel: 'Search contacts...',
    searchFieldStyle: ScribesTextStyles.bodyMd,
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final colors = ref.watch(themeProvider);
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primaryText),
        titleTextStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: colors.background,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primaryText,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    final colors = ref.watch(themeProvider);
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear, color: colors.primaryText),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    final colors = ref.watch(themeProvider);
    return IconButton(
      icon: Icon(Icons.arrow_back, color: colors.primaryText),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final colors = ref.watch(themeProvider);
    
    if (query.trim().isEmpty) {
      return Center(
        child: Text(
          'Search for contacts to message',
          style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
        ),
      );
    }

    final searchState = ref.watch(searchContactsProvider(query.trim()));

    return searchState.when(
      data: (contacts) {
        if (contacts.isEmpty) {
          return Center(
            child: Text(
              'No contacts found',
              style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
            ),
          );
        }
        return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ListTile(
              leading: ScribesAvatar(
                authorName: contact.displayName,
                imageUrl: null, // the SearchContacts query doesn't currently return avatarUrl, but it could be added in the backend
                radius: 20,
              ),
              title: Text(contact.displayName, style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText)),
              subtitle: Text('@${contact.handle}', style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText)),
              onTap: () async {
                try {
                  final repo = ref.read(messageRepositoryProvider);
                  final conv = await repo.getOrCreateDirectConversation(contact.id);
                  if (!context.mounted) return;
                  close(context, contact);
                  context.push('/conversation/${conv.id}');
                } catch (e) {
                  // Fallback if needed
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to start conversation. Are you offline?')),
                  );
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: ScribesLoadingIndicator()),
      error: (err, stack) => Center(
        child: Text(
          'Error searching contacts',
          style: ScribesTextStyles.bodyMd.copyWith(color: colors.orange),
        ),
      ),
    );
  }
}
