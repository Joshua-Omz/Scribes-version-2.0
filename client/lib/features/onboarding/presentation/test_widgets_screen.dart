import 'package:flutter/material.dart';
import 'package:scribes/core/widgets/scribes_ornament_divider.dart';
import 'package:scribes/core/widgets/scribes_post_card.dart';
import 'package:scribes/core/widgets/scribes_reaction_bar.dart';
import 'package:scribes/core/widgets/scribes_scripture_chip.dart';
import 'package:scribes/core/widgets/scribes_empty_state.dart';
import 'package:scribes/core/widgets/scribes_auto_save_dot.dart';
import 'package:scribes/core/widgets/scribes_bottom_nav.dart';
import 'package:scribes/core/widgets/scribes_unauth_banner.dart';

class TestWidgetsScreen extends StatelessWidget {
  const TestWidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared Widgets Test')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ScribesOrnamentDivider:'),
              const ScribesOrnamentDivider(),
              const SizedBox(height: 32),

              const Text('ScribesPostCard:'),
              const ScribesPostCard(
                title: 'The Nature of Grace',
                bodyExcerpt: 'Grace is not merely unmerited favor; it is favor bestowed when wrath is owed. It is the active, intervening love of God.',
                authorName: 'A.W. Tozer',
                authorHandle: '@tozer',
                scriptureRef: 'Ephesians 2:8',
                amenCount: 12,
                insightCount: 5,
                thoughtCount: 2,
                isFeatured: true,
              ),
              const SizedBox(height: 32),

              const Text('ScribesReactionBar:'),
              const ScribesReactionBar(
                amenCount: 24,
                insightCount: 12,
                thoughtCount: 3,
              ),
              const SizedBox(height: 32),

              const Text('ScribesScriptureChip:'),
              ScribesScriptureChip(
                reference: 'John 1:1',
                onTap: () {},
              ),
              const SizedBox(height: 32),

              const Text('ScribesEmptyState:'),
              Container(
                height: 300,
                color: Colors.black.withValues(alpha: 0.05),
                child: ScribesEmptyState(
                  title: 'Nothing written yet',
                  description: 'Your notes and drafts will appear here.',
                  ctaText: 'New Note',
                  onCtaTap: () {},
                ),
              ),
              const SizedBox(height: 32),

              const Text('ScribesAutoSaveDot (All states):'),
              const Row(
                children: [
                  ScribesAutoSaveDot(state: SaveState.saving),
                  SizedBox(width: 8),
                  ScribesAutoSaveDot(state: SaveState.localSaved),
                  SizedBox(width: 8),
                  ScribesAutoSaveDot(state: SaveState.serverSaved),
                  SizedBox(width: 8),
                  ScribesAutoSaveDot(state: SaveState.error),
                ],
              ),
              const SizedBox(height: 32),

              const Text('ScribesUnauthBanner:'),
              ScribesUnauthBanner(
                onJoinTap: () {},
                onLoginTap: () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 0),
    );
  }
}
