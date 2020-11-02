import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_learno/errors/login_errors.dart';
import 'package:flutter_learno/pages/feed.dart';
import 'package:flutter_learno/pages/homepage.dart';
import 'package:flutter_learno/models/user.dart';
import 'package:flutter_learno/pages/notifications.dart';
import 'package:flutter_learno/pages/profile.dart';
import 'package:flutter_learno/pages/subjects.dart';
import 'package:flutter_learno/screens/loading.dart';
import 'package:flutter_learno/widgets/progress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String currentUserId;
LearnoUser currentUser;
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final notificationRef = FirebaseFirestore.instance.collection('notification');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final StorageReference storageRef = FirebaseStorage.instance.ref();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int _pageIndex = 0;
  bool _isLoading = false;

  // Local Notification ---------------------------------------------
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  Future<void> initializing() async {
    androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  // ignore: missing_return
  Future onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("");
            },
            child: Text("Okay")),
      ],
    );
  }

  Future<void> notification({String body}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority(1), importance: Importance(5), ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'Learno', '$body', notificationDetails);
  }

  // ------------------------------------------------------------------

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfileData();
  }

  Future<void> getProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final User user = FirebaseAuth.instance.currentUser;
    currentUserId = user.uid;

    DocumentSnapshot doc = await usersRef.doc(user.uid).get();
    currentUser = LearnoUser.fromDocument(doc);
    setState(() {
      _isLoading = false;
    });
    await configurePushNotifications();
    await initializing();
  }

  void signOut(BuildContext context) {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Loading()));
    }).catchError((error) {
      CommonError(
              title: 'Sign out Error!',
              description: 'Something is wrong. Please check your connection.')
          .alertDialog(context);
    });
  }

  Future<void> configurePushNotifications() async {
    if (Platform.isIOS) await getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      usersRef.doc(currentUser.id).update({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == currentUser.id) {
          print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: InkWell(
            onTap: () {
              setState(() {
                _pageIndex = 3;
              });
            },
            child: Text(
              body,
              overflow: TextOverflow.ellipsis,
            ),
          ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
          await notification(body: body);
        }
        print("Notification NOT shown");
      },
    );
  }

  // ignore: missing_return
  Future<void> getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  Widget screen(context) {
    if (_pageIndex == 0) return HomePage();
    if (_pageIndex == 1) return Subjects();
    if (_pageIndex == 2) return Feed(currentUser: currentUser);
    if (_pageIndex == 3) return Notifications();
    if (_pageIndex == 4)
      return Profile(profileId: currentUser?.id, backButton: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(child: _isLoading ? linearProgress() : screen(context)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(
              FeatherIcons.home,
              color: Color(0xff615DFA),
            ),
            title: new Text(
              'Home',
              style: TextStyle(color: Color(0xff615DFA)),
            ),
          ),
          BottomNavigationBarItem(
            icon: new Icon(FeatherIcons.bookOpen, color: Color(0xff615DFA)),
            title: new Text('Subjects',
                style: TextStyle(color: Color(0xff615DFA))),
          ),
          BottomNavigationBarItem(
              icon: Icon(FeatherIcons.layers, color: Color(0xff615DFA)),
              title: Text('Feed', style: TextStyle(color: Color(0xff615DFA)))),
          BottomNavigationBarItem(
              icon: Icon(FeatherIcons.bell, color: Color(0xff615DFA)),
              title: Text('Notifications',
                  style: TextStyle(color: Color(0xff615DFA)))),
          BottomNavigationBarItem(
              icon: Icon(FeatherIcons.user, color: Color(0xff615DFA)),
              title:
                  Text('Profile', style: TextStyle(color: Color(0xff615DFA))))
        ],
      ),
    );
  }
}
