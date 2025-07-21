import 'package:flutter/material.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:socket_io_client/socket_io_client.dart';

class PrudioNotifier extends ChangeNotifier {
  static final PrudioNotifier _prudioNotifier = PrudioNotifier._internal();
  static PrudioNotifier get prudioNotifier => _prudioNotifier;

  factory PrudioNotifier() {
    return _prudioNotifier;
  }

  Future<void> connect() async {
    await tryAsync("socket connect", () async {
      prudSocket.connect();
      prudSocket.onConnect((d) {
        debugPrint('PrudSocket connect $d');
        prudIOConnectID = d;
        prudSocket.emit('AhlaluYahuah', 'test');
      });
      prudSocket.onError((e) {
        debugPrint('PrudSocket disconnect $e');
        prudSocket.emit('AhlaluYahuah', 'test');
      });
      prudSocket.on('event', (data) => debugPrint(data));
      prudSocket.onDisconnect((e) => debugPrint('PrudSocket disconnect $e'));
      prudSocket.on('fromServer', (e) => debugPrint(e));
    }, error: () {
      debugPrint("Unable To Connect To PrudSocketIO");
    });
  }


  PrudioNotifier._internal();
}

Socket prudSocket = io(
    apiEndPoint,
    OptionBuilder()
      .setAckTimeout(3000)
      .setPath("/prudio")
      .setReconnectionAttempts(3)
      .setReconnectionDelay(2000)
      .setRememberUpgrade(true)
      .setTransports(['websocket']) // for Flutter or Dart VM
      .setAuth({"AppCredential": prudApiKey,})
      .disableAutoConnect() // disable auto-connection
      .setExtraHeaders({"AppCredential": prudApiKey,}) // optional
      .build());

final prudioNotifier = PrudioNotifier();
