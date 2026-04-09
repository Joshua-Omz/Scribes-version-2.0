import 'package:flutter/material.dart';
import '../../app_config/typography.dart';
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THE DAILY JOURNAL',
          style: AppTypography.sectionOverline,
        ),
        const SizedBox(height: 12.0),
        Text(
          'Thoughts from the Digital Atelier.',
          style: AppTypography.headline
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 16.0),
        Container(
          width: 48,
          height: 2,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}