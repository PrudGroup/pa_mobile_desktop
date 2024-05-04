import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'i_cloud.dart';

class CurrencyMath extends ChangeNotifier{

  static final CurrencyMath _currencyMath = CurrencyMath._internal();
  static get currencyMath => _currencyMath;

  bool hasExpired = false;

  factory CurrencyMath(){
    return _currencyMath;
  }

  Future<bool> verifyPayment(String transID, double amount, String currency, String txRef) async {
    bool result = false;
    const st = Constants.waveSecretKey;
    prudDio.options.headers.addAll({
      "Authorization": "Bearer $st",
      "Content-Type": "application/json",
      "Accept": "application/json"
    });
    try{
      String url = "$waveApiUrl/transactions/$transID/verify";
      Response res = await prudDio.get(url);
      if (res.statusCode == 200) {
        var resData = res.data;
        if(resData != null && resData["status"] != null){
          if(resData["status"] == 'success' && resData["data"]["status"] == "successful"){
            double amountFrmServer = double.parse((resData["data"]["amount"]).toString());
            if("${resData["data"]["id"]}" == transID && amountFrmServer >= amount){
              if(resData["data"]["currency"] == currency && resData["data"]["tx_ref"] == txRef){
                result = true;
              }
            }
          }
        }
      }
    }catch(ex){
      debugPrint("Dio Error: $ex");
    }
    return result;
  }

  Future<void> init() async {
    try{

    }catch(ex){
      debugPrint("ErrorHandler: CurrencyMathClass: init(): $ex");
    }
  }

  double roundDouble(double value, int places){
    double mod = pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble()/mod);
  }

  Future<bool> creditUsersWallet(double amount, {
    required String userId,
    required String service,
    required String source, }) async {
    try{

    }catch(ex){
      return false;
    }
    return false;
  }

  Future<bool?> deductFromUsersWallet(double amount, {
    required String userId,
    required String service,
    required String source, }) async {
    try{

    }catch(ex){
      return false;
    }
    return false;
  }

  Future<bool> checkForBalanceSufficiency(String userId, double amount, ) async {
    try{

    }catch(ex){
      debugPrint("Error: CurrencyMath :checkForBalanceSufficiency: $ex");
      return false;
    }
    return false;
  }

  Future<void> loginAutomatically() async {
    await iCloud.checkIfAffLoggedIn("$prudApiUrl/affiliates/auth/login");
  }

  onError(dynamic ex){
    debugPrint("Error: Transaction: CurrencyMath: $ex");
    return false;
  }

  CurrencyMath._internal();
}

final currencyMath = CurrencyMath();