import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:prudapp/pages/recharge/biller_details.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:prudapp/singletons/utility_notifier.dart';

import '../models/images.dart';
import '../models/reloadly.dart';
import '../models/theme.dart';

class BillerComponent extends StatelessWidget {
  final Biller biller;
  final bool selected;

  const BillerComponent({super.key, required this.biller, required this.selected});

  void selectBiller(BuildContext context){
    utilityNotifier.updateSelectedBiller(biller);
    iCloud.goto(context, BillerDetails(biller: biller, buttonIcon: getUtilityTypeIcon(),));
  }

  String getUtilityTypeIcon(){
    if(biller.type != null){
      BillerType bType = utilityNotifier.translateToType(biller.type!);
      switch(bType){
        case BillerType.electricity: return prudImages.power1;
        case BillerType.water: return prudImages.water;
        case BillerType.tv: return prudImages.smartTv1;
        default: return prudImages.internet;
      }
    }else{
      return prudImages.prudIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectBiller(context),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                  color: selected? prudColorTheme.primary : prudColorTheme.lineC,
                  width: 5.0,
                )
            )
        ),
        child: Row(
          children: [
            GFAvatar(
              shape: GFAvatarShape.square,
              size: GFSize.SMALL,
              backgroundColor: biller.id != null? prudColorTheme.bgC : prudColorTheme.primary,
              child: Image.asset(getUtilityTypeIcon(), fit: BoxFit.contain,),
              // backgroundImage: AssetImage(getUtilityTypeIcon()),
            ),
            spacer.width,
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(biller.name != null) Text(
                  tabData.shortenStringWithPeriod(biller.name!, length: 35),
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: prudColorTheme.secondary,
                  ),
                ),
                Row(
                  children: [
                    if(biller.type != null) Text(
                      tabData.shortenStringWithPeriod(biller.type!, length: 35),
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.textB,
                      ),
                    ),
                    spacer.width,
                    if(biller.serviceType != null) Text(
                      tabData.shortenStringWithPeriod(biller.serviceType!, length: 35),
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.primary,
                      ),
                    ),
                  ],
                ),
                Row(
                    children: [
                      Text(
                        "${tabData.getCountryFlag(biller.countryCode!)}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      spacer.width,
                      if(biller.countryName != null) Text(
                        tabData.shortenStringWithPeriod(biller.countryName!, length: 22),
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: prudColorTheme.textA,
                        ),
                      ),
                    ]
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
