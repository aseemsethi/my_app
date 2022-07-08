import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../services/mqtt_manager.dart';
import '../utils/mqttAppState.dart';
//import 'package:provider/provider.dart';

class MqttPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MqttPageState();
  }
}

class _MqttPageState extends State<MqttPage> {
  late MQTTAppState currentAppState = MQTTAppState();
  late MQTTManager manager;
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // currentAppState = appState;
    print("MqttPage build...");
    return AnimatedBuilder(
      animation: Listenable.merge(
          [currentAppState.mqttState, currentAppState.mqttMsg]),
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text("MQTT"),
          ),
          body: ListView(
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'MQTT Service',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 30),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Server User Name',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Server Password',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  controller: topicController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Subscription Topic',
                  ),
                ),
              ),
              Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: ElevatedButton(
                    child: const Text('Start MQTT'),
                    onPressed: () {
                      print(nameController.text);
                      print(passwordController.text);
                      print(topicController.text);
                      FocusManager.instance.primaryFocus?.unfocus();
                      _configureAndConnect(nameController.text,
                          passwordController.text, topicController.text);
                    },
                  )),
              Row(
                children: <Widget>[
                  const Text('Start MQTT Foreground Service '),
                  TextButton(
                      child: const Text(
                        'Stop',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {}),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          ),
          // Column(
          //   children: <Widget>[
          //     Text(currentAppState.mqttState.value.toString()),
          //     Text(currentAppState.mqttMsg.value.toString()),
          //   ],
          // ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: _configureAndConnect,
          //   tooltip: 'Play',
          //   child: Icon(Icons.play_arrow),
          // ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }

  void _configureAndConnect(String user, String passwd, String topic) {
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    manager = MQTTManager(
        host: '52.66.70.168',
        topic: topic, // 'gurupada/100/#',
        identifier: osPrefix,
        username: user,
        password: passwd,
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }
}
