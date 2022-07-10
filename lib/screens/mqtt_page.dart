import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../services/mqtt_manager.dart';
import '../utils/mqttAppState.dart';
//import 'package:provider/provider.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:isolate';

class MqttPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MqttPageState();
  }
}

class _MqttPageState extends State<MqttPage> {
  late MQTTAppState currentAppState = MQTTAppState();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  ReceivePort? _receivePort;

  @override
  Widget build(BuildContext context) {
    // final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // currentAppState = appState;
    print("MqttPage build...");
    return AnimatedBuilder(
      animation: Listenable.merge(
          [currentAppState.mqttState, currentAppState.mqttMsg]),
      builder: (BuildContext context, _) {
        return WithForegroundTask(
            child: Scaffold(
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
                                  _startForegroundTask();
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
                            _stopForegroundTask();
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
                  Text('Logs',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 20)),
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
        ));
      },
    );
  }

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription: 'MQTT forground service.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    print("_startForegroundTask called");
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(
        key: 'topic', value: topicController.text);
    await FlutterForegroundTask.saveData(
        key: 'username', value: nameController.text);
    await FlutterForegroundTask.saveData(
        key: 'pwd', value: passwordController.text);

    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
      print('Restarting foreground service');
    } else {
      print('Starting foreground service');
      receivePort = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    print("Register receivePort");
    _closeReceivePort();

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is int) {
          print('eventCount: $message');
        } else if (message is String) {
          if (message == 'onNotificationPressed') {
            Navigator.of(context).pushNamed('/resume-route');
          } else if ((message == 'connected') ||
              (message == 'connecting') ||
              (message == 'disconnected')) {
            currentAppState.mqttState.value = message.toString();
          } else {
            currentAppState.mqttMsg.value = message.toString();
          }
          print('Msg recvd from MQTT: ${message.toString()}');
        } else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        }
      });

      return true;
    }

    return false;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }
}

// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;
  late MQTTManager manager;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    print('MyTaskHandler:OnStart: called: sendPort: ${sendPort?.hashCode}');

    // You can use the getData function to get the stored data.
    final topic = await FlutterForegroundTask.getData<String>(key: 'topic');
    final username =
        await FlutterForegroundTask.getData<String>(key: 'username');
    final pwd = await FlutterForegroundTask.getData<String>(key: 'pwd');
    print('topic: $topic, username: $username, pwd: $pwd');
    _configureAndConnect(username!, pwd!, topic!, sendPort!);
    //nameController.text, passwordController.text, topicController.text);
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
        notificationTitle: 'MyTaskHandler',
        notificationText: 'eventCount: $_eventCount');

    // Send data to the main isolate.
    print('SendPort..sending event data: sendPort: ${sendPort.hashCode}');
    sendPort?.send(_eventCount);
    manager.gsendPort = sendPort!;

    _eventCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('onTaskHandler: onDestroy');
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }

  void _configureAndConnect(
      String user, String passwd, String topic, SendPort sendPort) {
    print('Configure and Connect...');
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
        sendPort: sendPort);
    //state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }
}
