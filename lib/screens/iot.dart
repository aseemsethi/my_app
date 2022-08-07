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
  Device(title: 'Doors', icon: Icons.door_front_door_outlined),
  Device(title: 'Windows', icon: Icons.door_front_door_outlined),
  Device(title: 'Temp', icon: Icons.thermostat_auto_outlined),
  Device(title: 'Gateways', icon: Icons.router_outlined),
];

class deviceIcons extends StatelessWidget {
  deviceIcons({
    Key? key,
    required this.choice,
    required this.data,
  }) : super(key: key);
  final Device choice;
  final List<Map<String, dynamic>>? data;
  String gwOutput = "";
  String doorOutput = "";
  String tempOutput = "";
  int doorIndex = 1;
  int gwIndex = 1;
  int tempIndex = 1;

//  Temperature line - Same for Door too.
// Index [0]
// data
// Index [2] T:25.20:H:91.00 - Open/Close
//  gwid
//  78e36d642ff0
//  name
//  Index [6] DG Room - MainDoor
//  sensorid
//  54985c
//  time
//  [10] 14:18:32-17/07
//  type
//  temperature

// Alarm - topic: <gurupada/100/alarm> pt = MainDoor:Open
// topic is <gurupada/100/door>,
// pt = {"gwid":"78e36d642ff0","type":"esp32", "ip":"192.168.68.127", "time":"15:09:28-12/07"}
// pt = {"data":"T:25.70:H:80.00","gwid":"78e36d642ff0","name":"DG Room",
//       "sensorid":"54985c","time":"15:09:29-12/07","type":"temperature"}
// pt =  {"data":"Open","gwid":"78e36d642ff0","name":"MainDoor","sensorid":"4ffe1a",
//      "time":"12:47:01-17/07","type":"door"}
// 3 "types" - door, esp32, temperture
  @override
  Widget build(BuildContext context) {
    //List doorMap = door.multiSplit([': ', ", ", '{', '}']);
    //print("IOT: ${choice.title}");
    print("Build.................................................");
    for (var i = 0; i < data!.length; i++) {
      //print('Build...${data![i]['log']}');
      String tmp1 = data![i]['log'];
      List tmp2 = tmp1.multiSplit([': ', ", ", '{', '}']);
      print('Build...$tmp2..${tmp2.length}');
      if ((tmp2.length >= 10) && (tmp2[4] == 'esp32')) {
        gwOutput =
            "${gwOutput + gwIndex.toString() + ": " + tmp2[2] + "\n" + tmp2[6] + "\n" + tmp2[8]}\n";
        gwIndex++;
      } else if ((tmp2.length >= 12) && (tmp2[12] == 'door')) {
        doorOutput =
            "${doorOutput + doorIndex.toString() + ": " + tmp2[6] + "\n" + tmp2[2] + "\n" + tmp2[8] + "\nat " + tmp2[10]}\n";
        doorIndex++;
      } else if ((tmp2.length >= 14) && (tmp2[12] == 'temperature')) {
        tempOutput =
            "${tempOutput + tempIndex.toString() + ": " + tmp2[2] + "\n" + tmp2[6] + "\n" + tmp2[10]}\n";
        tempIndex++;
      }
    }

    return Card(
        color: const Color.fromARGB(194, 251, 249, 154),
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
                                fontSize: 12)),
                        subtitle: choice.title == 'Temp'
                            ? Text(tempOutput,
                                style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10))
                            : choice.title == 'Doors'
                                ? Text(doorOutput,
                                    style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10))
                                : choice.title == 'Gateways'
                                    ? Text(gwOutput,
                                        style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10))
                                    : const Text("TBD",
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10)),
                        trailing:
                            choice.title == 'Temp' || choice.title == 'Gateways'
                                ? null
                                // ? const Icon(
                                //     Icons.check,
                                //     color: Colors.green,
                                //     size: 20.0,
                                //   )
                                : ((choice.title.contains('Doors')) &&
                                        (doorOutput.contains('Open')))
                                    ? const Icon(
                                        Icons.lock_open_rounded,
                                        color: Colors.green,
                                        size: 40.0,
                                      )
                                    : const Icon(
                                        Icons.lock_outline_rounded,
                                        color: Colors.green,
                                        size: 40.0,
                                      )),
                    if (choice.title == 'Temp')
                      Expanded(
                          child: Icon(
                        choice.icon,
                        size: 70.0,
                        color: Colors.green,
                      ))
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

    Future<List<Map<String, dynamic>>> getTelemetry() async {
      //Future<List<Map<String, dynamic>>> tempList;
      print('IOT UI: getTelemetry');
      // tempList = dbHelper!.queryTemp();
      // List<Map<String, dynamic>> tempList1 = await tempList;

      Future<List<Map<String, dynamic>>> dbList = dbHelper!.getGwList();
      List<Map<String, dynamic>> dbList1 = await dbList;

      Future<List<Map<String, dynamic>>> doorList = dbHelper.getDoorList();
      List<Map<String, dynamic>> doorList1 = await doorList;

      Future<List<Map<String, dynamic>>> tempList = dbHelper.getTempList();
      List<Map<String, dynamic>> tempList1 = await tempList;

      // List<Map<String, dynamic>> newList = List.from(tempList1)
      //   ..addAll(dbList1);
      var newList = [...tempList1, ...dbList1, ...doorList1];

      print('getTelemetry: : $newList');
      return newList;
    }

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 5;
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
        builder: (ctx, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print('IOT UI: conn state done');
            if (snapshot.data != null) {
              print('IOT UI: has data');
              //Map<String, String> myMap = Map.from(snapshot.data!['log']);
              print('IOT UI: Got update - ${snapshot.data}');
              return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  margin: const EdgeInsets.all(5.0),
                  child: Column(children: <Widget>[
                    Expanded(
                        child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: (itemWidth / itemHeight),
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 8.0,
                            children: List.generate(devices.length, (index) {
                              return Center(
                                child: deviceIcons(
                                  choice: devices[index],
                                  data: snapshot.data,
                                ),
                              );
                            }))),
                    //Text('${snapshot.data![0]['log']}'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          //getTelemetry();
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
        future: getTelemetry(),
      ),
    );
  }
}
