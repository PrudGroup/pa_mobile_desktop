
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

class LocalSettings extends ChangeNotifier{

  static final LocalSettings _localSettings = LocalSettings._internal();
  static LocalSettings get localSettings => _localSettings;

  factory LocalSettings() {
    return _localSettings;
  }

  String lastRoute = "/";
  double lastScrollablePoint = 0;
  Map<String, dynamic>? lastRouteData;

  void updateLastRoute(String route){
    lastRoute = route;
    myStorage.addToStore(key: "lastRoute", value: lastRoute);
  }

  void updateLastRouteData(Map<String, dynamic> data){
    lastRouteData = data;
    myStorage.addToStore(key: "lastRouteData", value: lastRouteData);
  }

  void updateScrollablePoint(double point){
    lastScrollablePoint = point;
    myStorage.addToStore(key: "lastScrollablePoint", value: lastScrollablePoint);
  }

  void getLastRouteFromCache() {
    String? lastRouteString = myStorage.getFromStore(key: "lastRoute");
    if(lastRouteString != null ){
      lastRoute = lastRouteString;
    }
  }

  void getLastRouteDataFromCache() {
    Map<String, dynamic>? lastRouteDataString = myStorage.getFromStore(key: "lastRouteData");
    if(lastRouteDataString != null ){
      lastRouteData = lastRouteDataString;
    }
  }

  void getLastScrollablePointFromCache() {
    String? lastScrollablePointString = myStorage.getFromStore(key: "lastScrollablePoint");
    if(lastScrollablePointString != null ){
      lastScrollablePoint = double.parse(lastScrollablePointString);
    }
  }

  Future<void> clearLast() async {
    lastRouteData = null;
    lastScrollablePoint = 0;
    lastRoute = "/";
    await myStorage.lStore.remove("lastRouteData");
    await myStorage.lStore.remove("lastRoute");
    await myStorage.lStore.remove("lastScrollablePoint");
  }
  

  Future<void> init() async {
    await tryAsync("SettingsNotifier.init", () async {
      getLastRouteFromCache();
      getLastRouteDataFromCache();
      getLastScrollablePointFromCache();
    }, error: (){
      lastRouteData = null;
      lastScrollablePoint = 0;
      lastRoute = "/";
    });
  }

  String returnToLastPage(){
    return lastRoute;
  }


  LocalSettings._internal();
}


final localSettings = LocalSettings();