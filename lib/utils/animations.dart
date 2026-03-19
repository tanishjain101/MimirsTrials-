import 'package:flutter/material.dart';

class AppAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 500);
  static const Duration fastDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 800);
  
  static Curve curve = Curves.easeInOut;
}

class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(seconds: 1),
    this.style,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.addListener(() {
      setState(() {
        _displayValue = (widget.value * _animation.value).round();
      });
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayValue.toString(),
      style: widget.style,
    );
  }
}