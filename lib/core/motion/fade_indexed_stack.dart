import 'package:flutter/material.dart';
import 'package:maak_metro/core/motion/app_motion.dart';

/// [IndexedStack] with a Material 3 fade-through between tabs: the current tab
/// fades out completely first, then the next one fades in and settles from 98%.
/// The two are never visible together, so no old content lingers under the new
/// tab. Children stay alive; reduced motion swaps instantly.
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
    duration: AppMotion.slow,
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
    final leaving = ReverseAnimation(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.38, curve: AppMotion.accelerate),
      ),
    );
    final arriving = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.38, 1, curve: AppMotion.decelerate),
    );

    final stack = <Widget>[
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
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.98,
            end: 1,
          ).animate(previous == null ? kAlwaysCompleteAnimation : arriving),
          child: widget.children[widget.index],
        ),
      ),
    ];

    return Stack(fit: StackFit.expand, children: stack);
  }
}
