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

  const PrudDataViewer({
    super.key,
    required this.field,
    required this.value,
    this.size = PrudSize.small,
    this.inverseColor = false,
    this.valueIsMoney = false,
    this.removeWidth = false,
    this.fontSize = 25,
    this.headColor,
  }): assert(fontSize > 15 && inverseColor? headColor==null : true);

  double getSize(){
    switch(size){
      case PrudSize.smaller: return 60.0;
      case PrudSize.small: return 120.0;
      case PrudSize.medium: return 150.0;
      default: return 200.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = getSize();
    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: removeWidth? 50 : 120),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: inverseColor? prudColorTheme.primary : prudColorTheme.bgA,
      ),
      child: Center(
        child: Wrap(
          direction:  Axis.vertical,
          spacing: -(fontSize - 15),
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
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
            Text(
              field.toUpperCase(),
              style: prudWidgetStyle.typedTextStyle.copyWith(
                color: inverseColor? prudColorTheme.textHeader : prudColorTheme.textB,
                fontSize: fontSize - 15,
              ),
              textAlign: TextAlign.center,
            )
          ],
        )
      ),
    );
  }
}
