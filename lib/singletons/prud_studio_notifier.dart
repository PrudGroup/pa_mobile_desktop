import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/wallet.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../models/prud_vid.dart';
import 'i_cloud.dart';

class PrudStudioNotifier extends ChangeNotifier {
  static final PrudStudioNotifier _prudStudioNotifier = PrudStudioNotifier._internal();
  static get prudStudioNotifier => _prudStudioNotifier;

  factory PrudStudioNotifier() {
    return _prudStudioNotifier;
  }

  String? prudStudioWalletCurrencyCode;
  Studio? studio;
  StudioWallet? wallet;
  List<WalletHistory>? walletHistory;
  int selectedTab = 0;
  List<VidChannel> myChannels = [];
  ContentCreator? amACreator;
  List<VidChannel> affiliatedChannels = [];
  NewChannelData newChannelData = NewChannelData(
    ageTargets: SfRangeValues(18.0, 30.0),
    category: channelCategories[0],
    selectedCurrency: tabData.getCurrency("EUR"),
  );
  List<String> searchedTerms4Channel = [];
  List<CachedChannelCreator> channelCreators = [];
  List<RatedObject> objectsRated = [];
  List<ChannelMembership> affJoined = [];
  List<ChannelSubscriber> affSubscribed = [];
  List<ChannelRefferal> channelRefferals = [];
  String? changedDescription;
  double? changedMembershipCost;
  double? changedStreamingCost;
  double? changedViewShare;
  double? changedMembershipShare;
  String? selectedChannelId;
  PendingNewVideo newVideo = PendingNewVideo(
    thriller: VideoThriller(
      videoId: "", videoUrl: ""
    )
  );
  List<VisitedChannel> visitedChannels = [];
  List<String> watchedTrillers = [];
  List<String> watchedVideos = [];
  List<dynamic> thrillerDetailSuggestions = [];
  List<dynamic> videoDetailSuggestions = [];
  int thrillerDetailLastItemScroll = 0;
  int videoDetailLastItemScroll = 0;


  void updateThrillerDetailSuggestions(List<dynamic> items){
    thrillerDetailSuggestions = items;
    notifyListeners();
  }

  void updateVideoDetailSuggestions(List<dynamic> items){
    videoDetailSuggestions = items;
    notifyListeners();
  }

  bool isThrillerWatched(String thrillerId) => watchedTrillers.contains(thrillerId);

  bool isVideoWatched(String videoId) => watchedVideos.contains(videoId);

  void addToWatchedThrillers(String thrillerId){
    bool alreadyExists = watchedTrillers.contains(thrillerId);
    if(!alreadyExists) watchedTrillers.add(thrillerId);
    myStorage.addToStore(key: "watchedTrillers", value: watchedTrillers);
  }

  void addToWatchedVideos(String videoId){
    bool alreadyExists = watchedVideos.contains(videoId);
    if(!alreadyExists) watchedVideos.add(videoId);
    myStorage.addToStore(key: "watchedVideos", value: watchedVideos);
  }

  void getWatchedThrillersFromCache(){
    List<dynamic>?  watched = myStorage.getFromStore(key: "watchedTrillers");
    if(watched != null){
      watchedTrillers = watched as List<String>;
    }
  }

  void getWatchedVideosFromCache(){
    List<dynamic>?  watched = myStorage.getFromStore(key: "watchedVideos");
    if(watched != null){
      watchedVideos = watched as List<String>;
    }
  }

  void addChannelVideoToVisitedChannels(VisitedChannel visitedChannel, List<ChannelVideo> videos){
    int index = visitedChannels.indexWhere((cha) => cha.channel.id == visitedChannel.channel.id);
    visitedChannel.channel.videos = videos;
    visitedChannel.lastVideoOffset = videos.length;
    if(index == -1){
      visitedChannels.add(visitedChannel);
    }else{
      visitedChannels[index] = visitedChannel;
    }
    notifyListeners();
  }

  void updateChannelVideoToVisitedChannels(VisitedChannel visitedChannel, List<ChannelVideo> videos){
    int index = visitedChannels.indexWhere((cha) => cha.channel.id == visitedChannel.channel.id);
    visitedChannel.channel.videos = videos;
    if(index == -1){
      visitedChannels.add(visitedChannel);
    }else{
      VisitedChannel cha = visitedChannels[index];
      cha.channel.videos = videos;
      cha.lastVideoOffset = visitedChannel.lastVideoOffset;
      cha.lastVideoScrollPoint = visitedChannel.lastVideoScrollPoint;
      visitedChannels[index] = cha;
    }
    notifyListeners();
  }

  void updateVideoThrillerToVisitedChannels(String channelId, VideoThriller thrill){
    int index = visitedChannels.indexWhere((cha) => cha.channel.id == channelId);
    if(index > -1){
      VisitedChannel cha = visitedChannels[index];
      if(cha.channel.videos != null){
        int ind = cha.channel.videos!.indexWhere((vid) => vid.id == thrill.videoId);
        if(ind > -1){
          ChannelVideo dVid = cha.channel.videos![ind];
          dVid.thriller = thrill;
          cha.channel.videos![ind] = dVid;
          visitedChannels[index] = cha;
        }
      }
    }
    notifyListeners();
  }

  VisitedChannel? getCachedVisitedChannel(String channelId){
    int index = visitedChannels.indexWhere((cha) => cha.channel.id == channelId);
    return index >= 0? visitedChannels[index] : null;
  }

  void addChannelBroadcastToVisitedChannels(VisitedChannel visitedChannel, List<ChannelBroadcast> bCasts){
    int index = visitedChannels.indexWhere((cha) => cha.channel.id == visitedChannel.channel.id);
    visitedChannel.channel.broadcasts = bCasts;
    visitedChannel.lastBroadcastOffset = bCasts.length;
    if(index == -1){
      visitedChannels.add(visitedChannel);
    }else{
      visitedChannels[index] = visitedChannel;
    }
    notifyListeners();
  }

