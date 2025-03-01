import 'dart:convert';

import 'package:desktop_window/desktop_window.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/currency_math.dart';
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
  String networkImageLocation = "";
  bool hasInitialized = false;
  User? user;
  List<XFile> lostImageData = [];
  List<String> convertibleCurrencies = [];
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
      alertAlignment: Alignment.center,
      backgroundColor: Colors.white,
      overlayColor: Colors.black45,
      alertElevation: 0.0
  );
  String? installReferralCode;
  String? generalReferral;


  factory MyStorage() {
    return _myStorage;
  }

  Future<void> getLostImageData() async {
    final ImagePicker picker = ImagePicker();
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    final List<XFile>? files = response.files;
    if (files != null) {
      lostImageData = files;
    } else {
      debugPrint("LostImageData Error: ${response.exception}");
    }
  }

  Future<void> setConvertibleCurrencies() async {
    List<String>? curs = getFromStore(key: "convertibleCurrencies");
    if(curs != null){
      convertibleCurrencies = curs;
    }else{
      convertibleCurrencies = await currencyMath.getAvailableCurrencies();
    }
  }

  saveThrillerReferral(String tid, String linkId){
    Future.delayed(Duration.zero, () async {
      String key = "thriller_${tid}_referral";
      await addToStore(key: key, value: linkId);
    });
  }

  saveAdsReferral(String adsId, String linkId){
    Future.delayed(Duration.zero, () async {
      String key = "ads_${adsId}_referral";
      await addToStore(key: key, value: linkId);
    });
  }

  saveVideoReferral(String vid, String linkId){
    Future.delayed(Duration.zero, () async {
      String key = "video_${vid}_referral";
      await addToStore(key: key, value: linkId);
    });
  }

  saveChannelReferral(String cid, String linkId){
    Future.delayed(Duration.zero, () async {
      String key = "channel_${cid}_referral";
      await addToStore(key: key, value: linkId);
    });
  }

  saveGeneralReferral(String linkId){
    Future.delayed(Duration.zero, () async {
      String key = "general_referral";
      await addToStore(key: key, value: linkId);
    });
  }

  saveStreamReferral(String sid, String linkId){
    Future.delayed(Duration.zero, () async {
      String key = "stream_${sid}_referral";
      await addToStore(key: key, value: linkId);
    });
  }

  saveAppInstallReferral(String code){
    Future.delayed(Duration.zero, () async {
      String key = "install_referral_code";
      await addToStore(key: key, value: code);
    });
  }

  String? getGeneralReferral() => getFromStore(key: "general_referral");
  
  String? getThrillerReferral(String tid) => getFromStore(key: "thriller_${tid}_referral");

  String? getVideoReferral(String vid) => getFromStore(key: "video_${vid}_referral");

  String? getChannelReferral(String cid) => getFromStore(key: "channel_${cid}_referral");

  String? getAdsReferral(String adsId) => getFromStore(key: "ads_${adsId}_referral");

  String? getStreamReferral(String sid) => getFromStore(key: "stream_${sid}_referral");

  String? getAppInstallReferralCode() => getFromStore(key: "install_referral_code");

  Future<void> initializeValues() async {
    try{
      networkImageLocation = (await getApplicationDocumentsDirectory()).path;
      await FastCachedImageConfig.init(subDir: networkImageLocation, clearCacheAfter: const Duration(days: 10));
      var storedUser = myStorage.getFromStore(key: 'user');
      user = storedUser == null? null : User.fromJson(jsonDecode(storedUser));
      await setConvertibleCurrencies();
      await getLostImageData();
      hasInitialized = true;
      installReferralCode = getAppInstallReferralCode();
      generalReferral = getGeneralReferral();
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
    int diff = inWhat == 0? today.difference(dDate).inSeconds : (
        inWhat == 1? today.difference(dDate).inMinutes : (
            inWhat == 2?  today.difference(dDate).inHours : today.difference(dDate).inDays
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
    error: prudColorTheme.error,
    onError: prudColorTheme.danger,
    onPrimary: prudColorTheme.bgC,
    onSecondary: prudColorTheme.bgA,
    onSurface:prudColorTheme.textA,
    surface: prudColorTheme.bgB,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: prudColorTheme.bgA,
  appBarTheme: AppBarTheme(
    backgroundColor: prudColorTheme.primary,
    elevation: 0.0,
  ),
  tabBarTheme: const TabBarTheme(
    splashFactory: NoSplash.splashFactory,
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
      focusColor:prudColorTheme.iconB.withValues(alpha: 0.5)
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
