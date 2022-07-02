import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'navigation/navigate.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'my_app',
    options: FirebaseOptions(
      apiKey: "AIzaSyBSlG5gwt8BNYgTWSoykgYkFK1wnZ3AaOw",
      appId: "1:654349620102:android:2e90a5c7ee477784401207",
      messagingSenderId: "654349620102",
      projectId: "flutterapp-b1ba6",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.title,
      initialRoute: '/',
      routes: Navigate.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
