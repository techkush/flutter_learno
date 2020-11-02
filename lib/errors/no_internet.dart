import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_learno/screens/loading.dart';
import 'package:system_settings/system_settings.dart';

class NoInternet extends StatelessWidget {
  alertDialog(BuildContext context, String route) {
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
                    'No Internet Connection',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            content: Row(
              children: <Widget>[
                Text(
                  'Please check your internet connection.',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    elevation: 20,
                    child: Text(
                      'Goto Settings',
                      style: TextStyle(fontSize: 22),
                    ),
                    onPressed: () {
                      SystemSettings.system();
                    },
                  ),
                  MaterialButton(
                    elevation: 20,
                    child: Text(
                      'Retry',
                      style: TextStyle(fontSize: 22),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if(route == 'loading'){
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => Loading()));
                      }
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
