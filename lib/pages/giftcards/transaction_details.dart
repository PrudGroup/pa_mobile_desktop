import 'package:flutter/material.dart';
import 'package:prudapp/components/beneficiary_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:u_credit_card/u_credit_card.dart';

import '../../components/Translate.dart';
import '../../components/prud_container.dart';
import '../../models/reloadly.dart';
import '../../models/theme.dart';

class TransactionDetails extends StatefulWidget{
  final GiftTransaction trans;
  final GiftTransactionDetails tranDetails;

  const TransactionDetails({super.key, required this.trans, required this.tranDetails});

  @override
  TransactionDetailsState createState() => TransactionDetailsState();
}

class TransactionDetailsState extends State<TransactionDetails> {

  ScrollController scrollCtrl = ScrollController();
  Color lTxtColor = prudColorTheme.iconC;
  Color rTxtColor = prudColorTheme.textA;
  Color symbolColor = prudColorTheme.primary;
  double lTxtSize = 13;
  double rTxtSize = 15;
  FontWeight lTxtWeight = FontWeight.w500;
  FontWeight rTxtWeight = FontWeight.w600;
  double smallSize = 8;
  Color smallSizeColor = prudColorTheme.success;
  bool loading = false;
  GiftRedeemCode? giftCard;
  RedeemInstruction? redeemInstruction;



  @override
  void initState() {
    super.initState();
  }

