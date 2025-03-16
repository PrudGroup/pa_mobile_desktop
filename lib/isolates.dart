import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/singletons/backblaze_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

@pragma('vm:entry-point')
uploadVideoService(UploadVideoServiceArg uvSerArg) async {
  bool uploaded = false;
  int tryCount = 0;
  UploadPartResponse? uploadPartResponse;
  while (uploaded == false && tryCount < 6) {
    tryCount += 1;
    UploadUrlForLargeFile? uploadUrl = await backblazeNotifier.getUrlToUploadLargeFile(uvSerArg.fileId, uvSerArg.cred);
    if (uploadUrl != null) {
      uploadPartResponse = await backblazeNotifier.uploadPartOfLargeFile(uploadUrl, uvSerArg.part, uvSerArg.partVideo, uvSerArg.cred, uvSerArg.sha1);
      if (uploadPartResponse != null && uploadPartResponse.contentLength > 0) {
        uploaded = true;
        debugPrint('Video Part ${uvSerArg.part} uploaded successfully: ${uploadPartResponse.toJson()}');
      }
    }
  }
  uvSerArg.sendPort.send(uploadPartResponse?.toJson());
}

@pragma('vm:entry-point')
Future<void> uploadVideoStream(UploadVideoStreamArg uvsArg) async {
  int countPart = 0; 
  final receivePort = ReceivePort();
  await uvsArg.stream.forEach((Uint8List part) async {
    countPart += 1;
    UploadVideoServiceArg arg = UploadVideoServiceArg(
      fileId: uvsArg.createdFile.fileId,
      part: countPart,
      partVideo: part,
      sendPort: receivePort.sendPort,
      cred: uvsArg.cred,
      sha1: uvsArg.sha1,
    );
    await FlutterIsolate.spawn(uploadVideoService, arg);
  });
  receivePort.listen((response) {
    uvsArg.sendPort.send(response);
  }, onError: (err){
    debugPrint('Error in uploadVideoStream: $err');
  });
}

@pragma('vm:entry-point')
getRandom(({int length, SendPort port}) data){
  String chars = "0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz";
  chars = tabData.shuffle(chars);
  String result = ""; final random = Random();
  for(int i=1; i<=data.length; i++){
    result+=chars[random.nextInt(chars.length)];
  }
  data.port.send(result);
}



@pragma('vm:entry-point')
Future<void> computeStream(({int length, SendPort port}) arg) async {
  final receivePort = ReceivePort();
  for(var i=1; i <= arg.length; i++){
    await Isolate.spawn(getRandom, (length: 50, port: receivePort.sendPort));
  }
  receivePort.listen((response) {
    arg.port.send(response);
  }, onError: (err){
    debugPrint('Error in computeStream: $err');
  });
}