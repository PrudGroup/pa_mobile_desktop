
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../constants.dart';
import '../models/reloadly.dart';
import 'currency_math.dart';
import 'i_cloud.dart';

class UtilityNotifier extends ChangeNotifier {
  static final UtilityNotifier _utilityNotifier = UtilityNotifier._internal();
  static get utilityNotifier => _utilityNotifier;

  factory UtilityNotifier(){
    return _utilityNotifier;
  }
  
  List<UtilityDevice> deviceNumbers = [];
  List<Biller> billers = [];
  List<UtilityTransactionDetails> transactions = [];
  UtilityTransactionDetails? selectedTransDetail;
  UtilityDevice? selectedDeviceNumber;
  Biller? selectedBiller;
  BillerServiceType? selectedServiceType;
  BillerType? selectedUtilityType;
  bool continueTransaction = false;
  bool utilityPaymentMade = false;
  String? utilityPaymentId;
  UtilityTransaction? unsavedUtilityTrans;
  UtilityTransactionDetails? unsavedUtilityDetails;
  UtilitySearch? lastUtilitySearch;
  LastBillersUsed? lastBillerUsed;

  void updateSelectedUtilityType(BillerType type){
    selectedUtilityType = type;
    notifyListeners();
  }

  void updateSelectedServiceType(BillerServiceType type){
    selectedServiceType = type;
    notifyListeners();
  }

  Future<void> updateBillersInLastBillersUsed() async {
    try{
      if(lastBillerUsed != null){
        if(lastBillerUsed!.water != null && lastBillerUsed!.water!.id != null){
          Biller? water = await getBillerById(lastBillerUsed!.water!.id!);
          if(water != null){lastBillerUsed!.water = water;}
        }
        if(lastBillerUsed!.electricity != null && lastBillerUsed!.electricity!.id != null){
          Biller? electricity = await getBillerById(lastBillerUsed!.electricity!.id!);
          if(electricity != null){lastBillerUsed!.electricity = electricity;}
        }
        if(lastBillerUsed!.internet != null && lastBillerUsed!.internet!.id != null){
          Biller? internet = await getBillerById(lastBillerUsed!.internet!.id!);
          if(internet != null){lastBillerUsed!.internet = internet;}
        }
        if(lastBillerUsed!.tv != null && lastBillerUsed!.tv!.id != null){
          Biller? tv = await getBillerById(lastBillerUsed!.tv!.id!);
          if(tv != null){lastBillerUsed!.tv = tv;}
        }
        saveLastBillerUsedToCache();
      }
    }catch(ex){
      debugPrint("updateBillersInLastBillersUsed Error: $ex");
    }
  }

  Future<void> updateUnsavedTrans(UtilityTransaction item) async {
    unsavedUtilityTrans = item;
    await saveUnsavedTransToCache();
    notifyListeners();
  }

  Future<void> selectFromSavedBiller(Biller biller, UtilityDevice device) async {
    selectedBiller = biller;
    selectedDeviceNumber = device;
    notifyListeners();
  }

  Future<void> updateLastBillerUsed(Biller biller, String deviceNo) async {
    lastBillerUsed ??= LastBillersUsed();
    switch(biller.type){
      case "ELECTRICITY_BILL_PAYMENT": {
        lastBillerUsed!.electricity = biller;
        lastBillerUsed!.lastDeviceUsedOnElectricity = deviceNo;
        break;
      }
      case "WATER_BILL_PAYMENT": {
        lastBillerUsed!.water = biller;
        lastBillerUsed!.lastDeviceUsedOnWater = deviceNo;
        break;
      }
      case "TV_BILL_PAYMENT": {
        lastBillerUsed!.tv = biller;
        lastBillerUsed!.lastDeviceUsedOnTv = deviceNo;
        break;
      }
      default: {
        lastBillerUsed!.internet = biller;
        lastBillerUsed!.lastDeviceUsedOnInternet = deviceNo;
        break;
      }
    }
    await saveLastBillerUsedToCache();
    notifyListeners();
  }


  String translateType(BillerType bType){
    switch(bType){
      case BillerType.electricity: return "ELECTRICITY_BILL_PAYMENT";
      case BillerType.water: return "WATER_BILL_PAYMENT";
      case BillerType.tv: return "TV_BILL_PAYMENT";
      default: return "INTERNET_BILL_PAYMENT";
    }
  }

