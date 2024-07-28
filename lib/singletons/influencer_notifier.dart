
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/currency_math.dart';

import 'i_cloud.dart';


class InfluencerNotifier extends ChangeNotifier {
  static final InfluencerNotifier _influencerNotifier = InfluencerNotifier._internal();
  static get influencerNotifier => _influencerNotifier;

  factory InfluencerNotifier(){
    return _influencerNotifier;
  }

  double? referralPercentage;


  void setDioHeaders(){
    influencerDio.options.headers.addAll({
      "Content-Type": "application/json",
      "AppCredential": prudApiKey,
      "Authorization": iCloud.affAuthToken
    });
  }

  Future<void> getReferralPercentage() async{
    try{
      String path = "/";
      dynamic res = await makeRequest(path: path);
    }catch(ex){
      debugPrint("InfluencerNotifier_getReferralPercentage Error: $ex");
    }
  }

  Future<dynamic> makeRequest({required String path, bool isGet = true, Map<String, dynamic>? data}) async {
    currencyMath.loginAutomatically();
    if(iCloud.affAuthToken != null){
      setDioHeaders();
      String url = "$prudApiUrl/$path";
      Response res = isGet? (await influencerDio.get(url)) : (await influencerDio.post(url, data: data));
      debugPrint("Result: $res");
      return res.data;
    }else{
      return null;
    }
  }

  Future<void> initInfluencer() async {
    try{
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
