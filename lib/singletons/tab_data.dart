
import 'dart:async';
import 'dart:math';

import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

class TabData extends ChangeNotifier {
  static final TabData _tabData = TabData._internal();
  static get tabData => _tabData;

  int totalItemInCart = 0;
  double newVote = 0.0;
  dynamic selectedUser;
  List<String> votedFeatures = [];
  final TextStyle titleStyle = TextStyle(
    fontFamily: "Qhinanttika",
    fontWeight: FontWeight.w500,
    fontSize: 26,
    color: Colors.white,
    decoration: TextDecoration.none,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.2),
        offset: const Offset(0.5, 0.5),
        blurRadius: 0.3,
      ),
    ],
  ), tabStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "Lato-Italic",
    decoration: TextDecoration.none,
  ), nStyle = const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: Colors.black
  ), pStyle = const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Colors.black87,
      fontFamily: "Lato-Italic"
  ),bStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16.0,
    fontFamily: "Lato-Italic",
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  ), npStyle = const TextStyle(
    color: Colors.black87,
    fontSize: 16.0,
    decoration: TextDecoration.none,
  ), eStyle = TextStyle(
    color: Colors.white,
    fontSize: 20.0,
    decoration: TextDecoration.none,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.2),
        offset: const Offset(0.5, 0.5),
        blurRadius: 0.5,
      ),
    ],
  ), cStyle = const TextStyle(
      fontWeight: FontWeight.w400,
      color: Colors.black,
      fontSize: 20.0,
      decoration: TextDecoration.none,
      fontFamily: "OpenSans-SemiBold"
  ), nRStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontFamily: "Lato-Italic",
    fontWeight: FontWeight.w300,
    decoration: TextDecoration.none,
  ), errStyle = const TextStyle(
    color: Colors.red,
    fontSize: 16.0,
    fontFamily: "Lato-Italic",
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  ), tNStyle = const TextStyle(
    color: Colors.black,
    overflow: TextOverflow.clip,
    fontSize: 15.0,
    fontFamily: "Oswald-Regular",
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  ), tTStyle = const TextStyle(
    color: Colors.black,
    fontSize: 10.0,
    fontFamily: "OpenSans-SemiBold",
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.none,
    overflow: TextOverflow.clip
  ), tBStyle = TextStyle(
    color: prudTheme.primaryColor,
    fontSize: 30.0,
    fontFamily: "Tamil Sangam MN",
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.none,
  ), tDStyle = const TextStyle(
    color: Colors.pink,
    fontSize: 11.0,
    overflow: TextOverflow.clip,
    fontFamily: "Damascus",
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  ), tEStyle = const TextStyle(
    color: Color(0xff000000),
    fontSize: 11.0,
    overflow: TextOverflow.clip,
    fontFamily: "OpenSans-Regular",
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  ), toastStyle = TextStyle(
    color: prudTheme.colorScheme.onSurface,
    fontSize: 14.0,
    overflow: TextOverflow.clip,
    fontFamily: "Lato-Italic",
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  ), lStyle = TextStyle(
    color: prudTheme.cardColor,
    fontSize: 30.0,
    overflow: TextOverflow.clip,
    fontFamily: "Oswald-Regular",
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  ), fieldStyle = const TextStyle(
    color: Color(0xff474747),
    fontSize: 12.0,
    overflow: TextOverflow.clip,
    fontFamily: "OpenSans-Regular",
    fontWeight: FontWeight.w300,
    decoration: TextDecoration.none,
  ), sanBoldStyle = const TextStyle(
    color: Color(0xff474747),
    fontSize: 14.0,
    overflow: TextOverflow.clip,
    fontFamily: "OpenSans-SemiBold",
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.none,
  );


  factory TabData() {
    return _tabData;
  }

  String toTitleCase(String str) {
    return str
        .replaceAllMapped(
        RegExp(
            r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
            (Match m) =>
        "${m[0]?[0].toUpperCase()}${m[0]?.substring(1).toLowerCase()}")
        .replaceAll(RegExp(r'(_|-)+'), ' ');
  }

  dynamic getCountryFlag(String countryCode){
    Country? cty = CountryService().findByCode(countryCode);
    if(cty != null){
      return cty.flagEmoji;
    }else {
      return null;
    }
  }

  Duration parseDurationFromDouble(double hours) {
    return Duration(
      seconds: (hours * Duration.secondsPerHour).toInt()
    );
  }

  int getTimestampFromDate(DateTime dDate){
    String dRealDate = DateFormat('yyyy-MM-dd').format(dDate.toLocal());
    return (DateTime.parse(dRealDate)).microsecondsSinceEpoch;
  }

  String getRateInterpretation(double rate){
    if(rate < 1){
      return "Unrated";
    }else if(rate >= 1 && rate <= 1.49){
      return "Worst";
    }else if(rate >= 1.5 && rate <= 1.99){
      return "Very Bad";
    }else if(rate >= 2 && rate <= 2.49){
      return "Bad";
    }else if(rate >= 2.5 && rate <= 2.99){
      return "Fair";
    }else if(rate >= 3 && rate <= 3.49){
      return "Good";
    }else if(rate >= 3.5 && rate <= 3.99){
      return "Very Good";
    }else if(rate >= 4 && rate <= 4.49){
      return "Excellent";
    }else{
      return "Cloud 9";
    }
  }

  bool checkIfForeign(String currencyCode) => currencyCode != myStorage.user!.currencyCode;

  dynamic getCurrencySymbol(String curCode){
    Currency? cur = CurrencyService().findByCode(curCode);
    if(cur != null){
      return cur.symbol;
    }else {
      return null;
    }
  }

  String? getCurrencyName(String curCode){
    Currency? cur = CurrencyService().findByCode(curCode);
    if(cur != null){
      return cur.name;
    }else {
      return null;
    }
  }

  Country? getCountry(String curCode) => CountryService().findByCode(curCode);

  String? getCountryName(String curCode){
    Country? cur = CountryService().findByCode(curCode);
    if(cur != null){
      return cur.name;
    }else {
      return null;
    }
  }

  dynamic getCurrency(String curCode) => CurrencyService().findByCode(curCode);

  getFormattedNumber(dynamic nu){
    return NumberFormat.compactCurrency(decimalDigits: 0, symbol: '').format(nu);
  }

  String getRandomString(int length){
    String chars = "0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz";
    chars = shuffle(chars);
    String result = ""; final random = Random();
    for(int i=1; i<=length; i++){
      result+=chars[random.nextInt(chars.length)];
    }
    return result;
  }

  String getRandomDigitString(int length){
    if(length > 30) return "";
    String chars = "0123456789012345678901234567899876543210";
    chars = shuffle(chars);
    String result = ""; final random = Random();
    for(int i=1; i<=length; i++){
      result+=chars[random.nextInt(chars.length)];
    }
    return result;
  }

  String shuffle(String str) {
    List arr = str.split('');
    arr.shuffle();
    return arr.join();
  }

  Widget getNotFoundWidget({required String title, required String desc, bool isRow = false}){
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: isRow? 
        Row(
          children: [
            Image.asset(
              prudImages.prudIcon,
              width: 50,
              fit: BoxFit.contain,
            ),
            spacer.width,
            Expanded(
              child:SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Translate(
                      text: title,
                      style: tabData.cStyle.copyWith(color: Colors.black87, fontSize: 16.0),
                      align: TextAlign.left,
                    ),
                    Translate(
                      text: desc,
                      style: tabData.nRStyle.copyWith(color: Colors.black45, fontSize: 14.0),
                      align: TextAlign.left,
                    ),
                  ],
                )
              ),
            ),
          ],
        ) 
        : 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              prudImages.prudIcon,
              width: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20,),
            Translate(
              text: title,
              style: tabData.cStyle.copyWith(color: Colors.black45),
              align: TextAlign.center,
            ),
            const SizedBox(height: 2,),
            Container(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Translate(
                text: desc,
                style: tabData.nRStyle.copyWith(color: Colors.black45),
                align: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  String toTitleCaseWithoutSpace(String str) {
    return str.replaceAllMapped(
        RegExp(r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
        (Match m) => "${m[0]?[0].toUpperCase()}${m[0]?.substring(1).toLowerCase()}"
    ).replaceAll(RegExp(r'(_|-|" ")+'), '');
  }

  String removeSpace(String txt){
    return txt.replaceAll(RegExp(r'(_|-|" ")+'), '');
  }

  String shortenStringWithPeriod(String str, {int length = 30, bool makeTitleCased = true}){
    String newStr = makeTitleCased? toTitleCase(str) : str;
    return newStr.length > length? '${newStr.substring(0,length)}...': newStr;
  }

  int countWordsInString(String text){
    var regExp = RegExp(r"[\w-]+");
    return regExp.allMatches(text).length;
  }

  String encryptString(String str) => encrypter.encrypt(str, iv: enIV).base64;

  String decryptString(String str) => encrypter.decrypt64(str, iv: enIV);

  bool isBase64(str) {
    RegExp regExp = RegExp(
      r"^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$",
      caseSensitive: false,
      multiLine: false,
    );
    return regExp.hasMatch(str);
  }

  Color getTransactionStatusColor(String status){
    switch(status.toUpperCase()){
      case "SUCCESSFUL": return prudColorTheme.success;
      case "PENDING": return prudColorTheme.lineA;
      case "PROCESSING": return prudColorTheme.iconB;
      case "REFUNDED": return prudColorTheme.iconA;
      default: return prudColorTheme.primary;
    }
  }

  TabData._internal();
}

final enKey = en.Key.fromLength(32);
final enIV = en.IV.fromLength(8);
final encrypter = en.Encrypter(en.Salsa20(enKey));
final tabData = TabData();

Future<dynamic> tryAsync(String name, FutureOr<dynamic> Function() body, {Function()? error, Function()? done}) async {
  try {
    return await body();
  } catch (ex) {
    if(error != null) error();
    debugPrint("$name Error: $ex");
  } finally {
    if(done != null) done();
  }
}

dynamic tryOnly(String name, dynamic Function() body, {Function()? error, Function()? done}) async {
  try {
    return body();
  } catch (ex) {
    if(error != null) error();
    debugPrint("$name Error: $ex");
  } finally {
    if(done != null) done();
  }
}