import 'package:flutter/material.dart';
import 'package:scribes/components/postCard.dart';
import 'package:scribes/models/models.dart';
class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
      final dummyPostA = Post(
      id: '1',
      title: "The Architecture of Modern Thought",
      body: "An exploration into how our digital tools shape the very foundation of our creative process, limiting and expanding boundaries simultaneously.",
      category: "ESSAY",
    );
    final dummyPostB = Post(
      id: '2',
      title: "Whispers in the Code",
      body: "A silent machine hums along in the dark, generating endless possibilities while we sleep.",
      category: "POETRY",
    );
    final dummyPostC = Post(
      id: '3',
      title: "Shadows & Light: A Study of Forms",
      body: "",
      category: "PHOTOGRAPHY",
    );
    final dummyPostD = Post(
      id: '4',
      title: "The Lost Art of Letter Writing",
      body: "A retrospective on physical correspondence and what it meant to wait for words.",
      category: "ARCHIVE",
    );
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        PostCard(post: dummyPostA, layout: PostCardLayout.standard),
        const SizedBox(height: 16.0),
        PostCard(post: dummyPostB, layout: PostCardLayout.textOnly),
        const SizedBox(height: 16.0),
        PostCard(post: dummyPostC, layout: PostCardLayout.overlay),
        const SizedBox(height: 16.0),
        PostCard(post: dummyPostD, layout: PostCardLayout.feature),
        const SizedBox(height: 32.0),
      ],
    );
  }
}