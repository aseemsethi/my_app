import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/welcome_page.dart';
import 'package:my_app/screens/mqtt_page.dart';
import 'navigation/navigate.dart';
import 'utils/constants.dart';
import '../utils/mqttAppState.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:isolate';
import 'package:provider/provider.dart';

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
  // runApp(MyApp());
  runApp(
    ChangeNotifierProvider(
      create: (context) => MQTTAppState(),
      child: MyApp(),
    ),
  );
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
