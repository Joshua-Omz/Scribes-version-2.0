import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/onboarding_repository.dart';

part 'onboarding_notifier.g.dart';

class OnboardingState {
  final List<String> availableTopics;
  final Set<String> selectedTopics;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const OnboardingState({
    this.availableTopics = const [],
    this.selectedTopics = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  bool get canSubmit => selectedTopics.length >= 3;

  OnboardingState copyWith({
    List<String>? availableTopics,
    Set<String>? selectedTopics,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return OnboardingState(
      availableTopics: availableTopics ?? this.availableTopics,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() {
    _loadTopics();
    return const OnboardingState();
  }

  Future<void> _loadTopics() async {
    state = state.copyWith(isLoading: true, error: null);
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
      newSelected.add(topic);
    }
    state = state.copyWith(selectedTopics: newSelected);
  }

  Future<bool> saveTopics() async {
    if (!state.canSubmit) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      final repo = ref.read(onboardingRepositoryProvider);
      await repo.saveTopics(state.selectedTopics.toList());
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSaving: false);
      return false;
    }
  }
}
