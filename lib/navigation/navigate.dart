import '../screens/home_page.dart';
import '../screens/sign_in_page.dart';
import '../screens/welcome_page.dart';
import '../screens/wifi_page.dart';
import 'package:flutter/material.dart';

class Navigate {
  static Map<String, Widget Function(BuildContext)> routes = {
    '/': (context) => WelcomePage(),
    '/sign-in': (context) => SignInPage(),
    '/home': (context) => HomePage(),
    '/wifi': (context) => WiFiPage()
  };
}
