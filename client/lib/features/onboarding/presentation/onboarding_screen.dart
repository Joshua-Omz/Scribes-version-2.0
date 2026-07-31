import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scribes/features/explore/presentation/topic_selection_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TopicSelectionScreen(
      isModal: false,
      onContinue: () {
        // Upon completing onboarding, navigate to the main feed/explore
        context.go('/feed');
      },
    );
  }
}
