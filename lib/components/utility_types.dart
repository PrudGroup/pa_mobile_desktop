import 'package:flutter/material.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/utility_notifier.dart';

import '../models/theme.dart';

class UtilityTypes extends StatelessWidget {

  const UtilityTypes({super.key});

  void choose(BillerType dType, BuildContext context){
    utilityNotifier.updateSelectedUtilityType(dType);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.25,
      decoration: BoxDecoration(
        borderRadius: prudRad,
        color: prudColorTheme.bgC,
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            InkWell(
              onTap: () {
                choose(BillerType.electricity, context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: prudColorTheme.bgA,
                  border: Border(
                    bottom: BorderSide(color: prudColorTheme.bgC, width: 5)
                  )
                ),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage(prudImages.power1),
                      color: prudColorTheme.secondary,
                    ),
                    spacer.width,
                    Text(
                      "Electricity Bill",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: prudColorTheme.textA
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                choose(BillerType.water, context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: prudColorTheme.bgA,
                    border: Border(
                        bottom: BorderSide(color: prudColorTheme.bgC, width: 5)
                    )
                ),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage(prudImages.water),
                      color: prudColorTheme.secondary,
                    ),
                    spacer.width,
                    Text(
                      "Water Bill",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: prudColorTheme.textA
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                choose(BillerType.tv, context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: prudColorTheme.bgA,
                  border: Border(
                    bottom: BorderSide(color: prudColorTheme.bgC, width: 5)
                  )
                ),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage(prudImages.smartTv1),
                      color: prudColorTheme.secondary,
                    ),
                    spacer.width,
                    Text(
                      "Television/Cable Subscriptions",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: prudColorTheme.textA
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                choose(BillerType.internet, context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: prudColorTheme.bgA,
                  border: Border(
                      bottom: BorderSide(color: prudColorTheme.bgC, width: 5)
                  )
                ),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage(prudImages.internet),
                      color: prudColorTheme.secondary,
                    ),
                    spacer.width,
                    Text(
                      "Internet Subscriptions",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: prudColorTheme.textA
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

