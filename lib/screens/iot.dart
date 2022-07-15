import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/db_helper.dart';
import '../utils/db_helper.dart';
import '../utils/mqttAppState.dart';
import "../utils/constants.dart";

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
  Device(title: 'Temp', icon: Icons.thermostat_auto_outlined),
];

class deviceIcons extends StatelessWidget {
  deviceIcons({Key? key, required this.choice, required this.temperature})
      : super(key: key);
  final Device choice;
  final String temperature;

  @override
  Widget build(BuildContext context) {
    List tempMap = temperature.multiSplit([': ', ", ", '{', '}']);
    //tempMap.forEach((element) => {print('IOT: $element')});
    //print("IOT: ${choice.title}");

    return Card(
        color: Color.fromARGB(194, 251, 249, 154),
        elevation: 10.0,
        child: InkWell(
            onTap: () {},
            child: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      title: Text(choice.title,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14)),
                      subtitle: choice.title == 'Temp'
                          ? Text("${tempMap[2]}, ${tempMap[6]}, ${tempMap[10]}",
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12))
                          : const Text("True"),
                      trailing: const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                    ),
                    choice.title == 'Temp'
                        ? Expanded(
                            child: Icon(
                            choice.icon,
                            size: 70.0,
                            color: Colors.green,
                          ))
                        : Expanded(
                            child: Icon(
                            choice.icon,
                            size: 70.0,
                            color: Colors.black,
                          )),
                  ]),
            )));
  }
}

class IoTPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IoTPageState();
  }
}

class _IoTPageState extends State<IoTPage> {
  String msg = "Init";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var mqtt = context.watch<MQTTAppState>(); // rebuild when mqttState changes
    DatabaseHelper? dbHelper;
    dbHelper = context.watch<DatabaseHelper>(); // rebuild when dbHelper changes
    print('iot: build..');

    Future<Map<String, dynamic>> getTemp() {
      print('IOT UI: getTemp');
      //return Future.delayed(Duration(seconds: 2), () {
      return dbHelper!.queryTemp();
      //});
    }

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 3;
    final double itemWidth = size.width / 3;
    //return FutureBuilder(builder: builder) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IoT Devices"),
      ),
      // Never gets updated. Only updates when MQTT screen is active.
      // bottomNavigationBar: BottomAppBar(
      //   child: Text(mqtt.mqttMsg.value),
      //   color: Colors.amber,
      // ),
      body: FutureBuilder(
        builder: (ctx, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print('IOT UI: conn state done');
            if (snapshot.data != null) {
              print('IOT UI: has data');
              //Map<String, String> myMap = Map.from(snapshot.data!['log']);
              print('IOT UI: Got update - ${snapshot.data}');
              return Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  margin: EdgeInsets.all(5.0),
                  child: Column(children: <Widget>[
                    Expanded(
                        child: GridView.count(
                            crossAxisCount: 3,
                            childAspectRatio: (itemWidth / itemHeight),
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 8.0,
                            children: List.generate(devices.length, (index) {
                              return Center(
                                child: deviceIcons(
                                    choice: devices[index],
                                    temperature: snapshot.data!['log']),
                              );
                            }))),
                    Text('${snapshot.data!['log']}'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          //getTemp();
                        });
                      },
                      child: const Text("Refresh"),
                    )
                  ]));
            } else {
              return const CircularProgressIndicator();
            }
          }
          return const CircularProgressIndicator();
        },
        future: getTemp(),
      ),
    );
  }
}
