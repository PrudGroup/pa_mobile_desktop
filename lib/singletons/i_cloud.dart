import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connection_notifier/connection_notifier.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../components/page_transitions/scale.dart';
import '../constants.dart';
import '../models/shared_classes.dart';
import '../models/spark.dart';
import '../models/spark_cost.dart';
import '../models/user.dart';


enum RegisterState{
  first,
  second,
  third,
  success,
  failed,
}

enum AuthTask{
  login,
  linkTo,
  doAll,
}

enum BoardLoginState{
  existingOperator,
  newOperator,
  newFirm
}

class ICloud extends ChangeNotifier{
  static final ICloud _iCloud = ICloud._internal();
  static get iCloud => _iCloud;
  RegisterState registerState = RegisterState.first;
  String? affAuthToken;
  String mapKey = " ";
  bool serviceEnabled = false;
  bool isRealTimeConnected = false;
  bool clearDigitInput = false;
  String? apiEndPoint;
  List<SparkCost> sparkCosts = [];
  List<Spark> mySparks = isProduction? [] : testSparks;
  List<Spark> sparks = isProduction? [] : testSparks;
  bool showInnerTabsAndMenus = true;


  factory ICloud() {
    return _iCloud;
  }

  Future<bool> checkNetwork() async{
    await ConnectionNotifierTools.initialize();
    if(ConnectionNotifierTools.isConnected) {
      return true;
    } else {
      return false;
    }
  }

  void initRegisterState() async {
    int dState = (await myStorage.getFromStore(key: 'registerState'))?? -1;
    registerState = dState == -1? RegisterState.first : (dState == 3? RegisterState.second : intToRegisterState(state: dState));
    notifyListeners();
  }

  void updateSparkCost(List<SparkCost> costs){
    sparkCosts = costs;
    notifyListeners();
  }

  void updateMySpark(List<Spark> spks){
    mySparks = spks;
    notifyListeners();
  }

  void addToMySpark(Spark spk){
    mySparks.add(spk);
    notifyListeners();
  }

  void updateSparks(List<Spark> spks){
    sparks = spks;
    notifyListeners();
  }

  void addToSparks(Spark spk){
    sparks.add(spk);
    notifyListeners();
  }

  void toggleFooterMenu(){
    showInnerTabsAndMenus = !showInnerTabsAndMenus;
    notifyListeners();
  }

  void changeRegisterState({required RegisterState state}) async{
    registerState = state;
    await myStorage.addToStore(key: 'registerState', value: translateRegisterState(state: state));
    notifyListeners();
  }

  void getRegisterStateFromStore() {
    dynamic rst = myStorage.getFromStore(key: 'registerState')?? 0;
    registerState = intToRegisterState(state: rst);
    notifyListeners();
  }

  int translateRegisterState({required RegisterState state}){
    switch(state){
      case RegisterState.first: return 0;
      case RegisterState.second: return 1;
      case RegisterState.third: return 2;
      case RegisterState.success: return 3;
      default: return 4;
    }
  }

  void scrollTop(ScrollController ctrl) {
    ctrl.animateTo(
      0,
      duration: const Duration(milliseconds: 500), //duration of scroll
      curve:Curves.fastOutSlowIn //scroll type
    );
  }

  RegisterState intToRegisterState({required int state}){
    switch(state){
      case 0: return RegisterState.first;
      case 1: return RegisterState.second;
      case 2: return RegisterState.third;
      case 3: return RegisterState.success;
      default: return RegisterState.failed;
    }
  }

  Future<List<dynamic>> getSparkCost(String url) async {
    try {
      Response res = await prudDio.get(url);
      if (res.statusCode == 200) {
        return [res.data, true];
      } else {
        return [null, false];
      }
    } catch (ex) {
      debugPrint("Dio Error: $ex");
      return [null, false];
    }
  }

  Future<List> logAffiliateIn(String url) async{
    String? storedUser = myStorage.getFromStore(key: "user");
    if(storedUser != null){
      User user = User.fromJson(jsonDecode(storedUser));
      if(user.email != null && user.password != null) {
        try {
          Response res = await prudDio.get(url, queryParameters: {
            "email": user.email,
            "password": user.password,
          });
          if (res.statusCode == 200) {
            return [res.data, true];
          } else {
            return [null, false];
          }
        } catch (ex) {
          return [null, false];
        }
      }else{
        return [null, false];
      }
    }else {
      return [null, false];
    }
  }

  Future<bool> checkIfAffLoggedIn(String url) async {
    bool loggedIn = false;
    if(affAuthToken != null){
      loggedIn = true;
    }else{
      List logged = await logAffiliateIn(url);
      loggedIn = logged[1];
      if(loggedIn){
        affAuthToken = 'Bearer PrudApp ${logged[0]["auth_token"]}';
      }
    }
    prudDio.options.headers.clear();
    prudDio.options.headers.addAll({
      "Authorization": affAuthToken,
      "AppCredential": prudApiKey,
    });
    return loggedIn;
  }

  Future<Response> addAffiliate(String url, User newUser) async => await prudDio.post(url, data: newUser.toJson());

  Future<Response> verifyAffiliateEmail(String url) async => await prudDio.get(url);

