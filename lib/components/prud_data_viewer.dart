import 'package:flutter/material.dart';
import 'package:prudapp/models/theme.dart';

import '../singletons/tab_data.dart';

enum PrudSize{
  smaller,
  small,
  medium,
  large
}

class PrudDataViewer extends StatelessWidget {
  final String field;
  final dynamic value;
  final bool inverseColor;
  final PrudSize size;
  final double fontSize;
  final bool valueIsMoney;
  final Color? headColor;
  final bool removeWidth;
  final bool makeTransparent;
  final dynamic subValue;

  const PrudDataViewer({
    super.key,
    required this.field,
    required this.value,
    this.size = PrudSize.small,
    this.inverseColor = false,
    this.valueIsMoney = false,
    this.removeWidth = false,
    this.makeTransparent = false,
    this.fontSize = 25,
    this.headColor,
    this.subValue,
  }): assert(fontSize > 15 && inverseColor? headColor==null : true);

  double getSize(){
    switch(size){
      case PrudSize.smaller: return subValue != null? 100 : 60.0;
      case PrudSize.small: return subValue != null? 180 : 120.0;
      case PrudSize.medium: return subValue != null? 220 : 150.0;
      default: return subValue != null? 300 : 200.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = getSize();
    double spa = fontSize + 3;
    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: removeWidth? 50 : 120),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: makeTransparent? prudColorTheme.bgE : ( inverseColor? prudColorTheme.primary : prudColorTheme.bgA),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "$value",
              style: valueIsMoney? tabData.tBStyle.copyWith(
                color: inverseColor? prudColorTheme.bgA : ( headColor?? prudColorTheme.primary),
                fontSize: fontSize,
              ) : prudWidgetStyle.typedTextStyle.copyWith(
                color: inverseColor? prudColorTheme.bgA : ( headColor?? prudColorTheme.primary),
                fontSize: fontSize,
              ),
              textAlign: TextAlign.center,
            ),
            if(subValue != null) Padding(
              padding: EdgeInsets.only(top: spa + 3),
              child: Text(
                "$subValue",
                style: prudWidgetStyle.typedTextStyle.copyWith(
                  color: inverseColor? prudColorTheme.buttonA : prudColorTheme.secondary,
                  fontSize: fontSize - 8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: subValue != null? spa + 25 : spa),
                child: Text(
                  field.toUpperCase(),
                  style: prudWidgetStyle.typedTextStyle.copyWith(
                    color: inverseColor? prudColorTheme.textHeader : prudColorTheme.iconC,
                    fontSize: fontSize - 15,
                  ),
                  textAlign: TextAlign.center,
                )
            ),
          ],
        ),
      ),
    );
  }
}
