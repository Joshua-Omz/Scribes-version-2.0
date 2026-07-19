// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_lookup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches and caches a single user's public profile by UUID.
/// Used by comment tiles to resolve author_id → displayName + handle.
/// Uses keepAlive so repeated renders of the same author don't refetch.

@ProviderFor(commentAuthor)
final commentAuthorProvider = CommentAuthorFamily._();

/// Fetches and caches a single user's public profile by UUID.
/// Used by comment tiles to resolve author_id → displayName + handle.
/// Uses keepAlive so repeated renders of the same author don't refetch.

final class CommentAuthorProvider
    extends
        $FunctionalProvider<
          AsyncValue<CommentAuthor>,
          CommentAuthor,
          FutureOr<CommentAuthor>
        >
    with $FutureModifier<CommentAuthor>, $FutureProvider<CommentAuthor> {
  /// Fetches and caches a single user's public profile by UUID.
  /// Used by comment tiles to resolve author_id → displayName + handle.
  /// Uses keepAlive so repeated renders of the same author don't refetch.
  CommentAuthorProvider._({
    required CommentAuthorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentAuthorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentAuthorHash();

  @override
  String toString() {
    return r'commentAuthorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CommentAuthor> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CommentAuthor> create(Ref ref) {
    final argument = this.argument as String;
    return commentAuthor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentAuthorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentAuthorHash() => r'a6943a79591871181c15225ce77846f6d418da4e';

/// Fetches and caches a single user's public profile by UUID.
/// Used by comment tiles to resolve author_id → displayName + handle.
/// Uses keepAlive so repeated renders of the same author don't refetch.

final class CommentAuthorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CommentAuthor>, String> {
  CommentAuthorFamily._()
    : super(
        retry: null,
        name: r'commentAuthorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches and caches a single user's public profile by UUID.
  /// Used by comment tiles to resolve author_id → displayName + handle.
  /// Uses keepAlive so repeated renders of the same author don't refetch.

  CommentAuthorProvider call(String userId) =>
      CommentAuthorProvider._(argument: userId, from: this);

  @override
  String toString() => r'commentAuthorProvider';
}

/// Searches users by handle prefix for @mention autocomplete.
/// Debouncing should be handled at the UI layer, not here.

@ProviderFor(userSearch)
final userSearchProvider = UserSearchFamily._();

/// Searches users by handle prefix for @mention autocomplete.
/// Debouncing should be handled at the UI layer, not here.

final class UserSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CommentAuthor>>,
          List<CommentAuthor>,
          FutureOr<List<CommentAuthor>>
        >
    with
        $FutureModifier<List<CommentAuthor>>,
        $FutureProvider<List<CommentAuthor>> {
  /// Searches users by handle prefix for @mention autocomplete.
  /// Debouncing should be handled at the UI layer, not here.
  UserSearchProvider._({
    required UserSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userSearchHash();

  @override
  String toString() {
    return r'userSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CommentAuthor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CommentAuthor>> create(Ref ref) {
    final argument = this.argument as String;
    return userSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userSearchHash() => r'a6b19e32edc92845be7a58221382735b1060bd6d';

/// Searches users by handle prefix for @mention autocomplete.
/// Debouncing should be handled at the UI layer, not here.

final class UserSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CommentAuthor>>, String> {
  UserSearchFamily._()
    : super(
        retry: null,
        name: r'userSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Searches users by handle prefix for @mention autocomplete.
  /// Debouncing should be handled at the UI layer, not here.

  UserSearchProvider call(String query) =>
      UserSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'userSearchProvider';
}
