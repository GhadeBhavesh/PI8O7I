import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:widget_app/pages/Home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCU_M32ciniLVsotqGaQxUX6593V1sL2DA",
        appId: "1:77417343007:android:e85ad5b9e1c35893e60d2a",
        messagingSenderId: "77417343007",
        projectId: "care-59e97",
        databaseURL: "https://care-59e97-default-rtdb.firebaseio.com",
      ),
    );
  } catch (e) {
    if (Firebase.apps.isNotEmpty) {
      Firebase.app();
    } else {
      rethrow;
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assignment App',
      home: const HomePage(),
    );
  }
}
