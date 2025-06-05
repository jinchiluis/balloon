import 'package:flutter/material.dart';

class Balloon extends StatefulWidget {
  final double x;
  final Function(Balloon) onPopped;

  const Balloon({
    Key? key,
    required this.x,
    required this.onPopped,
  }) : super(key: key);

  @override
  _BalloonState createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double? yStart;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final screenHeight = MediaQuery.of(context).size.height;
      yStart = screenHeight;
      _animation = Tween<double>(begin: yStart, end: -100).animate(_controller)
        ..addListener(() {
          if (mounted) setState(() {});
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.onPopped(widget);
          }
        });
      _controller.forward();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pop() {
    widget.onPopped(widget);
  }

  @override
  Widget build(BuildContext context) {
    if (yStart == null) {
      return SizedBox.shrink();
    }
    return Positioned(
      left: widget.x,
      top: _animation.value,
      child: GestureDetector(
        onTap: _pop,
        child: Image.asset('assets/balloon.png', width: 240),
      ),
    );
  }
}
