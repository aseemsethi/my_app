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
                        fontSize: 24),
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    //'Status: ' + currentAppState.mqttState.value.toString(),
                    'Status: ' +
                        currentAppState.mqttState.value
                            .toString()
                            .split('.')
                            .last,
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
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
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                  height: 100,
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  _configureAndConnect(
                                      nameController.text,
                                      passwordController.text,
                                      topicController.text);
                                },
                                child: Text(
                                  "Start",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20),
                                ))),
                        const Spacer(flex: 1),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            manager.disconnect();
                          },
                          child: Text(
                            "Stop",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 20),
                          ),
                        )),
                      ])),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Logs'),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                child: Text(
                  currentAppState.mqttMsg.value.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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