  BillerType translateToType(String bType){
    switch(bType){
      case "ELECTRICITY_BILL_PAYMENT": return BillerType.electricity;
      case "WATER_BILL_PAYMENT": return BillerType.water;
      case "TV_BILL_PAYMENT": return BillerType.tv;
      default: return BillerType.internet;
    }
  }

  String translateService(BillerServiceType service){
    switch(service){
      case BillerServiceType.prepaid: return "PREPAID";
      default: return "POSTPAID";
    }
  }

  BillerServiceType translateToService(String service){
    switch(service){
      case "PREPAID": return BillerServiceType.prepaid;
      default: return BillerServiceType.postpaid;
    }
  }

  Future<void> updateLastSearch(UtilitySearch item) async {
    lastUtilitySearch = item;
    await saveLastSearchToCache();
    notifyListeners();
  }

  Future<void> saveLastSearchToCache() async {
    if(lastUtilitySearch != null){
      Map<String, dynamic> item = lastUtilitySearch!.toJson();
      await myStorage.addToStore(key: "lastUtilitySearch", value: item);
    }else{
      myStorage.lStore.remove("lastUtilitySearch");
    }
  }

  Future<void> saveLastBillerUsedToCache() async {
    if(lastBillerUsed != null){
      Map<String, dynamic> item = lastBillerUsed!.toJson();
      await myStorage.addToStore(key: "lastBillerUsed", value: item);
    }else{
      myStorage.lStore.remove("lastBillerUsed");
    }
  }

  Future<void> updateUnsavedUtilityDetails(UtilityTransactionDetails item) async {
    unsavedUtilityDetails = item;
    await saveUnsavedUtilityDetailsToCache();
    notifyListeners();
  }

  Future<void> saveUnsavedUtilityDetailsToCache() async {
    if(unsavedUtilityDetails != null){
      Map<String, dynamic> item = unsavedUtilityDetails!.toJson();
      await myStorage.addToStore(key: "unsavedUtilityDetails", value: item);
    }else{
      myStorage.lStore.remove("unsavedUtilityDetails");
    }
  }

  Future<void> saveUnsavedTransToCache() async {
    if(unsavedUtilityTrans != null){
      Map<String, dynamic> item = unsavedUtilityTrans!.toJson();
      await myStorage.addToStore(key: "unsavedUtilityTrans", value: item);
    }else{
      myStorage.lStore.remove("unsavedUtilityTrans");
    }
  }

  void getUnsavedTransFromCache(){
    dynamic unsaved = myStorage.getFromStore(key: "unsavedUtilityTrans");
    if(unsaved != null){
      unsavedUtilityTrans = UtilityTransaction.fromJson(unsaved);
    }
  }

  void getLastSearchFromCache(){
    dynamic last = myStorage.getFromStore(key: "lastUtilitySearch");
    if(last != null){
      lastUtilitySearch = UtilitySearch.fromJson(last);
    }
  }

  void getLastBillerUsedFromCache(){
    dynamic last = myStorage.getFromStore(key: "lastBillerUsed");
    if(last != null){
      lastBillerUsed = LastBillersUsed.fromJson(last);
    }
  }

  Future<UtilityOrderResult?> makeOrder(UtilityOrder order) async {
    String path = "pay";
    dynamic result = await makeRequest(path: path, isGet: false, data: order.toJson());
    if(result != null){
      UtilityOrderResult tran = UtilityOrderResult.fromJson(result);
      return tran;
    }else{
      return null;
    }
  }

  void getUnsavedUtilityDetailsFromCache(){
    dynamic unsavedDetail = myStorage.getFromStore(key: "unsavedUtilityDetails");
    if(unsavedDetail != null){
      unsavedUtilityDetails = UtilityTransactionDetails.fromJson(unsavedDetail);
    }
  }

  Future<void> updateSelectedDeviceNo(UtilityDevice num) async {
    selectedDeviceNumber = num;
    await saveDeviceNoToCache();
    notifyListeners();
  }

  Future<void> updateSelectedBiller(Biller bill) async {
    selectedBiller = bill;
    await saveLastBillerUsedToCache();
    notifyListeners();
  }

  Future<void> updatePaymentStatus(bool status, String id) async {
    utilityPaymentMade = status;
    utilityPaymentId = id;
    savePaymentStatus();
    notifyListeners();
  }

  Future<void> savePaymentStatus() async {
    await myStorage.addToStore(key: "utilityPaymentMade", value: utilityPaymentMade);
    await myStorage.addToStore(key: "utilityPaymentId", value: utilityPaymentId);
  }

