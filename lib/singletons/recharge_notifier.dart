
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../constants.dart';
import '../models/reloadly.dart';
import 'currency_math.dart';
import 'i_cloud.dart';

class RechargeNotifier extends ChangeNotifier {
  static final RechargeNotifier _rechargeNotifier = RechargeNotifier._internal();
  static get rechargeNotifier => _rechargeNotifier;

  factory RechargeNotifier(){
    return _rechargeNotifier;
  }

  List<RechargeTransactionDetails> transactions = [];
  RechargeTransactionDetails? selectedTransDetail;

  void selectTransactionDetail(RechargeTransactionDetails detail){
    selectedTransDetail = detail;
    notifyListeners();
  }

  void updateTransactions(List<RechargeTransactionDetails> trans){
    transactions = trans;
    notifyListeners();
  }

  Future<void> getTransactionsFromCloud(DateTime startDate, DateTime endDate) async {
    try{
      await currencyMath.loginAutomatically();
      if(iCloud.affAuthToken != null && myStorage.user != null && myStorage.user!.id != null){
        String transUrl = "$apiEndPoint/recharges/aff/${myStorage.user!.id}/dates";
        Response res = await prudDio.get(
            transUrl,
            queryParameters: {
              "start_date": startDate.toIso8601String(),
              "end_date": endDate.toIso8601String(),
            }
        );
        if (res.data != null  && res.data.length > 0) {
          List<RechargeTransactionDetails> newTrans = [];
          for(dynamic trans in res.data){
            newTrans.add(RechargeTransactionDetails.fromJson(trans));
          }
          if(newTrans.isNotEmpty) updateTransactions(newTrans);
        }
        debugPrint("GetTransResults: $res : ${res.data}");
      }
    }catch(ex){
      debugPrint("rechargeCardNotifier.getTransactionsFromCloud Error: $ex");
    }
  }


  Future<bool> saveTransactionToCloud(GiftTransactionDetails details) async {
    bool saved = false;
    try{
      await currencyMath.loginAutomatically();
      if(iCloud.affAuthToken != null){
        String transUrl = "$apiEndPoint/recharges/";
        Response res = await prudDio.post(transUrl, data: details.toJson());
        if (res.data != null  && res.data["recharge_transaction_id"] != null) {
          saved = true;
        }else{
          saved = false;
        }
        debugPrint("TransSaveResults: $res : ${res.data}");
      }
    }catch(ex){
      debugPrint("rechargeCardNotifier.saveTransactionToCloud Error: $ex");
      return saved;
    }
    return saved;
  }

  Future<bool> addTransToCloud(GiftTransaction tran, CartItem gift) async {

    return false;
  }



  Future<void> saveRechargeableCountriesToCache() async {
    List<Map<String, dynamic>> items = [];
    if(rechargeableCountries.isNotEmpty){
      for(ReloadlyCountry item in rechargeableCountries){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "rechargeableCountries", value: items);
    }else{
      myStorage.lStore.remove("rechargeableCountries");
    }
  }

  void getCountriesFromCache(){
    dynamic rechargeCountys = myStorage.getFromStore(key: "rechargeableCountries");
    if(rechargeCountys != null){
      List<dynamic> countys = rechargeCountys;
      if(countys.isNotEmpty){
        for (dynamic co in countys) {
          rechargeableCountries.add(ReloadlyCountry.fromJson(co));
        }
      }
    }
  }

