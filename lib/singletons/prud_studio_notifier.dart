
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/models/wallet.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/prud_vid.dart';
import '../models/user.dart';
import 'i_cloud.dart';


class PrudStudioNotifier extends ChangeNotifier {
  static final PrudStudioNotifier _prudStudioNotifier = PrudStudioNotifier._internal();
  static get prudStudioNotifier => _prudStudioNotifier;

  factory PrudStudioNotifier(){
    return _prudStudioNotifier;
  }

  String? prudStudioWalletCurrencyCode;
  StudioWallet? myWallet;
  List<WalletHistory>? myWalletHistory;

  void updateWallet(StudioWallet wallet){
    myWallet = wallet;
    notifyListeners();
  }

  Future<StudioWallet?> getWallet(String affId) async {
    return await tryAsync("getWallet", () async {
      dynamic res = await makeRequest(path: "wallets/aff/$affId");
      if (res != null) {
        StudioWallet wt = StudioWallet.fromJson(res);
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

  Future<User?> getPrudStudioById(String id) async {
    return await tryAsync("getPrudStudioById",() async{
      dynamic res = await makeRequest(path: id);
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
      String url = "$prudApiUrl/affiliates/$path";
      Response res = isGet? (await prudStudioDio.get(url)) : (await prudStudioDio.post(url, data: data));
      debugPrint("prudStudio Request: $res");
      return res.data;
    }else{
      return null;
    }
  }

  Future<void> initPrudStudio() async {
    try{
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
