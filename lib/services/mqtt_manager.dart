import 'dart:convert';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/mqttAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:isolate';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import '../utils/db_helper.dart';
import 'package:intl/intl.dart';

class MQTTManager {
  // Private instance of client
  //final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String? _identifier;
  final String? _host;
  final String? _topic;
  final String? _username;
  final String? _password;
  SendPort? gsendPort;
  DatabaseHelper? dbHelper;

  // Constructor
  // ignore: sort_constructors_first
  MQTTManager(
      {required String? host,
      required String? topic,
      required String? identifier,
      required String? username,
      required String? password,
      required SendPort? sendPort})
      //required MQTTAppState state})
      : _identifier = identifier,
        _host = host,
        _topic = topic,
        _username = username,
        _password = password,
        gsendPort = sendPort;

  saveState(String state) async {
    dbHelper = DatabaseHelper.instance;
    dbHelper!.updateState(state);
  }

  void initializeMQTTClient() {
    _client = MqttServerClient(_host!, _identifier!);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    WidgetsFlutterBinding.ensureInitialized();
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier!)
        .authenticateAs(_username, _password)
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('MQTT::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  // ignore: avoid_void_async
  void connect() async {
    assert(_client != null);
    try {
      print('MQTT::Mosquitto start client connecting....');
      //gsendPort.send("connecting");
      await _client!.connect();
    } on Exception catch (e) {
      print('MQTT::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic!, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('MQTT::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    var formatter = DateFormat.MMMd().add_jm();
    var now = DateTime.now();
    String formattedDate = formatter.format(now);
    FlutterForegroundTask.updateService(
        notificationTitle: 'MQTT Disconnected',
        notificationText: formattedDate);
    print('MQTT::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('MQTT::OnDisconnected callback is solicited');
      saveState("Disconnected");
    }

    //gsendPort.send("disconnected");
    waitAndConnect();
  }

  waitAndConnect() async {
    await Future.delayed(const Duration(seconds: 4), () {
      print('MQTT::OnDisconnected not solicited......retry connect.....');
      connect();
    });
  }

  /// The successful connect callback
  void onConnected() {
    var formatter = DateFormat.MMMd().add_jm();
    var now = DateTime.now();
    String formattedDate = formatter.format(now);
    saveState("Connected");

    FlutterForegroundTask.updateService(
        notificationTitle: 'MQTT Connected', notificationText: formattedDate);
    gsendPort?.send("MQTT Connected");
    print('MQTT::Mosquitto client connected....');
    _client!.subscribe(_topic!, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(MQTTAppConnectionState.Connected);
      print('MQTT MSG: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');

      //gsendPort.send(pt);
      gsendPort?.send("connected");
      dbHelper = DatabaseHelper.instance;
      if (c[0].topic.contains('alarm')) {
        now = DateTime.now();
        formattedDate = formatter.format(now);
        //gsendPort.send('Alarm:$pt : $formattedDate');
        FlutterForegroundTask.updateService(
            notificationTitle: 'MQTT Service: Alarm',
            notificationText: '$pt : $formattedDate');
      } else {
        _insertRaw(pt);
        //_query();
      }
    });
    print(
        'MQTT::OnConnected client callback - Client connection was sucessful');
  }

// Alarm - topic: <gurupada/100/alarm> pt = MainDoor:Open
// topic is <gurupada/100/door>,
// pt = {"gwid":"78e36d642ff0","type":"esp32", "ip":"192.168.68.127", "time":"15:09:28-12/07"}
// pt = {"data":"T:25.70:H:80.00","gwid":"78e36d642ff0","name":"DG Room",
//       "sensorid":"54985c","time":"15:09:29-12/07","type":"temperature"}
// pt =  {"data":"Open","gwid":"78e36d642ff0","name":"MainDoor","sensorid":"4ffe1a",
//      "time":"12:47:01-17/07","type":"door"}
// 3 "types" - door, esp32, temperture
  void _insertRaw(String log) async {
    Map<String, dynamic> log1 = jsonDecode(log);
    if (log1['type'] == "esp32") {
      dbHelper!.updateGw(log1['gwid'], log1);
    } else if (log1['type'] == "door") {
      dbHelper!.updateDoors(log1['sensorid'], log1);
    } else {
      dbHelper!.updateTemp(log1['sensorid'], log1);
      //id = await dbHelper!.insertRaw(log1['type'], log1);
    }
    print("DB _insertRaw: ${log1['type']} => $log1");
  }

  void _query() async {
    final count = await dbHelper!.queryRowCount();
    final allRows = await dbHelper!.queryAllRows();
    print('DB query all rows: $count');
    allRows.forEach(print);
  }
}
