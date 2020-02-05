import 'dart:collection';
import 'dart:math';

import 'package:esense_flutter/esense.dart';
import 'package:flutter/material.dart';
import 'helper.dart';
import 'dart:async';
import 'blocks/block.dart';
import 'blocks/alivePoint.dart';
import 'scoreDisplay.dart';
import 'userInput.dart';
import 'settings.dart';

class Game extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Game();
}

StreamSubscription subscription;

class _Game extends State<Game> {
  LastButtonPressed performAction = LastButtonPressed.NONE;
  Block currentBlock;
  List<AlivePoint> alivePoints = List<AlivePoint>();
  int score = 0;
  var settings = Settings();

  double _accelZ = -7.5;

  bool listenToEEventsactive = false;

  void _startListenToSensorEvents() async {
    // Queue queueX = new Queue();
    // Queue queueY = new Queue();
    Queue queueZ = new Queue();
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      if (this.mounted) {
        setState(() {
          if (queueZ.length < 5) {
            queueZ.addFirst(event.accel[2]);
          } else {
            List<int> filteredData = new List();
            // const int offsetX = -6216;
            // const int offsetY = -6894;
            const int offsetZ = 9220;
            filteredData.add(_filter(queueZ) - offsetZ);
            _accelZ = _doubleRound(((filteredData[0]) / 8192 * 9.80665), 2);
            queueZ.removeLast();
          }
        });
      }
    });
    if (this.mounted) {
      setState(() {
        listenToEEventsactive = true;
      });
    }
  }

  double _doubleRound(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  int _filter(Queue queue) {
    List<int> list = new List();
    queue.forEach((element) => list.add(element));
    // print("List form queue" + list.toString());
    list.sort();
    int a = 10; // Abweichung
    int middleValue = list[(list.length / 2).round() + 1];
    int filterValue = middleValue + a;
    for (var i = 0; i < list.length; i++) {
      if (list[i].abs() < filterValue) {
        list.removeAt(i);
      }
    }
    int outputValue = 0;
    for (var i = 0; i < list.length; i++) {
      outputValue = outputValue + list[i];
    }
    return (outputValue / list.length).round();
  }

  @override
  void initState() {
    super.initState();
    if (ESenseManager.connected) {
      _startListenToSensorEvents();
    }
    startGame();
  }

  void onActionButtonPressed(LastButtonPressed newAction) {
    setState(() {
      performAction = newAction;
    });
  }

  void startGame() {
    if (this.mounted) {
      setState(() {
        currentBlock = getRandomBlock();
      });
    }

    settings.timer = new Timer.periodic(
      new Duration(milliseconds: settings.gameSpeed),
      onTimeTick,
    );
  }

  void checkForUserInput() {
    if (performAction != LastButtonPressed.NONE) {
      setState(() {
        switch (performAction) {
          case LastButtonPressed.LEFT:
            currentBlock.move(MoveDirection.LEFT);
            break;
          case LastButtonPressed.RIGHT:
            currentBlock.move(MoveDirection.RIGHT);
            break;
          case LastButtonPressed.ROTATE_LEFT:
            currentBlock.rotateLeft();
            break;
          case LastButtonPressed.ROTATE_RIGHT:
            currentBlock.rotateRight();
            break;
          default:
            break;
        }
        performAction = LastButtonPressed.NONE;
      });
    }
  }

  void checkForUserAcceleration() {
    print(_accelZ.toString());
    if (_accelZ < -12) {
      currentBlock.move(MoveDirection.LEFT);
    } else if (_accelZ > -5.5) {
      currentBlock.move(MoveDirection.RIGHT);
    }
  }

  void checkForESenseButton() {
    ESenseManager.eSenseEvents.listen((event) {
      if (this.mounted) {
        setState(() {
          switch (event.runtimeType) {
            case ButtonEventChanged:
              if ((event as ButtonEventChanged).pressed) {
                currentBlock.rotateLeft();
              }
              break;
          }
        });
      }
    });
  }

  void saveOldBlock() {
    currentBlock.points.forEach((point) {
      AlivePoint newPoint = AlivePoint(point.x, point.y, currentBlock.color);
      setState(() {
        alivePoints.add(newPoint);
      });
    });
  }

  bool isAboweOldBlock() {
    bool retVal = false;
    alivePoints.forEach((oldPoint) {
      if (oldPoint.checkIfPointsCollide(currentBlock.points)) {
        retVal = true;
      }
    });

    return retVal;
  }

  void removeRow(int row) {
    setState(() {
      alivePoints.removeWhere((point) => point.y == row);

      alivePoints.forEach((point) {
        if (point.y < row) {
          point.y += 1;
        }
      });

      score += 1;
    });
  }

  void removeFullRows() {
    for (int currentRow = 0; currentRow < settings.boardHeight; currentRow++) {
      //loop through all rows (top to bottom)
      int counter = 0;
      alivePoints.forEach((point) {
        if (point.y == currentRow) {
          counter++;
        }
      });

      if (counter >= settings.boardWidth) {
        //remove current row
        removeRow(currentRow);
      }
    }
  }

  bool playerLost() {
    bool retVal = false;

    alivePoints.forEach((point) {
      if (point.y <= 0) {
        retVal = true;
      }
    });

    return retVal;
  }

  void onTimeTick(Timer time) {
    if (currentBlock == null || playerLost()) return;

    //remove full rows
    removeFullRows();

    //check if tile is already at the bottom
    if (currentBlock.isAtBottom() || isAboweOldBlock()) {
      //save the block
      saveOldBlock();

      //spawn new block
      setState(() {
        currentBlock = getRandomBlock();
      });
    } else {
      setState(() {
        currentBlock.move(MoveDirection.DOWN);
      });
      checkForUserInput();
      if (ESenseManager.connected) {
        checkForUserAcceleration();
        checkForESenseButton();
      }
    }
  }

  Widget drawTetrisBlocks() {
    if (currentBlock == null) return null;

    List<Positioned> visiblePoints = List();

    //currentBlock
    currentBlock.points.forEach((point) {
      visiblePoints.add(
        Positioned(
          child: getTetrisPoint(currentBlock.color),
          left: point.x * settings.pointSize,
          top: point.y * settings.pointSize,
        ),
      );
    });

    //old blocks
    alivePoints.forEach((point) {
      visiblePoints.add(
        Positioned(
          child: getTetrisPoint(point.color),
          left: point.x * settings.pointSize,
          top: point.y * settings.pointSize,
        ),
      );
    });

    return Stack(children: visiblePoints);
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Center(
          child: Container(
            width: settings.pixelWidth,
            height: settings.pixelHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: (playerLost() == false)
                ? drawTetrisBlocks()
                : getGameOverText(score),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ScoreDisplay(score),
            UserInput(onActionButtonPressed),
          ],
        )
      ],
    );
  }
}
