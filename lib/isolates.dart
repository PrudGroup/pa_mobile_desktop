import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/singletons/backblaze_notifier.dart';

@pragma('vm:entry-point')
void uploadVideoService(UploadVideoServiceArg uvSerArg) async {
  bool uploaded = false;
  int tryCount = 0;
  UploadPartResponse? uploadPartResponse;
  while (uploaded == false && tryCount < 6) {
    tryCount += 1;
    UploadUrlForLargeFile? uploadUrl = await backblazeNotifier.getUrlToUploadLargeFile(uvSerArg.fileId);
    if (uploadUrl != null) {
      uploadPartResponse = await backblazeNotifier.uploadPartOfLargeFile(uploadUrl, uvSerArg.part, uvSerArg.partVideo);
      if (uploadPartResponse != null && uploadPartResponse.contentLength > 0) {
        uploaded = true;
        debugPrint('Video Part ${uvSerArg.part} uploaded successfully: ${uploadPartResponse.toJson()}');
      }
    }
  }
  uvSerArg.sendPort.send(uploadPartResponse?.toJson());
}

@pragma('vm:entry-point')
void uploadVideoStream(UploadVideoStreamArg uvsArg) async {
  int countPart = 0; 
  final receivePort = ReceivePort();
  await uvsArg.stream.forEach((Uint8List part){
    countPart += 1;
    UploadVideoServiceArg arg = UploadVideoServiceArg(
      fileId: uvsArg.createdFile.fileId,
      part: countPart,
      partVideo: part,
      sendPort: receivePort.sendPort,
    );
    FlutterIsolate.spawn(uploadVideoService, arg);
  });
  receivePort.listen((response) {
    uvsArg.sendPort.send(response);
  });
}