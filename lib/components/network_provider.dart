import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/images.dart';
import '../models/theme.dart';

class NetworkProvider extends StatelessWidget {
  final bool selected;
  final RechargeOperator operator;

  const NetworkProvider({super.key, required this.operator, required this.selected});

  @override
  Widget build(BuildContext context) {
    List<Widget> carousels = operator.logoUrls == null? [] : operator.logoUrls!.map((dynamic str){
      return PrudNetworkImage(
        url: str,
        width: 90.0,
        fit: BoxFit.contain,
      );
    }).toList();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: prudColorTheme.bgE,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: selected? prudColorTheme.buttonC : prudColorTheme.bgD,
              width: 4.0
            ),
          ),
          child: Container(
            width: 90.0,
            height: 90.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: carousels.isNotEmpty?
              GFCarousel(
                  height: 90.0,
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
        ),
        spacer.height,
        if(operator.name != null) SizedBox(
          width: 110,
          child: Text(
            tabData.shortenStringWithPeriod(operator.name!, length: 35),
            style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 13,
              color: prudColorTheme.secondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
