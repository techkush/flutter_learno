import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

// ignore: must_be_immutable
class CommonError extends StatelessWidget {
  CommonError({@required this.title, @required this.description});

  String title;
  String description;

  alertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            title: Container(
              child: Row(
                children: <Widget>[
                  Icon(
                    FeatherIcons.alertTriangle,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            content: Flexible(
              child: Text(
                description,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: TextStyle(fontSize: 18),
              ),
            ),
            actions: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    elevation: 20,
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 22),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
