import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EsenseButton extends StatelessWidget {
  Function onClickedFunction;
  EsenseButton(this.onClickedFunction);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 60,
      minWidth: 200,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: RaisedButton(
          onPressed: () {
            onClickedFunction();
          },
          color: Colors.blue,
          child: Icon(Icons.bluetooth_connected),
        ),
      ),
    );
  }
}
