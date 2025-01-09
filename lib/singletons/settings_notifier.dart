
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../pages/prudVid/thrillers.dart';

class LocalSettings extends ChangeNotifier{

  static final LocalSettings _localSettings = LocalSettings._internal();
  static get localSettings => _localSettings;

  factory LocalSettings() {
    return _localSettings;
  }

  Widget lastScreen = const Thrillers(tab: 0,);

  void updateLastScreen(Widget widget){
    lastScreen = widget;
    myStorage.addToStore(key: "lastScreen", value: lastScreen.toString());
  }


  LocalSettings._internal();
}


final localSettings = LocalSettings();