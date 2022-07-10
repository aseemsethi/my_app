import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../utils/mqttAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:isolate';

class MQTTManager {
  // Private instance of client
  //final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;
  final String _username;
  final String _password;
  SendPort gsendPort;

  // Constructor
  // ignore: sort_constructors_first
  MQTTManager(
      {required String host,
      required String topic,
      required String identifier,
      required String username,
      required String password,
      required SendPort sendPort})
      //required MQTTAppState state})
      : _identifier = identifier,
        _host = host,
        _topic = topic,
        _username = username,
        _password = password,
        gsendPort = sendPort;
  //_currentState = state;

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        //.authenticateAs('draadmin', 'DRAAdmin@123')
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
      //_currentState.setAppConnectionState(MQTTAppConnectionState.Connecting);
      gsendPort.send("connecting");
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
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('MQTT::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('MQTT::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('MQTT::OnDisconnected callback is solicited, this is correct');
    }
    //_currentState.setAppConnectionState(MQTTAppConnectionState.Disconnected);
    gsendPort.send("disconnected");
  }

  /// The successful connect callback
  void onConnected() {
    //_currentState.setAppConnectionState(MQTTAppConnectionState.Connected);
    gsendPort.send("connected");
    print('MQTT::Mosquitto client connected....');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      //_currentState.setReceivedText(pt);
      //_currentState.setMsg(pt);
      print(MQTTAppConnectionState.Connected);
      print('MQTT MSG: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
      gsendPort.send(pt);
      gsendPort.send("connected");
    });
    print(
        'MQTT::OnConnected client callback - Client connection was sucessful');
  }
}
