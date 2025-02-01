
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  factory PrudStudioNotifier(){
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

  void changeTab(int tab){
    selectedTab = tab;
    notifyListeners();
  }

  void addToCachedChannelCreators(CachedChannelCreator ccc){
    channelCreators.add(ccc);
    notifyListeners();
  }

  Future<void> updateSearchedTerms4Channel(String searchedTerm) async {
    if(searchedTerms4Channel.contains(searchedTerm) == false){
      searchedTerms4Channel.add(searchedTerm);
      await myStorage.addToStore(key: "searchedTerms4Channel", value: searchedTerms4Channel);
      notifyListeners();
    }
  }

  void getSearchedTearm4ChannelFromCache(){
    List<dynamic>? searchTerms = myStorage.getFromStore(key: "searchedTerms4Channel");
    if(searchTerms != null){
      for(var item in searchTerms){
        if(searchedTerms4Channel.contains(item) == false) searchedTerms4Channel.add(item);
      }
    }
  }

  Future<void> saveNewChannelData() async {
    await myStorage.addToStore(key: "unfinishedNewChannel", value: newChannelData.toJson());
  }

  void retrieveUnfinishedNewChannelData(){
    Map<String, dynamic>? unfinishedNewChannel = myStorage.getFromStore(key: "unfinishedNewChannel");
    if(unfinishedNewChannel != null){
      newChannelData = NewChannelData.fromJson(unfinishedNewChannel);
    }
  }

  void updateWallet(StudioWallet wallet){
    wallet = wallet;
    notifyListeners();
  }

  void updateMyChannel(VidChannel cha){
    myChannels.add(cha);
    notifyListeners();
  }

  Future<void> getStudio() async {
    studio = await tryAsync("getStudio", () async {
      dynamic stud = myStorage.getFromStore(key: "studio");
      if(stud != null){
        return Studio.fromJson(jsonDecode(stud));
      }else{
        if(myStorage.user != null && myStorage.user!.id != null){
          dynamic res = await makeRequest(path: "aff/${myStorage.user!.id}");
          if (res != null && res != false) {
            Studio st = Studio.fromJson(res);
            await myStorage.addToStore(key: "studio", value: jsonEncode(st));
            return st;
          } else {
            return null;
          }
        }else{
          return null;
        }
      }
    });
  }

  Future<void> getAmACreator() async {
    amACreator = await tryAsync("getAmACreator", () async {
      dynamic crt = myStorage.getFromStore(key: "amACreator");
      if(crt != null){
        return ContentCreator.fromJson(jsonDecode(crt));
      }else{
        if(myStorage.user != null && myStorage.user!.id != null){
          dynamic res = await makeRequest(path: "creators/aff/${myStorage.user!.id}");
          if (res != null && res != false) {
            ContentCreator cc = ContentCreator.fromJson(res);
            await myStorage.addToStore(key: "amACreator", value: jsonEncode(cc));
            return cc;
          } else {
            return null;
          }
        }else{
          return null;
        }
      }
    });
  }

  Future<void> getMyChannels() async {
    myChannels = await tryAsync("getMyChannels", () async {
      if(studio != null && studio!.id != null){
        dynamic res = await makeRequest(path: "channels/studio/${studio!.id}");
        if (res != null && res != [] && res != false && res.length > 0) {
          List<VidChannel> chas = [];
          for (var item in res){
            chas.add(VidChannel.fromJson(item));
          }
          return chas;
        } else {
          return List<VidChannel>.empty();
        }
      }else{
        return List<VidChannel>.empty();
      }
    });
  }

  Future<void> getAffiliatedChannels() async {
    affiliatedChannels = await tryAsync("getAffiliatedChannels", () async {
      if(amACreator != null && amACreator!.id != null){
        dynamic res = await makeRequest(path: "channels/affiliated/${amACreator!.id}");
        if (res != null && res != [] && res != false && res.length > 0) {
          List<VidChannel> chas = [];
          for (var item in res){
            chas.add(VidChannel.fromJson(item));
          }
          return chas;
        } else {
          return List<VidChannel>.empty();
        }
      }else{
        return List<VidChannel>.empty();
      }
    });
  }

  Future<List<ContentCreator>> getChannelCreators(String channelId) async {
    return await tryAsync("getChannelCreators", () async {
      dynamic res = await makeRequest(path: "channels/$channelId/creators");
      if (res != null && res != [] && res != false && res.length > 0) {
        List<ContentCreator> chas = [];
        for (var item in res){
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

  Future<ContentCreator?> createNewCreator(ContentCreator newCreator) async {
    return await tryAsync("createNewCreator", () async {
      dynamic res = await makeRequest(path: "creators/", isGet: false, data: newCreator.toJson());
      if (res != null && res != false) {
        ContentCreator added = ContentCreator.fromJson(res);
        amACreator = added;
        notifyListeners();
        await myStorage.addToStore(key: "amACreator", value: jsonEncode(amACreator));
        return added;
      } else {
        return null;
      }
    });
  }

  Future<bool> addCreatorToChannel(String  creatorId, String channelId) async {
    return await tryAsync("addCreatorToChannel", () async {
      dynamic res = await makeRequest(path: "channels/$channelId/add_creator/$creatorId");
      if (res != null && res == true) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> removeCreatorFromChannel(String  creatorId, String channelId) async {
    return await tryAsync("removeCreatorFromChannel", () async {
      dynamic res = await makeRequest(path: "channels/$channelId/remove_creator/$creatorId");
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

  Future<List<VidChannel>> searchForChannels(String filter, String? filterValue, int limit, int? offset, {bool onlySeeking = false}) async {
    return await tryAsync("searchForChannels", () async {
      String path = "";
      List<VidChannel> results = [];
      switch(filter.toLowerCase()){
        case "country": path = onlySeeking? "channels/search/country/$filterValue/request" : "channels/search/country/$filterValue";
        case "channelname": path = onlySeeking? "channels/search/$filterValue/request" : "channels/search/$filterValue";
        default: path = onlySeeking? "channels/search/category/$filter/request" : "channels/search/category/$filter";
      }
      dynamic res = await makeRequest(path: path, qParam: {
        "limit": limit,
        "offset": offset,
      });
      if (res != null && res.isNotEmpty) {
        for(var re in res){
          results.add(VidChannel.fromJson(re));
        }
      }
      return results;
    });
  }

  Future<WalletTransactionResult> creditOrDebitWallet(WalletAction action) async{
    WalletTransactionResult wtRes = WalletTransactionResult(tran: null, succeeded: false);
    return await tryAsync("creditOrDebitWallet", () async {
      String path = "wallets/";
      dynamic res = await makeRequest(path: path, isGet: false, data: action.toJson());
      if (res != null) {
        WalletHistory ht = WalletHistory.fromJson(res);
        wtRes.succeeded = true;
        wtRes.tran = ht;
        return wtRes;
      } else {
        wtRes.succeeded = false;
        return wtRes;
      }
    }, error: (){
      wtRes.succeeded = false;
      return wtRes;
    });
  }

  Future<void> changeWalletCurrency(String code) async {
    prudStudioWalletCurrencyCode = code;
    await myStorage.addToStore(key: "prudStudioWalletCurrencyCode", value: prudStudioWalletCurrencyCode);
  }

  void getWalletCurrency() {
    prudStudioWalletCurrencyCode = myStorage.getFromStore(key: "prudStudioWalletCurrencyCode")?? "EUR";
  }

  void setDioHeaders(){
    prudStudioDio.options.headers.addAll({
      "Content-Type": "application/json",
      "AppCredential": prudApiKey,
      "Authorization": iCloud.affAuthToken
    });
  }

  Future<Studio?> getPrudStudioById(String id) async {
    return await tryAsync("getPrudStudioById",() async{
      dynamic res = await makeRequest(path: id);
      if(res != null){
        return Studio.fromJson(res);
      }else{
        return null;
      }
    }, error: (){
      return null;
    });
  }

  Future<dynamic> makeRequest({required String path, bool isGet = true, Map<String, dynamic>? data, Map<String, dynamic>? qParam}) async {
    currencyMath.loginAutomatically();
    if(iCloud.affAuthToken != null){
      setDioHeaders();
      String url = "$prudApiUrl/studios/$path";
      Response res = isGet? (await prudStudioDio.get(url, queryParameters: qParam)) : (await prudStudioDio.post(url, data: data));
      debugPrint("prudStudio Request: $res");
      return res.data ;
    }else{
      return null;
    }
  }

  Future<void> initPrudStudio() async {
    try{
      await getStudio();
      retrieveUnfinishedNewChannelData();
      getSearchedTearm4ChannelFromCache();
      if(studio != null && studio!.id != null){
        wallet = await getWallet(studio!.id!);
        await getAmACreator();
        await getMyChannels();
        await getAffiliatedChannels();
      }
      notifyListeners();
    }catch(ex){
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
      if(statusCode != null) {
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
));
final prudStudioNotifier = PrudStudioNotifier();
List<String> channelCategories = ["movies", "music", "learn", "news", "cuisines", "comedy"];
List<String> channelRequestStatuses = ["PENDING", "SEEN", "REJECTED", "ACCEPTED"];
