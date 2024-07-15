import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_panel.dart';

import '../../components/Translate.dart';
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
                          child: Translate(
                            text: "Reference:",
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: rTxtSize,
                              color: rTxtColor,
                              fontWeight: rTxtWeight
                            ),
                          ),
                        ),
                      ],
                    )
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
