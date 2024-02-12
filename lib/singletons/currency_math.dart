import 'dart:math';
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

class CurrencyMath extends ChangeNotifier{

  static final CurrencyMath _currencyMath = CurrencyMath._internal();
  static get currencyMath => _currencyMath;

  late DateTime lastUpdated;
  bool hasExpired = false;

  factory CurrencyMath(){
    return _currencyMath;
  }

  Future<void> init() async {
    try{
      _checkIfExpired();
      notifyListeners();
    }catch(ex){
      debugPrint("ErrorHandler: CurrencyMathClass: init(): $ex");
    }
  }

  void _checkIfExpired(){
    if(myStorage.dateDifference(dDate: lastUpdated,) >= 7) {
      hasExpired = true;
    } else {
      hasExpired = false;
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

  onError(dynamic ex){
    debugPrint("Error: Transaction: CurrencyMath: $ex");
    return false;
  }

  CurrencyMath._internal();
}

final currencyMath = CurrencyMath();
