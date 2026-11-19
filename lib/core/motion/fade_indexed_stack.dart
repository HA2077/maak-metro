import 'package:flutter/material.dart';
import 'package:maak_metro/core/motion/app_motion.dart';

/// [IndexedStack] with a cross-dissolve between tabs: the old tab fades out
/// while the new one fades in, on top of it, from the first frame.
///
/// Earlier versions either held the old tab at full opacity until the new one
/// was halfway in, or faded to nothing before the new tab appeared. Both read
/// as a flash. Here the two opacities always sum to one, so there is never a
/// frame with no content, and the old tab is never sitting still underneath.
/// Children stay alive; reduced motion swaps instantly.
class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.base,
    value: 1,
  );
  int? _previousIndex;

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    if (AppMotion.reduced(context)) {
      _previousIndex = null;
      _controller.value = 1;
      return;
    }
    _previousIndex = oldWidget.index;
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _previousIndex = null);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previous = _previousIndex;
    final arriving = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.standard,
    );
    final leaving = ReverseAnimation(arriving);

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          if (i != widget.index && i != previous)
            Offstage(offstage: true, child: widget.children[i]),
        if (previous != null && previous != widget.index)
          IgnorePointer(
            child: FadeTransition(
              opacity: leaving,
              child: widget.children[previous],
            ),
          ),
        FadeTransition(
          opacity: previous == null ? kAlwaysCompleteAnimation : arriving,
          child: widget.children[widget.index],
        ),
      ],
    );
  }
}
