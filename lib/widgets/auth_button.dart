import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AuthButton extends StatelessWidget {

  AuthButton({@required this.handleFunction, @required this.name});

  Function handleFunction;
  String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: double.infinity,
      child: RaisedButton(
        onPressed: () {
          handleFunction();
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              color: Color(0xff23D2E2),
              borderRadius: BorderRadius.circular(40.0)),
          child: Container(
            constraints: BoxConstraints(minHeight: 60.0),
            alignment: Alignment.center,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }


}
