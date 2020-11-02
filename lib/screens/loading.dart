import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno/errors/no_internet.dart';
import 'package:flutter_learno/screens/home.dart';
import 'package:flutter_learno/screens/login.dart';
import 'package:flutter_learno/screens/register_form.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(seconds: 5), () {
      _checkInternet();
    });
    super.initState();
  }

  _checkInternet() async {
    var result = await DataConnectionChecker().hasConnection;
    if (!result) {
      // Not Connected
      NoInternet().alertDialog(context, 'loading');
    } else {
      // Connected
      final User user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((value) {
          if (!value.exists) {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegisterForm()));
          } else {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
          }
        });
      } else {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xff615DFA)),
          child: Center(
              child: Text(
            'Learno',
            style: TextStyle(fontSize: 48, color: Colors.white),
          )),
        ),
      ),
    );
  }
}
