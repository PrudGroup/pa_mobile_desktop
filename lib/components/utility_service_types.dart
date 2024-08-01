import 'package:flutter/material.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/utility_notifier.dart';

import '../models/theme.dart';

class UtilityServiceTypes extends StatelessWidget {

  const UtilityServiceTypes({super.key});

  void choose(BillerServiceType dType, BuildContext context){
    utilityNotifier.updateSelectedServiceType(dType);
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
                choose(BillerServiceType.prepaid, context);
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
                      AssetImage(prudImages.prepaid),
                      color: prudColorTheme.secondary,
                    ),
                    Text(
                      "Prepaid Service Bills",
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
                choose(BillerServiceType.postpaid, context);
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
                      AssetImage(prudImages.postpaid),
                      color: prudColorTheme.secondary,
                    ),
                    Text(
                      "PostPaid Service Bills",
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

