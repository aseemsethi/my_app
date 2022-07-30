import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import "../widgets/drawer.dart";

class Choice {
  final String title;
  final IconData icon;
  final String routeName;

  const Choice(
      {required this.title, required this.icon, required this.routeName});
}

const List<Choice> choices = <Choice>[
  Choice(
      title: 'Service Discovery (mDNS)',
      icon: Icons.network_check_rounded,
      routeName: '/nd'),
  Choice(title: 'IOT Info', icon: Icons.router, routeName: '/iot'),
  Choice(
      title: 'Network Discovery', icon: Icons.map, routeName: '/pingDiscover'),
  Choice(title: 'Security Posture', icon: Icons.security, routeName: '/wifi'),
  Choice(
      title: 'Mqtt',
      icon: Icons.nest_cam_wired_stand_outlined,
      routeName: '/mqtt'),
  Choice(title: 'WiFi Info', icon: Icons.network_cell, routeName: '/wifi'),
];

class homeIcons extends StatelessWidget {
  homeIcons({Key? key, required this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Color.fromARGB(255, 178, 219, 238),
        elevation: 6.0,
        child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                choice.routeName,
                arguments: {'title': 'WiFi MQTT'},
              );
            },
            child: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      title: Text(choice.title),
                      //subtitle: Text("Subheading"),
                      trailing: Icon(Icons.details),
                    ),
                    Expanded(child: Icon(choice.icon, size: 50.0)),
                  ]),
            )));
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;
    final double itemWidth = size.width / 2;
    return Scaffold(
        appBar: AppBar(
          elevation: 15,
          // leading: Icon(Icons.account_circle_rounded),
          // leadingWidth: 60, // default is 56
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () async {
                FirebaseService service = FirebaseService();
                await service.signOutFromGoogle();
                Navigator.pushReplacementNamed(
                    context, Constants.signInNavigate);
              },
            )
          ],
          systemOverlayStyle:
              const SystemUiOverlayStyle(statusBarColor: Colors.blue),
          title: Text("${user!.displayName}"),
        ),
        drawer: myDrawer(),
        body: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: (itemWidth / itemHeight),
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 8.0,
            children: List.generate(choices.length, (index) {
              return Center(
                child: homeIcons(choice: choices[index]),
              );
            })));
  }
}
