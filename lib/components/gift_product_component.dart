import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/giftcards/gift_details.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import '../singletons/tab_data.dart';
import 'translate.dart';

class GiftProductComponent extends StatefulWidget {
  final GiftProduct product;

  const GiftProductComponent({
    super.key,
    required this.product,
  });

  @override
  GiftProductComponentState createState() => GiftProductComponentState();
}

class GiftProductComponentState extends State<GiftProductComponent> {

  List<Widget> carousels = [];
  bool selected = false;

  void openDetails(){
    giftCardNotifier.changeSelectedProduct(widget.product.productId!);
    iCloud.goto(context, GiftDetails(gift: widget.product,));
  }

  double getDiscountInPercentage(){
    double discount = widget.product.discountPercentage?? 0;
    if(discount > 0) discount = discount * giftCustomerDiscountInPercentage;
    return discount > 0? currencyMath.roundDouble(discount, 1) : 0;
  }

  @override
  void initState() {
    if(mounted && widget.product.logoUrls != null && widget.product.logoUrls!.isNotEmpty) {
      setState(() {
        carousels = widget.product.logoUrls!.map((dynamic str){
          return PrudNetworkImage(
            url: str,
            width: double.maxFinite,
          );
        }).toList();
      });
    }
    super.initState();
    giftCardNotifier.addListener(() async {
      if(mounted){
        if(giftCardNotifier.presentSelectedProductId == widget.product.productId && giftCardNotifier.cartCanListen){
          setState(() => selected = true);
        }else{
          setState(() => selected = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openDetails,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                width: 160.0,
                height: 120.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: selected? prudColorTheme.bgC : prudColorTheme.lineC,
                    width: 2.0
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: widget.product.logoUrls != null && widget.product.logoUrls!.isNotEmpty?
                  GFCarousel(
                      height: 137.0,
                      autoPlay: true,
                      aspectRatio: double.maxFinite,
                      viewportFraction: 1.0,
                      enlargeMainPage: true,
                      enableInfiniteScroll: true,
                      pauseAutoPlayOnTouch: const Duration(seconds: 10),
                      autoPlayInterval: const Duration(seconds: 5),
                      items: carousels
                  )
                      :
                  Image.asset(prudImages.screen, fit: BoxFit.cover,),
                ),
              ),
              if(widget.product.productName != null) SizedBox(
                width: 150,
                child: Text(
                  tabData.shortenStringWithPeriod(widget.product.productName!, length: 40),
                  textAlign: TextAlign.center,
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: selected? prudColorTheme.bgC : prudColorTheme.textB,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: 60.0,
              margin: const EdgeInsets.only(top: 20.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: prudColorTheme.lineB,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: prudShadows,
              ),
              child: FittedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${getDiscountInPercentage()}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                            fontSize: 40.0,
                            fontWeight: FontWeight.w700,
                            color: prudColorTheme.error
                          ),
                        ),
                        Text(
                          "%",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w700,
                            color: prudColorTheme.buttonA
                          ),
                        ),
                      ],
                    ),
                    Translate(
                      text: "DISCOUNT",
                      align: TextAlign.center,
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        color: prudColorTheme.textA,
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
