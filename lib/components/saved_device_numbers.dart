import 'package:flutter/material.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';
import '../singletons/utility_notifier.dart';

class SavedDeviceNumbers extends StatelessWidget {

  const SavedDeviceNumbers({super.key});

  void choose(UtilityDevice device, BuildContext context){
    utilityNotifier.updateSelectedDeviceNo(device);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.35,
      decoration: BoxDecoration(
        borderRadius: prudRad,
        color: prudColorTheme.bgC,
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: utilityNotifier.deviceNumbers.length,
          itemBuilder: (context, index){
            UtilityDevice device = utilityNotifier.deviceNumbers[index];
            return InkWell(
              onTap: () => choose(device, context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: prudColorTheme.bgA,
                    border: Border(
                        bottom: BorderSide(
                            color: prudColorTheme.bgC, width: 5
                        )
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${tabData.getCountryFlag(device.countryIsoCode)}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: prudColorTheme.textB
                          ),
                        ),
                        Text(
                          device.type,
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: prudColorTheme.textA
                          ),
                        ),
                      ],
                    ),
                    Text(
                      device.serviceType,
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}

