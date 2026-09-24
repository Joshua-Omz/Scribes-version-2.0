import 'package:flutter/material.dart';

/// A lightweight keep-alive wrapper for virtualized list items (such as horizontal
/// spotlight carousels or tab pages) that preserves their element state and prevents
/// images and layout trees from being destroyed when scrolled out of the viewport.
class ScribesKeepAliveItem extends StatefulWidget {
  final Widget child;

  const ScribesKeepAliveItem({
    super.key,
    required this.child,
  });

  @override
  State<ScribesKeepAliveItem> createState() => _ScribesKeepAliveItemState();
}

class _ScribesKeepAliveItemState extends State<ScribesKeepAliveItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
