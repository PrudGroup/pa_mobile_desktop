import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/spark.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

class SparkContainer extends StatelessWidget {
  final Spark spark;
  final bool canCreateAffLink;
  final bool selected;

  const SparkContainer({
    super.key,
    required this.spark,
    required this.selected,
    this.canCreateAffLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: selected? 3 : 0,
            color: selected? prudColorTheme.primary : prudColorTheme.bgE
          )
        ),
        borderRadius: selected && canCreateAffLink? const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ) : BorderRadius.zero
      ),
      child: PrudContainer(
        hasPadding: true,
        hasOnlyTopRadius: canCreateAffLink? false : true,
        hasTitle: true,
        title: "${spark.sparkCategory}",
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  spacer.height,
                  spacer.height,
                  Text(
                    tabData.shortenStringWithPeriod("${spark.title}"),
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 13,
                        color: prudColorTheme.textB
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: Translate(
                      text: "${spark.description}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        color: prudColorTheme.textA,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Translate(
                        text: "Duration:",
                        style: prudWidgetStyle.typedTextStyle.copyWith(
                            color: prudColorTheme.iconC,
                            fontSize: 10
                        ),
                      ),
                      mediumSpacer.width,
                      Translate(
                        text: "${spark.duration} Months",
                        style: prudWidgetStyle.typedTextStyle.copyWith(
                            color: prudColorTheme.iconB,
                            fontSize: 10
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if(spark.updatedAt != null) Text(
                      "Updated ${myStorage.ago(dDate: spark.updatedAt!, isShort: false)}",
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        color: prudColorTheme.iconB,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.right
                  ),
                  spacer.height,
                  Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Translate(
                          text: "Target:",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              color: prudColorTheme.iconC,
                              fontSize: 10
                          ),
                        ),
                        spacer.width,
                        Wrap(
                          direction: Axis.vertical,
                          spacing: -8,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(
                                "${tabData.getFormattedNumber(spark.targetSparks)}",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.primary,
                                  fontSize: 20,
                                )
                            ),
                            Text(
                                "sparks".toUpperCase(),
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.lineB,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center
                            ),
                          ],
                        ),
                      ]
                  ),
                  spacer.height,
                  Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Translate(
                          text: "Achieved:",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              color: prudColorTheme.iconC,
                              fontSize: 10
                          ),
                        ),
                        spacer.width,
                        Wrap(
                          direction: Axis.vertical,
                          spacing: -8,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(
                                "${tabData.getFormattedNumber(spark.sparksCount)}",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.primary,
                                  fontSize: 20,
                                )
                            ),
                            Text(
                                "sparks".toUpperCase(),
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.lineB,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center
                            ),
                          ],
                        ),
                      ]
                  ),
                  if(spark.status != null) FittedBox(
                    child: Text(
                        "${spark.createdAt} | ${spark.status}".toUpperCase(),
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          color: prudColorTheme.lineB,
                          fontSize: 6,
                        ),
                        textAlign: TextAlign.center
                    ),
                  ),
                ],
              )
            ],
          )
      ),
    );
  }
}
