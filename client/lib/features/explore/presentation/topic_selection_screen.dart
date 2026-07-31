import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/features/onboarding/application/onboarding_notifier.dart';
import 'package:scribes/core/widgets/scribes_loading_indicator.dart';

class TopicSelectionScreen extends ConsumerWidget {
  final VoidCallback onContinue;
  final bool isModal;

  const TopicSelectionScreen({
    super.key,
    required this.onContinue,
    this.isModal = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final colors = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: isModal
          ? AppBar(
              backgroundColor: colors.background,
              elevation: 0,
              leading: IconButton(
                icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: colors.primaryText),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text('Your Interests',
                  style: ScribesTextStyles.bodyLg
                      .copyWith(color: colors.primaryText)),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isModal) const SizedBox(height: 48),
              Text(
                isModal ? 'Update Topics' : 'What draws you?',
                style: ScribesTextStyles.displayLg
                    .copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 12),
              Text(
                'Select at least 3 topics to begin your feed.',
                style: ScribesTextStyles.bodyLg.copyWith(
                  color: colors.secondaryText,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: state.isLoading
                    ? Center(child: ScribesLoadingIndicator())
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 12.0,
                          runSpacing: 16.0,
                          children: state.availableTopics.map((topic) {
                            final isSelected =
                                state.selectedTopics.contains(topic);
                            return _TopicChip(
                              label: topic,
                              isSelected: isSelected,
                              colors: colors,
                              onTap: () {
                                ref
                                    .read(onboardingProvider.notifier)
                                    .toggleTopic(topic);
                              },
                            );
                          }).toList(),
                        ),
                      ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    state.error!,
                    style: ScribesTextStyles.labelLg
                        .copyWith(color: colors.orange),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.canSubmit && !state.isSaving
                        ? () async {
                            final success = await ref
                                .read(onboardingProvider.notifier)
                                .saveTopics();
                            if (success) {
                              onContinue();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryText,
                      foregroundColor: colors.background,
                      disabledBackgroundColor:
                          colors.primaryText.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: state.isSaving
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.background,
                            ),
                          )
                        : Text(
                            isModal ? 'Save Changes' : 'Continue',
                            style: ScribesTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.background,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ScribesColors colors;
  final VoidCallback onTap;

  const _TopicChip({
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryText : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? colors.primaryText : colors.border,
          ),
        ),
        child: Text(
          label,
          style: ScribesTextStyles.bodyMd.copyWith(
            color: isSelected ? colors.background : colors.primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
