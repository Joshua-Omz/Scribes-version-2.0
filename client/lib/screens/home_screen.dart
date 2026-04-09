import 'package:flutter/material.dart';
import '../components/feeds/feed.dart ';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Feed(), // FEED
          Center(child: Text('NOTES')), // NOTES
          Center(child: Text('DRAFTS')), // DRAFTS
          Center(child: Text('SETTINGS')), // SETTINGS
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // 2. Top App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: const Icon(Icons.auto_awesome), // Brand mark
      centerTitle: true,
      title: const Text('Scribes'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80'),
            ),
          ),
        ),
      ],
    );
  }

 

  // 4. Bottom Navigation
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'FEED',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          activeIcon: Icon(Icons.description),
          label: 'NOTES',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_document),
          activeIcon: Icon(Icons.edit_document),
          label: 'DRAFTS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'SETTINGS',
        ),
      ],
    );
  }
}
