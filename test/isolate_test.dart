import 'dart:isolate';

import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:test/test.dart';
import 'package:flutter/material.dart';

void main() {
  final rPort = ReceivePort();
  
  group('dart_isolates', () {

    test('listItemSearch', () {
      ListItemSearchArg searchArgs = ListItemSearchArg(
        sendPort: rPort.sendPort,
        searchList: ["2345ABCDEF", "2345", "102030"],
        searchItem: "EMEA"
      );
      Isolate.spawn(listItemSearch, searchArgs, onError: rPort.sendPort, onExit: rPort.sendPort);
      rPort.listen((resp) {
        debugPrint("Result: $resp");
        expect(resp, 1);
      });
    });
  });

  tearDown((){
    rPort.close();
  });
}