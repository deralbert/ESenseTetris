import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'settings.dart';

class ActionButton extends StatelessWidget {
  Function onClickedFunction;
  Icon buttonIcon;
  LastButtonPressed nextAction;

  ActionButton(this.onClickedFunction, this.buttonIcon, this.nextAction);

  Widget build(BuildContext context) {
    return ButtonTheme(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: RaisedButton(
          onPressed: () {
            onClickedFunction(nextAction);
          },
          color: Colors.blue,
          child: buttonIcon,
        ),
      ),
    );
  }
}
