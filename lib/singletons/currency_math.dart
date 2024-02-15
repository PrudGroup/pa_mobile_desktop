import 'dart:math';
import 'package:flutter/material.dart';

class CurrencyMath extends ChangeNotifier{

  static final CurrencyMath _currencyMath = CurrencyMath._internal();
  static get currencyMath => _currencyMath;

  bool hasExpired = false;

  factory CurrencyMath(){
    return _currencyMath;
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

  onError(dynamic ex){
    debugPrint("Error: Transaction: CurrencyMath: $ex");
    return false;
  }

  CurrencyMath._internal();
}

final currencyMath = CurrencyMath();
