
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prudio_client.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';


class PrudVidNotifier extends ChangeNotifier{

  static final PrudVidNotifier _prudVidNotifier = PrudVidNotifier._internal();
  static PrudVidNotifier get prudVidNotifier => _prudVidNotifier;

  factory PrudVidNotifier() {
    return _prudVidNotifier;
  }

  List<String> currentPlaylist = [];
  List<String> watchLater = [];
  List<String> notInterestedVideos = [];
  List<String> dontRecommend = [];
  List<String> notInterestedBroadcasts = [];
  List<LikeDislikeAction> likedBroadcasts = [];
  List<LikeDislikeAction> likedVideos = [];
  List<LikeDislikeAction> likedThrillers = [];
  List<LikeDislikeAction> likedThrillerComments = [];
  List<LikeDislikeAction> likedVideoComments = [];
  List<LikeDislikeAction> likedBroadcastComments = [];
  List<LikeDislikeAction> likedStreamBroadcast = [];
  List<LikeDislikeAction> likedStreamBroadcastComments = [];
  PrudCredential cred = PrudCredential(key: prudApiKey, token: iCloud.affAuthToken!);
  List<VideoPaidFor> videosPaidFor = [];
  List<DownloadedVideo> localVideoLibrary = [];
  EdittedComment? edittedComment;

  void updateEdittedComment(EdittedComment cmt){
    edittedComment = cmt;
    notifyListeners();
  }

  Future<void> addToLocalVideoLibrary(DownloadedVideo vid) async {
    int index = localVideoLibrary.indexWhere((itm) => itm.videoId == vid.videoId);
    if(index == -1){
      localVideoLibrary.add(vid);
    }else{
      localVideoLibrary[index] = vid;
    }
    await myStorage.addToStore(key: "localVideoLibrary", value: localVideoLibrary.map((itm) => itm.toJson()).toList());
    notifyListeners();
  }

  Future<void> removeFromLocalVideoLibrary(DownloadedVideo vid) async {
    localVideoLibrary.removeWhere((itm) => itm.videoId == vid.videoId);
    await myStorage.addToStore(key: "localVideoLibrary", value: localVideoLibrary.map((itm) => itm.toJson()).toList());
    notifyListeners();
  }

  Future<void> removeAllFromLocalVideoLibrary(DownloadedVideo vid) async {
    localVideoLibrary = [];
    await myStorage.lStore.remove("localVideoLibrary");
    notifyListeners();
  }

  void getLocalVideoLibrary(){
    dynamic localVids = myStorage.getFromStore(key: "localVideoLibrary");
    if(localVids != null){
      localVideoLibrary = localVids.map<DownloadedVideo>((itm) => DownloadedVideo.fromJson(itm)).toList();
    }else{
      localVideoLibrary = [];
    }
  }

  bool checkIfVideoExistLocally(String vidId){
    int index = localVideoLibrary.indexWhere((itm) => itm.videoId == vidId);
    return index >= 0;
  }

  Future<void> autoCompleteUnfinishedDownloads() async {
    // TODO: auto complete unfinished local videos
  }

  bool checkIfVideoHasBeenBought(String vid){
    int index = videosPaidFor.indexWhere((itm) => itm.videoId == vid);
    return index > -1;
  }

  Future<void> addToVideosBought(VideoPaidFor vid) async {
    int index = videosPaidFor.indexWhere((itm) => itm.videoId == vid.videoId);
    if(index != -1){
      videosPaidFor[index] = vid;
    }else{
      videosPaidFor.add(vid);
    }
    await myStorage.addToStore(key: "videosPaidFor", value: videosPaidFor.map((itm) => itm.toJson()).toList());
    notifyListeners();
  }

  Future<void> removeAllExpiredVideoBought() async {
    if(videosPaidFor.isNotEmpty){
      videosPaidFor.removeWhere((itm) => itm.isExpired());
      await myStorage.addToStore(key: "videosPaidFor", value: videosPaidFor.map((itm) => itm.toJson()).toList());
      notifyListeners();
    }
  }

