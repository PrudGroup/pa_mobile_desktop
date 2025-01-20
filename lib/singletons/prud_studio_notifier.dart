
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/models/wallet.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

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

  void changeTab(int tab){
    selectedTab = tab;
    notifyListeners();
  }

  void updateWallet(StudioWallet wallet){
    wallet = wallet;
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
          return [];
        }
      }else{
        return [];
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
          return [];
        }
      }else{
        return [];
      }
    });
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
      dynamic res = await makeRequest(path: "/channels/", isGet: false, data: newChannel.toJson());
      if (res != null) {
        return VidChannel.fromJson(res);
      } else {
        return null;
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

  Future<dynamic> makeRequest({required String path, bool isGet = true, Map<String, dynamic>? data}) async {
    currencyMath.loginAutomatically();
    if(iCloud.affAuthToken != null){
      setDioHeaders();
      String url = "$prudApiUrl/studios/$path";
      Response res = isGet? (await prudStudioDio.get(url)) : (await prudStudioDio.post(url, data: data));
      debugPrint("prudStudio Request: $res");
      return res.data;
    }else{
      return null;
    }
  }

  Future<void> initPrudStudio() async {
    try{
      await getStudio();
      if(studio != null && studio!.id != null){
        wallet = await getWallet(studio!.id!);
        await getAmACreator();
        await getMyChannels();
        await getAffiliatedChannels();
        notifyListeners();
      }
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
List<String> channelCategories = ["movie", "music", "learn", "news", "cuisines", "comedy"];
