import 'package:flutter/material.dart';

import '../../components/translate_text.dart';
import '../../components/prud_panel.dart';
import '../../models/reloadly.dart';
import '../../models/theme.dart';
import '../../singletons/tab_data.dart';

class RechargeAndUtilityTransactionDetails extends StatefulWidget {
  final TopUpTransaction trans;
  final RechargeTransactionDetails tranDetails;

  const RechargeAndUtilityTransactionDetails({
    super.key, required this.trans, required this.tranDetails
  });

  @override
  RechargeAndUtilityTransactionDetailsState createState() => RechargeAndUtilityTransactionDetailsState();
}

class RechargeAndUtilityTransactionDetailsState extends State<RechargeAndUtilityTransactionDetails> {

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
    });
    super.initState();
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
                            text: "${widget.trans.transactionDate}",
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
              title: "Pin Details",
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
                          widget.trans.operatorName!,
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
                            text: "Country:",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: lTxtSize,
                                color: lTxtColor,
                                fontWeight: lTxtWeight
                            ),
                          ),
                        ),
                        if(widget.trans.countryCode != null) Text(
                          "${tabData.getCountryName(widget.trans.countryCode!)}",
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
                                text: "${widget.trans.deliveredAmountCurrencyCode}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontSize: rTxtSize,
                                  color: rTxtColor,
                                  fontWeight: rTxtWeight
                                ),
                              ),
                              spacer.width,
                              Text(
                                "${tabData.getCurrencyName(widget.trans.deliveredAmountCurrencyCode!)}",
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
                                "${tabData.getCurrencySymbol(widget.trans.deliveredAmountCurrencyCode!)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                    fontSize: smallSize,
                                    color: smallSizeColor
                                ),
                              ),
                              Text(
                                "${widget.trans.deliveredAmount}",
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
            spacer.height,
          ],
        ),
      ),
    );
  }
}
