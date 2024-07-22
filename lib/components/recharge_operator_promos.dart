import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:prudapp/components/Translate.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/models/theme.dart';

import '../models/images.dart';
import '../models/reloadly.dart';

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
      return SizedBox(
        width: double.maxFinite,
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
                  fontSize: 18,
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
                        color: prudColorTheme.lineC
                    ),
                  ),
                  if(pro.endDate != null) Text(
                    "Ends: ${pro.endDate}",
                    style: prudWidgetStyle.typedTextStyle.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.primary
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: PrudContainer(
            title: operatorName,
            titleBorderColor: prudColorTheme.bgC,
            hasTitle: true,
            titleAlignment: MainAxisAlignment.end,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: GFCarousel(
                height: 130.0,
                autoPlay: true,
                aspectRatio: double.maxFinite,
                viewportFraction: 1.0,
                enlargeMainPage: true,
                enableInfiniteScroll: true,
                pauseAutoPlayOnTouch: const Duration(seconds: 10),
                autoPlayInterval: const Duration(seconds: 3),
                items: getPromoWidgets(),
              ),
            ),
          ),
        ),
        Container(
          width: 50.0,
          height: 50.0,
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: prudColorTheme.bgC,
              width: 5.0
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: carousels.isNotEmpty?
            GFCarousel(
              height: 50.0,
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
              child: Image.asset(prudImages.airtime, fit: BoxFit.contain,),
            ),
          ),
        ),
      ],
    );
  }
}
