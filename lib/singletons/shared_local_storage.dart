import 'dart:convert';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prudapp/models/theme.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:translator/translator.dart';
import 'package:timeago/timeago.dart' as time_ago;
import 'package:get_storage/get_storage.dart';

import '../models/user.dart';



class MyStorage extends ChangeNotifier {
  static final MyStorage _myStorage = MyStorage._internal();
  static get myStorage => _myStorage;

  GetStorage lStore = GetStorage();
  bool hasInitialized = false;
  User? user;
  var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: true,
      isOverlayTapDismiss: true,
      descStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 13.0,
          fontFamily: "Lato-Italic",
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w400
      ),
      descTextAlign: TextAlign.center,
      animationDuration: const Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: const BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: const TextStyle(
        color: Colors.black,
        fontSize: 16.0
      ),
      alertAlignment: Alignment.topCenter,
      backgroundColor: Colors.white,
      overlayColor: Colors.black45,
      alertElevation: 0.0
  );

  factory MyStorage() {
    return _myStorage;
  }

  Future<void> initializeValues() async {
    try{
      var storedUser = myStorage.getFromStore(key: 'user');
      user = storedUser == null? null : User.fromJson(jsonDecode(storedUser));
      hasInitialized = true;
      notifyListeners();
    }catch (ex) {
      debugPrint("ErrorHandler: SharedLocalStorage: initializeValues(): $ex");
    }
  }

  Future<void> addToStore({required String key, required dynamic value}) async {
    try{
      await lStore.write(key, value);
    }catch (ex) {
      debugPrint(ex.toString());
    }
  }

  dynamic getFromStore({required String key}) {
    dynamic result;
    try{
      result = lStore.read(key);
    }catch (ex) {
      debugPrint(ex.toString());
    }
    return result;
  }

  // inWhat: 0 -seconds, 1 -minutes, 2 -hour, 3 -days
  int dateDifference({required DateTime dDate, int inWhat = 3}){
    final today = DateTime.now();
    int diff = inWhat == 0? dDate.difference(today).inSeconds : (
        inWhat == 1? dDate.difference(today).inMinutes : (
            inWhat == 2?  dDate.difference(today).inHours : dDate.difference(today).inDays
        )
    );
    return diff;
  }

  String ago({bool isShort= true, required DateTime dDate}){
    return isShort? time_ago.format(dDate, locale: 'en_short') : time_ago.format(dDate);
  }

  Future<String> translate({required String text, String fromLocaleCode= 'en'}) async{
    final translator = GoogleTranslator();
    final String lang = myStorage.user !=null && myStorage.user.locale != null? myStorage.user.locale : "en";
    String translation = (await translator.translate(text,from: fromLocaleCode, to: lang)) as String;
    return translation;
  }

  void setWindowSize({required Size size}){
    if(UniversalPlatform.isAndroid || UniversalPlatform.isIOS){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp
      ]);
    } else {
      DesktopWindow.setWindowSize(size);
      DesktopWindow.setMinWindowSize(size);
      DesktopWindow.setMaxWindowSize(size);
    }
  }

  MyStorage._internal();
}

final myStorage = MyStorage();

bool isPhone() => UniversalPlatform.isIOS || UniversalPlatform.isAndroid? true : false;
ThemeData prudTheme = ThemeData(
  primarySwatch: Colors.red,
  brightness: Brightness.light,
  primaryColor: prudColorTheme.primary,
  disabledColor: prudColorTheme.bgA,
  indicatorColor: Colors.black,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.windows: ZoomPageTransitionsBuilder(),
    },
  ),
  hintColor: const Color(0xffd0782f),
  colorScheme: ColorScheme(
    primary: prudColorTheme.primary,
    primaryContainer: prudColorTheme.lineA,
    secondary: prudColorTheme.secondary,
    secondaryContainer: Colors.green,
    background: prudColorTheme.bgB,
    error: prudColorTheme.error,
    onBackground: Colors.black,
    onError: prudColorTheme.danger,
    onPrimary: prudColorTheme.bgC,
    onSecondary: prudColorTheme.bgA,
    onSurface:prudColorTheme.textA,
    surface: prudColorTheme.buttonC,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: prudColorTheme.bgA,
  appBarTheme: AppBarTheme(
    backgroundColor: prudColorTheme.primary,
    elevation: 0.0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: prudColorTheme.primary,
  ),
  unselectedWidgetColor: const Color(0xffffe3b3),
  highlightColor: Colors.white38,
  fontFamily: 'Revans',
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: prudColorTheme.bgA,
    modalBackgroundColor: prudColorTheme.bgA,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: prudColorTheme.iconB,
      foregroundColor: prudColorTheme.bgD,
      focusColor:prudColorTheme.iconB.withOpacity(0.5)
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: false,
    fillColor: prudColorTheme.bgA
  ),
  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
        fontSize: 42.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87
    ),
    titleLarge: TextStyle(
        fontSize: 16.0,
        fontFamily: "OpenSans-Bold",
        color: Colors.black87
    ),
    headlineMedium: TextStyle(
      fontSize: 17.0,
      fontFamily: 'Oswald-Regular',
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      fontSize: 16.0,
      fontFamily: 'OpenSans-Regular',
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      fontSize: 15.0,
      fontFamily: 'Champagne-Bold',
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    displayLarge: TextStyle(
      fontSize: 14.0,
      fontFamily: 'Champagne',
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
        fontSize: 16.0,
        fontFamily: 'Autobus',
        color: Colors.black87,
        fontWeight: FontWeight.normal
    ),
  ),
);
