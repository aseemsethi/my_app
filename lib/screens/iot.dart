import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/mqttAppState.dart';

// class IoTPage extends StatefulWidget {
//   IoTPage({Key? key}) : super(key: key);

//   @override
//   _IoTPageState createState() => _IoTPageState();
// }

class Device {
  final String title;
  final IconData icon;

  const Device({required this.title, required this.icon});
}

const List<Device> devices = <Device>[
  Device(title: 'Main Door', icon: Icons.door_front_door),
  Device(title: 'Back Door', icon: Icons.door_back_door),
  Device(title: 'Side Door', icon: Icons.door_sliding),
  Device(title: 'Temperature', icon: Icons.thermostat),
];

class deviceIcons extends StatelessWidget {
  deviceIcons({Key? key, required this.choice}) : super(key: key);
  final Device choice;
  @override
  Widget build(BuildContext context) {
    return Card(
        color: Color.fromARGB(255, 178, 219, 238),
        elevation: 6.0,
        child: InkWell(
            onTap: () {},
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

class IoTPage extends StatelessWidget {
  String msg = "Init";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var mqtt = context.watch<MQTTAppState>(); // rebuild when mqttState changes

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;
    final double itemWidth = size.width / 3;
    return Scaffold(
      appBar: AppBar(
        title: Text("IoT Devices"),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Text(mqtt.mqttMsg.value),
        color: Colors.amber,
      ),
      body: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: (itemWidth / itemHeight),
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 12.0,
          children: List.generate(devices.length, (index) {
            return Center(
              child: deviceIcons(choice: devices[index]),
            );
          })),
    );
  }
}
