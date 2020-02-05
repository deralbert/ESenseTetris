import 'point.dart';
import 'package:flutter/material.dart';

class AlivePoint extends Point {
  Color color;

  AlivePoint(int x, int y, this.color) : super(x, y) {
    // this.color = color;
  }

  bool checkIfPointsCollide(List<Point> pointList) {
    bool returnValue = false;

    pointList.forEach((pointToCheck) {
      if (pointToCheck.x == x && pointToCheck.y == y - 1) {
        returnValue = true;
      }
    });

    return returnValue;
  }
}
