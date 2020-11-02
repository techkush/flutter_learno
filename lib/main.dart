import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_learno/screens/loading.dart';

// ignore: non_constant_identifier_names
bool USE_FIRESTORE_EMULATOR = false;

Future<void> main() async {

  // 🔥 I have to fix the data connection settings. 🔥
  // ⚠ warning ⚡ high voltage 🚨 police siren

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (USE_FIRESTORE_EMULATOR) {
    FirebaseFirestore.instance.settings = Settings(
        host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  }

  print("The statement 'this machine is connected to the Internet' is: ");
  print(await DataConnectionChecker().hasConnection);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Loading(),
    );
  }
}

