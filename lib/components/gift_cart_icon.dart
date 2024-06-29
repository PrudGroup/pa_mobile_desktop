import 'package:flutter/material.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/giftcards/gift_cart.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class GiftCartIcon extends StatelessWidget {
  const GiftCartIcon({super.key});

  void openCartDetails(BuildContext context){
    iCloud.goto(context, const GiftCart());
  }

  @override
  Widget build(BuildContext context) {
    int quantity = giftCardNotifier.cartItems.length;
    return InkWell(
      onTap: () => openCartDetails(context),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: quantity > 0? 5.0 : 0.0),
            child: ImageIcon(
              AssetImage(prudImages.cart),
              size: 20,
              color: prudColorTheme.bgB,
            ),
          ),
          if(quantity > 0) Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              width: 15.0,
              height: 15.0,
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: prudColorTheme.success,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                quantity.toString().length > 1? "9+" : "$quantity",
                style: prudWidgetStyle.btnTextStyle.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: prudColorTheme.bgB
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
