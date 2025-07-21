import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/user.dart';
import 'package:prudapp/services/search_history.dart';
import 'package:prudapp/singletons/backblaze_notifier.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

@pragma('vm:entry-point')
Future<void> uploadVideoService(UploadVideoServiceArg uvSerArg) async {
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
void getRandom(({int length, SendPort port}) data){
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


@pragma('vm:entry-point')
Future<void> getRelatedVideoService(VideoSearchServiceArg vssArg) async {
  bool foundSome = false;
  int tryCount = 0;
  List<ChannelVideo>? foundVideos;
  while (foundSome == false && tryCount < 6) {
    tryCount += 1;
    foundVideos = await prudStudioNotifier.getSuggestedVideos(criteria: vssArg, cred: vssArg.cred);
    if (foundVideos != null && foundVideos.isNotEmpty) {
      foundSome = true;
    }
  }
  if(foundVideos != null && foundVideos.isNotEmpty){
    vssArg.sendPort.send(foundVideos.map((vid) => vid.toJson()).toList());
  }else{
    vssArg.sendPort.send(null);
  }
}


@pragma('vm:entry-point')
Future<void> getRelatedBroadcastService(BroadcastSearchServiceArg bssArg) async {
  bool foundSome = false;
  int tryCount = 0;
  List<ChannelBroadcast>? foundCasts;
  while (foundSome == false && tryCount < 6) {
    tryCount += 1;
    foundCasts = await prudStudioNotifier.getSuggestedBroadcasts(criteria: bssArg.broadcastSearchText, cred: bssArg.cred);
    if (foundCasts != null && foundCasts.isNotEmpty) {
      foundSome = true;
    }
  }
  if(foundCasts != null && foundCasts.isNotEmpty){
    bssArg.sendPort.send(foundCasts.map((bc) => bc.toJson()).toList());
  }else{
    bssArg.sendPort.send(null);
  }
}

@pragma('vm:entry-point')
Future<void> incrementBroadcastImpressionService(ServiceArg sArg) async {
  bool done = false;
  int tryCount = 0;
  while (done == false && tryCount < 6) {
    tryCount += 1;
    done = await prudStudioNotifier.incrementBroadcastImpression(
      castId: sArg.itemId,
      cred: sArg.cred,
    );
  }
  sArg.sendPort.send(done);
}

@pragma('vm:entry-point')
Future<void> incrementVideoImpressionService(ServiceArg sArg) async {
  bool done = false;
  int tryCount = 0;
  while (done == false && tryCount < 6) {
    tryCount += 1;
    done = await prudStudioNotifier.incrementVideoImpression(
      vidId: sArg.itemId,
      cred: sArg.cred,
    );
  }
  sArg.sendPort.send(done);
}

@pragma('vm:entry-point')
Future<void> incrementVideoDownloadService(ServiceArg sArg) async {
  bool done = false;
  int tryCount = 0;
  while (done == false && tryCount < 6) {
    tryCount += 1;
    done = await prudStudioNotifier.incrementVideoDownloads(
      vidId: sArg.itemId,
      cred: sArg.cred,
    );
  }
  sArg.sendPort.send(done);
}

@pragma('vm:entry-point')
Future<void> incrementVideoWatchMiniutesService(MinuteServiceArg sArg) async {
  bool done = false;
  int tryCount = 0;
  while (done == false && tryCount < 6) {
    tryCount += 1;
    done = await prudStudioNotifier.incrementVideoWatchMinutes(
      vidId: sArg.itemId,
      cred: sArg.cred,
      minutes: sArg.minutes
    );
  }
  sArg.sendPort.send(done);
}


@pragma('vm:entry-point')
Future<void> getVideoAndBroadcastSuggestions(VideoSuggestionServiceArg vssArg) async {
  final receivePort = ReceivePort();
  await FlutterIsolate.spawn(getRelatedVideoService, VideoSearchServiceArg(
    cred: vssArg.cred,
    sendPort: receivePort.sendPort,
    searchType: vssArg.videoCateria.searchType,
    audience: vssArg.videoCateria.audience,
    category: vssArg.videoCateria.category,
    country: vssArg.videoCateria.country,
    searchText: vssArg.videoCateria.searchText,
    limit: vssArg.videoCateria.limit,
    offset: vssArg.videoCateria.offset
  ));
  if(!vssArg.onlyVideos){
    await FlutterIsolate.spawn(getRelatedVideoService, VideoSearchServiceArg(
      cred: vssArg.cred,
      sendPort: receivePort.sendPort,
      searchType: vssArg.promotedType,
      country: vssArg.videoCateria.country,
      limit: vssArg.videoCateria.limit,
      offset: vssArg.videoCateria.offset
    ));
    
    await FlutterIsolate.spawn(getRelatedBroadcastService, BroadcastSearchServiceArg(
      broadcastSearchText: vssArg.broadcastSearchText,
      cred: vssArg.cred,
      sendPort: receivePort.sendPort,
    ));
  }
  List<dynamic> result = [];
  int responseCount = 0;
  receivePort.listen((response) {
    responseCount++;
    if(response != null && response is List && response.isNotEmpty){
      result.addAll(response);
    }
    if(responseCount >= 3) {
      List<dynamic> distincted = result.toSet().toList();
      distincted.shuffle();
      for(String item in vssArg.unwantedChannels){
        int index = distincted.indexWhere((itm) => itm["channelId"] == item);
        if(index != -1){
          distincted.removeAt(index);
        }
      }
      for(String item in vssArg.unwantedVideos){
        int index = distincted.indexWhere((itm) => itm["id"] == item && itm["message"] == null);
        if(index != -1){
          distincted.removeAt(index);
        }
      }
      for(String item in vssArg.unwantedBroadcasts){
        int index = distincted.indexWhere((itm) => itm["id"] == item && itm["message"] != null);
        if(index != -1){
          distincted.removeAt(index);
        }
      }
      vssArg.sendPort.send(distincted);
    }
  }, onError: (err){
    debugPrint('Error in getVideoAndBroadcastSuggestions: $err');
  });
}

@pragma('vm:entry-point')
Future<void> listItemSearch(ListItemSearchArg lisArg) async {
  int result = -1;
  if(lisArg.searchItem != null){
    result = lisArg.searchList.indexWhere((item) => item == lisArg.searchItem);
  }else{
    result = lisArg.searchList.indexWhere((item){
      bool found = true;
      for(int i = 0; i < lisArg.searchValues!.length; i++){
        found = found && item[lisArg.searchFields![i]] == lisArg.searchValues![i]; 
      }
      return found;
    });
  }
  lisArg.sendPort.send(result);
}


@pragma('vm:entry-point')
Future<void> makeLikeDislikeAction(LikeDislikeActionArg actArg) async {
  int index = actArg.existingActions.indexWhere((item) => item.itemId == actArg.action.itemId);
  bool actionAlreadyTaken = false;
  if(index > -1){
    LikeDislikeAction existing = actArg.existingActions[index];
    if(existing.liked == actArg.action.liked){
      actArg.sendPort.send(false);
      return;
    }else{
      actArg.existingActions[index] = actArg.action;
      actionAlreadyTaken = true;
    }
  }else{
    actArg.existingActions.add(actArg.action);
  }
  bool done = false;
  int tryCount = 0;
  while (done == false && tryCount < 6) {
    tryCount += 1;
    done = await prudVidNotifier.takeLikeOrDislikeAction(
      objId: actArg.action.itemId,
      cred: actArg.cred,
      actionType: actArg.actionType,
      isLike: actArg.action.liked == 1,
      actionAlreadyTaken: actionAlreadyTaken,
    );
  }
  if(done == true){
    String storage = "";
    switch(actArg.actionType){
      case ActionType.video: storage = "likedVideos";
      case ActionType.thriller: storage = "likedThrillers";
      case ActionType.channelBroadcast: storage = "likedBroadcasts";
      case ActionType.videoComment: storage = "likedVideoComments";
      case ActionType.thrillerComment: storage = "likedThrillerComments";
      case ActionType.streamBroadcast: storage = "likedStreamBroadcast";
      case ActionType.streamBroadcastComment: storage = "likedStreamBroadcastComments";
      case ActionType.channelBroadcastComment: storage = "likedBroadcastComments";
    }
    await myStorage.addToStore(key: storage, value: actArg.existingActions.map((itm) => itm.toJson()).toList());
  }
  actArg.sendPort.send(done);
}


@pragma('vm:entry-point')
Future<void> downloadChunk(DownloadChunkArg dcArg) async {
  String path = (await getTemporaryDirectory()).path;
  String tempFilePath = '$path${dcArg.filename}.part${dcArg.chunkIndex}';
  File tempFile = File(tempFilePath);

  // Check if chunk already exists
  int downloadedBytes = 0;
  if (await tempFile.exists()) {
    downloadedBytes = await tempFile.length();
  }

  // If chunk is fully downloaded, skip
  if (downloadedBytes >= (dcArg.end - dcArg.start + 1)) {
    debugPrint('Chunk ${dcArg.chunkIndex} is already fully downloaded, skipping.');
    if(await tempFile.exists()){
      DownloadChunkResponse resp = DownloadChunkResponse(
        chunkIndex: dcArg.chunkIndex,
        finished: true,
        downloadedBytes: await tempFile.readAsBytes(),
      );
      await tempFile.delete();
      dcArg.port.send(resp.toJson());
    }
    return;
  }
  // Resume partially downloaded chunk
  int rangeStart = dcArg.start + downloadedBytes;
  bool finished = false;
  try {
    Dio dio = Dio()..interceptors.add(PrettyDioLogger());
    await dio.download( dcArg.url, tempFilePath,
      options: Options(
        headers: {'Range': 'bytes=$rangeStart-${dcArg.end}'},
      ),
      deleteOnError: false, // Keep the file if download fails
      onReceiveProgress: (received, total){
        if(total > 0 && received == total){
          finished = true;
        }
      }
    );
  } catch (e) {
    debugPrint('Failed to download chunk ${dcArg.chunkIndex}: $e');
  }
  if(finished){
    DownloadChunkResponse resp = DownloadChunkResponse(
      chunkIndex: dcArg.chunkIndex,
      finished: true,
      downloadedBytes: await tempFile.readAsBytes(),
    );
    dcArg.port.send(resp.toJson());
  }
}


@pragma("vm:entry-point")
Future<void> downloadChunks(DownloadChunksArg dcsArg) async {
  final receivePort = ReceivePort();
  for(int index in dcsArg.chunkIndexs){
    int start = index * dcsArg.eachChunkSize;
    int end = start + dcsArg.eachChunkSize - 1;
    if (end >= dcsArg.fileSize) {
      end = dcsArg.fileSize - 1;
    }
    await Isolate.spawn(downloadChunk, DownloadChunkArg(
      port: receivePort.sendPort, 
      chunkIndex: index, 
      start: start, 
      end: end, 
      url: dcsArg.url, 
      filename: dcsArg.filename
    ));
  }

  receivePort.listen((resp){
    dcsArg.port.send(resp);
  });
}

@pragma("vm:entry-point")
Future<void> downloadSmallFileInBytes(DownloadSmallFileArg dsfArg) async {
  bool finished = false;
  int trial = 0;
  while(finished == false && trial < 3){
    trial++;

    String path = (await getTemporaryDirectory()).path;
    String tempFilePath = '$path${dsfArg.filename}.pt';
    File tempFile = File(tempFilePath);

    // Check if chunk already exists
    int downloadedBytes = 0;
    if (await tempFile.exists()) {
      downloadedBytes = await tempFile.length();
    }

    // If chunk is fully downloaded, skip
    if (downloadedBytes >= dsfArg.fileSize) {
      debugPrint('file ${dsfArg.filename} is already fully downloaded, skipping.');
      if(await tempFile.exists()){
        DownloadChunkResponse resp = DownloadChunkResponse(
          chunkIndex: 0,
          finished: true,
          downloadedBytes: await tempFile.readAsBytes(),
        );
        await tempFile.delete();
        dsfArg.port.send(resp.toJson());
      }
      finished = true;
      break;
    }
    // Resume partially downloaded chunk
    int rangeStart = 0 + downloadedBytes;
    try {
      Dio dio = Dio()..interceptors.add(PrettyDioLogger());
      await dio.download( dsfArg.url, tempFilePath,
        options: Options(
          headers: {'Range': 'bytes=$rangeStart-${dsfArg.fileSize}'},
        ),
        deleteOnError: false, // Keep the file if download fails
        onReceiveProgress: (received, total){
          if(total > 0 && received == total){
            finished = true;
          }
        }
      );
    } catch (e) {
      debugPrint('Failed to download file ${dsfArg.fileSize}: $e');
    }
    if(finished){
      DownloadChunkResponse resp = DownloadChunkResponse(
        chunkIndex: 0,
        finished: true,
        downloadedBytes: await tempFile.readAsBytes(),
      );
      dsfArg.port.send(resp.toJson());
    }
  }
}


@pragma("vm:entry-point")
void mergeBytesData(MergeBytesArg mbArg){
  List<int> mergedFile = [];
  for(int itm in mbArg.arrangedIndex){
    int index = mbArg.actualBytesIndexes.indexWhere((va) => va == itm);
    if(index != -1){
      Uint8List data = mbArg.actualBytes[index];
      mergedFile.addAll(data);
    }
  }
  Uint8List res = Uint8List.fromList(mergedFile);
  mbArg.port.send(res);
}


@pragma('vm:entry-point')
Future<void> getChannelFromCloud(CommonArg comArg) async {
  int trials = 0;
  VidChannel? result;
  while (result == null && trials < 3){
    trials++;
    result = await tryAsync("getChannel", () async {
      VidChannel? cha = await prudStudioNotifier.getChannelById(comArg.id, cred: comArg.cred);
      return cha;
    }, error: (){
      return null;
    });
  }
  comArg.sendPort.send(result?.toJson());
}


@pragma('vm:entry-point')
Future<void> getVideoFromCloud(CommonArg comArg) async {
  int trials = 0;
  ChannelVideo? result;
  while (result == null && trials < 3){
    trials++;
    result = await tryAsync("getChannel", () async {
      ChannelVideo? cha = await prudStudioNotifier.getVideoById(comArg.id, cred: comArg.cred);
      return cha;
    }, error: (){
      return null;
    });
  }
  comArg.sendPort.send(result?.toJson());
}

@pragma('vm:entry-point')
Future<void> getThrillerFromCloud(CommonArg comArg) async {
  int trials = 0;
  VideoThriller? result;
  while (result == null && trials < 3){
    trials++;
    result = await tryAsync("getChannel", () async {
      VideoThriller? cha = await prudStudioNotifier.getThrillerById(thrillId: comArg.id, cred: comArg.cred);
      return cha;
    }, error: (){
      return null;
    });
  }
  comArg.sendPort.send(result?.toJson());
}


@pragma("vm:entry-point")
Future<void> getTotalComments(CommentActionArg caArg) async {
  CountSchema? res;
  int trials = 0;
  while(res == null && trials > 3){
    trials++;
    res = await prudStudioNotifier.getTotalComments(
      caArg.id, caArg.commentType, cred: caArg.cred
    );
  }
  caArg.sendPort.send(res?.toJson());
}

@pragma("vm:entry-point")
Future<void> getTotalMemberComments(CommentActionArg caArg) async {
  CountSchema? res;
  int trials = 0;
  while(res == null && trials > 3){
    trials++;
    res = await prudStudioNotifier.getTotalMemberComments(
      caArg.channelOrStreamId!, caArg.id, caArg.commentType, cred: caArg.cred
    );
  }
  caArg.sendPort.send(res?.toJson());
}

@pragma("vm:entry-point")
Future<void> getComments(CommentActionArg caArg) async {
  bool found = false;
  int trials = 0;
  List<dynamic>? res;
  while(found == false && trials > 3){
    trials++;
    res = await prudStudioNotifier.getComments(
      caArg.id, caArg.commentType, cred: caArg.cred,
      limit: caArg.limit, offset: caArg.offset
    );
    if(res != null && res.isNotEmpty){
      found = true;
    }
  }
  caArg.sendPort.send(res?.map((itm) => itm.toJson()).toList());
}


@pragma("vm:entry-point")
Future<void> getInnerComments(CommentActionArg caArg) async {
  bool found = false;
  int trials = 0;
  List<dynamic>? res;
  while(found == false && trials > 3){
    trials++;
    res = await prudStudioNotifier.getInnerComments(
      caArg.id, caArg.commentType, cred: caArg.cred,
      limit: caArg.limit, offset: caArg.offset
    );
    if(res != null && res.isNotEmpty){
      found = true;
    }
  }
  caArg.sendPort.send(res?.map((itm) => itm.toJson()).toList());
}

@pragma("vm:entry-point")
Future<void> getTotalInnerComments(CommentActionArg caArg) async {
  CountSchema? res;
  int trials = 0;
  while(res == null && trials > 3){
    trials++;
    res = await prudStudioNotifier.getTotalInnerComments(
      caArg.id, caArg.commentType, cred: caArg.cred
    );
  }
  caArg.sendPort.send(res?.toJson());
}


@pragma("vm:entry-point")
Future<void> getMembersComments(CommentActionArg caArg) async {
  bool found = false;
  int trials = 0;
  List<dynamic>? res;
  while(found == false && trials > 3){
    trials++;
    res = await prudStudioNotifier.getMembersComments(
      caArg.channelOrStreamId!, caArg.id, caArg.commentType, cred: caArg.cred,
      limit: caArg.limit, offset: caArg.offset
    );
    if(res != null && res.isNotEmpty){
      found = true;
    }
  }
  caArg.sendPort.send(res?.map((itm) => itm.toJson()).toList());
}

@pragma("vm:entry-point")
Future<void> likeOrDislikeComments(CommentActionArg caArg) async {
  bool found = false;
  int trials = 0;
  while(found == false && trials > 3){
    trials++;
    found = await prudStudioNotifier.likeOrDislikeComments(
      caArg.id, caArg.commentType, cred: caArg.cred,
      like: caArg.like, actionAlreadyTaken: caArg.actionAlreadyTaken
    );
  }
  caArg.sendPort.send(found);
}


@pragma("vm:entry-point")
Future<void> deleteComments(CommentActionArg caArg) async {
  bool deleted = false;
  int trials = 0;
  while(deleted == false && trials > 3){
    trials++;
    deleted = await prudStudioNotifier.deleteComments(
      caArg.id, caArg.commentType, cred: caArg.cred,
    );
  }
  caArg.sendPort.send(deleted);
}


@pragma("vm:entry-point")
Future<void> updateComments(CommentActionArg caArg) async {
  bool updated = false;
  int trials = 0;
  if(caArg.newUpdate == null){
    caArg.sendPort.send(null);
    return;
  }
  while(updated == false && trials > 3){
    trials++;
    updated = await prudStudioNotifier.updateComments(
      caArg.id, caArg.commentType, cred: caArg.cred,
      newUpdate: caArg.newUpdate!
    );
  }
  caArg.sendPort.send(updated);
}

@pragma("vm:entry-point")
Future<void> addComments(CommentActionArg caArg) async {
  dynamic addedComment;
  int trials = 0;
  if(caArg.newComment == null){
    caArg.sendPort.send(null);
    return;
  }
  while(addedComment == null && trials > 3){
    trials++;
    addedComment = await prudStudioNotifier.addComments(
      caArg.commentType, cred: caArg.cred,
      newObj: caArg.newComment!
    );
  }
  caArg.sendPort.send(addedComment?.toJson());
}


@pragma("vm:entry-point")
Future<void> isCommentMadeByCreatorOrOwner(CommentActionArg caArg) async {
  WhoCommented? res;
  int trials = 0;
  while(res == null && trials > 3){
    trials++;
    res = await prudStudioNotifier.isCommentMadeByCreatorOrOwner(
      caArg.id, caArg.affId!, caArg.commentType, cred: caArg.cred
    );
  }
  caArg.sendPort.send(res?.toJson());
}

@pragma("vm:entry-point")
Future<void> getInfluencerById(CommonArg cArg) async {
  User? res;
  int trials = 0;
  while(res == null && trials > 3){
    trials++;
    res = await influencerNotifier.getInfluencerById(
      cArg.id, cred: cArg.cred
    );
  }
  cArg.sendPort.send(res?.toJson());
}


@pragma("vm:entry-point")
Future<void> getVideoSuggestionsByChannel(SearchVideosByChannelArg svcArg) async {
  List<ChannelVideo>? foundVideos;
  int trials = 0;
  while(foundVideos == null && trials > 3){
    trials++;
    foundVideos = await prudStudioNotifier.getSuggestedVideosByChannel(
      criteria: svcArg.criteria, cred: svcArg.cred,
    );
  }
  svcArg.port.send(foundVideos?.map((itm) => itm.toJson()));
}


@pragma("vm:entry-point")
Future<String?> writeBytesToFileInIsolate(List<dynamic> args) async {
  try {
    final Uint8List bytes = args[0];
    final String filename = args[1];
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename.mp4');
    await file.writeAsBytes(bytes);
    return file.path;
  } catch (e) {
    debugPrint('Error writing bytes to file in isolate: $e');
    return null;
  }
}

@pragma("vm:entry-point")
Future<Uint8List> readFileBytesInIsolate(String filePath) async {
  try {
    return await File(filePath).readAsBytes();
  } catch (e) {
    debugPrint('Error reading file bytes in isolate: $e');
    throw Exception('Failed to read file: $e');
  }
}

@pragma("vm:entry-point")
void storageIsolateEntry(SendPort mainSendPort) async {
  final ReceivePort isolateReceivePort = ReceivePort();
  mainSendPort.send(isolateReceivePort.sendPort); // Send Isolate's SendPort back to main

  await GetStorage.init(); // Initialize GetStorage in the Isolate

  await for (var message in isolateReceivePort) {
    if (message is SearchHistoryArg) {
      final box = GetStorage();
      List<String> history = box.read<List<dynamic>>(searchHistoryKey)?.cast<String>() ?? [];

      if (message.action == HistroyAction.save && message.searchText != null) {
        // Remove existing entry if it's already in the history to move it to the front
        history.remove(message.searchText);
        // Add new search text to the beginning
        history.insert(0, message.searchText!);
        // Trim history to max size
        if (history.length > maxHistorySize) {
          history = history.sublist(0, maxHistorySize);
        }
        await box.write(searchHistoryKey, history);
        // Optionally, send a confirmation back
        message.sendPort?.send('saved');
      } else if (message.action == HistroyAction.load) {
        message.sendPort?.send(history);
      }
    }
  }
}