  Future<RechargeOperator?> getOperatorById(int operatorId, {bool isAirtime = true}) async {
    String path = "operators/$operatorId?suggestedAmountsMap=true&suggestedAmounts=true&includeData=${isAirtime? false : true}&includeBundles=true&includeCombo=true";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      RechargeOperator operator = RechargeOperator.fromJson(result);
      return operator;
    }else{
      return null;
    }
  }

  Future<TransactionStatus?> getTransactionStatusById(int transactionId) async {
    String path = "topups/$transactionId/status";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      TransactionStatus sta = TransactionStatus.fromJson(result);
      return sta;
    }else{
      return null;
    }
  }

  Future<TopUpTransaction?> getTransactionById(int transactionId) async {
    String path = "topups/reports/transactions/$transactionId";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      TopUpTransaction tran = TopUpTransaction.fromJson(result);
      return tran;
    }else{
      return null;
    }
  }

  Future<List<OperatorCommission>> getCommissionById(int operatorId) async {
    String path = "operators/$operatorId/commissions";
    dynamic result = await makeRequest(path: path);
    if(result != null && result.isNotEmpty){
      List<OperatorCommission> commissions = [];
      for(Map<String, dynamic> res in result["content"]){
        commissions.add(OperatorCommission.fromJson(res));
      }
      return commissions;
    }else{
      return [];
    }
  }

  Future<List<OperatorPromotion>> getPromotionById(int operatorId) async {
    String path = "promotions/operators/$operatorId?languageCode=EN";
    dynamic result = await makeRequest(path: path);
    if(result != null && result.isNotEmpty){
      List<OperatorPromotion> promotions = [];
      for(Map<String, dynamic> res in result["content"]){
        promotions.add(OperatorPromotion.fromJson(res));
      }
      return promotions;
    }else{
      return [];
    }
  }

  Future<void> getOperators(ReloadlyCountry country, {bool isAirtime = true}) async {
    String path = "operators/countries/${country.currencyCode}?suggestedAmountsMap=true&suggestedAmounts=true&includeData=${isAirtime? false : true}&includeBundles=true&includeCombo=true";
    dynamic result = await makeRequest(path: path);
    List<RechargeOperator> operators = [];
    if(result != null && result.isNotEmpty){
      for(Map<String, dynamic> res in result["content"]){
        operators.add(RechargeOperator.fromJson(res));
      }
      isAirtime? airtimeProviders = operators : dataProviders = operators;
    }
  }

  Future<OperatorFx?> getFxRate(int operatorId, double amount) async {
    String path = "operators/fx-rate";
    Map<String, dynamic> data = {
      "amount": amount,
      "operatorId": operatorId,
    };
    dynamic result = await makeRequest(path: path, isGet: false, data: data);
    if(result != null){
      return OperatorFx.fromJson(result);
    }else{ return null; }
  }

  Future<TopUpTransaction?> makeTopUpOrder(TopUpOrder order) async {
    String path = "topups";
    dynamic result = await makeRequest(path: path, isGet: false, data: order.toJson());
    if(result != null){
      return TopUpTransaction.fromJson(result);
    }else{ return null; }
  }

  Future<RechargeOperator?> detectOperator(String country, String phoneNo, {bool isAirtime = true}) async {
    String path = "operators/auto-detect/phone/${int.parse(phoneNo)}/countries/$country?suggestedAmountsMap=true&suggestedAmounts=true&includeData=${isAirtime? false : true}&includeBundles=true&includeCombo=true";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      RechargeOperator operator = RechargeOperator.fromJson(result);
      debugPrint("operate: $result");
      return operator;
    }else {
      return null;
    }
  }

  Future<void> getRechargeableCountries() async {
    String path = "countries";
    dynamic result = await makeRequest(path: path);
    if(result != null && result.isNotEmpty){
      for(Map<String, dynamic> res in result){
        rechargeableCountries.add(ReloadlyCountry.fromJson(res));
      }
    }
  }

  ReloadlyCountry? getCountryByIso(String iso){
    if(iso.length == 2 && rechargeableCountries.isNotEmpty){
      return rechargeableCountries.firstWhere((ReloadlyCountry country) => country.isoName == iso);
    }else{
      return null;
    }
  }

  Future<void> getRechargeToken() async {
    reloadlyRechargeToken = await iCloud.getReloadlyToken(rechargeApiUrl);
  }

  void setDioHeaders(){
    rechargeDio.options.headers.addAll({
      "Content-Type": "application/json",
      "Accept": "application/com.reloadly.topups-v1+json",
      "Authorization": "$reloadlyRechargeToken"
    });
  }

  Future<PrudBalance?> getBalance() async {
    String path = "accounts/balance";
    dynamic res = await makeRequest(path: path);
    if(res != null){
      return PrudBalance(amount: res["balance"], currency: res["currencyCode"]);
    }else{
      return null;
    }
  }

  Future<dynamic> makeRequest({required String path, bool isGet = true, Map<String, dynamic>? data}) async {
    if(reloadlyRechargeToken == null) await getRechargeToken();
    if(reloadlyRechargeToken != null){
      setDioHeaders();
      String url = "$rechargeApiUrl/$path";
      Response res = isGet? (await rechargeDio.get(url)) : (await rechargeDio.post(url, data: data));
      debugPrint("Result: $res");
      return res.data;
    }
  }

  Future<bool> isBalanceSufficient(double baseAmount, String baseCur) async {
    PrudBalance? balance = await getBalance();
    if(balance != null){
      if(baseCur.toLowerCase() == balance.currency.toLowerCase()){
        return balance.amount >= baseAmount;
      }else{
        double convertedAmount = await currencyMath.convert(
            amount: baseAmount,
            quoteCode: balance.currency,
            baseCode: baseCur
        );
        return balance.amount >= convertedAmount;
      }
    }else{
      return false;
    }
  }

  Future<void> initRecharge() async {
    try{
      getCountriesFromCache();
      notifyListeners();
    }catch(ex){
      debugPrint("RechargeNotifier_initRecharge Error: $ex");
    }
  }

  RechargeNotifier._internal();
}


Dio rechargeDio = Dio(BaseOptions(
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
String rechargeApiUrl = Constants.apiStatues == 'production'? "https://topups.reloadly.com" : "https://topups-sandbox.reloadly.com";
final rechargeNotifier = RechargeNotifier();
List<ReloadlyCountry> rechargeableCountries = [];
List<RechargeOperator> airtimeProviders = [];
List<RechargeOperator> dataProviders = [];
double rechargeCustomerDiscountInPercentage = 1/3;
String? reloadlyRechargeToken;
