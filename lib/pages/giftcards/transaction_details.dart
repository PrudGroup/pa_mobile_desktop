import 'package:flutter/material.dart';
import 'package:prudapp/components/beneficiary_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../components/Translate.dart';
import '../../components/prud_container.dart';
import '../../components/redeem_card.dart';
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
  double smallSize = 10;
  Color smallSizeColor = prudColorTheme.success;
  bool loading = false;
  List<GiftRedeemCode>? giftCard;
  RedeemInstruction? redeemInstruction;



  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getRedeemDetails();
    });
    super.initState();
  }

  Future<void> getRedeemDetails() async {
    try{
      if(mounted) setState(() => loading = true);
      if(widget.trans.transactionId != null){
        List<GiftRedeemCode>? redCodes = await giftCardNotifier.getRedeemCode(widget.trans.transactionId!);
        if(mounted) setState(() => giftCard = redCodes);
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
            mediumSpacer.height,
            PrudPanel(
              title: "Transaction Details",
              bgColor: prudColorTheme.bgC,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    spacer.height,
                    Container(
                      width: double.maxFinite,
                      height: 20,
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
                        Text(
                          "${widget.trans.customIdentifier}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                            fontSize: rTxtSize,
                            color: rTxtColor,
                            fontWeight: rTxtWeight
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
              bgColor: prudColorTheme.bgC,
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
                        Text(
                          widget.trans.product!.productName!,
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: tabData.getTransactionStatusColor(widget.trans.status!),
                              fontWeight: rTxtWeight
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
                        Text(
                          "${widget.trans.product!.brand!.brandName}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: rTxtColor,
                              fontWeight: rTxtWeight
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
                        Text(
                          "${tabData.getCountryName(widget.trans.product!.countryCode!)}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: rTxtColor,
                              fontWeight: rTxtWeight
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
                        Text(
                          "${widget.trans.product!.quantity}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: rTxtColor,
                              fontWeight: rTxtWeight
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
              bgColor: prudColorTheme.bgC,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    spacer.height,
                    BeneficiaryComponent(
                      ben: widget.tranDetails.beneficiary!,
                      forSelection: false,
                    ),
                  ],
                ),
              ),
            ),
            spacer.height,
            PrudPanel(
              title: "GiftCard",
              bgColor: prudColorTheme.bgC,
              child: Column(
                children: [
                  mediumSpacer.height,
                  if(!loading && giftCard != null && giftCard!.length > 1) Translate(
                    text: "Swipe right to see more cards.",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: prudColorTheme.success,
                      fontSize: 16
                    ),
                    align: TextAlign.center,
                  ),
                  if(!loading && giftCard != null && giftCard!.length > 1) spacer.height,
                  if(loading) Padding(
                    padding: const EdgeInsets.all(5),
                    child: LoadingComponent(
                      size: 30,
                      isShimmer: false,
                      defaultSpinnerType: false,
                      spinnerColor: tabData.getTransactionStatusColor(widget.trans.status!),
                    ),
                  ),
                  if(!loading && giftCard != null) SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: giftCard!.length,
                      itemBuilder: (context, index){
                        return RedeemCard(
                          tranDetails: widget.tranDetails,
                          trans: widget.trans,
                          giftCard: giftCard![index],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            spacer.height,
            PrudPanel(
              bgColor: prudColorTheme.bgC,
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
