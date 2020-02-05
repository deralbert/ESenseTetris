import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  Function onClickedFunction;
  MenuButton(this.onClickedFunction);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      padding: EdgeInsets.all(10),
      height: 60,
      minWidth: 200,
      child: RaisedButton(
        onPressed: () {
          onClickedFunction();
        },
        color: Colors.blue,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
