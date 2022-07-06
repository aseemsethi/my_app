import 'package:flutter/material.dart';

class myDrawer extends StatelessWidget {
  myDrawer();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                    image: AssetImage("assets/images/main-img.png"),
                    fit: BoxFit.cover)),
            child: Text('Categories', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.pop(context); //closes the drawer
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
