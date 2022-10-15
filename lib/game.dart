import 'dart:math';

import 'package:demo2048/math.dart';
import 'package:flutter/material.dart';

enum Direction {
  up,
  down,
  left,
  right,
}

Random _rand = Random();

class Node {
  // if one prefers to remove presentation layer data,
  // we can replace this with a unique key
  // this can be used in doing animation too
  late Color colour;
  int value;

  Node(this.value) {
    colour = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  }
}

class Game extends ChangeNotifier {
  static const int puzzleSize = 4; // 4x4
  static const int spawn = 2; // spawn 2
  static const int goal = 2048;

  final Map<int, Node> data = {};
  int _highest = 0;

  void slide(Direction direction) {
    var mapper = List<List<int>>.generate(
      puzzleSize,
      (i) => List<int>.generate(puzzleSize, (j) => i * puzzleSize + j).toList(),
    ).toList();

    switch (direction) {
      case Direction.left:
        break;
      case Direction.up:
        transpose(mapper);
        break;
      case Direction.right:
        reflect(mapper);
        break;
      case Direction.down:
        transpose(mapper);
        reflect(mapper);
        break;
    }

    for (int i = 0; i < mapper.length; i++) {
      var lastEmpty = data[mapper[i][0]] == null ? 0 : 1;
      var lastMerger = 0;
      for (int j = 1; j < mapper.length; j++) {
        var mappedIdx = mapper[i][j];
        if (data[mappedIdx] != null) {
          if (lastMerger < lastEmpty) {
            var mergerIdx = mapper[i][lastMerger];
            var sum = data[mergerIdx]!.value + data[mappedIdx]!.value;
            if (sum > _highest) _highest = sum;
            data[mergerIdx]!.value = sum;
            data.remove(mappedIdx);
            lastMerger++;
          } else {
            // shift to last empty position
            var emptyIdx = mapper[i][lastEmpty];
            data[emptyIdx] = data[mappedIdx]!;
            data.remove(mappedIdx);
            lastEmpty++;
          }
        }
      }
    }
    notifyListeners();
  }

  bool generateRandom(int count) {
    if (puzzleSize * puzzleSize - data.length < count) return false;
    var availables =
        List<int>.generate(puzzleSize * puzzleSize, (index) => index)
            .toSet()
            .difference(
              data.keys.toSet(),
            )
            .toList();
    for (int i = 0; i < count; i++) {
      data[availables[_rand.nextInt(availables.length)]] = Node(
        1,
      );
    }
    notifyListeners();
    return true;
  }

  bool get isWon => _highest >= goal;
}
