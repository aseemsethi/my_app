import 'dart:isolate';

import 'package:flutter/cupertino.dart';

enum MQTTAppConnectionState { Disconnected, Connecting, Connected }

class MQTTAppState with ChangeNotifier {
  ValueNotifier<String?> mqttState = ValueNotifier<String>('Init State');
  ValueNotifier<String> mqttMsg = ValueNotifier<String>('No Msg');

  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.Disconnected;
  String _receivedText = '';
  String _historyText = '';
  String wifiGatewayIP = '';

  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = _historyText + '\n' + _receivedText;
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    mqttState.value = state.toString();
    // state.index.toString();
    notifyListeners();
  }

  void setMsg(String msg) {
    mqttMsg.value = msg;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}