  void updateChannelBroadcastToVisitedChannels(VisitedChannel visitedChannel, List<ChannelBroadcast> bCasts){
    int index = visitedChannels.indexWhere((cha) => cha.channel.id == visitedChannel.channel.id);
    visitedChannel.channel.broadcasts = bCasts;
    if(index == -1){
      visitedChannels.add(visitedChannel);
    }else{
      VisitedChannel cha = visitedChannels[index];
      cha.channel.broadcasts = bCasts;
      cha.lastBroadcastOffset = visitedChannel.lastBroadcastOffset;
      cha.lastBroadcastScrollPoint = visitedChannel.lastBroadcastScrollPoint;
      visitedChannels[index] = cha;
    }
    notifyListeners();
  }


  void channelChangesOccurred(VidChannel cha){
    changedMembershipCost = cha.monthlyMembershipCost;
    changedDescription = cha.description;
    changedStreamingCost = cha.monthlyStreamingCost;
    changedViewShare = cha.contentPercentageSharePerView;
    changedMembershipShare = cha.membershipPercentageSharePerMonth;
    notifyListeners();
  }

  void clearChannelChanges(){
    changedMembershipCost = null;
    changedDescription = null;
    changedStreamingCost = null;
    changedViewShare = null;
    changedMembershipShare = null;
    // notifyListeners();
  }

  Future<void> clearUnfinishedNewVideoFromCache() async {
    await myStorage.lStore.remove("unfinishedNewVideo");
  }
  
  Future<ChannelStreamServiceFigure> getChannelStreamFigures(String channelId) async {
    ChannelStreamServiceFigure result = ChannelStreamServiceFigure(active: 0, total: 0);
    return await tryAsync("getChannelStreamFigures", () async {
      dynamic res = await makeRequest(
        path: "channels/$channelId/services/figure",
        isGet: true,
      );
      if (res != null && res != false) {
        result = ChannelStreamServiceFigure.fromJson(res);
        return result;
      } else {
        return result;
      }
    }, error: () {
      return result;
    });
  }
  
  Future<void> updateChannelRefferals(ChannelRefferal ref, bool isAdd) async {
    if(isAdd){
      channelRefferals.add(ref);
    }else{
      channelRefferals.remove(ref);
    }
    await myStorage.addToStore(key: "channelRefferals", value: channelRefferals.map((reff) => reff.toJson()).toList());
  }

  void getChannelRefferalsFromCache(){
    List<dynamic>? cacheRefs = myStorage.getFromStore(key: "channelRefferals");
    if (cacheRefs != null && cacheRefs.isNotEmpty) {
      channelRefferals = cacheRefs.map((ref) => ChannelRefferal.fromJson(ref)).toList();
      notifyListeners();
    }
  }

  void changeTab(int tab) {
    selectedTab = tab;
    notifyListeners();
  }

  RatingSearchResult checkIfVotedObject(String objId) {
    int index = objectsRated.indexWhere((rating) => rating.id == objId);
    if (index != -1) {
      if (objectsRated[index].monthRated == DateTime.now().month &&
          objectsRated[index].yearRated == DateTime.now().year) {
        return RatingSearchResult(
            index: index, ratedObject: objectsRated[index], canVote: false);
      } else {
        return RatingSearchResult(
            index: index, ratedObject: objectsRated[index], canVote: true);
      }
    } else {
      return RatingSearchResult(index: -1, ratedObject: null, canVote: true);
    }
  }

  Future<void> updateObjectRating(RatedObject rating, bool hasRatedB4, int index) async {
    if (hasRatedB4) {
      objectsRated[index] = rating;
    } else {
      objectsRated.add(rating);
    }
    await saveObjectRatingToCache();
    notifyListeners();
  }

  Future<void> saveObjectRatingToCache() async {
    await myStorage.addToStore(
      key: "objectsRated",
      value: objectsRated.map((rating) => rating.toJson()).toList()
    );
  }

  void retrieveObjectRatingFromCache() {
    List<dynamic>? channelRatings =
        myStorage.getFromStore(key: "objectsRated");
    if (channelRatings != null) {
      objectsRated =
          channelRatings.map((json) => RatedObject.fromJson(json)).toList();
      notifyListeners();
    }
  }

  void addToCachedChannelCreators(CachedChannelCreator ccc) {
    channelCreators.add(ccc);
    notifyListeners();
  }

  void updateChannelPromoteStatus(VidChannel channel, bool status) {
    int index = myChannels.indexOf(channel);
    if (index != -1) {
      myChannels[index].promoted = status;
      notifyListeners();
    }
  }

  Future<void> updateSearchedTerms4Channel(String searchedTerm) async {
    if (searchedTerms4Channel.contains(searchedTerm) == false) {
      searchedTerms4Channel.add(searchedTerm);
      await myStorage.addToStore(
          key: "searchedTerms4Channel", value: searchedTerms4Channel);
      notifyListeners();
    }
  }

  void getSearchedTerm4ChannelFromCache() {
    List<dynamic>? searchTerms =
        myStorage.getFromStore(key: "searchedTerms4Channel");
    if (searchTerms != null) {
      for (var item in searchTerms) {
        if (searchedTerms4Channel.contains(item) == false) {
          searchedTerms4Channel.add(item);
        }
      }
    }
  }

  Future<void> saveNewChannelData() async {
    await myStorage.addToStore(
        key: "unfinishedNewChannel", value: newChannelData.toJson());
  }

  Future<void> saveNewVideoData() async {
    await myStorage.addToStore(
      key: "unfinishedNewVideo", value: newVideo.toJson()
    );
  }

  void retrieveUnfinishedNewChannelData() {
    Map<String, dynamic>? unfinishedNewChannel = myStorage.getFromStore(key: "unfinishedNewChannel");
    if (unfinishedNewChannel != null) {
      newChannelData = NewChannelData.fromJson(unfinishedNewChannel);
    }
  }

