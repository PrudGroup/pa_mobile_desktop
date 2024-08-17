
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/models/wallet.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/user.dart';
import 'i_cloud.dart';


class InfluencerNotifier extends ChangeNotifier {
  static final InfluencerNotifier _influencerNotifier = InfluencerNotifier._internal();
  static get influencerNotifier => _influencerNotifier;

  factory InfluencerNotifier(){
    return _influencerNotifier;
  }

  double? referralPercentage;
  String? pin;
  int pinTrial = 0;
  DateTime? lastPinTrialAt;
  bool pinBlocked = false;
  bool pinWasVerified = false;
  String? influencerWalletCurrencyCode;
  InfluencerWallet? myWallet;
  List<WalletHistory>? myWalletHistory;

  void updateWallet(InfluencerWallet wallet){
    myWallet = wallet;
    notifyListeners();
  }

  Future<void> clearPinStatus() async {
    pinTrial = 0;
    pinBlocked = false;
    lastPinTrialAt = null;
    await savePinStatus();
  }

  Future<InfluencerWallet?> getWallet(String affId) async {
    return await tryAsync("getWallet", () async {
      dynamic res = await makeRequest(path: "affiliates/wallets/aff/$affId");
      if (res != null) {
        InfluencerWallet wt = InfluencerWallet.fromJson(res);
        updateWallet(wt);
        return wt;
      } else {
        return null;
      }
    });
  }

  Future<WalletTransactionResult> creditOrDebitWallet(WalletAction action) async{
    WalletTransactionResult wtRes = WalletTransactionResult(tran: null, succeeded: false);
    return await tryAsync("creditOrDebitWallet", () async {
      String path = "affiliates/wallets/";
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

  Future<bool> verifyPin(String dPin) async {
    bool verified = false;
    if(dPin == pin){
      verified = true;
      await clearPinStatus();
    }else{
      await incrementPinTrial();
    }
    updatePinStatus(verified);
    return verified;
  }

  void updatePinStatus(bool status){
    pinWasVerified = status;
    notifyListeners();
  }

  Future<void> incrementPinTrial() async {
    if(pinTrial >= 3){
      pinTrial = 0;
      blockPin();
    }else{
      pinTrial++;
    }
    await savePinStatus();
    notifyListeners();
  }

  Future<void> unblockPin() async {
    pinTrial = 0;
    lastPinTrialAt = null;
    pinBlocked = false;
    await savePinStatus();
    notifyListeners();
  }

  Future<void> blockPin() async {
    lastPinTrialAt = DateTime.now();
    pinBlocked = true;
    await savePinStatus();
    notifyListeners();
  }

  Future<void> checkPinBlockage() async {
    if(lastPinTrialAt != null && pinBlocked) {
      int hours = myStorage.dateDifference(dDate: lastPinTrialAt!, inWhat: 2);
      if(hours >= 3){
        await unblockPin();
      }
    }
  }

  Future<void> savePinStatus() async {
    await myStorage.addToStore(key: "pin", value: pin);
    await myStorage.addToStore(key: "pinTrial", value: pinTrial);
    await myStorage.addToStore(key: "lastPinTrialAt", value: lastPinTrialAt == null? lastPinTrialAt : lastPinTrialAt!.toIso8601String());
    await myStorage.addToStore(key: "pinBlocked", value: pinBlocked);
  }

  Future<void> changeWalletCurrency(String code) async {
    influencerWalletCurrencyCode = code;
    await myStorage.addToStore(key: "influencerWalletCurrencyCode", value: influencerWalletCurrencyCode);
  }

  void getWalletCurrency() {
    influencerWalletCurrencyCode = myStorage.getFromStore(key: "influencerWalletCurrencyCode")?? "NGN";
  }

  void getPinStatus() {
    pin = myStorage.getFromStore(key: "pin");
    pinTrial = myStorage.getFromStore(key: "pinTrial")?? 0;
    String? date = myStorage.getFromStore(key: "lastPinTrial");
    lastPinTrialAt = date == null? null : DateTime.parse(date);
    pinBlocked = myStorage.getFromStore(key: "pinBlocked")?? false;
  }

  void setDioHeaders(){
    influencerDio.options.headers.addAll({
      "Content-Type": "application/json",
      "AppCredential": prudApiKey,
      "Authorization": iCloud.affAuthToken
    });
  }

  Future<double?> getLinkReferralPercentage(String linkId) async {
    try{
      String path = "affiliates/aff_links/$linkId";
      dynamic res = await makeRequest(path: path);
      if(res != null){
        return res.toDouble();
      }else{
        return null;
      }
    }catch(ex){
      debugPrint("InfluencerNotifier_getReferralPercentage Error: $ex");
      return null;
    }
  }

  Future<User?> getInfluencerById(String id) async {
    return await tryAsync("getInfluencerById",() async{
      String path = "affiliates/$id";
      dynamic res = await makeRequest(path: path);
      if(res != null){
        User foundUser = User.fromJson(res);
        return foundUser;
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
      String url = "$prudApiUrl/$path";
      Response res = isGet? (await influencerDio.get(url)) : (await influencerDio.post(url, data: data));
      // debugPrint("influencer Request: $res");
      return res.data;
    }else{
      return null;
    }
  }

  Future<void> initInfluencer() async {
    try{
      getPinStatus();
      getWalletCurrency();
      notifyListeners();
    }catch(ex){
      debugPrint("InfluencerNotifier_initInfluencer Error: $ex");
    }
  }

  InfluencerNotifier._internal();
}


Dio influencerDio = Dio(BaseOptions(
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
final influencerNotifier = InfluencerNotifier();
double influencersReferralCommissionPercentage = 0;
