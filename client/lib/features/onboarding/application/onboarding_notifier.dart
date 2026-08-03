import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/onboarding_repository.dart';
import '../../auth/application/auth_notifier.dart';
import 'package:scribes/main.dart';

part 'onboarding_notifier.g.dart';

class OnboardingState {
  final List<String> availableTopics;
  final Set<String> selectedTopics;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isChurch;

  const OnboardingState({
    this.availableTopics = const [],
    this.selectedTopics = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isChurch = false,
  });

  bool get canSubmit => selectedTopics.length >= 3;

  OnboardingState copyWith({
    List<String>? availableTopics,
    Set<String>? selectedTopics,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? isChurch,
  }) {
    return OnboardingState(
      availableTopics: availableTopics ?? this.availableTopics,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      isChurch: isChurch ?? this.isChurch,
    );
  }
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() {
    Future.microtask(_loadTopics);
    final user = ref.read(authProvider).value;
    return OnboardingState(
      isLoading: true,
      selectedTopics: user?.selectedTags.toSet() ?? const {},
      isChurch: user?.isChurch ?? false,
    );
  }

  Future<void> _loadTopics() async {
    try {
      final repo = ref.read(onboardingRepositoryProvider);
      final topics = await repo.getAvailableTopics();
      state = state.copyWith(availableTopics: topics, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void toggleTopic(String topic) {
    final newSelected = Set<String>.from(state.selectedTopics);
    if (newSelected.contains(topic)) {
      newSelected.remove(topic);
    } else {
      if (newSelected.length >= 7) {
        state = state.copyWith(error: 'You can select up to 7 topics.');
        return;
      }
      newSelected.add(topic);
    }
    state = state.copyWith(selectedTopics: newSelected, error: null);
  }

  void setChurch(bool isChurch) {
    state = state.copyWith(isChurch: isChurch);
  }

  Future<bool> saveTopics() async {
    if (!state.canSubmit) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      final user = ref.read(authProvider).value;
      if (user != null) {
        await sharedPrefs.setBool('has_seen_onboarding_${user.id}', true);
      }

      final repo = ref.read(onboardingRepositoryProvider);
      await repo.saveTopics(state.selectedTopics.toList());
      
      // Also update the isChurch flag
      final authNotif = ref.read(authProvider.notifier);
      // Update tags in auth provider to pass the router gate
      await authNotif.updateTags(state.selectedTopics.toList());

      if (user != null && user.isChurch != state.isChurch) {
        await authNotif.updateProfile(
          handle: user.handle,
          displayName: user.displayName,
          bio: user.bio,
          isChurch: state.isChurch,
        );
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSaving: false);
      return false;
    }
  }
}
