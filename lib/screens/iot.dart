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
  Device(title: 'Main Door', icon: Icons.door_front_door_outlined),
  Device(title: 'Back Door', icon: Icons.door_back_door_outlined),
  Device(title: 'Side Door', icon: Icons.door_sliding_outlined),
  Device(title: 'Temperature', icon: Icons.thermostat_auto_outlined),
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
                      title: Text(choice.title,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                      subtitle: Text("Status",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 10)),
                      trailing: Icon(Icons.open_in_full_outlined),
                    ),
                    Expanded(child: Icon(choice.icon, size: 70.0)),
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
