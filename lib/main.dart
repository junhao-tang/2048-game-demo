import 'dart:math';

import 'package:demo2048/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var gameRef = Game();
    gameRef.generateRandom(2);

    return MaterialApp(
      title: '2048 demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: WrapperWidget(gameRef),
      ),
    );
  }
}

class WrapperWidget extends StatefulWidget {
  final Game gameRef;

  const WrapperWidget(this.gameRef, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WrapperWidgetState();
}

class _WrapperWidgetState extends State<WrapperWidget> {
  static const Duration debounce = Duration(milliseconds: 500);

  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (_disabled) return;
        if (details.delta.dx > 0) {
          widget.gameRef.slide(Direction.right);
        } else if (details.delta.dx < 0) {
          widget.gameRef.slide(Direction.left);
        } else if (details.delta.dy > 0) {
          widget.gameRef.slide(Direction.down);
        } else {
          widget.gameRef.slide(Direction.up);
        }
        setState(
          () {
            _disabled = true;
          },
        );
        if (widget.gameRef.isWon) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Completed'),
              content: const Text('Done'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          if (!widget.gameRef.generateRandom(2)) {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Gameover'),
                content: const Text('Gameover'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          Future.delayed(
            debounce,
            () => setState(() => _disabled = false),
          );
        }
      },
      child: GameWidget(widget.gameRef),
    );
  }
}

class GameWidget extends StatelessWidget {
  static const double cellSize = 50;

  final Game gameRef;
  final Map<String, Color> colourMapper = {};

  GameWidget(this.gameRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Game>.value(
      value: gameRef,
      builder: (context, child) => Consumer<Game>(
        builder: (context, gameRef, child) => SizedBox(
          width: cellSize * Game.puzzleSize,
          child: GridView.count(
            crossAxisCount: Game.puzzleSize,
            children: List<Container>.generate(
                Game.puzzleSize * Game.puzzleSize, (index) {
              var node = gameRef.data[index];
              var text = node == null ? '' : '${node.value}';
              var color = node == null ? Colors.white : node.colour;
              return Container(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
