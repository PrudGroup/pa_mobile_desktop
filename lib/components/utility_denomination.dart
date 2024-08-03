import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/reloadly.dart';

import '../models/theme.dart';
import '../singletons/tab_data.dart';

class UtilityDenomination extends StatelessWidget {
  final BillerFixedAmount fixedAmount;
  final String currencyCode;
  final bool selected;

  const UtilityDenomination({
    super.key,
    required this.fixedAmount,
    required this.currencyCode,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6, right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: prudColorTheme.bgE,
        border: selected? Border.symmetric(
          horizontal: BorderSide(
            color: prudColorTheme.textD,
            width: 5,
          )
        ) : Border.all(
          color: prudColorTheme.bgA,
          width: 3,
        )
      ),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 50,
          maxHeight: 140.0,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: prudColorTheme.primary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  "${tabData.getCurrencySymbol(currencyCode)}",
                  style: tabData.tBStyle.copyWith(
                    fontSize: 16,
                    color: prudColorTheme.bgC
                  ),
                ),
                Text(
                  "${fixedAmount.amount}",
                  style: TextStyle(
                    fontSize: 25.0,
                    color: prudColorTheme.bgA,
                  ),
                )
              ],
            ),
            if(fixedAmount.description != null) SizedBox(
                width: 100,
                child: Translate(
                  text: tabData.shortenStringWithPeriod(fixedAmount.description!, length: 20),
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: prudColorTheme.lineD
                  ),
                  align: TextAlign.center,
                )
            ),
          ],
        ),
      )
    );
  }
}