  void retrieveUnfinishedNewVideoData() {
    Map<String, dynamic>? unfinishedNewVideo = myStorage.getFromStore(key: "unfinishedNewVideo");
    if (unfinishedNewVideo != null) {
      newVideo = PendingNewVideo.fromJson(unfinishedNewVideo);
    }
  }

  void updateWallet(StudioWallet wallet) {
    wallet = wallet;
    notifyListeners();
  }

  void updateMyChannel(VidChannel cha) {
    myChannels.add(cha);
    notifyListeners();
  }

  void updateAChannelInMyChannels(VidChannel cha) {
    int index = myChannels.indexWhere((ch) => ch.id == cha.id);
    if (index != -1) {
      myChannels[index] = cha;
      notifyListeners();
    }
  }

  Future<bool> promoteChannel(VidChannel channel, bool promote,
      String? fileType, String? fileUrl) async {
    if (promote) {
      if (channel.id != null && fileType != null && fileUrl != null) {
        PromoteChannel pro = PromoteChannel(
            channelId: channel.id!, mediaType: fileType, mediaUrl: fileUrl);
        dynamic res = await makeRequest(
            path: "promote_channels/", isGet: false, data: pro.toJson());
        if (res != null && res != false) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      dynamic res =
          await makeRequest(path: "channels/${channel.id!}/unpromote");
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<PromoteVideo?> promoteVideo(PromoteVideo pro) async {
    dynamic res = await makeRequest(path: "promote_videos/", isGet: false, data: pro.toJson());
    if (res != null && res != false) {
      return PromoteVideo.fromJson(res);
    } else {
      return null;
    }
  }

  Future<PayForVideoViewSchema?> pay4View(PayForVideoViewSchema pay) async{
    return await tryAsync("pay4View", () async {
      dynamic res = await makeRequest(path: "channels/videos/pay_for_view/", isGet: false, data: pay.toJson());
      if (res != null) {
        return PayForVideoViewSchema.fromJson(res);
      } else {
        return null;
      }
    }, error: (){
      return null;
    });
  }

  Future<PayForVideoViewSchema?> pay4Download(PayForVideoViewSchema pay) async{
    return await tryAsync("pay4Download", () async {
      dynamic res = await makeRequest(path: "channels/videos/pay_for_download/", isGet: false, data: pay.toJson());
      if (res != null) {
        return PayForVideoViewSchema.fromJson(res);
      } else {
        return null;
      }
    }, error: (){
      return null;
    });
  }

  Future<void> getStudio() async {
    studio = await tryAsync("getStudio", () async {
      dynamic stud = myStorage.getFromStore(key: "studio");
      if (stud != null) {
        return Studio.fromJson(jsonDecode(stud));
      } else {
        if (myStorage.user != null && myStorage.user!.id != null) {
          dynamic res = await makeRequest(path: "aff/${myStorage.user!.id}");
          if (res != null && res != false) {
            Studio st = Studio.fromJson(res);
            await myStorage.addToStore(key: "studio", value: jsonEncode(st));
            return st;
          } else {
            return null;
          }
        } else {
          return null;
        }
      }
    });
  }

  Future<void> getAmACreator() async {
    amACreator = await tryAsync("getAmACreator", () async {
      dynamic crt = myStorage.getFromStore(key: "amACreator");
      if (crt != null) {
        return ContentCreator.fromJson(jsonDecode(crt));
      } else {
        if (myStorage.user != null && myStorage.user!.id != null) {
          dynamic res =
              await makeRequest(path: "creators/aff/${myStorage.user!.id}");
          if (res != null && res != false) {
            ContentCreator cc = ContentCreator.fromJson(res);
            await myStorage.addToStore(
                key: "amACreator", value: jsonEncode(cc));
            return cc;
          } else {
            return null;
          }
        } else {
          return null;
        }
      }
    });
  }

  Future<List<ChannelVideo>?> getChannelVideos({required String channelId, int limit = 100, int? offset}) async {
    return await tryAsync("getChannelVideos", () async {
      dynamic res = await makeRequest(path: "channels/$channelId/videos", qParam: {
        "limit": limit,
        if(offset != null) "offset": offset
      });
      if (res != null && res != false && res.length > 0) {
        List<ChannelVideo> chas = [];
        for (var item in res) {
          chas.add(ChannelVideo.fromJson(item));
        }
        return chas;
      } else {
        return null;
      }
    });
  }

  Future<List<ChannelVideo>?> getSuggestedVideosByChannel({required SearchByChannelSchema criteria, PrudCredential? cred}) async {
    return await tryAsync("getSuggestedVideos", () async {
      dynamic res = await makeRequest(path: "channels/videos/search_by_channel/", isGet: false, data: criteria.toJson(), cred: cred);
      if (res != null && res != false && res.length > 0) {
        List<ChannelVideo> chas = [];
        for (var item in res) {
          chas.add(ChannelVideo.fromJson(item));
        }
        return chas;
      } else {
        return null;
      }
    }, error: () => null);
  }

  Future<List<ChannelVideo>?> getSuggestedVideos({required VideoSearch criteria, PrudCredential? cred}) async {
    return await tryAsync("getSuggestedVideos", () async {
      dynamic res = await makeRequest(path: "channels/videos/search_by/${criteria.toInt()}", qParam: {
        "limit": criteria.limit,
        "offset": criteria.offset,
        "category": criteria.category,
        "audience": criteria.audience?.name,
        "country": criteria.country,
        "search_text": criteria.searchText,
      }, cred: cred);
      if (res != null && res != false && res.length > 0) {
        List<ChannelVideo> chas = [];
        for (var item in res) {
          chas.add(ChannelVideo.fromJson(item));
        }
        return chas;
      } else {
        return null;
      }
    }, error: () => null);
  }

  Future<List<ChannelBroadcast>?> getSuggestedBroadcasts({required String criteria, PrudCredential? cred, int limit = 100, int offset = 0}) async {
    return await tryAsync("getSuggestedBroadcasts", () async {
      dynamic res = await makeRequest(path: "channels/broadcasts/search/random", qParam: {
        "limit": limit,
        "offset": offset,
        "search_text": criteria,
      }, cred: cred);
      if (res != null && res != false && res.length > 0) {
        List<ChannelBroadcast> chas = [];
        for (var item in res) {
          chas.add(ChannelBroadcast.fromJson(item));
        }
        return chas;
      } else {
        return null;
      }
    }, error: () => null);
  }

  Future<List<ChannelBroadcast>?> getChannelBroadcasts({required String channelId, int limit = 100, int? offset}) async {
    return await tryAsync("getChannelBroadcasts", () async {
      dynamic res = await makeRequest(path: "channels/broadcasts/channel/$channelId", qParam: {
        "limit": limit,
        if(offset != null) "offset": offset
      });
      if (res != null && res != false && res.length > 0) {
        List<ChannelBroadcast> chas = [];
        for (var item in res) {
          chas.add(ChannelBroadcast.fromJson(item));
        }
        return chas;
      } else {
        return null;
      }
    });
  }

  Future<bool> incrementVideoImpression({required String vidId, PrudCredential? cred}) async {
    return await tryAsync("incrementVideoImpression", () async {
      dynamic res = await makeRequest(path: "channels/videos/$vidId/increment_impressions", cred: cred);
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    }, error: () => false);
  }

  Future<bool> incrementVideoDownloads({required String vidId, PrudCredential? cred}) async {
    return await tryAsync("incrementVideoDownloads", () async {
      dynamic res = await makeRequest(path: "channels/videos/$vidId/increment_download", cred: cred);
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    }, error: () => false);
  }

  Future<bool> incrementVideoWatchMinutes({required String vidId, required int minutes, PrudCredential? cred}) async {
    return await tryAsync("incrementVideoWatchMinutes", () async {
      dynamic res = await makeRequest(path: "channels/videos/$vidId/increment_watch_minutes", qParam: {"minutes": minutes}, cred: cred);
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    }, error: () => false);
  }

  Future<bool> incrementBroadcastImpression({required String castId, PrudCredential? cred}) async {
    return await tryAsync("incrementBroadcastImpression", () async {
      dynamic res = await makeRequest(path: "channels/broadcasts/$castId/impressions/increment", cred: cred);
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    }, error: () => false);
  }

  Future<ChannelVideo?> getVideoById(String vid, {PrudCredential? cred}) async {
    return await tryAsync("getVideoById", () async {
      dynamic res = await makeRequest(path: "channels/videos/$vid", cred: cred);
      if (res != null && res != false) {
        return ChannelVideo.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<VidChannel?> getChannelById(String cid, {PrudCredential? cred}) async {
    return await tryAsync("getChannelById", () async {
      dynamic res = await makeRequest(path: "channels/$cid", cred: cred);
      if (res != null && res != false) {
        return VidChannel.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<VideoThriller?> getThrillerById({required String thrillId, PrudCredential? cred}) async {
    return await tryAsync("getThrillerById", () async {
      dynamic res = await makeRequest(path: "channels/videos/thrillers/$thrillId", isGet: true, cred: cred);
      if (res != null && res != false) {
        return VideoThriller.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<VideoThriller?> getThrillerByVideoId({required String videoId}) async {
    return await tryAsync("getThrillerByVideoId", () async {
      dynamic res = await makeRequest(path: "channels/videos/thrillers/video/$videoId", isGet: true);
      if (res != null && res != false) {
        return VideoThriller.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<void> getMyChannels() async {
    myChannels = await tryAsync("getMyChannels", () async {
      if (studio != null && studio!.id != null) {
        dynamic res = await makeRequest(path: "channels/studio/${studio!.id}");
        if (res != null && res != [] && res != false && res.length > 0) {
          List<VidChannel> chas = [];
          for (var item in res) {
            chas.add(VidChannel.fromJson(item));
          }
          return chas;
        } else {
          return List<VidChannel>.empty();
        }
      } else {
        return List<VidChannel>.empty();
      }
    });
  }

  Future<void> getAffiliatedChannels() async {
    affiliatedChannels = await tryAsync("getAffiliatedChannels", () async {
      if (amACreator != null && amACreator!.id != null) {
        dynamic res = await makeRequest(path: "channels/affiliated/${amACreator!.id}");
        if (res != null && res != [] && res != false && res.length > 0) {
          List<VidChannel> chas = [];
          for (var item in res) {
            chas.add(VidChannel.fromJson(item));
          }
          return chas;
        } else {
          return List<VidChannel>.empty();
        }
      } else {
        return List<VidChannel>.empty();
      }
    });
  }

  Future<VidChannel?> updateChannelInCloud(String channelId, ChannelUpdate newUpdate) async {
    return await tryAsync("updateChannelInCloud", () async {
      dynamic res = await makeRequest(
        path: "channels/$channelId", isGet: false, isPut: true, data: newUpdate.toJson()
      );
      if (res != null && res != false) {
        return VidChannel.fromJson(res);
      } else {
        return null;
      }
    }, error: () => null);
  }

  Future<List<ContentCreator>> getChannelCreators(String channelId) async {
    return await tryAsync("getChannelCreators", () async {
      dynamic res = await makeRequest(path: "channels/$channelId/creators");
      if (res != null && res != [] && res != false && res.length > 0) {
        List<ContentCreator> chas = [];
        for (var item in res) {
          chas.add(ContentCreator.fromJson(item));
        }
        return chas;
      } else {
        return List<ContentCreator>.empty();
      }
    }, error: () => List<ContentCreator>.empty());
  }

  Future<Studio?> createStudio(Studio newStudio) async {
    return await tryAsync("createStudio", () async {
      dynamic res = await makeRequest(path: "", isGet: false, data: newStudio.toJson());
      if (res != null) {
        Studio st = Studio.fromJson(res);
        await myStorage.addToStore(key: "studio", value: jsonEncode(st));
        return st;
      } else {
        return null;
      }
    });
  }

  Future<dynamic> voteAnObject(
    String objId,  VoteObjectType objType, Map<String, dynamic> rateData, {PrudCredential? cred}
  ) async {
    return await tryAsync("voteAnObject", () async {
      String path = "channels/$objId/rate";
      switch(objType){
        case VoteObjectType.channel: path = "channels/$objId/rate"; 
        case VoteObjectType.stream: path = "streams/$objId/rate";
        case VoteObjectType.video: path = "channels/videos/$objId/rate";
        case VoteObjectType.movieCast: path = "channels/videos/movie_details/casts/$objId/rate";
      }
      dynamic res = await makeRequest(
        path: path, isGet: false, isPut: true, data: rateData, cred: cred,
      );
      if (res != null && res != false && res != true) {
        switch(objType){
          case VoteObjectType.channel: return VidChannel.fromJson(res); 
          case VoteObjectType.stream: return VidStream.fromJson(res);
          case VoteObjectType.video: return ChannelVideo.fromJson(res);
          case VoteObjectType.movieCast: return VideoMovieCast.fromJson(res);
        }
      } else {
        return null;
      }
    });
  }

  Future<int> getSubscribersCount(String channelId) async {
    int result = 0;
    return await tryAsync("getSubscribersCount", () async {
      dynamic res = await makeRequest(
        path: "channels/subscribers/channel/$channelId/",
        isGet: true,
      );
      if (res != null && res != false) {
        result = res;
        return result;
      } else {
        return result;
      }
    }, error: () {
      return result;
    });
  }

  Future<int> getMembersCount(String channelId) async {
    int result = 0;
    return await tryAsync("getMembersCount", () async {
      dynamic res = await makeRequest(
        path: "channels/members/channel/$channelId/count",
        isGet: true,
      );
      if (res != null && res != false) {
        result = res;
        return result;
      } else {
        return result;
      }
    }, error: () {
      return result;
    });
  }

  Future<void> addJoinedToCache(ChannelMembership memb) async {
    await tryAsync("updateJoinedToCache", () async {
      affJoined.add(memb);
      await myStorage.addToStore(key: "joined", value: affJoined.map((mem) => mem.toJson()).toList());
      notifyListeners();
    });
  }

  Future<void> removeJoinedFromCache(ChannelMembership memb) async {
    await tryAsync("updateJoinedToCache", () async {
      affJoined.removeWhere((item) => item.affId == memb.affId && item.channelId == memb.channelId);
      await myStorage.addToStore(key: "joined", value: affJoined.map((mem) => mem.toJson()).toList());
      notifyListeners();
    });
  }

  Future<void> addSubscribedToCache(ChannelSubscriber sub) async {
    await tryAsync("addSubscribedToCache", () async {
      affSubscribed.add(sub);
      await myStorage.addToStore(
          key: "subscribed",
          value: affSubscribed.map((mem) => mem.toJson()).toList());
      notifyListeners();
    });
  }

  Future<void> removeSubscribedFromCache(ChannelSubscriber sub) async {
    await tryAsync("removeSubscribedFromCache", () async {
      affSubscribed.removeWhere((item) => item.channelId == sub.channelId && item.affId == sub.affId);
      await myStorage.addToStore(
          key: "subscribed",
          value: affSubscribed.map((mem) => mem.toJson()).toList());
      notifyListeners();
    });
  }

  Future<void> getChannelsJoinedFromCache() async {
    //you have to get this from cloud first to assert latest update
    if (myStorage.user != null && myStorage.user!.id != null) {
      List<ChannelMembership> cloudJoined = await getChannelsMembered(myStorage.user!.id!);
      if (cloudJoined.isNotEmpty) {
        affJoined = cloudJoined;
      } else {
        affJoined = List<ChannelMembership>.empty();
      }
    } else {
      affJoined = List<ChannelMembership>.empty();
    }
    if(affJoined.isEmpty){
      List<dynamic>? cacheJoined = myStorage.getFromStore(key: "joined");
      if(cacheJoined != null){
        affJoined = cacheJoined.map((dynamic mem) => ChannelMembership.fromJson(mem)).toList();
      }
    }
    await myStorage.addToStore(
      key: "joined",
      value: affJoined.map((mem) => mem.toJson()).toList()
    );
    notifyListeners();
  }

  Future<void> getChannelsSubscribedFromCache() async {
    List<dynamic>? cacheSubscribed = myStorage.getFromStore(key: "subscribed");
    if (cacheSubscribed != null) {
      affSubscribed = cacheSubscribed
          .map((dynamic mem) => ChannelSubscriber.fromJson(mem))
          .toList();
    } else {
      if (myStorage.user != null && myStorage.user!.id != null) {
        List<ChannelSubscriber> cloudSubscribed =
            await getChannelsSubscribed(myStorage.user!.id!);
        if (cloudSubscribed.isNotEmpty) {
          affSubscribed = cloudSubscribed;
        } else {
          affSubscribed = List<ChannelSubscriber>.empty();
        }
      } else {
        affSubscribed = List<ChannelSubscriber>.empty();
      }
      await myStorage.addToStore(
          key: "subscribed",
          value: affSubscribed.map((mem) => mem.toJson()).toList());
    }
    notifyListeners();
  }

  Future<List<ChannelMembership>> getChannelsMembered(String affId) async {
    List<ChannelMembership> result = [];
    return await tryAsync("getChannelsMembered", () async {
      dynamic res = await makeRequest(
        path: "channels/members/aff/$affId",
        isGet: true,
      );
      if (res != null && res != false && res.isNotEmpty) {
        result =
            res.map<ChannelMembership>((dynamic mem) => ChannelMembership.fromJson(mem)).toList();
        return result;
      } else {
        return result;
      }
    }, error: () {
      return result;
    });
  }

  Future<List<ChannelSubscriber>> getChannelsSubscribed(String affId) async {
    List<ChannelSubscriber> result = [];
    return await tryAsync("getChannelsSubscribed", () async {
      dynamic res = await makeRequest(
        path: "channels/subscribers/aff/$affId",
        isGet: true,
      );
      if (res != null && res != false && res.isNotEmpty) {
        result = res.map<ChannelSubscriber>((dynamic mem) => ChannelSubscriber.fromJson(mem)).toList();
        return result;
      } else {
        return result;
      }
    }, error: () {
      return result;
    });
  }

  Future<ChannelSubscriber>? subscribeToChannel(String channelId) async {
    return await tryAsync("subscribeToChannel", () async {
      if(myStorage.user != null && myStorage.user!.id != null) {
        ChannelSubscriber sub = ChannelSubscriber(
          affId: myStorage.user!.id!, channelId: channelId
        );
        dynamic res = await makeRequest(
          path: "channels/subscribers/",
          isGet: false,
          data: sub.toJson()
        );
        if (res != null && res != false) {
          return ChannelSubscriber.fromJson(res);
        } else {
          return null;
        }
      }else{
        return null;
      }
    });
  }

  ChannelRefferal? getChannelRefferal(String channelId){
    return tryOnly("getChannelRefferal", (){
      if(channelRefferals.isNotEmpty){
        return channelRefferals.firstWhere((ref) => ref.channelId == channelId);
      }else{
        return null;
      }
    }, error: (){
      return null;
    });
  }

  Future<ChannelMembership?> joinAChannel(String channelId) async {
    if(myStorage.user != null && myStorage.user!.id != null) {
      ChannelMembership data = ChannelMembership(
        channelId: channelId,
        affId: myStorage.user!.id!,
        appInstallReferral: myStorage.installReferralCode,
        channelReferral: getChannelRefferal(channelId)?.referrerId,
      );
      return await tryAsync("joinAChannel", () async {
        dynamic res = await makeRequest(
          path: "channels/members/", 
          isGet: false, data: data.toJson()
        );
        if (res != null && res != false) {
          return ChannelMembership.fromJson(res);
        } else {
          return null;
        }
      }, error: (){
        return null;
      });
    }else{
      return null;
    }
  }

  Future<bool> leaveAChannel(String channelId) async {
    return await tryAsync("leaveAChannel", () async {
      if (myStorage.user != null && myStorage.user!.id != null) {
        dynamic res = await makeRequest(
          path: "channels/members/channel/$channelId/aff/${myStorage.user!.id!}",
          isGet: false,
          isDelete: true,
        );
        return res;
      } else {
        return false;
      }
    });
  }

  Future<bool> unsubscribeFromAChannel(String channelId) async {
    return await tryAsync("unsubscribeFromAChannel", () async {
      if (myStorage.user != null && myStorage.user!.id != null) {
        dynamic res = await makeRequest(
          path: "channels/subscribers/channel/$channelId/aff/${myStorage.user!.id!}",
          isGet: false,
          isDelete: true,
        );
        return res;
      } else {
        return false;
      }
    });
  }

  Future<VidChannel?> createVidChannel(VidChannel newChannel) async {
    return await tryAsync("createVidChannel", () async {
      dynamic res = await makeRequest(path: "channels/", isGet: false, data: newChannel.toJson());
      if (res != null && res != false) {
        return VidChannel.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<VideoMovieDetail?> createMovieDetail(VideoMovieDetail newDetail) async {
    return await tryAsync("createMovieDetail", () async {
      dynamic res = await makeRequest(path: "channels/videos/movie_details/", isGet: false, data: newDetail.toJson());
      if (res != null && res != false) {
        return VideoMovieDetail.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<VideoMusicDetail?> createMusicDetail(VideoMusicDetail newDetail) async {
    return await tryAsync("createMusicDetail", () async {
      dynamic res = await makeRequest(path: "channels/videos/music_details/", isGet: false, data: newDetail.toJson());
      if (res != null && res != false) {
        return VideoMusicDetail.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<ChannelVideo?> createNewVideo(ChannelVideo newVideo) async {
    return await tryAsync("createNewVideo", () async {
      dynamic res = await makeRequest(path: "channels/videos/", isGet: false, data: newVideo.toJson());
      if (res != null && res != false) {
        return ChannelVideo.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<VideoThriller?> createNewThriller(VideoThriller newThriller) async {
    return await tryAsync("createNewThriller", () async {
      dynamic res = await makeRequest(path: "channels/videos/thrillers/", isGet: false, data: newThriller.toJson());
      if (res != null && res != false) {
        return VideoThriller.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<VideoSnippet?> createNewSnippet(VideoSnippet newSnippet) async {
    return await tryAsync("createNewSnippet", () async {
      dynamic res = await makeRequest(path: "channels/videos/snippets/", isGet: false, data: newSnippet.toJson());
      if (res != null && res != false) {
        return VideoSnippet.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<bool> createNewBulkSnippet(List<VideoSnippet> newSnippets) async {
    dynamic snippets = newSnippets.map((snip) => snip.toJson()).toList();
    return await tryAsync("createNewBulkSnippet", () async {
      dynamic res = await makeRequest(path: "channels/videos/snippets/", isGet: false, data: {"bulk": snippets});
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<ContentCreator?> createNewCreator(ContentCreator newCreator) async {
    return await tryAsync("createNewCreator", () async {
      dynamic res = await makeRequest(
          path: "creators/", isGet: false, data: newCreator.toJson());
      if (res != null && res != false) {
        ContentCreator added = ContentCreator.fromJson(res);
        amACreator = added;
        notifyListeners();
        await myStorage.addToStore(
            key: "amACreator", value: jsonEncode(amACreator));
        return added;
      } else {
        return null;
      }
    });
  }

  Future<bool> addCreatorToChannel(String creatorId, String channelId) async {
    return await tryAsync("addCreatorToChannel", () async {
      dynamic res =
          await makeRequest(path: "channels/$channelId/add_creator/$creatorId");
      if (res != null && res == true) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> removeCreatorFromChannel(
      String creatorId, String channelId) async {
    return await tryAsync("removeCreatorFromChannel", () async {
      dynamic res = await makeRequest(
          path: "channels/$channelId/remove_creator/$creatorId");
      if (res != null && res == true) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<StudioWallet?> getWallet(String studId) async {
    return await tryAsync("getWallet", () async {
      dynamic res = await makeRequest(path: "wallets/studio/$studId");
      if (res != null) {
        return StudioWallet.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<CountSchema?> getTotalComments(String objId, CommentType commentType, {PrudCredential? cred}) async {
    return await tryAsync("getTotalComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/$objId/comments/count";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/$objId/comments/count";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/$objId/comments/count";
        default: path = "streams/broadcasts/$objId/comments/count";
      }
      dynamic res = await makeRequest(path: path, cred: cred);
      if (res != null && res != false) {
        return CountSchema.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<CountSchema?> getTotalInnerComments(String commentId, CommentType commentType, {PrudCredential? cred}) async {
    return await tryAsync("getTotalComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/comments/$commentId/count/inner";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/comments/$commentId/count/inner";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/comments/$commentId/count/inner";
        default: path = "streams/broadcasts/comments/$commentId/count/inner";
      }
      dynamic res = await makeRequest(path: path, cred: cred);
      if (res != null && res != false) {
        return CountSchema.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<CountSchema?> getTotalMemberComments( String channelId, String objId, CommentType commentType, {PrudCredential? cred}) async {
    return await tryAsync("getTotalMemberComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/$objId/comments/$channelId/count";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/$objId/comments/$channelId/count";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/$objId/comments/$channelId/count";
        default: path = "streams/broadcasts/$objId/comments/$channelId/count";
      }
      dynamic res = await makeRequest(path: path, cred: cred);
      if (res != null && res != false) {
        return CountSchema.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<List<Comment>?> getComments(String objId, CommentType commentType, {PrudCredential? cred, int limit = 150, int offset = 0}) async {
    return await tryAsync("getComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/$objId/comments/main";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/$objId/comments/main";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/$objId/comments/main";
        default: path = "streams/broadcasts/$objId/comments/main";
      }
      dynamic res = await makeRequest(
        path: path, cred: cred, qParam: {
        "limit": limit,
        "offset": offset
      });
      if (res != null && res != false && res.length > 0) {
        List<Comment> result = [];
        for(var re in res){
          result.add(Comment.fromJson(re, commentType));
        }
        return res;
      } else {
        return null;
      }
    });
  }

  Future<dynamic> getLastComments(String objId, CommentType commentType, {PrudCredential? cred, int limit = 150, int offset = 0}) async {
    return await tryAsync("getLastComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/$objId/comments/main";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/$objId/comments/main";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/$objId/comments/main";
        default: path = "streams/broadcasts/$objId/comments/main";
      }
      dynamic res = await makeRequest(
        path: path, cred: cred, qParam: {
        "limit": limit,
        "offset": offset
      });
      if (res != null && res != false) {
        switch(commentType){
          case CommentType.videoComment: return VideoComment.fromJson(res);
          case CommentType.thrillerComment: return VideoThrillerComment.fromJson(res);
          case CommentType.channelBroadcastComment: return ChannelBroadcastComment.fromJson(res);
          default: return StreamBroadcastComment.fromJson(res);
        }
      } else {
        return null;
      }
    });
  }

  Future<List<Comment>?> getInnerComments(String commentId, CommentType commentType, {PrudCredential? cred, int limit = 150, int offset = 0}) async {
    return await tryAsync("getInnerComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/comments/$commentId/comments";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/comments/$commentId/comments";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/comments/$commentId/comments";
        default: path = "streams/broadcasts/comments/$commentId/comments";
      }
      dynamic res = await makeRequest(
        path: path, cred: cred, qParam: {
        "limit": limit,
        "offset": offset
      });
      if (res != null && res != false && res.length > 0) {
        List<Comment> result = [];
        for(var re in res){
          result.add(Comment.fromJson(re, commentType));
        }
        return res;
      } else {
        return null;
      }
    });
  }

  Future<List<Comment>?> getMembersComments(String channelId, String objId, CommentType commentType, {PrudCredential? cred, int limit = 150, int offset = 0}) async {
    return await tryAsync("getMembersComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/$objId/comments/$channelId/main";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/$objId/comments/$channelId/main";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/$objId/comments/$channelId/main";
        default: path = "streams/broadcasts/$objId/comments/$channelId/main";
      }
      dynamic res = await makeRequest(
        path: path, cred: cred, qParam: {
        "limit": limit,
        "offset": offset
      });
      if (res != null && res != false && res.length > 0) {
        List<Comment> result = [];
        for(var re in res){
          result.add(Comment.fromJson(re, commentType));
        }
        return res;
      } else {
        return null;
      }
    });
  }

  Future<bool> likeOrDislikeComments(String commentId, CommentType commentType, {PrudCredential? cred, bool like = true, bool actionAlreadyTaken = false}) async {
    return await tryAsync("likeOrDislikeComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/comments/$commentId/liked_action";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/comments/$commentId/liked_action";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/comments/$commentId/liked_action";
        default: path = "streams/broadcasts/comments/$commentId/liked_action";
      }
      dynamic res = await makeRequest(
        path: path, cred: cred, qParam: {
        "liked": like,
        "already_took_action": actionAlreadyTaken
      });
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> deleteComments(String commentId, CommentType commentType, {PrudCredential? cred}) async {
    return await tryAsync("deleteComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/comments/$commentId";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/comments/$commentId";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/comments/$commentId";
        default: path = "streams/broadcasts/comments/$commentId";
      }
      dynamic res = await makeRequest(path: path, cred: cred, isDelete: true, isGet: false, isPut: false);
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> updateComments(String commentId, CommentType commentType, {PrudCredential? cred, required CommentPutSchema newUpdate}) async {
    return await tryAsync("updateComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/comments/$commentId";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/comments/$commentId";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/comments/$commentId";
        default: path = "streams/broadcasts/comments/$commentId";
      }
      dynamic res = await makeRequest(path: path, cred: cred, isDelete: false, isGet: false, isPut: true, data: newUpdate.toJson());
      if (res != null && res != false) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<dynamic> addComments(CommentType commentType, {PrudCredential? cred, required dynamic newObj}) async {
    return await tryAsync("updateComments", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/comments/";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/comments/";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/comments/";
        default: path = "streams/broadcasts/comments/";
      }
      dynamic res = await makeRequest(path: path, cred: cred, isGet: false, data: newObj.toJson());
      if (res != null && res != false) {
        switch(commentType){
          case CommentType.videoComment: return VideoComment.fromJson(res);
          case CommentType.thrillerComment: return VideoThrillerComment.fromJson(res);
          case CommentType.channelBroadcastComment: return ChannelBroadcastComment.fromJson(res);
          default: return StreamBroadcastComment.fromJson(res);
        }
      } else {
        return false;
      }
    });
  }

  Future<WhoCommented?> isCommentMadeByCreatorOrOwner( String objId, String affId, CommentType commentType, {PrudCredential? cred}) async {
    return await tryAsync("isCommentMadeByCreatorOrOwner", () async {
      String path = "";
      switch(commentType){
        case CommentType.videoComment: path = "channels/videos/$objId/comments/$affId/who_is_commenting";
        case CommentType.thrillerComment: path = "channels/videos/thrillers/$objId/comments/$affId/who_is_commenting";
        case CommentType.channelBroadcastComment: path = "channels/broadcasts/$objId/comments/$affId/who_is_commenting";
        default: path = "streams/broadcasts/$objId/comments/$affId/who_is_commenting";
      }
      dynamic res = await makeRequest(path: path, cred: cred);
      if (res != null && res != false) {
        return WhoCommented.fromJson(res);
      } else {
        return null;
      }
    });
  }

  Future<List<VidChannel>> searchForChannels(
      String filter, String? filterValue, int limit, int? offset,
      {bool onlySeeking = false}) async {
    return await tryAsync("searchForChannels", () async {
      String path = "";
      List<VidChannel> results = [];
      switch (filter.toLowerCase()) {
        case "country":
          path = onlySeeking
              ? "channels/search/country/$filterValue/request"
              : "channels/search/country/$filterValue";
        case "channelname":
          path = onlySeeking
              ? "channels/search/$filterValue/request"
              : "channels/search/$filterValue";
        default:
          path = onlySeeking
              ? "channels/search/category/$filter/request"
              : "channels/search/category/$filter";
      }
      dynamic res = await makeRequest(path: path, qParam: {
        "limit": limit,
        "offset": offset,
      });
      if (res != null && res.isNotEmpty) {
        for (var re in res) {
          results.add(VidChannel.fromJson(re));
        }
      }
      return results;
    });
  }

  Future<WalletTransactionResult> creditOrDebitWallet(
      WalletAction action) async {
    WalletTransactionResult wtRes =
        WalletTransactionResult(tran: null, succeeded: false);
    return await tryAsync("creditOrDebitWallet", () async {
      String path = "wallets/";
      dynamic res =
          await makeRequest(path: path, isGet: false, data: action.toJson());
      if (res != null) {
        WalletHistory ht = WalletHistory.fromJson(res);
        wtRes.succeeded = true;
        wtRes.tran = ht;
        return wtRes;
      } else {
        wtRes.succeeded = false;
        return wtRes;
      }
    }, error: () {
      wtRes.succeeded = false;
      return wtRes;
    });
  }

  Future<void> changeWalletCurrency(String code) async {
    prudStudioWalletCurrencyCode = code;
    await myStorage.addToStore(
        key: "prudStudioWalletCurrencyCode",
        value: prudStudioWalletCurrencyCode);
  }

  void getWalletCurrency() {
    prudStudioWalletCurrencyCode =
        myStorage.getFromStore(key: "prudStudioWalletCurrencyCode") ?? "EUR";
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

  Future<Studio?> getPrudStudioById(String id) async {
    return await tryAsync("getPrudStudioById", () async {
      dynamic res = await makeRequest(path: id);
      if (res != null) {
        return Studio.fromJson(res);
      } else {
        return null;
      }
    }, error: () {
      return null;
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
      Response res = isGet? (await prudStudioDio.get(url, queryParameters: qParam))
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

  Future<void> initPrudStudio() async {
    try {
      await getStudio();
      retrieveUnfinishedNewChannelData();
      retrieveUnfinishedNewVideoData();
      getSearchedTerm4ChannelFromCache();
      retrieveObjectRatingFromCache();
      await getChannelsJoinedFromCache();
      await getChannelsSubscribedFromCache();
      getChannelRefferalsFromCache();
      getWatchedThrillersFromCache();
      getWatchedVideosFromCache();
      if (studio != null && studio!.id != null) {
        wallet = await getWallet(studio!.id!);
        await getAmACreator();
        await getMyChannels();
        await getAffiliatedChannels();
      }
      ReceivePort rPort = ReceivePort();
      ListItemSearchArg searchArgs = ListItemSearchArg(
        sendPort: rPort.sendPort,
        searchList: ["2345ABCDEF", "2345", "102030"],
        searchItem: "EMEA"
      );
      Isolate.spawn(listItemSearch, searchArgs, onError: rPort.sendPort, onExit: rPort.sendPort);
      rPort.listen((resp) {
        debugPrint("Result: $resp");
      });
      notifyListeners();
    } catch (ex) {
      debugPrint("PrudStudioNotifier_initPrudStudio Error: $ex");
    }
  }

  PrudStudioNotifier._internal();
}

Dio prudStudioDio = Dio(BaseOptions(
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 60), // 60 seconds
    receiveTimeout: const Duration(seconds: 60),
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
    }))..interceptors.add(PrettyDioLogger());
final prudStudioNotifier = PrudStudioNotifier();
List<String> channelCategories = [
  "movies",
  "music",
  "learn",
  "news",
  "cuisines",
  "comedy"
];
List<String> channelRequestStatuses = [
  "PENDING",
  "SEEN",
  "REJECTED",
  "ACCEPTED"
];
