import 'dart:async';

import 'package:connection_notifier/connection_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/components/page_transitions/size.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../models/shared_classes.dart';

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
  bool loggedIn = true;
  String mapKey = " ";
  bool serviceEnabled = false;
  bool isRealTimeConnected = false;
  bool clearDigitInput = false;


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

  changeRegisterState({required RegisterState state}) async{
    registerState = state;
    await myStorage.addToStore(key: 'registerState', value: translateRegisterState(state: state));
    notifyListeners();
  }

  int translateRegisterState({required RegisterState state}){
    switch(state){
      case RegisterState.first: return 0;
      case RegisterState.second: return 1;
      case RegisterState.success: return 2;
      default: return 3;
    }
  }

  RegisterState intToRegisterState({required int state}){
    switch(state){
      case 0: return RegisterState.first;
      case 1: return RegisterState.second;
      case 2: return RegisterState.success;
      default: return RegisterState.failed;
    }
  }

  checkIfLoggedIn() {

  }

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

  Future<FirebaseApp> setFirebase() async {
    FirebaseApp fireApp = await Firebase.initializeApp();
    // await auth.useAuthEmulator('localhost', 9099);
    return fireApp;
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

  void goto( BuildContext context, Widget where) => Navigator.push(context, SizeRoute(page: where));

  ICloud._internal();
}

const bool useRestApiEnvironment = false;
bool isLoggedIn = false;
List<PushMessage> pushMessages = [];
FirebaseMessaging messenger = FirebaseMessaging.instance;
final iCloud = ICloud();
