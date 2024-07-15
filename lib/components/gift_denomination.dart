import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/components/Translate.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';
import '../singletons/currency_math.dart';

class Denomination{
  double sender;
  String recipient;

  Denomination({required this.sender, required this.recipient});
}

class GiftDenomination extends StatelessWidget {

  final Denomination denMap;
  final double senderFee;
  final double discountInPercentage;
  final bool selected;
  final String recipientCur;

  const GiftDenomination({
    super.key,
    required this.denMap,
    required this.senderFee,
    required this.discountInPercentage,
    required this.recipientCur,
    this.selected = false
  });

  double getRecipientDenomination() => currencyMath.roundDouble(double.parse(denMap.recipient), 2);

  void select(){
    giftCardNotifier.updateSelectedDenMap(denMap);
  }

  double getTotalAmountSenderIsToPay(){
    double discount = discountInPercentage > 0? (denMap.sender * (discountInPercentage/100)) : 0;
    double toPay = denMap.sender - discount;
    double amount = senderFee + toPay + reloadlySmsFee;
    return amount;
  }

  Future<double?> getFxAmount(String quoteCurrency) async {
    double amountToBePaid = getTotalAmountSenderIsToPay();
    double fx = await currencyMath.convert(
      amount: amountToBePaid,
      baseCode: "NGN",
      quoteCode: quoteCurrency,
    );
    if(fx != 0 ){
      return currencyMath.roundDouble(fx, 2);
    }else{
      return null;
    }
  }

  double getAmountInNaira() => getTotalAmountSenderIsToPay();

  @override
  Widget build(BuildContext context) {
    GiftSearchCriteria? cri = giftCardNotifier.lastGiftSearch;
    Currency? benCur = tabData.getCurrency(recipientCur);
    Currency? senderCur = cri?.senderCurrency;
    return benCur != null && senderCur != null?
    InkWell(
      onTap: select,
      child: Container(
        height: 150,
        constraints: const BoxConstraints(
          maxWidth: 130,
          minWidth: 100,
        ),
        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: prudColorTheme.primary,
          boxShadow: prudShadows,
          borderRadius: prudRadAll,
          border: Border.symmetric(
            vertical: BorderSide(
              color: selected? prudColorTheme.buttonC : prudColorTheme.primary.withOpacity(0.6),
              width: 4.0
            )
          )
        ),
        child: Center(
          child: FutureBuilder(
              future: getFxAmount(senderCur.code),
              builder: (context, AsyncSnapshot<double?> snapshot){
                if(snapshot.hasError) return const SizedBox();
                switch(snapshot.connectionState){
                  case ConnectionState.waiting: {
                    return LoadingComponent(
                      size: 20,
                      isShimmer: false,
                      spinnerColor: prudColorTheme.textD,
                    );
                  }
                  default: {
                    if(snapshot.hasData){
                      double? fxRate = snapshot.data;
                      return Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              FittedBox(
                                child: Row(
                                  children: [
                                    Text(
                                      benCur.symbol,
                                      style: tabData.tBStyle.copyWith(
                                        fontSize: 16.0,
                                        color: prudColorTheme.bgC,
                                      ),
                                    ),
                                    Text(
                                      denMap.recipient,
                                      style: TextStyle(
                                        fontSize: 25.0,
                                        color: prudColorTheme.bgA,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Translate(
                                text: "Beneficiary Gets",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: prudColorTheme.lineD
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                child: Row(
                                  children: [
                                    Text(
                                      "${fxRate != null? senderCur.symbol : tabData.getCurrencySymbol("NGN")}",
                                      style: tabData.tBStyle.copyWith(
                                        fontSize: 16,
                                        color: prudColorTheme.bgC
                                      ),
                                    ),
                                    Text(
                                      "${fxRate?? getAmountInNaira()}",
                                      style: TextStyle(
                                        fontSize: 25.0,
                                        color: prudColorTheme.bgA,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Translate(
                                    text: "You Pay",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: prudColorTheme.lineD
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top:15),
                                    child: Translate(
                                      text: "(Charges Included)",
                                      style: prudWidgetStyle.tabTextStyle.copyWith(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                          color: prudColorTheme.textHeader
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      );
                    }else{
                      return const SizedBox();
                    }
                  }
                }
              }
          ),
        ),
      ),
    )
        :
    const SizedBox();
  }
}
