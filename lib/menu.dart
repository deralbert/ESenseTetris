import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:flutter/material.dart';
import 'package:tetris/eSenseButton.dart';
import 'package:tetris/main.dart';
import 'eSenseDisposeButton.dart';
import 'menuButton.dart';
import 'dart:collection';

class Menu extends StatefulWidget {
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  void onPlayClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen()),
    );
  }

  String _accelerometer;
  String _accelX;
  String _accelY;
  String _accelZ;
  String _deviceStatus = 'unknown';
  bool sampling = false;

  bool listenToEEventsactive = false;

  // the name of the eSense device to connect to -- change this to your own device.
  String eSenseName = 'eSense-0539';

  @override
  void initState() {
    super.initState();
  }

  void _listenConnectionEvents() {
// if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });
  }

  Future<void> _connectToESense() async {
    bool con = false;
    if (_deviceStatus != 'connected' &&
        _deviceStatus != 'device_found' &&
        _deviceStatus != 'connecting') {
      _listenConnectionEvents();
      con = await ESenseManager.connect(eSenseName);
      if (con == false) {
        setState(() {
          _deviceStatus = 'unknown';
        });
      } else {
        setState(() {
          _deviceStatus = con ? 'connecting' : 'connection failed';
        });
      }
    }
  }

  StreamSubscription subscription;
  void _startListenToSensorEvents() async {
    Queue queueX = new Queue();
    Queue queueY = new Queue();
    Queue queueZ = new Queue();
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      // print('SENSOR event: $event');
      setState(() {
        if (queueZ.length < 11) {
          //print(queueX.length);
          //queueX.addFirst(event.accel[0]);
          //queueY.addFirst(event.accel[1]);
          queueZ.addFirst(event.accel[2]);
        } else {
          List<int> filteredData = new List();
          const int offsetX = -6216;
          const int offsetY = -6894;
          const int offsetZ = 9220;
          //filteredData.add(_filter(queueX) - offsetX);
          //filteredData.add(_filter(queueY) - offsetY);
          filteredData.add(_filter(queueZ) - offsetZ);
          //_accelX = ((filteredData[0]) / 8192 * 9.80665).toStringAsFixed(0);
          //_accelY = ((filteredData[1]) / 8192 * 9.80665).toStringAsFixed(0);
          _accelZ = ((filteredData[0]) / 8192 * 9.80665).toStringAsFixed(1);
          // _accelerometer = ((filteredData[0]) / 8192 * 9.80665).toString() +
          //     ", " +
          //     ((filteredData[1]) / 8192 * 9.80665).toString() +
          //     ", " +
          //     ((filteredData[2]) / 8192 * 9.80665).toString();
          //queueX.removeLast();
          //queueY.removeLast();
          queueZ.removeLast();
        }
        // offsets
        // x: -6216
        // y: -6894
        // z: 9220
        // _accelerometerPure = (event.accel.toString());
      });
    });
    setState(() {
      sampling = true;
      listenToEEventsactive = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    subscription.cancel();
    setState(() {
      sampling = false;
      listenToEEventsactive = false;
    });
  }

  void dispose() {
    _pauseListenToSensorEvents();
    ESenseManager.disconnect();
    super.dispose();
  }

  void disconnet() {
    //_pauseListenToSensorEvents();
    ESenseManager.disconnect();
  }

  void prConStatus() {
    print(ESenseManager.connected.toString());
  }

  int _filter(Queue queue) {
    List<int> list = new List();
    queue.forEach((element) => list.add(element));
    // print("List form queue" + list.toString());
    list.sort();
    int a = 10; // Abweichung
    int middleValue = list[5];
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

  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Tetris',
              style: TextStyle(
                  fontSize: 70.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  shadows: [
                    Shadow(
                        color: Colors.black,
                        blurRadius: 8.0,
                        offset: Offset(2.0, 2.0))
                  ])),
          Text('with eSense',
              style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  shadows: [
                    Shadow(
                        color: Colors.black,
                        blurRadius: 8.0,
                        offset: Offset(2.0, 2.0))
                  ])),
          MenuButton(onPlayClicked),
          EsenseButton((!ESenseManager.connected)
              ? _connectToESense
              : (!listenToEEventsactive)
                  ? _startListenToSensorEvents
                  : _pauseListenToSensorEvents),
          EsenseDisposeButton(
              (ESenseManager.connected) ? disconnet : prConStatus),
          Text('Device status: $_deviceStatus'
              /*(ESenseManager.connected ? 'connected' : 'disconnected')*/
              ),
          // Text('Accelerometer X data: $_accelX'),
          // Text('Accelerometer Y data: $_accelY'),
          // Text('Accelerometer Z data: $_accelZ'),
        ],
      ),
    );
  }
}
