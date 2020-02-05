import 'package:flutter/material.dart';
import 'blocks/block.dart';
import 'blocks/IBlock.dart';
import 'blocks/JBlock.dart';
import 'blocks/LBlock.dart';
import 'blocks/SBlock.dart';
import 'blocks/SqBlock.dart';
import 'blocks/TBlock.dart';
import 'blocks/ZBlock.dart';
import 'dart:math';
import 'game.dart';
import 'settings.dart';

Block getRandomBlock() {
  int randomNumber = Random().nextInt(7); // 7 blocks at all
  var settings = Settings();
  switch (randomNumber) {
    case 0:
      return IBlock(settings.boardWidth);
      break;
    case 1:
      return JBlock(settings.boardWidth);
      break;
    case 2:
      return LBlock(settings.boardWidth);
      break;
    case 3:
      return SBlock(settings.boardWidth);
      break;
    case 4:
      return SqBlock(settings.boardWidth);
      break;
    case 5:
      return TBlock(settings.boardWidth);
      break;
    case 6:
      return ZBlock(settings.boardWidth);
      break;
    default:
      return IBlock(settings.boardWidth);
      break;
  }
}

Widget getTetrisPoint(Color color) {
  var settings = Settings();
  return Container(
    width: settings.pointSize,
    height: settings.pointSize,
    decoration: new BoxDecoration(color: color, shape: BoxShape.rectangle),
  );
}

Widget getGameOverText(int score) {
  return Center(
    child: Text(
      'Game Over\nEnd Score $score',
      style: TextStyle(
          fontSize: 35.0,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          shadows: [
            Shadow(
                color: Colors.black, blurRadius: 3.0, offset: Offset(2.0, 2.0))
          ]),
    ),
  );
}
