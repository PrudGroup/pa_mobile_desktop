import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:prudapp/models/shared_classes.dart';

import '../components/translate_text.dart';
import '../singletons/tab_data.dart';

class ColorTheme {
  final Color primary;
  final Color secondary;
  final Color bgA;
  final Color bgB;
  final Color bgC;
  final Color bgD;
  final Color bgE;
  final Color bgF;
  final Color textA;
  final Color textB;
  final Color textC;
  final Color textD;
  final Color textHeader;
  final Color iconA;
  final Color iconB;
  final Color iconC;
  final Color iconD;
  final Color lineA;
  final Color lineB;
  final Color lineC;
  final Color lineD;
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
    required this.bgF,
    required this.textA,
    required this.textB,
    required this.textC,
    required this.textD,
    required this.textHeader,
    required this.iconA,
    required this.iconB,
    required this.iconC,
    required this.iconD,
    required this.lineA,
    required this.lineB,
    required this.lineC,
    required this.lineD,
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
  final OutlinedBorder choiceChipShape;
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
    color: prudColorTheme.textA
  ),
  centeredTitleStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 24,
    fontFamily: "Lato-Italic",
    color: prudColorTheme.textC
  );

  WidgetStyle({
    required this.enabledBorder,
    required this.focusedBorder,
    required this.textPadding,
    required this.hintStyle,
    required this.typedTextStyle,
    required this.logoStyle,
    required this.tabTextStyle,
    required this.choiceChipShape,
  }){
    inputDeco = InputDecoration(
      filled: true,
      fillColor: prudColorTheme.bgA,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      border: enabledBorder,
      hintStyle: hintStyle,
      contentPadding: textPadding,
    );

    digitInputDeco = InputDecoration(
      filled: true,
      fillColor: prudColorTheme.bgA,
      enabledBorder: enabledBorder.copyWith(
          borderRadius: BorderRadius.circular(6.0)
      ),
      focusedBorder: focusedBorder.copyWith(
        borderRadius: BorderRadius.circular(6.0)
      ),
      counter: const SizedBox(),
      contentPadding: EdgeInsets.zero,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: prudColorTheme.lineC),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget getLongButton({
    required Function onPressed,
    required String text,
    bool makeLight = false,
    int shape = 0,
  }){
    Color btnColor = makeLight? prudColorTheme.buttonD : prudColorTheme.primary;
    Color lightColor = btnColor.withValues(alpha: 0.7);
    Color textColor = makeLight? prudColorTheme.error : prudColorTheme.textC;
    GFButtonShape btShape = GFButtonShape.pills;
    switch(shape){
      case 0: btShape = GFButtonShape.pills;
      case 1: btShape = GFButtonShape.standard;
      default: btShape = GFButtonShape.square;
    }
    return GFButton(
      onPressed: () => onPressed(),
      shape: btShape,
      size: btnSize,
      color: btnColor,
      // blockButton: true,
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

  Widget getIconButton({
    required Function onPressed,
    String? image,
    IconData? icon,
    double? size,
    bool isIcon = false,
    bool makeLight = false,
  }){
    Color btnColor = makeLight? prudColorTheme.buttonD : prudColorTheme.primary;
    Color lightColor = btnColor.withValues(alpha: 0.7);
    Color textColor = makeLight? prudColorTheme.error : prudColorTheme.textC;
    return InkWell(
      onTap: () => onPressed(),
      splashColor: lightColor,
      highlightColor: lightColor,
      hoverColor: lightColor,
      child: Container(
        padding: const EdgeInsets.all(5),
        color: btnColor,
        child: Center(
          child: isIcon? Icon(icon, color: textColor, size: 30,)
              : Image.asset(image!, color: textColor, width: 30, height: 30),
        ),
      ),
    );
  }

  Widget getShortButton({required Function onPressed, required String text, bool makeLight = false, bool isPill = true, bool isSmall = false}){
    Color btnColor = makeLight? prudColorTheme.buttonD : prudColorTheme.primary;
    Color lightColor = btnColor.withValues(alpha: 0.7);
    Color textColor = makeLight? prudColorTheme.error : prudColorTheme.textC;
    return GFButton(
      onPressed: () => onPressed(),
      shape: isPill? GFButtonShape.pills : GFButtonShape.square,
      size: isSmall? GFSize.SMALL : btnSize,
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
      style: prudWidgetStyle.tabTextStyle.copyWith(
        color: color,
        fontSize: 14.0
      ),
    )
  );
}

ColorTheme prudColorTheme = const ColorTheme(
    primary: Color(0xffff0000),
    secondary: Color(0xff000000),
    bgA: Color(0xffFFFFFF),
    bgB: Color(0xffe4e1e6),
    bgC: Color(0xffF2F4F7),
    bgD: Color(0xffEAECF0),
    bgE: Colors.transparent,
    bgF: Color(0xff474747),
    textA: Color(0xff292929),
    textB: Color(0xff595757),
    textC: Color(0xffFFFFFF),
    textD: Color(0xfff76a6a),
    textHeader: Color(0xffFEBF60),
    iconA: Color(0xff38106A),
    iconB: Color(0xffCE1567),
    iconC: Color(0xff82858A),
    iconD: Color(0xfffbd2ce),
    lineA: Color(0xffd0782f),
    lineB: Color(0xffC3C8D2),
    lineC: Color(0xffEAECF0),
    lineD: Color(0xffD0D5DD),
    buttonA: Color(0xff1377AE),
    buttonB: Color(0xff32B6E9),
    buttonC: Colors.orange,
    buttonD: Color(0xffffe3b3),
    danger: Color(0xffED5050),
    warning: Color(0xffFF8C00),
    success: Color(0xff219653),
    error: Color(0xffED1111)
);
WidgetStyle prudWidgetStyle = WidgetStyle(
  choiceChipShape: RoundedRectangleBorder(
    side: BorderSide(color: prudColorTheme.bgD),
    borderRadius: BorderRadius.circular(10)
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: prudColorTheme.lineB),
    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: prudColorTheme.iconB),
    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
  ),
  textPadding: const EdgeInsets.only(left: 16, right: 20, top: 8, bottom: 8,),
  hintStyle: TextStyle(
    color: prudColorTheme.textB,
    fontFamily: "Lato-Italic",
    fontSize: 18,
    fontWeight: FontWeight.w500,
  ),
  typedTextStyle: TextStyle(
    decoration: TextDecoration.none,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: prudColorTheme.textA
  ),
  logoStyle: TextStyle(
    fontFamily: "Qhinanttika",
    fontWeight: FontWeight.w600,
    fontSize: 30,
    color: prudColorTheme.secondary,
    decoration: TextDecoration.none,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.2),
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

PrudSpacer spacer = const PrudSpacer(
  height: SizedBox(height: 10),
  width: SizedBox(width: 10),
);

PrudSpacer mediumSpacer = const PrudSpacer(
  height: SizedBox(height: 30),
  width: SizedBox(width: 30),
);

PrudSpacer largeSpacer = const PrudSpacer(
  height: SizedBox(height: 100),
  width: SizedBox(width: 100),
);

PrudSpacer xLargeSpacer = const PrudSpacer(
  height: SizedBox(height: 200),
  width: SizedBox(width: 200),
);

List<BoxShadow> prudShadows = [
  BoxShadow(
    color: prudColorTheme.secondary.withValues(alpha: 0.3),
    spreadRadius: -3,
    blurRadius: 6,
    offset: const Offset(2, 2),
  ),
  BoxShadow(
    color: prudColorTheme.secondary.withValues(alpha: 0.3),
    spreadRadius: -3,
    blurRadius: 10,
    offset: const Offset(0, 6),
  ),
];

InputDecoration getDeco(String label, {
  Widget suffixIcon = const SizedBox(),
  bool filled = false,
  double hintSize = 16.0,
  String hintText = '',
  TextStyle? labelStyle,
  bool hasBorders = true,
  bool onlyBottomBorder = false,
  Color? borderColor,
}) => InputDecoration(
  labelText: label,
  filled: filled,
  suffixIcon: suffixIcon,
  fillColor: prudColorTheme.bgC,
  hintText: hintText,
  labelStyle: labelStyle?? tabData.nRStyle.copyWith(
    fontSize: hintSize,
  ),
  enabledBorder: hasBorders? (onlyBottomBorder? bottomBorder.copyWith(
    borderSide: BorderSide(color: borderColor?? prudColorTheme.lineB)
  ) : prudWidgetStyle.enabledBorder.copyWith(
      borderSide: BorderSide(color: borderColor?? prudColorTheme.lineB)
  )) : InputBorder.none,
  focusedBorder: hasBorders? (onlyBottomBorder? bottomBorder.copyWith(
      borderSide: BorderSide(color: borderColor?? prudColorTheme.iconB)
  ) : prudWidgetStyle.focusedBorder.copyWith(
      borderSide: BorderSide(color: borderColor?? prudColorTheme.iconB)
  )) : InputBorder.none,
  border: hasBorders? (onlyBottomBorder? bottomBorder.copyWith(
      borderSide: BorderSide(color: borderColor?? prudColorTheme.lineB)
  ) : prudWidgetStyle.enabledBorder.copyWith(
      borderSide: BorderSide(color: borderColor?? prudColorTheme.lineB)
  )) : InputBorder.none
);
BorderRadiusGeometry prudRad = const BorderRadius.only(
  topLeft: Radius.circular(30),
  topRight: Radius.circular(30),
);
BorderRadiusGeometry prudRadAll = BorderRadius.circular(30);
InputBorder bottomBorder = UnderlineInputBorder(
  borderSide: BorderSide(color: prudColorTheme.lineB),
  borderRadius: const BorderRadius.all(Radius.zero),
);