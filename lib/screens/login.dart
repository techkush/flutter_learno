import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_learno/errors/login_errors.dart';
import 'package:flutter_learno/errors/no_internet.dart';
import 'package:flutter_learno/screens/home.dart';
import 'package:flutter_learno/screens/register_form.dart';
import 'package:flutter_learno/screens/sign_up.dart';
import 'package:flutter_learno/widgets/auth_button.dart';
import 'package:flutter_learno/widgets/form_field.dart';
import 'package:flutter_learno/widgets/progress.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _email;
  String _password;
  String _error;
  bool _submitted = false;

  void setEmail(String email) {
    setState(() {
      _email = email;
    });
  }

  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  void loginWithEmail() async {
    var result = await DataConnectionChecker().hasConnection;
    if (!result) {
      // Not Connected
      NoInternet().alertDialog(context, 'login');
    } else {
      // Connected
      if (_email == null || _password == null) {
        setState(() {
          _error = 'Email Address or Password field is empty!';
        });
      }
      if (_email != null) {
        if (!_email.toString().contains("@") &&
            !_email.toString().contains(".")) {
          setState(() {
            _error = 'Incorrect Email address!';
          });
        }
      }
      if (_email != null &&
          _password != null &&
          _email.toString().contains("@") &&
          _email.toString().contains(".")) {
        setState(() {
          _error = null;
          _submitted = true;
        });

        // Firebase part
        FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password)
            .then((user) async {
          final User user = FirebaseAuth.instance.currentUser;
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
        }).catchError((e) {
          setState(() {
            _submitted = false;
          });
          CommonError(
                  title: 'Login Error!',
                  description:
                      'Something is wrong. Please check your email & password.')
              .alertDialog(context);
        });
      }
    }
  }

  GoogleSignIn _googleSignInVal = new GoogleSignIn();

  Future<void> _googleSignIn() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignInVal.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
      final User user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) {
        if (!value.exists) {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RegisterForm()));
        } else {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Home()));
        }
      });
    }).catchError((e) {
      CommonError(
              title: 'Login Error!',
              description: 'Something is wrong. Please check your connection.')
          .alertDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color(0xff615DFA)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Logo
                _submitted ? linearProgress() : Container(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.27,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                    'Learno',
                    style: TextStyle(fontSize: 48, color: Colors.white),
                  )),
                ),
                // Login Area
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Login Text
                        Text(
                          'Sign In',
                          style: TextStyle(fontSize: 28, color: Colors.white),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // Email TextFormField
                        RoundTextField(
                            icon: Icon(
                              FeatherIcons.mail,
                              color: Colors.grey,
                            ),
                            hintText: 'Email Address',
                            hideText: false,
                            textInputType: false,
                            controllerFunction: setEmail),
                        SizedBox(
                          height: 20,
                        ),
                        RoundTextField(
                            icon: Icon(
                              FeatherIcons.lock,
                              color: Colors.grey,
                            ),
                            hintText: 'Password',
                            hideText: true,
                            textInputType: false,
                            controllerFunction: setPassword),
                        SizedBox(
                          height: 15,
                        ),
                        // Error Message
                        _error != null
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      _error,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 15,
                        ),
                        AuthButton(
                            handleFunction: loginWithEmail, name: 'Sign In'),
                        SizedBox(
                          height: 10,
                        ),
                        FlatButton(
                          padding: EdgeInsets.all(0),
                          child: Center(
                              child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        AuthButton(
                            handleFunction: _googleSignIn,
                            name: 'Sign In with Google'),
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Don\'t have an account? ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                            FlatButton(
                              padding: EdgeInsets.all(1),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUp()));
                              },
                              child: Text(
                                'Create one',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