  void getPaymentStatusFromCache(){
    bool? paid = myStorage.getFromStore(key: "utilityPaymentMade");
    String? airPayId = myStorage.getFromStore(key: "utilityPaymentId");
    if(paid != null ){
      utilityPaymentMade = paid;
      if(airPayId != null) utilityPaymentId = airPayId;
    }
  }

  void updateContinuedStatus(bool status){
    continueTransaction = status;
    notifyListeners();
  }
  
  void selectTransactionDetail(UtilityTransactionDetails detail){
    selectedTransDetail = detail;
    notifyListeners();
  }

  void updateTransactions(List<UtilityTransactionDetails> trans){
    transactions = trans;
    notifyListeners();
  }

  Future<void> getTransactionsFromCloud(DateTime startDate, DateTime endDate) async {
    try{
      await currencyMath.loginAutomatically();
      if(iCloud.affAuthToken != null && myStorage.user != null && myStorage.user!.id != null){
        String transUrl = "$apiEndPoint/utilities/aff/${myStorage.user!.id}/dates";
        Response res = await prudDio.get(
            transUrl,
            queryParameters: {
              "start_date": startDate.toIso8601String(),
              "end_date": endDate.toIso8601String(),
            }
        );
        if (res.data != null  && res.data.length > 0) {
          List<UtilityTransactionDetails> newTrans = [];
          for(dynamic trans in res.data){
            newTrans.add(UtilityTransactionDetails.fromJson(trans));
          }
          if(newTrans.isNotEmpty) updateTransactions(newTrans);
        }
        debugPrint("GetTransResults: $res : ${res.data}");
      }
    }catch(ex){
      debugPrint("UtilityNotifier.getTransactionsFromCloud Error: $ex");
    }
  }

  void addToTransactions(UtilityTransactionDetails tran){
    transactions.add(tran);
    notifyListeners();
  }

  Future<bool> saveTransactionToCloud(UtilityTransactionDetails details) async {
    bool saved = false;
    try{
      await currencyMath.loginAutomatically();
      if(iCloud.affAuthToken != null){
        String transUrl = "$apiEndPoint/utilities/";
        Response res = await prudDio.post(transUrl, data: details.toJson());
        if (res.data != null  && res.data["utility_transaction_id"] != null) {
          saved = true;
        } else {
          saved = false;
        }
        debugPrint("TransSaveResults: $res : ${res.data}");
      }
    }catch(ex){
      debugPrint("utilityNotifier.saveTransactionToCloud Error: $ex");
      return saved;
    }
    return saved;
  }

  Future<void> saveUtilitizedCountriesToCache() async {
    List<Map<String, dynamic>> items = [];
    if(utilitizedCountries.isNotEmpty){
      for(ReloadlyCountry item in utilitizedCountries){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "utilitizedCountries", value: items);
    }else{
      myStorage.lStore.remove("utilitizedCountries");
    }
  }

  void getCountriesFromCache(){
    dynamic utiCountys = myStorage.getFromStore(key: "utilitizedCountries");
    if(utiCountys != null){
      List<dynamic> countys = utiCountys;
      if(countys.isNotEmpty){
        for (dynamic co in countys) {
          utilitizedCountries.add(ReloadlyCountry.fromJson(co));
        }
      }
    }
  }

