import '../screens/home_page.dart';
import '../screens/sign_in_page.dart';
import '../screens/welcome_page.dart';
import '../screens/mqtt_page.dart';
import '../screens/iot.dart';
import 'package:flutter/material.dart';

class Navigate {
  static Map<String, Widget Function(BuildContext)> routes = {
    '/': (context) => WelcomePage(),
    '/sign-in': (context) => SignInPage(),
    '/home': (context) => HomePage(),
    '/iot': (context) => IoTPage(),
    '/mqtt': (context) => MqttPage()
  };
}
