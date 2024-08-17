
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/bus_models.dart';
import 'currency_math.dart';

class BusNotifier extends ChangeNotifier {
  static final BusNotifier _busNotifier = BusNotifier._internal();
  static get busNotifier => _busNotifier;

  factory BusNotifier(){
    return _busNotifier;
  }

  BusBrand? busBrand;
  String? busBrandId;
  String? busOperatorId;
  String? busDriverId;
  bool isActive = false;
  String? busBrandRole;
  BusBrandOperator? selectedOperator;
  List<String> roles = ["ADMIN", "DRIVER", "SUPER"];
  List<BusBrandOperator> operators = [];
  List<BusBrandDriver> drivers = [];

  void updateSelectedOperator(BusBrandOperator op){
    selectedOperator = op;
    notifyListeners();
  }


  void getDefaultSettings(){
    busOperatorId = myStorage.getFromStore(key: "busOperatorId");
    busDriverId = myStorage.getFromStore(key: "busDriverId");
    busBrandId = myStorage.getFromStore(key: "busBrandId");
    isActive = myStorage.getFromStore(key: "isActive")?? false;
    busBrandRole = myStorage.getFromStore(key: "busBrandRole");
  }

  Future<void> saveDefaultSettings() async {
    if(busOperatorId != null) await myStorage.addToStore(key: "busOperatorId", value: busOperatorId);
    if(busDriverId != null) await myStorage.addToStore(key: "busDriverId", value: busDriverId);
    if(busBrandId != null) await myStorage.addToStore(key: "busBrandId", value: busBrandId);
    await myStorage.addToStore(key: "isActive", value: isActive);
    if(busBrandRole != null) await myStorage.addToStore(key: "busBrandRole", value: busBrandRole);
  }

  Future<BusBrandOperator?> createNewOperator(BusBrandOperator opr) async {
    String path = "operators/";
    dynamic res = await makeRequest(path: path, method: 1, data: opr.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        BusBrandOperator opr = BusBrandOperator.fromJson(res);
        return opr;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<BusBrandOperator?> getOperatorByAffId(String affId) async {
    String path = "operators/aff/$affId";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res["id"] != null){
        BusBrandOperator opr = BusBrandOperator.fromJson(res);
        return opr;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<BusBrandOperator?> getOperatorById(String id) async {
    String path = "operators/$id";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res["id"] != null){
        BusBrandOperator opr = BusBrandOperator.fromJson(res);
        return opr;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<bool> createNewBrand(BusBrand brand) async {
    String path = "";
    dynamic res = await makeRequest(path: path, method: 1, data: brand.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        busBrand = BusBrand.fromJson(res);
        if(busBrand != null && busBrand!.id != null) busBrandId = busBrand!.id;
        await saveDefaultSettings();
        notifyListeners();
        return true;
      }else{
        return false;
      }
    }else{
      return false;
    }
  }

  Future<String?> sendCode(String email, String code) async {
    String path = "send_code";
    dynamic res = await makeRequest(path: path,data: {
      "email": email,
      "code": code,
    });
    if(res != null && res != false){
      return res;
    }else{
      return null;
    }
  }

  Future<bool> updateEmailVerification(String brandId, String email) async {
    String path = "$brandId/email/verify";
    dynamic res = await makeRequest(path: path);
    if(res == true){
      return true;
    }else{
      return false;
    }
  }

  Future<BusBrand?> getBusBrandById(String id) async {
    String path = id;
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      dynamic brand = res;
      if(brand["id"] == id){
        busBrand = BusBrand.fromJson(brand);
        notifyListeners();
        return busBrand;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  void setDioHeaders(){
    busDio.options.headers.addAll({
      "Content-Type": "application/json",
      "AppCredential": prudApiKey,
      "Authorization": iCloud.affAuthToken
    });
  }

  // method: 0 = GET, 1 = POST, 2 = PUT, 3 = DELETE
  Future<dynamic> makeRequest({required String path, int method = 0, Map<String, dynamic>? data}) async {
    currencyMath.loginAutomatically();
    if(iCloud.affAuthToken != null){
      setDioHeaders();
      String url = "$prudApiUrl/bus_brands/$path";
      Response? res;
      switch(method){
        case 1: res = await busDio.post(url, data: data);
        case 2: res = await busDio.put(url, data: data);
        case 3: res = await busDio.delete(url);
        default: res = await busDio.get(url, queryParameters: data);
      }
      debugPrint("Bus Request: $res");
      if(res.data != null){
        return res.data;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<void> clearDefaultSettings() async {
    busBrandId = null;
    busBrand = null;
    busBrandRole = null;
    busOperatorId = null;
    isActive = false;
    await saveDefaultSettings();
  }

  Future<void> initBus() async {
    await tryAsync("initBus", () async {
      getDefaultSettings();
      notifyListeners();
    });
  }

  BusNotifier._internal();
}

double customerDiscountInPercentage = 0.02;
double influencerCommissionInPercentage = 0.025;
Dio busDio = Dio(BaseOptions(
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
final busNotifier = BusNotifier();