  Future<bool> getMessengerPermissions() async{
    bool supported = false;
    try{
      supported = await messenger.isSupported();
      if(supported == false){
        NotificationSettings settings = await messenger.requestPermission(
          announcement: true,
          criticalAlert: true,
          provisional: true,
        );
        if(settings.authorizationStatus == AuthorizationStatus.authorized){
          supported = true;
        }else{
          supported = false;
        }
      }
    }catch(ex){
      debugPrint("Messenger Error: $ex");
    }
    return supported;
  }

  void addPushMessages(RemoteMessage message){
    RemoteNotification? notice;
    Map<String, dynamic> msg = message.data;
    if (message.notification != null) {
      notice = message.notification;
    }
    pushMessages.add(PushMessage(msg, notice));

  }

  Future<FirebaseApp> setFirebase(String apiKey, String appId, String msgID) async {
    FirebaseApp? fireApp;
    if (Platform.isAndroid || Platform.isIOS) {
      fireApp = await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: msgID,
          projectId: 'prudapp',
        ),
      );
    } else {
      fireApp = await Firebase.initializeApp();
    }
    return fireApp;
  }

  void setDioHeaders(){
    prudDio.options.headers.addAll({
      "AppCredential": prudApiKey,
    });
  }

  void showSnackBar(String msg, BuildContext context, {String title = 'Oops!'
    , int type = 0} ){
    ContentType contentType = getType(type);
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: msg,
        messageFontSize: 16.0,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

  }

  ContentType getType(int value){
    switch(value){
      case 0: return ContentType.help;
      case 1: return ContentType.warning;
      case 2: return ContentType.success;
      default: return ContentType.failure;
    }
  }

  void go(BuildContext context, String route, Map<String, dynamic>? qParam){
    GoRouter.of(context).go(Uri(path: route, queryParameters: qParam).toString());
  }

  void goByName(BuildContext context, String routeName, Map<String, String> pParam, Map<String, dynamic>? qParam){
    if(qParam != null){
      context.goNamed(routeName, pathParameters: pParam, queryParameters: qParam);
    }else{
      context.goNamed(routeName, pathParameters: pParam);
    }

  }

  void goto( BuildContext context, Widget where) => Navigator.push(context, ScaleRoute(page: where));

  Future<String?> getReloadlyToken(String audience) async {
    Dio reloadlyDio = Dio();
    reloadlyDio.options.headers.addAll({
      "Accept": "application/json",
      "Content-Type": "application/json"
    });
    String url = "https://auth.reloadly.com/oauth/token";
    Map<String, dynamic> credentials = {
      "client_id": reloadlyKey,
      "client_secret": reloadlySecret,
      "grant_type": "client_credentials",
      "audience": audience
    };
    Response res = await reloadlyDio.post(url, data: credentials);
    if(res.data != null){
      return "${res.data['token_type']} ${res.data['access_token']}";
    }else {
      return null;
    }
  }

  ICloud._internal();
}

const bool isProduction = Constants.envType=="production";
const String prudApiUrl = Constants.prudApiUrl;
const String localApiUrl = Constants.localApiUrl;
const String prudApiKey = Constants.prudApiKey;
const String reloadlyKey = Constants.apiStatues == 'production'? Constants.reloadlyLiveClientId : Constants.reloadlyTestClientId;
const String reloadlySecret = Constants.apiStatues == 'production'? Constants.reloadlyLiveSecretKey : Constants.reloadlyTestSecretKey;
const String apiEndPoint = isProduction? prudApiUrl : localApiUrl;
const String waveApiUrl = "https://api.flutterwave.com/v3";
const double waveVat = 0.07;
const bool paymentIsInTestMode = isProduction? false : true;
List<PushMessage> pushMessages = [];
FirebaseMessaging messenger = FirebaseMessaging.instance;
Dio prudDio = Dio(BaseOptions(validateStatus: (statusCode) {
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
}));

List<Spark> testSparks = [
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Ages Past",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Ages Past Many things fall apart for unbelievers and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "prudapp",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Ages Past",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Ages Past Many things fall apart for unbelievers and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "instagram",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Ages Past",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Ages Past Many things fall apart for unbelievers and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "youtube",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Making Dates In Years",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Ages Past Many things fall apart for unbelievers and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "youtube",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Ages Past",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Ages Past Many things fall apart for unbelievers and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "youtube",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Gaming Upside controls",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Most people think and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "facebook",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Ages Past",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Ages Past Many things fall apart for unbelievers and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "youtube",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Gaming Upside controls",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Most people think and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "facebook",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Gaming Upside controls",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Most people think and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "facebook",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Ages Past",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Ages Past Many things fall apart for unbelievers and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "youtube",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
  Spark(
    id: "5678GETEYWB788OP0",
    affId: "NniMlp8xumSPUSASYjJA",
    title: "Gaming Upside controls",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: "Most people think and things got to be very cool.",
    monthCreated: DateTime.now().month,
    yearCreated: DateTime.now().year,
    duration: 3,
    locationTarget: "town",
    sparkCategory: "facebook",
    sparkType: "all",
    startDate: DateTime.now(),
    targetCities: ["Abuja"],
    targetCountries: ["Nigeria"],
    targetSparks: 30000,
    targetStates: ["Federal Capital Territory"],
    targetTowns: ["Bwari"],
    targetLink: "https://youtu.be/watch",
    status: "Pending",
    sparksCount: 20000,
  ),
];
final iCloud = ICloud();

