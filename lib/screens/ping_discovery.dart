import 'package:flutter/material.dart';
import 'package:my_app/navigation/navigate.dart';
import 'dart:async';

import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:provider/provider.dart';

import '../utils/mqttAppState.dart';

class PingDiscover extends StatefulWidget {
  const PingDiscover({Key? key}) : super(key: key);

  @override
  State<PingDiscover> createState() => _PingDiscoverState();
}

class _PingDiscoverState extends State<PingDiscover> {
  bool _scanning = false;
  final devices = <String>[];
  TextEditingController scanAddress = TextEditingController(text: '192.168.68');
  late MQTTAppState currentAppState;

  @override
  void initState() {
    super.initState();
    _scanning = false;
  }

  Future<void> startDiscovery(String ip) async {
    if (_scanning) return;
    print('PD: Start Discovery');

    setState(() {
      devices.clear();
      _scanning = true;
    });
    pingScan(ip);
  }

  void pingScan(String ip) async {
    // NetworkAnalyzer.discover pings PORT:IP one by one according to timeout.
    // NetworkAnalyzer.discover2 pings all PORT:IP addresses at once.
    const port = 80;
    final stream = NetworkAnalyzer.discover2(
      ip,
      port,
      timeout: const Duration(milliseconds: 5000),
    );
    print('PD: Starting pingScan on Submet IP: $ip');

    int found = 0;
    stream.listen((NetworkAddress addr) {
      // print('${addr.ip}:$port');
      if (addr.exists) {
        String device = addr.ip + ":" + port.toString();
        //print('Found dev: $device');
        found++;
        print('PD: Found device: ${addr.ip}:$port');
        setState(() {
          devices.add(device);
        });
      }
    }).onDone(() {
      setState(() {
        _scanning = false;
      });
      print('Finish. Found $found device(s)');
    });
  }

  @override
  Widget build(BuildContext context) {
    currentAppState =
        context.watch<MQTTAppState>(); // rebuild when mqttState changes
    String result = currentAppState.wifiGatewayIP
        .substring(0, currentAppState.wifiGatewayIP.lastIndexOf('.'));
    scanAddress.text = result;

    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Device Discovery'),
            ),
            body: Column(children: <Widget>[
              //ListView(children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Devices IP:Port',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 24),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: scanAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Subnet IP',
                  ),
                ),
              ),
              Container(
                  height: 100,
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  startDiscovery(scanAddress.text);
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      Colors.greenAccent, // Background color
                                ),
                                child: const Text(
                                  "Start",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20),
                                ))),
                        //const Spacer(flex: 1),
                        SizedBox(width: 10),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orangeAccent, // Background color
                          ),
                          child: const Text(
                            "Stop",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 20),
                          ),
                        )),
                        SizedBox(width: 10),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orangeAccent, // Background color
                          ),
                          child: const Text(
                            "Back",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 20),
                          ),
                        )),
                      ])),
              Container(
                padding: const EdgeInsets.all(10),
                height: 80.0 * 4,
                child: _buildMainWidget(context),
              ),
              //])
            ])));
  }

  Widget _buildMainWidget(BuildContext context) {
    if (_scanning) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (devices.length == 0) {
      print('PD: Empty device list');
      return Text("No devices found");
    } else {
      return ListView.builder(
        itemCount: devices.length,
        //itemCount: 6,
        itemBuilder: (context, i) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text("Srv".toString()),
            ),
            title: Text(devices[i]),
            subtitle: Text("Server"),
            trailing: const Icon(Icons.computer_outlined),
            onTap: () {
              print("Tapped ${devices[i]}");
            },
          );
        },
      );
    }
  }
}
