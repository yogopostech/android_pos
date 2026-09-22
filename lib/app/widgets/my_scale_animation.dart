import 'package:flutter/material.dart';

class MyScaleAnimation extends StatefulWidget {
  const MyScaleAnimation({
    super.key,
    required this.child,
    this.startSize = 100,
    this.endSize = 600,
    this.duration = 800,
  });

  final Widget child;
  final double startSize;
  final double endSize;
  final int duration;

  @override
  State<MyScaleAnimation> createState() => _MyScaleAnimationState();
}

class _MyScaleAnimationState extends State<MyScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );

    _animation =
        Tween<double>(begin: widget.startSize, end: widget.endSize).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
            setState(() {});
          });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
