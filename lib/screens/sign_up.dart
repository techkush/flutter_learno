import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_learno/errors/login_errors.dart';
import 'package:flutter_learno/errors/no_internet.dart';
import 'package:flutter_learno/screens/home.dart';
import 'package:flutter_learno/screens/login.dart';
import 'package:flutter_learno/screens/register_form.dart';
import 'package:flutter_learno/widgets/auth_button.dart';
import 'package:flutter_learno/widgets/form_field.dart';
import 'package:flutter_learno/widgets/progress.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String _email;
  String _password;
  String _rePassword;
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

  void setRePassword(String rePassword) {
    setState(() {
      _rePassword = rePassword;
    });
  }

  Future<void> registerWithEmail() async {
    var result = await DataConnectionChecker().hasConnection;
    if (!result) {
      // Not Connected
      NoInternet().alertDialog(context, 'signup');
    } else {
      if (_email == null || _password == null || _rePassword == null) {
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
      if (_password != _rePassword) {
        setState(() {
          _error = 'Password not match!';
        });
      }
      if (_email != null &&
          _email.toString().contains("@") &&
          _email.toString().contains(".") &&
          _password == _rePassword) {
        setState(() {
          _error = null;
          _submitted = true;
        });
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: _email, password: _password)
            .then((user) async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.user.uid)
              .get()
              .then((value) {
            if (!value.exists) {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => RegisterForm()));
            }else{
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            }
          });
        }).catchError((e) {
          CommonError(
              title: 'Register Error!',
              description:
              'Something is wrong. Please check your email & password.')
              .alertDialog(context);
          setState(() {
            _submitted = false;
          });
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
    await FirebaseAuth.instance.signInWithCredential(credential).then((value_1) async {
      final User user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value_3) {
        if (!value_3.exists) {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RegisterForm()));
        }else{
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Home()));
        }
      });
    }).catchError((e) {
      CommonError(
          title: 'Login Error!',
          description:
          'Something is wrong. Please check your connection.')
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
                _submitted ? linearProgress() : Container(),
                // Logo
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
                          'Register',
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
                          height: 20,
                        ),
                        RoundTextField(
                            icon: Icon(
                              FeatherIcons.lock,
                              color: Colors.grey,
                            ),
                            hintText: 'RePassword',
                            hideText: true,
                            textInputType: false,
                            controllerFunction: setRePassword),
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
                            handleFunction: registerWithEmail,
                            name: 'Create Account'),
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: Text(
                            'OR',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        AuthButton(
                            handleFunction: _googleSignIn, name: 'Register with Google'),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Have an account? ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()));
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
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
