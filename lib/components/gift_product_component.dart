import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/giftcards/gift_details.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import 'Translate.dart';

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

  @override
  void initState() {
    if(mounted && widget.product.logoUrls != null && widget.product.logoUrls!.isNotEmpty) {
      setState(() {
        carousels = widget.product.logoUrls!.map((dynamic str){
          return Image.network(
            str,
            width: double.maxFinite,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress){
              if (loadingProgress == null) return child;
              return Center(
                child: LoadingComponent(
                  isShimmer: false,
                  size: 40,
                  spinnerColor: prudColorTheme.lineC,
                ),
              );
            },
            errorBuilder: (context, wid, chunk){
              return const LoadingComponent(
                isShimmer: false,
                size: 20,
              );
            },
          );
        }).toList();
      });
    }
    super.initState();
    giftCardNotifier.addListener(() async {
      if(mounted){
        if(giftCardNotifier.presentSelectedProductId == widget.product.productId){
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
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            constraints: const BoxConstraints(
              minHeight: 100.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(
                color: prudColorTheme.lineC,
                width: 2.0
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
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
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 20),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
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
                              "${widget.product.discountPercentage?? 0}",
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
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 120.0,
                    maxWidth: 180.0,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(width: 5.0, color: prudColorTheme.bgC),
                    color: selected? prudColorTheme.error : prudColorTheme.bgA,
                  ),
                  child: FittedBox(
                    child: Text(
                      "${widget.product.productName}",
                      textAlign: TextAlign.center,
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        color: selected? prudColorTheme.bgC : prudColorTheme.textB,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
