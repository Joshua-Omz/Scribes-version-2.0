import 'package:flutter/material.dart';

class ScribesTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  ScribesTabBarDelegate({required this.child});

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant ScribesTabBarDelegate oldDelegate) {
    return true; // or compare children
  }
}
