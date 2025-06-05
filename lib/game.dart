import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'balloon.dart';

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
                    'Score: $score',
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
