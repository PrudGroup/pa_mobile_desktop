
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';


class PrudVidNotifier extends ChangeNotifier{

  static final PrudVidNotifier _prudVidNotifier = PrudVidNotifier._internal();
  static get prudVidNotifier => _prudVidNotifier;

  factory PrudVidNotifier() {
    return _prudVidNotifier;
  }

  List<String> currentPlaylist = [];
  List<String> watchLater = [];
  List<String> notInterestedVideos = [];
  List<String> dontRecommend = [];

  void addToPlaylist(String vid){
    currentPlaylist.add(vid);
    myStorage.addToStore(key: "currentPlaylist", value: currentPlaylist);
  }

  void addToWatchLater(String vid){
    watchLater.add(vid);
    myStorage.addToStore(key: "watchLater", value: watchLater);
  }

  void addToNotInterested(String vid){
    notInterestedVideos.add(vid);
    myStorage.addToStore(key: "notInterestedVideos", value: notInterestedVideos);
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

  void getWatchLaterFromCache(){
    dynamic wl = myStorage.getFromStore(key: "watchLater");
    if(wl != null && wl.isNotEmpty){
      watchLater = wl;
    }
  }

  Future<void> init() async {
    await tryAsync("init", () async {
      getCurrentPlaylistFromCache();
      getWatchLaterFromCache();
      getDontRecommendFromCache();
      getNotInterestedFromCache();
    });
  }


  PrudVidNotifier._internal();
}


final prudVidNotifier = PrudVidNotifier();