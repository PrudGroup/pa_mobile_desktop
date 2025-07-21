import 'dart:math';
import 'package:flutter/material.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';
import 'i_cloud.dart';

class CurrencyMath extends ChangeNotifier{

  static final CurrencyMath _currencyMath = CurrencyMath._internal();
  static CurrencyMath get currencyMath => _currencyMath;

  bool hasExpired = false;

  factory CurrencyMath(){
    return _currencyMath;
  }

  Future<bool> verifyPayment(String transID, double amount, String currency, String txRef) async {
    return false;
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

  bool onError(dynamic ex){
    debugPrint("Error: Transaction: CurrencyMath: $ex");
    return false;
  }

  Future<List<String>> getAvailableCurrencies() async => await Forex().getAvailableCurrencies();

  Future<double> convert({required double amount, required String quoteCode, required String baseCode}) async {
    if(quoteCode.toLowerCase() == baseCode.toLowerCase()) return amount;
    final fx = Forex();
    double converted = await fx.getCurrencyConverted(
        sourceCurrency: baseCode,
        destinationCurrency: quoteCode,
        sourceAmount: amount,
        numberOfDecimals: 2
    );
    return converted;
  }

  CurrencyMath._internal();
}

final currencyMath = CurrencyMath();