  void getVideoBoughtFromCache(){
    dynamic videosPaid = myStorage.getFromStore(key: "videosPaidFor");
    if(videosPaid != null){
      videosPaidFor = videosPaid.map<VideoPaidFor>((itm) => VideoPaidFor.fromJson(itm)).toList();
    }
  }

  void addToPlaylist(String vid){
    currentPlaylist.add(vid);
    myStorage.addToStore(key: "currentPlaylist", value: currentPlaylist);
    notifyListeners();
  }

  void getAnExistingActionsFromCache(ActionType actionType){
    switch(actionType){
      case ActionType.video: {
        dynamic lv = myStorage.getFromStore(key: "likedVideos");
        if(lv != null && lv.isNotEmpty) likedVideos = lv!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
      }
      case ActionType.thriller:{
        dynamic lt = myStorage.getFromStore(key: "likedThrillers");
        if(lt != null && lt.isNotEmpty) likedThrillers = lt!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
      }
      case ActionType.videoComment:{
        dynamic lvc = myStorage.getFromStore(key: "likedVideoComments");
        if(lvc != null && lvc.isNotEmpty) likedVideoComments = lvc!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
      }
      case ActionType.thrillerComment:{
        dynamic ltc = myStorage.getFromStore(key: "likedThrillerComments");
        if(ltc != null && ltc.isNotEmpty) likedThrillerComments = ltc!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
      }
      case ActionType.channelBroadcast:{
        dynamic lb = myStorage.getFromStore(key: "likedBroadcasts");
        if(lb != null && lb.isNotEmpty) likedBroadcasts = lb!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
      }
      case ActionType.channelBroadcastComment:{
        dynamic lbc = myStorage.getFromStore(key: "likedBroadcastComments");
        if(lbc != null && lbc.isNotEmpty) likedBroadcastComments = lbc!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
      }
      case ActionType.streamBroadcast:{
        dynamic lsb = myStorage.getFromStore(key: "likedStreamBroadcast");
        if(lsb != null && lsb.isNotEmpty) likedStreamBroadcast = lsb!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
      }
      case ActionType.streamBroadcastComment:{
        dynamic lsbc = myStorage.getFromStore(key: "likedVideoComments");
        if(lsbc != null && lsbc.isNotEmpty) likedVideoComments = lsbc!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
      }
    }
  }

  void getAllExistingActionsFromCache(){
    dynamic lb = myStorage.getFromStore(key: "likedBroadcasts");
    dynamic lv = myStorage.getFromStore(key: "likedVideos");
    dynamic lt = myStorage.getFromStore(key: "likedThrillers");
    dynamic ltc = myStorage.getFromStore(key: "likedThrillerComments");
    dynamic lvc = myStorage.getFromStore(key: "likedVideoComments");
    dynamic lbc = myStorage.getFromStore(key: "likedBroadcastComments");
    dynamic lsb = myStorage.getFromStore(key: "likedStreamBroadcast");
    dynamic lsbc = myStorage.getFromStore(key: "likedStreamBroadcastComments");
    if(lb != null && lb.isNotEmpty) likedBroadcasts = lb!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
    if(lv != null && lv.isNotEmpty) likedVideos = lv!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
    if(lt != null && lt.isNotEmpty) likedThrillers = lt!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
    if(ltc != null && ltc.isNotEmpty) likedThrillerComments = ltc!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
    if(lvc != null && lvc.isNotEmpty) likedVideoComments = lvc!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
    if(lbc != null && lbc.isNotEmpty) likedBroadcastComments = lbc!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
    if(lsb != null && lsb.isNotEmpty) likedStreamBroadcast = lsb!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
    if(lsbc != null && lsbc.isNotEmpty) likedStreamBroadcastComments = lsbc!.map<LikeDislikeAction>((itm) => LikeDislikeAction.fromJson(itm)).toList();
  }

