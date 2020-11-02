import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RoundTextField extends StatefulWidget {

  RoundTextField({@required this.icon, @required this.hintText, @required this.hideText, @required this.controllerFunction,@required this.textInputType});

  Icon icon;
  String hintText;
  bool hideText;
  bool textInputType;
  Function controllerFunction;

  @override
  _RoundTextFieldState createState() => _RoundTextFieldState();
}

class _RoundTextFieldState extends State<RoundTextField> {
  TextEditingController textController = TextEditingController();

  clearTextBox(){
    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            widget.icon,
            SizedBox(
              width: 10,
            ),
            Flexible(
              child: TextFormField(
                controller: textController,
                obscureText: widget.hideText,
                keyboardType:widget.textInputType ? TextInputType.number : TextInputType.text,
                cursorColor: Colors.black,
                onChanged: (value) {
                  widget.controllerFunction(value);
                },
                decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.grey)
                ) ,
              ),
            )
          ],
        ),
      ),
    );
  }
}
