import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_learno/errors/login_errors.dart';
import 'package:flutter_learno/screens/home.dart';
import 'package:flutter_learno/widgets/auth_button.dart';
import 'package:flutter_learno/widgets/form_field.dart';
import 'package:flutter_learno/widgets/progress.dart';

// ignore: must_be_immutable
class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _RegisterFormState extends State<RegisterForm> {
  String _firstName;
  String _lastName;
  String _mobileNumber;
  String _gender;
  String _userRole;
  Schools _school;
  List<String> _schoolList = [];
  String _selectedSchool;
  DateTime selectedDate;

  String _error;
  bool _loading = false;

  void setFirstName(String firstName) {
    setState(() {
      _firstName = firstName;
    });
  }

  void setLastName(String lastName) {
    setState(() {
      _lastName = lastName;
    });
  }

  void setMobileNumber(String mobileNumber) {
    setState(() {
      _mobileNumber = mobileNumber;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    //var list = [objectBeingAdded];
    List<String> schools = [
      "Rahula College",
      "Mahamaya College",
      "Sujatha College"
    ];
    FirebaseFirestore.instance
        .collection('app_settings')
        .doc('schools')
        .set({"schools": schools});
    super.initState();
    getSchoolList();
  }

  void getSchoolList() async {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('app_settings')
        .doc('schools')
        .get();
    _school = Schools.fromDocument(doc);
    for (final e in _school.schoolList) {
      _schoolList.add(e);
    }
  }

  void saveData() async {
    if (_firstName == null ||
        _lastName == null ||
        _mobileNumber == null ||
        _gender == null ||
        _userRole == null ||
        _selectedSchool == null) {
      setState(() {
        _error = 'Some fields are empty. Please fill the all fields!';
      });
    }

    if (!(_firstName == null) &&
        !(_lastName == null) &&
        !(_mobileNumber == null) &&
        !(_gender == null) &&
        !(_userRole == null) &&
        !(_selectedSchool == null)) {
      setState(() {
        _loading = true;
      });
      final User user = _auth.currentUser;
      await followersRef
          .doc(user.uid)
          .collection('userFollowers')
          .doc(user.uid)
          .set({});
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        "firstName": _firstName,
        "lastName": _lastName,
        "mobileNumber": _mobileNumber,
        "gender": _gender,
        "userRole": _userRole,
        "school": _selectedSchool,
        "birthday": selectedDate,
        "photoUrl": user.photoURL,
        "email": user.email,
        "id": user.uid,
        "displayName": "$_firstName $_lastName"
      }).then((value) {
        Navigator.of(context).pop();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      }).catchError((e) {
        CommonError(
                title: 'Form Error!',
                description:
                    'Something is wrong. Please check your connection.')
            .alertDialog(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color(0xff615DFA)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Logo
                _loading ? linearProgress() : Container(),
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
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Login Text
                        Text(
                          'Fill the form',
                          style: TextStyle(fontSize: 28, color: Colors.white),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // Email TextFormField
                        RoundTextField(
                            icon: Icon(
                              FeatherIcons.user,
                              color: Colors.grey,
                            ),
                            hintText: 'First Name',
                            hideText: false,
                            textInputType: false,
                            controllerFunction: setFirstName),
                        SizedBox(
                          height: 20,
                        ),
                        RoundTextField(
                            icon: Icon(
                              FeatherIcons.user,
                              color: Colors.grey,
                            ),
                            hintText: 'Last Name',
                            hideText: false,
                            textInputType: false,
                            controllerFunction: setLastName),
                        SizedBox(
                          height: 20,
                        ),
                        RoundTextField(
                            icon: Icon(
                              FeatherIcons.smartphone,
                              color: Colors.grey,
                            ),
                            hintText: 'Mobile Number',
                            hideText: false,
                            textInputType: true,
                            controllerFunction: setMobileNumber),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _selectDate(context);
                          },
                          child: Container(
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
                                  Icon(FeatherIcons.calendar,
                                      color: Colors.grey),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                      child: selectedDate == null
                                          ? Text(
                                              "Select your Birthday",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                            )
                                          : Text("${selectedDate.toLocal()}"
                                              .split(' ')[0]))
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // Gender Drop Down
                        Container(
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
                                Icon(
                                  FeatherIcons.userCheck,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.66,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                        value: _gender,
                                        hint: Text('Gender',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        items: [
                                          DropdownMenuItem(
                                            child: Text("Male"),
                                            value: "Male",
                                          ),
                                          DropdownMenuItem(
                                            child: Text("Female"),
                                            value: "Female",
                                          ),
                                        ],
                                        onChanged: (value) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          setState(() {
                                            _gender = value;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // User Role Drop Down
                        Container(
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
                                Icon(
                                  FeatherIcons.penTool,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.66,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                        value: _userRole,
                                        hint: Text('User Role',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        items: [
                                          DropdownMenuItem(
                                            child: Text("Student"),
                                            value: "Student",
                                          ),
                                          DropdownMenuItem(
                                            child: Text("Teacher"),
                                            value: "Teacher",
                                          ),
                                          DropdownMenuItem(
                                            child: Text("Parent"),
                                            value: "Parent",
                                          ),
                                        ],
                                        onChanged: (value) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          setState(() {
                                            _userRole = value;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // School List from Firebase
                        Container(
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
                                Icon(
                                  FeatherIcons.home,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.66,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      items: _schoolList.map((view) {
                                        return new DropdownMenuItem(
                                          child: new Text(
                                            view,
                                          ),
                                          value: view,
                                        );
                                      }).toList(),
                                      value: _selectedSchool,
                                      onChanged: (String newValue) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        setState(() {
                                          _selectedSchool = newValue;
                                        });
                                      },
                                      hint: Text('School',
                                          style: TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
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
                          height: 20,
                        ),
                        AuthButton(handleFunction: saveData, name: 'Save'),
                        SizedBox(
                          height: 40,
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

class Schools {
  List schoolList;

  Schools({this.schoolList});

  factory Schools.fromDocument(DocumentSnapshot doc) {
    return Schools(schoolList: doc['schools']);
  }
}
