import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';

import '../components/translate.dart';

class ColorTheme {
  final Color primary;
  final Color secondary;
  final Color bgA;
  final Color bgB;
  final Color bgC;
  final Color bgD;
  final Color bgE;
  final Color textA;
  final Color textB;
  final Color textC;
  final Color textHeader;
  final Color iconA;
  final Color iconB;
  final Color iconC;
  final Color iconD;
  final Color lineA;
  final Color lineB;
  final Color lineC;
  final Color buttonA;
  final Color buttonB;
  final Color buttonC;
  final Color buttonD;
  final Color danger;
  final Color warning;
  final Color success;
  final Color error;

  const ColorTheme({
    required this.primary,
    required this.secondary,
    required this.bgA,
    required this.bgB,
    required this.bgC,
    required this.bgD,
    required this.bgE,
    required this.textA,
    required this.textB,
    required this.textC,
    required this.textHeader,
    required this.iconA,
    required this.iconB,
    required this.iconC,
    required this.iconD,
    required this.lineA,
    required this.lineB,
    required this.lineC,
    required this.buttonA,
    required this.buttonB,
    required this.buttonC,
    required this.buttonD,
    required this.danger,
    required this.warning,
    required this.success,
    required this.error,
  });

}

class WidgetStyle{
  final OutlineInputBorder enabledBorder;
  final OutlineInputBorder focusedBorder;
  final TextStyle hintStyle;
  final TextStyle typedTextStyle;
  final TextStyle logoStyle;
  final TextStyle tabTextStyle;
  final EdgeInsetsGeometry textPadding;
  late InputDecoration inputDeco;
  late InputDecoration digitInputDeco;
  double elevation = 0.0;
  double btnSize = 50.0;
  TextStyle btnTextStyle = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 18,
    fontFamily: "Oswald-Regular",
    color: pagadoColorScheme.textA
  ),
  centeredTitleStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 24,
    fontFamily: "Lato-Italic",
    color: pagadoColorScheme.textC
  );

  WidgetStyle({
    required this.enabledBorder,
    required this.focusedBorder,
    required this.textPadding,
    required this.hintStyle,
    required this.typedTextStyle,
    required this.logoStyle,
    required this.tabTextStyle,
  }){
    inputDeco = InputDecoration(
      filled: true,
      fillColor: pagadoColorScheme.bgA,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      border: enabledBorder,
      hintStyle: hintStyle,
      contentPadding: textPadding,
    );

    digitInputDeco = InputDecoration(
      filled: true,
      fillColor: pagadoColorScheme.bgA,
      enabledBorder: enabledBorder.copyWith(
          borderRadius: BorderRadius.circular(10.0)
      ),
      focusedBorder: focusedBorder.copyWith(
          borderRadius: BorderRadius.circular(10.0)
      ),
      counter: const SizedBox(),
      contentPadding: EdgeInsets.zero,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: pagadoColorScheme.lineC),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget getLongButton({required Function onPressed, required String text, bool makeLight = false}){
    Color btnColor = makeLight? pagadoColorScheme.buttonD : pagadoColorScheme.secondary;
    Color lightColor = btnColor.withOpacity(0.7);
    Color textColor = makeLight? pagadoColorScheme.secondary : pagadoColorScheme.textC;
    return GFButton(
      onPressed: () => onPressed(),
      shape: GFButtonShape.pills,
      size: btnSize,
      color: btnColor,
      blockButton: true,
      fullWidthButton: true,
      splashColor: lightColor,
      highlightColor: lightColor,
      hoverColor: lightColor,
      hoverElevation: elevation,
      elevation: elevation,
      highlightElevation: elevation,
      textStyle: btnTextStyle.copyWith(color: textColor),
      text: text,
    );
  }

  Widget getShortButton({required Function onPressed, required String text, bool makeLight = false}){
    Color btnColor = makeLight? pagadoColorScheme.buttonD : pagadoColorScheme.secondary;
    Color lightColor = btnColor.withOpacity(0.7);
    Color textColor = makeLight? pagadoColorScheme.secondary : pagadoColorScheme.textC;
    return GFButton(
      onPressed: () => onPressed(),
      shape: GFButtonShape.pills,
      size: btnSize,
      padding: const EdgeInsets.only(left: 25, right: 25),
      color: btnColor,
      splashColor: lightColor,
      highlightColor: lightColor,
      hoverColor: lightColor,
      hoverElevation: elevation,
      elevation: elevation,
      highlightElevation: elevation,
      textStyle: btnTextStyle.copyWith(color: textColor),
      text: text,
    );
  }
}

Widget getTextButton({required String title, required Function onPressed, Color color = const Color(0xff000000)}){
  return TextButton(
    onPressed: () => onPressed(),
    child: Translate(
      text: title,
      align: TextAlign.center,
      style: pagadoWidgetStyle.tabTextStyle.copyWith(
        color: color,
        fontSize: 14.0
      ),
    )
  );
}

ColorTheme pagadoColorScheme = const ColorTheme(
    primary: Color(0xffff6302),
    secondary: Color(0xff127d0c),
    bgA: Color(0xffFFFFFF),
    bgB: Colors.green,
    bgC: Color(0xff222222),
    bgD: Color(0xff1377AE),
    bgE: Colors.transparent,
    textA: Color(0xff292929),
    textB: Color(0xff595757),
    textC: Color(0xffFFFFFF),
    textHeader: Color(0xffFEBF60),
    iconA: Color(0xff38106A),
    iconB: Color(0xffCE1567),
    iconC: Color(0xff82858A),
    iconD: Color(0xffFFFFFF),
    lineA: Color(0xffd0782f),
    lineB: Color(0xffC3C8D2),
    lineC: Colors.black12,
    buttonA: Color(0xff1377AE),
    buttonB: Color(0xff32B6E9),
    buttonC: Colors.orange,
    buttonD: Color(0xffffe3b3),
    danger: Color(0xffED5050),
    warning: Color(0xffFF8C00),
    success: Color(0xff219653),
    error: Color(0xffED1111)
);
WidgetStyle pagadoWidgetStyle = WidgetStyle(
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: pagadoColorScheme.lineC),
    borderRadius: const BorderRadius.all(Radius.circular(25.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: pagadoColorScheme.lineB),
    borderRadius: const BorderRadius.all(Radius.circular(25.0)),
  ),
  textPadding: const EdgeInsets.only(left: 16, right: 20, top: 8, bottom: 8,),
  hintStyle: TextStyle(
    color: pagadoColorScheme.textB,
    fontFamily: "Lato-Italic",
    fontSize: 18,
    fontWeight: FontWeight.w500,
  ),
  typedTextStyle: TextStyle(
    decoration: TextDecoration.none,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: pagadoColorScheme.textA
  ),
  logoStyle: TextStyle(
    fontFamily: "Qhinanttika",
    fontWeight: FontWeight.w600,
    fontSize: 30,
    color: pagadoColorScheme.secondary,
    decoration: TextDecoration.none,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.2),
        offset: const Offset(0.5, 0.5),
        blurRadius: 0.3,
      ),
    ],
  ),
  tabTextStyle: const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: "Lato-Italic",
    decoration: TextDecoration.none,
  ),
);
