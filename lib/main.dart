import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(BalloonPopApp());
}

class BalloonPopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BalloonPopPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BalloonPopPage extends StatefulWidget {
  @override
  _BalloonPopPageState createState() => _BalloonPopPageState();
}

class _BalloonPopPageState extends State<BalloonPopPage> {
  final List<Balloon> balloons = [];
  final Random random = Random();
  int score = 0;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _startAddingBalloons();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _startAddingBalloons() async {
    while (_isMounted) {
      await Future.delayed(Duration(seconds: 2));
      if (_isMounted) _addBalloon();
    }
  }

  void _addBalloon() {
    final contextOverlay = Overlay.of(context)?.context ?? context;
    final screenWidth = MediaQuery.of(contextOverlay).size.width;
    final x = random.nextDouble() * (screenWidth - 80);

    setState(() {
      balloons.add(
        Balloon(
          key: UniqueKey(),
          x: x,
          onPopped: _onBalloonPopped,
        ),
      );
    });
  }

  Future<void> _onBalloonPopped(Balloon balloon) async {
    final player = AudioPlayer();
    await player.play('assets/pop.mp3', isLocal: true);
    setState(() {
      balloons.remove(balloon);
      score++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Stack(
        children: [
          ...balloons,
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.pink, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Score: \\$score',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        child: Image.asset('assets/balloon.png', width: 80),
      ),
    );
  }
}
