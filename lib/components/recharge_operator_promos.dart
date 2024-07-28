import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:prudapp/components/Translate.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/theme.dart';

import '../models/images.dart';
import '../models/reloadly.dart';
import '../singletons/tab_data.dart';

class RechargeOperatorPromos extends StatelessWidget {
  final List<dynamic> promos;
  final String operatorName;
  final List<Widget> carousels;

  const RechargeOperatorPromos({
    super.key,
    required this.promos,
    required this.operatorName,
    required this.carousels
  });

  List<Widget> getPromoWidgets(){
    return promos.map((dynamic promo) {
      OperatorPromotion pro = OperatorPromotion.fromJson(promo);
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: PrudPanel(
              title: tabData.shortenStringWithPeriod(pro.title1?? operatorName, length: 30),
              hasPadding: true,
              bgColor: prudColorTheme.bgC,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 5, 5),
                child: Column(
                  children: [
                    if(pro.title1 != null) Translate(
                      text: "${pro.title1}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: prudColorTheme.secondary
                      ),
                      align: TextAlign.left,
                    ),
                    /*if(pro.title2 != null) Translate(
                text: "${pro.title2}",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: prudColorTheme.secondary
                ),
                align: TextAlign.left,
              ),*/
                    if(pro.description != null) Translate(
                      text: "${pro.description}",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: prudColorTheme.primary
                      ),
                      align: TextAlign.left,
                    ),
                    /* if(pro.denominations != null) Translate(
                text: "${pro.denominations}",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: prudColorTheme.iconA
                ),
                align: TextAlign.left,
              ),
              if(pro.localDenominations != null) Translate(
                text: "${pro.localDenominations}",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: prudColorTheme.iconA
                ),
                align: TextAlign.left,
              ),*/
                    if(pro.startDate != null || pro.endDate != null) Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(pro.startDate != null) Text(
                          "Starts: ${pro.startDate}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.textB
                          ),
                        ),
                        if(pro.endDate != null) Text(
                          "Ends: ${pro.endDate}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.secondary
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 80.0,
            height: 80.0,
            margin: const EdgeInsets.only(top: 30, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(
                  color: prudColorTheme.bgC,
                  width: 5.0
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: carousels.isNotEmpty?
              GFCarousel(
                  height: 80.0,
                  autoPlay: true,
                  aspectRatio: double.maxFinite,
                  viewportFraction: 1.0,
                  enlargeMainPage: true,
                  enableInfiniteScroll: true,
                  pauseAutoPlayOnTouch: const Duration(seconds: 10),
                  autoPlayInterval: const Duration(seconds: 3),
                  items: carousels
              )
                  :
              Center(
                child: Image.asset(prudImages.airtime, fit: BoxFit.cover,),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: getPromoWidgets(),
    );
  }
}