  Future<UtilityTransaction?> getTransactionById(int transactionId) async {
    String path = "transactions/$transactionId";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      UtilityTransaction tran = UtilityTransaction.fromJson(result);
      return tran;
    }else{
      return null;
    }
  }

  Future<void> getBillers(UtilitySearch us) async {
    String path = "billers?type=${us.type}&serviceType=${us.serviceType}&countryISOCode=${us.countryISOCode}&size=200";
    dynamic result = await makeRequest(path: path);
    List<Biller> bs = [];
    if(result != null && result.isNotEmpty){
      for(Map<String, dynamic> res in result["content"]){
        bs.add(Biller.fromJson(res));
      }
      billers = bs;
    }
    notifyListeners();
  }

  Future<Biller?> getBillerById(int id) async {
    String path = "billers?id=$id";
    Biller? bi;
    dynamic result = await makeRequest(path: path);
    List<Biller> bs = [];
    if(result != null && result["content"] != null){
      for(Map<String, dynamic> res in result["content"]){
        bs.add(Biller.fromJson(res));
      }
      if(bs.isNotEmpty) bi = bs[0];
    }
    return bi;
  }

  Future<OperatorFx?> getFxRate(int operatorId, double amount) async {
    String path = "billers/fx-rate";
    Map<String, dynamic> data = {
      "amount": amount,
      "billerId": operatorId,
    };
    dynamic result = await makeRequest(path: path, isGet: false, data: data);
    if(result != null){
      return OperatorFx.fromJson(result);
    }else{ return null; }
  }

  Future<void> getUtilizeableCountries() async {
    String path = "countries";
    dynamic result = await makeRequest(path: path);
    if(result != null && result.isNotEmpty){
      for(Map<String, dynamic> res in result){
        utilitizedCountries.add(ReloadlyCountry.fromJson(res));
      }
    }
  }

  ReloadlyCountry? getCountryByIso(String iso){
    if(iso.length == 2 && utilitizedCountries.isNotEmpty){
      return utilitizedCountries.firstWhere((ReloadlyCountry country) => country.isoName == iso);
    }else{
      return null;
    }
  }

  Future<void> getUtilityToken() async {
    reloadlyUtilityToken = await iCloud.getReloadlyToken(utilityApiUrl);
  }

  void setDioHeaders(){
    utilityDio.options.headers.addAll({
      "Content-Type": "application/json",
      "Accept": "application/com.reloadly.utilities-v1+json",
      "Authorization": "$reloadlyUtilityToken"
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
    if(reloadlyUtilityToken == null) await getUtilityToken();
    if(reloadlyUtilityToken != null){
      setDioHeaders();
      String url = "$utilityApiUrl/$path";
      Response res = isGet? (await utilityDio.get(url)) : (await utilityDio.post(url, data: data));
      // debugPrint("Result: $res");
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

  Future<void> saveDeviceNoToCache() async {
    if(deviceNumbers.isNotEmpty){
      List<Map<String, dynamic>> items = deviceNumbers.map((UtilityDevice item) => item.toJson()).toList();
      await myStorage.addToStore(key: "deviceNumbers", value: items);
    }else{
      myStorage.lStore.remove("deviceNumbers");
    }
  }


  void getDeviceNumbersFromCache(){
    dynamic devices = myStorage.getFromStore(key: "deviceNumbers");
    if(devices != null){
      List<dynamic> deviceNos = devices.reversed.toList();
      if(deviceNos.isNotEmpty){
        for (dynamic num in deviceNos) {
          deviceNumbers.add(UtilityDevice.fromJson(num));
        }
      }
    }
  }

  Future<void> addItemToDeviceNumber(UtilityDevice num) async {
    bool exists = checkIfDeviceNumberExistInCache(num);
    if(exists == false) {
      deviceNumbers.add(num);
      await saveDeviceNoToCache();
      notifyListeners();
    }
  }

  bool checkIfDeviceNumberExistInCache(UtilityDevice num){
    bool exists = false;
    exists = deviceNumbers.contains(num);
    return exists;
  }

  Future<void> clearAllSavePaymentDetails() async {
    unsavedUtilityTrans = null;
    unsavedUtilityDetails = null;
    utilityPaymentId = null;
    utilityPaymentMade = false;
    continueTransaction = false;
    myStorage.lStore.remove("unsavedUtilityTrans");
    myStorage.lStore.remove("unsavedUtilityDetails");
    myStorage.lStore.remove("utilityPaymentMade");
    myStorage.lStore.remove("utilityPaymentId");
  }


  Future<void> initUtility() async {
    try{
      await getUtilizeableCountries();
      getDeviceNumbersFromCache();
      getUnsavedUtilityDetailsFromCache();
      getUnsavedTransFromCache();
      getPaymentStatusFromCache();
      getLastSearchFromCache();
      getLastBillerUsedFromCache();
      updateBillersInLastBillersUsed();
      if(unsavedUtilityTrans != null && unsavedUtilityDetails != null) await saveTransactionToCloud(unsavedUtilityDetails!);
      notifyListeners();
    }catch(ex){
      debugPrint("UtilityNotifier_initUtility Error: $ex");
    }
  }

  
  UtilityNotifier._internal();
}

String utilityApiUrl = Constants.apiStatues == 'production'? "https://utilities.reloadly.com" : "https://utilities-sandbox.reloadly.com";
List<ReloadlyCountry> utilitizedCountries = [];
double utilityCustomerDiscountInPercentage = 1/3;
double prudUtilityChargeInPercentage = 0.02;
String? reloadlyUtilityToken;
Dio utilityDio = Dio(BaseOptions(
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
final utilityNotifier = UtilityNotifier();