  Future<void> getRedeemDetails() async {
    try{
      if(mounted) setState(() => loading = true);
      if(widget.trans.transactionId != null){
        GiftRedeemCode? redCode = await giftCardNotifier.getRedeemCode(widget.trans.transactionId!);
        if(mounted) setState(() => giftCard = redCode);
      }
      if(widget.trans.product != null &&
          widget.trans.product!.brand != null &&
          widget.trans.product!.brand!.brandId != null){
        RedeemInstruction? redIns = await giftCardNotifier.getRedeemInstructions(widget.trans.product!.brand!.brandId!);
        if(mounted) setState(() => redeemInstruction = redIns);
      }
      if(mounted) setState(() => loading = false);
    }catch(ex){
      if(mounted) setState(() => loading = false);
      debugPrint("getRedeemDetails Error: $ex");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        controller: scrollCtrl,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            spacer.height,
            PrudPanel(
              title: "Transaction Details",
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    spacer.height,
                    Container(
                      width: double.maxFinite,
                      height: 50,
                      color: tabData.getTransactionStatusColor(widget.trans.status!),
                    ),
                    spacer.height,
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Status:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: lTxtSize,
                              color: lTxtColor,
                              fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "${widget.trans.status}",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: tabData.getTransactionStatusColor(widget.trans.status!),
                              fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Reference:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: lTxtSize,
                              color: lTxtColor,
                              fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "${widget.trans.customIdentifier}",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: rTxtColor,
                              fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Transaction ID:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: lTxtSize,
                                color: lTxtColor,
                                fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "${widget.trans.transactionId}",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: rTxtColor,
                              fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Reference:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: lTxtSize,
                                color: lTxtColor,
                                fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "${widget.trans.customIdentifier}",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                                fontSize: rTxtSize,
                                color: rTxtColor,
                                fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Currency:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: lTxtSize,
                              color: lTxtColor,
                              fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              Translate(
                                text: "${widget.tranDetails.selectedCurrencyCode}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                    fontSize: rTxtSize,
                                    color: rTxtColor,
                                    fontWeight: rTxtWeight
                                ),
                              ),
                              spacer.width,
                              Text(
                                "${tabData.getCurrencyName(widget.tranDetails.selectedCurrencyCode!)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                  fontSize: smallSize,
                                  color: smallSizeColor
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Amount:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: lTxtSize,
                              color: lTxtColor,
                              fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              Text(
                                "${tabData.getCurrencySymbol(widget.tranDetails.selectedCurrencyCode!)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                  fontSize: smallSize,
                                  color: smallSizeColor
                                ),
                              ),
                              Text(
                                "${widget.tranDetails.transactionPaidInSelected}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontSize: rTxtSize,
                                  color: rTxtColor,
                                  fontWeight: rTxtWeight
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Transaction Date:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: lTxtSize,
                              color: lTxtColor,
                              fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Translate(
                            text: "${widget.trans.transactionCreatedTime}",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: rTxtColor,
                              fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            spacer.height,
            PrudPanel(
              title: "Gift Card Details",
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    spacer.height,
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Product Name:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: lTxtSize,
                              color: lTxtColor,
                              fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            widget.trans.product!.productName!,
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: tabData.getTransactionStatusColor(widget.trans.status!),
                              fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Brand:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: lTxtSize,
                                color: lTxtColor,
                                fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "${widget.trans.product!.brand!.brandName}",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                                fontSize: rTxtSize,
                                color: rTxtColor,
                                fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Country:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: lTxtSize,
                                color: lTxtColor,
                                fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "${tabData.getCountryName(widget.trans.product!.countryCode!)}",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: rTxtColor,
                              fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Currency:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: lTxtSize,
                                color: lTxtColor,
                                fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              Translate(
                                text: "${widget.trans.product!.currencyCode}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                    fontSize: rTxtSize,
                                    color: rTxtColor,
                                    fontWeight: rTxtWeight
                                ),
                              ),
                              spacer.width,
                              Text(
                                "${tabData.getCurrencyName(widget.trans.product!.currencyCode!)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                  fontSize: smallSize,
                                  color: smallSizeColor
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Quantity:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: lTxtSize,
                                color: lTxtColor,
                                fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "${widget.trans.product!.quantity}",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                                fontSize: rTxtSize,
                                color: rTxtColor,
                                fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Unit Amount:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: lTxtSize,
                                color: lTxtColor,
                                fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              Text(
                                "${tabData.getCurrencySymbol(widget.trans.product!.currencyCode!)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                    fontSize: smallSize,
                                    color: smallSizeColor
                                ),
                              ),
                              Text(
                                "${widget.trans.product!.unitPrice}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontSize: rTxtSize,
                                  color: rTxtColor,
                                  fontWeight: rTxtWeight
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Translate(
                            text: "Total Amount:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: lTxtSize,
                              color: lTxtColor,
                              fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              Text(
                                "${tabData.getCurrencySymbol(widget.trans.product!.currencyCode!)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                    fontSize: smallSize,
                                    color: smallSizeColor
                                ),
                              ),
                              Text(
                                "${widget.trans.product!.totalPrice}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                    fontSize: rTxtSize,
                                    color: rTxtColor,
                                    fontWeight: rTxtWeight
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if(widget.tranDetails.beneficiary != null) spacer.height,
            if(widget.tranDetails.beneficiary != null) PrudPanel(
              title: "Beneficiary Details",
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    spacer.height,
                    BeneficiaryComponent(ben: widget.tranDetails.beneficiary!),
                  ],
                ),
              ),
            ),
            spacer.height,
            PrudPanel(
              title: "GiftCard",
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    spacer.height,
                    if(loading) const LoadingComponent(
                      size: 30,
                      isShimmer: false,
                      defaultSpinnerType: false,
                    ),
                    if(!loading && giftCard != null) Column(
                      children: [
                        CreditCardUi(
                          cardHolderFullName: widget.tranDetails.beneficiary!.fullName,
                          cardNumber: '${giftCard!.cardNumber}',
                          validThru: '10/24',
                          cardProviderLogo: Image.asset(prudImages.logo, width: 40,),
                          showValidThru: false,
                          showBalance: true,
                          showValidFrom: false,
                          currencySymbol: tabData.getCurrencySymbol(widget.trans.product!.currencyCode!),
                          balance: widget.trans.product!.totalPrice,
                          enableFlipping: true,
                          backgroundDecorationImage: DecorationImage(
                            fit: BoxFit.cover,
                            onError: (obj, stack){
                              debugPrint("NetworkImage Error: $obj : $stack");
                            },
                            image: NetworkImage(
                              widget.tranDetails.productPhoto!,
                            )
                          ),
                        ),
                        spacer.height,
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                          children: [
                            FittedBox(
                              child: Translate(
                                text: "Card Number:",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 20,
                                  color: lTxtColor,
                                  fontWeight: lTxtWeight
                                ),
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                "${giftCard!.cardNumber}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontSize: 22,
                                  color: prudColorTheme.secondary,
                                  fontWeight: rTxtWeight
                                ),
                              ),
                            ),
                          ],
                        ),
                        spacer.height,
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                          children: [
                            FittedBox(
                              child: Translate(
                                text: "Card PIN:",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                    fontSize: 20,
                                    color: lTxtColor,
                                    fontWeight: lTxtWeight
                                ),
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                "${giftCard!.pinCode}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontSize: 25,
                                  color: prudColorTheme.primary,
                                  fontWeight: rTxtWeight
                                ),
                              ),
                            ),
                          ],
                        ),
                        spacer.height,
                      ],
                    ),
                  ],
                ),
              ),
            ),
            spacer.height,
            PrudPanel(
              title: "GiftCard Redeem Instructions",
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    spacer.height,
                    if(loading) const LoadingComponent(
                      size: 30,
                      isShimmer: false,
                      defaultSpinnerType: false,
                    ),
                    if(!loading && redeemInstruction != null) Column(
                      children: [
                        if(redeemInstruction!.concise != null) PrudContainer(
                          hasTitle: true,
                          title: "Concise Instructions",
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                            child: Translate(
                              text: "${redeemInstruction!.concise}",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: prudColorTheme.success
                              ),
                              align: TextAlign.left,
                            ),
                          ),
                        ),
                        spacer.height,
                        if(redeemInstruction!.verbose != null) PrudContainer(
                          hasTitle: true,
                          title: "Elaborated Instructions",
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                            child: Translate(
                              text: "${redeemInstruction!.verbose}",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: prudColorTheme.primary
                              ),
                              align: TextAlign.left,
                            ),
                          ),
                        ),
                        spacer.height,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
