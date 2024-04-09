import 'package:flutter/material.dart';
import 'package:prudapp/components/translate.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/tab_data.dart';

class FigureDisplay extends StatefulWidget{

  final String title;
  final String per;
  final double perFigure;
  final int quantity;
  final String subtitle;
  final String? descTitle;
  final String? desc;
  final int duration;
  final String durationDesc;

  const FigureDisplay({
    super.key,
    required this.title,
    required this.per,
    required this.perFigure,
    required this.quantity,
    required this.duration,
    required this.durationDesc,
    this.subtitle = "Sparks",
    this.desc,
    this.descTitle,
  });

  @override
  FigureDisplayState createState() => FigureDisplayState();
}

class FigureDisplayState extends State<FigureDisplay> {
  final GlobalKey _containerKey = GlobalKey();
  double containerHeight = 220;


  getSizeAndPosition() {
    containerHeight = _containerKey.currentContext!.size!.height;
    setState(() {});
  }

  double getTotal() => (widget.quantity * widget.perFigure) * widget.duration;

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, (){
      if(mounted) WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currency = Text(
      "€",
      style: prudWidgetStyle.typedTextStyle.copyWith(
        color: prudColorTheme.bgA,
        fontSize: 20
      ),
    );
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(
            minHeight: 200,
          ),
          padding: const EdgeInsets.all(10),
          key: _containerKey,
          decoration: BoxDecoration(
            color: prudColorTheme.primary,
            border: Border.all(color: prudColorTheme.bgC, width: 2),
            borderRadius: BorderRadius.circular(25.0)
          ),
          child: Column(
            children: [
              spacer.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    direction: Axis.vertical,
                    spacing: -15.0,
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          currency,
                          Text(
                            "${widget.perFigure}",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                              color: prudColorTheme.bgA,
                              fontSize: 35
                            ),
                            textAlign: TextAlign.left,
                          )
                        ],
                      ),
                      Text(
                        "PER ${widget.per}",
                        style: prudWidgetStyle.typedTextStyle.copyWith(
                          color: prudColorTheme.buttonD,
                          fontSize: 14
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    direction: Axis.vertical,
                    spacing: -15.0,
                    children: [
                      FittedBox(
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            currency,
                            Text(
                              "${tabData.getFormattedNumber(getTotal())}",
                              style: prudWidgetStyle.typedTextStyle.copyWith(
                                color: prudColorTheme.bgA,
                                fontSize: 35
                              ),
                              textAlign: TextAlign.right,
                            )
                          ],
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          "${widget.quantity} ${widget.subtitle}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                            color: prudColorTheme.buttonD,
                            fontSize: 14
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              spacer.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    direction: Axis.vertical,
                    spacing: -15.0,
                    children: [
                      Text(
                        "${widget.duration}",
                        style: prudWidgetStyle.typedTextStyle.copyWith(
                          color: prudColorTheme.bgA,
                          fontSize: 35
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Duration",
                        style: prudWidgetStyle.typedTextStyle.copyWith(
                            color: prudColorTheme.buttonD,
                            fontSize: 14
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    direction: Axis.vertical,
                    spacing: -10.0,
                    children: [
                      FittedBox(
                        child: Text(
                          widget.durationDesc,
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                            color: prudColorTheme.bgA,
                            fontSize: 25
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          "Duration In",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                            color: prudColorTheme.buttonD,
                            fontSize: 14
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              spacer.height,
              spacer.height,
              if(widget.desc != null) SizedBox(
                width: 250,
                child: Translate(
                  text: "${widget.descTitle}: ${widget.desc}",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.bgD,
                    fontSize: 12,
                  ),
                  align: TextAlign.center,
                ),
              ),
              mediumSpacer.height
            ],
          )
        ),
        Padding(
          padding: EdgeInsets.only(top: (containerHeight - 20.0)),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: prudColorTheme.bgA,
                  border: Border.all(color: prudColorTheme.bgC, width: 5),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Text(
                  tabData.toTitleCase(widget.title),
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.primary,
                    fontSize: 16
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
