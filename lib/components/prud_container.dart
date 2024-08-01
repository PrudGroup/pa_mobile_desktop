import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';

import '../models/theme.dart';

class PrudContainer extends StatelessWidget {
  final Widget child;
  final bool hasPadding;
  final bool hasOnlyTopRadius;
  final bool hasTitle;
  final String? title;
  final Color? titleBorderColor;
  final MainAxisAlignment titleAlignment;

  const PrudContainer({
    super.key,
    required this.child,
    this.hasPadding = true,
    this.hasOnlyTopRadius = false,
    this.hasTitle = false,
    this.titleAlignment = MainAxisAlignment.start,
    this.title,
    this.titleBorderColor,
  }): assert(hasTitle? title != null : title == null);

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry rad = hasOnlyTopRadius? const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ) : BorderRadius.circular(20.0);
    Widget container = Container(
      constraints: const BoxConstraints(
        minHeight: 100.0,
        minWidth: double.maxFinite,
      ),
      decoration: BoxDecoration(
        color: prudColorTheme.bgA,
        borderRadius: rad
      ),
      child: ClipRRect(
        borderRadius: rad,
        child: Padding(
            padding: EdgeInsets.all(hasPadding? 5.0 : 0.0),
            child: child,
          )
      ),
    );
    return hasTitle?
    Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: container,
        ),
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: titleAlignment,
          children:[
            Container(
              constraints: const BoxConstraints(
                minWidth: 100.0,
                maxWidth: 200.0,
              ),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: prudColorTheme.bgA,
                border: Border.all(
                  color: titleBorderColor?? prudColorTheme.bgC,
                  width: 6.0,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Translate(
                text: "$title",
                style: prudWidgetStyle.btnTextStyle.copyWith(
                    fontSize: 14,
                    color: prudColorTheme.iconB
                ),
                align: TextAlign.center,
              ),
            )
          ]
        )
      ],
    )
        :
    container;
  }
}
