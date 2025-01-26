
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:socket_io_client/socket_io_client.dart';

class PrudioNotifier extends ChangeNotifier {
  static final PrudioNotifier _prudioNotifier = PrudioNotifier._internal();
  static get prudioNotifier => _prudioNotifier;

  factory PrudioNotifier(){
    return _prudioNotifier;
  }

  Future<void> connect() async {
    await tryAsync("socket connect", () async {
      prudSocket.connect();
    }, error: (){
      debugPrint("Unable To Connect To PrudSocketIO");
    });
  }



  PrudioNotifier._internal();
}

Socket prudSocket = io("$prudApiUrl/prudio",
    OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .disableAutoConnect()  // disable auto-connection
        .setExtraHeaders({"AppCredential": prudApiKey,}) // optional
        .build()
);
final prudioNotifier = PrudioNotifier();

