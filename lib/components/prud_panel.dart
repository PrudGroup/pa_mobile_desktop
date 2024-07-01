import 'package:flutter/material.dart';
import 'package:prudapp/components/translate.dart';
import 'package:prudapp/models/theme.dart';

class PrudPanel extends StatelessWidget {
  final String title;
  final Widget? child;
  final Color? titleColor;
  final Color? bgColor;
  final double? titleSize;
  final bool hasPadding;

  const PrudPanel({
    super.key,
    required this.title,
    this.hasPadding = true,
    this.titleColor,
    this.bgColor,
    this.titleSize,
    this.child
  });

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 11),
          child: Container(
            width: screen.width,
            padding: child != null? EdgeInsets.symmetric(horizontal: hasPadding? 10 : 0) : const EdgeInsets.all(0),
            constraints: const BoxConstraints(minHeight: 50.0,),
            decoration: BoxDecoration(
              color: bgColor?? prudColorTheme.bgA,
              border: child != null? Border.all(color: prudColorTheme.lineB,)
                  : Border(top: BorderSide(color: prudColorTheme.lineB,)),
              borderRadius: child != null? BorderRadius.circular(10) : BorderRadius.zero
            ),
            child: child?? const SizedBox(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            color: bgColor?? prudColorTheme.bgA,
            child: Translate(
              text: title,
              style: prudWidgetStyle.tabTextStyle.copyWith(
                color: child != null? titleColor?? prudColorTheme.textB : prudColorTheme.iconB,
                fontSize: titleSize?? (child != null? 16 : 18),
                fontWeight: child != null? FontWeight.w500 : FontWeight.w600
              ),
            ),
          ),
        )
      ],
    );
  }
}
