import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:prudapp/components/Translate.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/models/theme.dart';

import '../models/images.dart';
import '../models/reloadly.dart';

class RechargeOperatorPromos extends StatelessWidget {
  final List<OperatorPromotion> promos;
  final String operatorName;
  final List<Widget> carousels;

  const RechargeOperatorPromos({
    super.key,
    required this.promos,
    required this.operatorName,
    required this.carousels
  });

  List<Widget> getPromoWidgets(){
    return promos.map((promo) => SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          if(promo.title1 != null) Translate(
          text: "${promo.title1}",
           style: prudWidgetStyle.tabTextStyle.copyWith(
             fontSize: 13,
             fontWeight: FontWeight.w600,
             color: prudColorTheme.secondary
           ),
           align: TextAlign.left,
          ),
          if(promo.title2 != null) Translate(
            text: "${promo.title2}",
            style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: prudColorTheme.secondary
            ),
            align: TextAlign.left,
          ),
          if(promo.description != null) Translate(
            text: "${promo.description}",
            style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: prudColorTheme.primary
            ),
            align: TextAlign.left,
          ),
          if(promo.denominations != null) Translate(
            text: "${promo.denominations}",
            style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: prudColorTheme.iconA
            ),
            align: TextAlign.left,
          ),
          if(promo.localDenominations != null) Translate(
            text: "${promo.localDenominations}",
            style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: prudColorTheme.iconA
            ),
            align: TextAlign.left,
          ),
          if(promo.startDate != null || promo.endDate != null) Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(promo.startDate != null) Text(
                "Starts: ${promo.startDate}",
                style: prudWidgetStyle.typedTextStyle.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: prudColorTheme.lineC
                ),
              ),
              if(promo.endDate != null) Text(
                "Ends: ${promo.endDate}",
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
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30),
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
          width: 100.0,
          height: 100.0,
          margin: const EdgeInsets.only(top: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
              color: prudColorTheme.bgC,
              width: 2.0
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: carousels.isNotEmpty?
            GFCarousel(
              height: 100.0,
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
