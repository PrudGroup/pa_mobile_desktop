import 'package:flutter/material.dart';

import '../models/images.dart';
import '../models/reloadly.dart';
import '../models/theme.dart';
import '../singletons/utility_notifier.dart';

class SavedBillers extends StatelessWidget {

  const SavedBillers({super.key});

  void choose(Biller biller, UtilityDevice deviceUsed, BuildContext context){
    utilityNotifier.selectFromSavedBiller(biller, deviceUsed);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    LastBillersUsed lastBillers = utilityNotifier.lastBillerUsed!;
    return Container(
      height: height * 0.45,
      decoration: BoxDecoration(
        borderRadius: prudRad,
        color: prudColorTheme.bgC,
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            if(lastBillers.electricity != null) InkWell(
              onTap: () => choose(lastBillers.electricity!, UtilityDevice(
                no: lastBillers.lastDeviceUsedOnElectricity!,
                serviceType: lastBillers.electricity!.serviceType!,
                type: lastBillers.electricity!.type!,
                countryIsoCode: lastBillers.electricity!.countryCode!,
                billerId: lastBillers.electricity!.id!,
              ), context),
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
                        ImageIcon(
                          AssetImage(prudImages.power1),
                          color: prudColorTheme.secondary,
                        ),
                        Column(
                          children: [
                            Text(
                              "${lastBillers.electricity?.name}",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: prudColorTheme.textA
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${lastBillers.electricity?.type}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: prudColorTheme.textA
                                  ),
                                ),
                                spacer.width,
                                Text(
                                  "${lastBillers.electricity?.serviceType}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: prudColorTheme.danger
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    if(lastBillers.lastDeviceUsedOnElectricity != null) Text(
                      "${lastBillers.lastDeviceUsedOnElectricity}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: prudColorTheme.primary
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if(lastBillers.water != null) InkWell(
              onTap: () => choose(lastBillers.water!, UtilityDevice(
                no: lastBillers.lastDeviceUsedOnWater!,
                serviceType: lastBillers.water!.serviceType!,
                type: lastBillers.water!.type!,
                countryIsoCode: lastBillers.water!.countryCode!,
                billerId: lastBillers.water!.id!,
              ), context),
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
                        ImageIcon(
                          AssetImage(prudImages.water),
                          color: prudColorTheme.secondary,
                        ),
                        Column(
                          children: [
                            Text(
                              "${lastBillers.water?.name}",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: prudColorTheme.textA
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${lastBillers.water?.type}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: prudColorTheme.textA
                                  ),
                                ),
                                spacer.width,
                                Text(
                                  "${lastBillers.water?.serviceType}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: prudColorTheme.danger
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    if(lastBillers.lastDeviceUsedOnWater != null) Text(
                      "${lastBillers.lastDeviceUsedOnWater}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: prudColorTheme.primary
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if(lastBillers.tv != null) InkWell(
              onTap: () => choose(lastBillers.tv!, UtilityDevice(
                no: lastBillers.lastDeviceUsedOnTv!,
                serviceType: lastBillers.tv!.serviceType!,
                type: lastBillers.tv!.type!,
                countryIsoCode: lastBillers.tv!.countryCode!,
                billerId: lastBillers.tv!.id!,
              ), context),
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
                        ImageIcon(
                          AssetImage(prudImages.smartTv1),
                          color: prudColorTheme.secondary,
                        ),
                        Column(
                          children: [
                            Text(
                              "${lastBillers.tv?.name}",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: prudColorTheme.textA
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${lastBillers.tv?.type}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: prudColorTheme.textA
                                  ),
                                ),
                                spacer.width,
                                Text(
                                  "${lastBillers.tv?.serviceType}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: prudColorTheme.danger
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    if(lastBillers.lastDeviceUsedOnTv != null) Text(
                      "${lastBillers.lastDeviceUsedOnTv}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: prudColorTheme.primary
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if(lastBillers.internet != null) InkWell(
              onTap: () => choose(lastBillers.internet!, UtilityDevice(
                no: lastBillers.lastDeviceUsedOnInternet!,
                serviceType: lastBillers.internet!.serviceType!,
                type: lastBillers.internet!.type!,
                countryIsoCode: lastBillers.internet!.countryCode!,
                billerId: lastBillers.internet!.id!,
              ), context),
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
                        ImageIcon(
                          AssetImage(prudImages.internet),
                          color: prudColorTheme.secondary,
                        ),
                        Column(
                          children: [
                            Text(
                              "${lastBillers.internet?.name}",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: prudColorTheme.textA
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${lastBillers.internet?.type}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: prudColorTheme.textA
                                  ),
                                ),
                                spacer.width,
                                Text(
                                  "${lastBillers.internet?.serviceType}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: prudColorTheme.danger
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    if(lastBillers.lastDeviceUsedOnInternet != null) Text(
                      "${lastBillers.lastDeviceUsedOnInternet}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: prudColorTheme.primary
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
