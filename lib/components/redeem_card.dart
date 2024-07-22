import 'package:flutter/material.dart';
import 'package:u_credit_card/u_credit_card.dart';

import '../models/images.dart';
import '../models/reloadly.dart';
import '../models/theme.dart';
import '../singletons/tab_data.dart';
import 'translate.dart';

class RedeemCard extends StatelessWidget {
  final GiftTransaction trans;
  final GiftTransactionDetails tranDetails;
  final GiftRedeemCode giftCard;
  
  const RedeemCard({
    super.key, 
    required this.trans, 
    required this.tranDetails, 
    required this.giftCard
  });

  @override
  Widget build(BuildContext context) {
    Color lTxtColor = prudColorTheme.iconC;
    FontWeight lTxtWeight = FontWeight.w500;
    FontWeight rTxtWeight = FontWeight.w600;

    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      width: 300,
      child: Column(
        children: [
          CreditCardUi(
            cardHolderFullName: tranDetails.beneficiary!.fullName,
            cardNumber: '${giftCard.cardNumber}',
            validThru: '10/24',
            cardProviderLogo: Image.asset(prudImages.prudIcon, width: 30,),
            showValidThru: false,
            bottomRightColor: prudColorTheme.primary.withRed(250),
            topLeftColor: prudColorTheme.primary,
            showBalance: true,
            showValidFrom: false,
            currencySymbol: tabData.getCurrencySymbol(trans.product!.currencyCode!),
            balance: trans.product!.unitPrice,
            enableFlipping: true,
            backgroundDecorationImage: DecorationImage(
              fit: BoxFit.cover,
              onError: (obj, stack){
                debugPrint("NetworkImage Error: $obj : $stack");
              },
              image: NetworkImage(
                tranDetails.productPhoto!,
              )
            ),
          ),
          spacer.height,
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment:  MainAxisAlignment.spaceBetween,
            children: [
              Translate(
                text: "Card Number:",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                  fontSize: 16,
                  color: lTxtColor,
                  fontWeight: lTxtWeight
                ),
                align: TextAlign.left,
              ),
              Text(
                "${giftCard.cardNumber}",
                style: prudWidgetStyle.typedTextStyle.copyWith(
                  fontSize: 18,
                  color: prudColorTheme.secondary,
                  fontWeight: rTxtWeight
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          spacer.height,
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment:  MainAxisAlignment.spaceBetween,
            children: [
              Translate(
                text: "Card PIN:",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                  fontSize: 16,
                  color: lTxtColor,
                  fontWeight: lTxtWeight
                ),
                align: TextAlign.left,
              ),
              Text(
                "${giftCard.pinCode}",
                style: prudWidgetStyle.typedTextStyle.copyWith(
                    fontSize: 20,
                    color: prudColorTheme.primary,
                    fontWeight: rTxtWeight
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          spacer.height,
        ],
      ),
    );
  }
}