  void addToLikeOrDislikeActions(
    ActionType actionType, LikeDislikeAction action, 
    BuildContext context
  ) async {
    ReceivePort actionPort = ReceivePort();
    List<LikeDislikeAction> existing = [];
    switch(actionType){
      case ActionType.video: existing = likedVideos;
      case ActionType.channelBroadcast: existing = likedBroadcasts;
      case ActionType.thriller: existing = likedThrillers;
      case ActionType.thrillerComment: existing = likedThrillerComments;
      case ActionType.videoComment: existing = likedVideoComments;
      case ActionType.channelBroadcastComment: existing = likedBroadcastComments;
      case ActionType.streamBroadcast: existing = likedStreamBroadcast;
      case ActionType.streamBroadcastComment: existing = likedStreamBroadcastComments;
    }
    LikeDislikeActionArg arg = LikeDislikeActionArg(
      sendPort: actionPort.sendPort,
      actionType: actionType,
      action: action,
      existingActions: existing,
      cred: cred,
    );
    final actionIsolate = await Isolate.spawn(makeLikeDislikeAction, arg, onError: actionPort.sendPort, onExit: actionPort.sendPort);
    actionPort.listen((resp) {
      if(resp == true){
        prudSocket.emit(actionType.name, action.toJson());
        getAnExistingActionsFromCache(actionType);
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: action.liked == 1? "Liked" : "Disliked"),
        ));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Action Failed!"),
          backgroundColor: prudColorTheme.primary,
        ));
      }
      actionPort.close();
      actionIsolate.kill(priority: Isolate.immediate);
    });
  }

  void addToWatchLater(String vid){
    watchLater.add(vid);
    myStorage.addToStore(key: "watchLater", value: watchLater);
  }

  void addToNotInterested(String vid){
    notInterestedVideos.add(vid);
    myStorage.addToStore(key: "notInterestedVideos", value: notInterestedVideos);
  }

  void addToNotInterestedCast(String vid){
    notInterestedBroadcasts.add(vid);
    myStorage.addToStore(key: "notInterestedBroadcasts", value: notInterestedBroadcasts);
  }

  void addToDontRecommend(String cid){
    dontRecommend.add(cid);
    myStorage.addToStore(key: "dontRecommend", value: dontRecommend);
  }

  void getCurrentPlaylistFromCache(){
    dynamic playlist = myStorage.getFromStore(key: "currentPlaylist");
    if(playlist != null && playlist.isNotEmpty){
      currentPlaylist = playlist;
    }
  }

  void getDontRecommendFromCache(){
    dynamic dont = myStorage.getFromStore(key: "dontRecommend");
    if(dont != null && dont.isNotEmpty){
      dontRecommend = dont;
    }
  }

  void getNotInterestedFromCache(){
    dynamic nt = myStorage.getFromStore(key: "notInterestedVideos");
    if(nt != null && nt.isNotEmpty){
      notInterestedVideos = nt;
    }
  }

  void getNotInterestedCastsFromCache(){
    dynamic nt = myStorage.getFromStore(key: "notInterestedBroadcasts");
    if(nt != null && nt.isNotEmpty){
      notInterestedBroadcasts = nt;
    }
  }

  void getWatchLaterFromCache(){
    dynamic wl = myStorage.getFromStore(key: "watchLater");
    if(wl != null && wl.isNotEmpty){
      watchLater = wl;
    }
  }

  LikeDislikeAction? checkIfLikeOrDislikeActionExist(String objId, ActionType actionType){
    List<LikeDislikeAction> objList = [];
    switch(actionType){
      case ActionType.video: objList = likedVideos;
      case ActionType.thriller: objList = likedThrillers;
      case ActionType.channelBroadcast: objList = likedBroadcasts;
      case ActionType.videoComment: objList = likedVideoComments;
      case ActionType.thrillerComment: objList = likedThrillerComments;
      case ActionType.streamBroadcast: objList = likedStreamBroadcast;
      case ActionType.streamBroadcastComment: objList = likedStreamBroadcastComments;
      case ActionType.channelBroadcastComment: objList = likedBroadcastComments;
    }
    int index = objList.indexWhere((itm) => itm.itemId == objId);
    if(index > -1){
      return objList[index];
    }else{ return null;}
  }

  Future<bool> takeLikeOrDislikeAction({
    required String objId, PrudCredential? cred,
    required ActionType actionType, bool isLike = true, 
    bool actionAlreadyTaken = false,
  }) async {
    String path = "";
    switch(actionType){
      case ActionType.video: path = "channels/videos/$objId/liking";
      case ActionType.thriller: path = "channels/videos/thrillers/$objId/liking";
      case ActionType.channelBroadcast: path = "channels/broadcasts/$objId/liked_action";
      case ActionType.videoComment: path = "channels/videos/comments/$objId/liked_action";
      case ActionType.thrillerComment: path = "channels/videos/thrillers/comments/$objId/liked_action";
      case ActionType.streamBroadcast: path = "streams/broadcasts/$objId/liked_action";
      case ActionType.streamBroadcastComment: path = "streams/broadcasts/comments/$objId/liked_action";
      case ActionType.channelBroadcastComment: path = "channels/broadcasts/comments/$objId/liked_action";
    }
    return await tryAsync("takeLikeOrDislikeAction", () async {
      dynamic res = await makeRequest(path: path, cred: cred, qParam: {
        "liked": isLike,
        "already_took_action": actionAlreadyTaken
      });
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    }, error: () => false);
  }

  void setDioHeaders(PrudCredential? cred) {
    String? token = cred != null? cred.token : iCloud.affAuthToken;
    String? key = cred != null? cred.key : prudApiKey;
    prudStudioDio.options.headers.addAll({
      "Content-Type": "application/json",
      "AppCredential": key,
      "Authorization": token
    });
  }

  Future<dynamic> makeRequest({
    required String path, bool isGet = true,
    bool isPut = false, bool isDelete = false, PrudCredential? cred,
    Map<String, dynamic>? data, Map<String, dynamic>? qParam
  }) async {
    currencyMath.loginAutomatically();
    if (iCloud.affAuthToken != null || cred != null) {
      setDioHeaders(cred);
      String url = "$prudApiUrl/studios/$path";
      Response res = isGet
          ? (await prudStudioDio.get(url, queryParameters: qParam))
          : (isPut
              ? await prudStudioDio.put(url, data: data)
              : (isDelete
                  ? await prudStudioDio.delete(url, data: data)
                  : await prudStudioDio.post(url, data: data)));
      debugPrint("prudStudio Request: $res");
      return res.data;
    } else {
      return null;
    }
  }

  Future<void> init() async {
    await tryAsync("init", () async {
      getCurrentPlaylistFromCache();
      getWatchLaterFromCache();
      getDontRecommendFromCache();
      getNotInterestedFromCache();
      getNotInterestedCastsFromCache();
      getAllExistingActionsFromCache();
      getVideoBoughtFromCache();
      await removeAllExpiredVideoBought();
      getLocalVideoLibrary();
      notifyListeners();
    });
  }


  PrudVidNotifier._internal();
}

Dio prudStudioDio = Dio(
  BaseOptions(
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 120), // 120 seconds
    receiveTimeout: const Duration(seconds: 120),
    validateStatus: (statusCode) {
      if (statusCode != null) {
        if (statusCode == 422) {
          return true;
        }
        if (statusCode >= 200 && statusCode <= 300) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    }
  )
)..interceptors.add(PrettyDioLogger());
final prudVidNotifier = PrudVidNotifier();