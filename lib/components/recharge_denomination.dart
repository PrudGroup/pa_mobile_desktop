import 'package:flutter/material.dart';
import 'package:prudapp/models/theme.dart';

import '../singletons/tab_data.dart';
import 'Translate.dart';

class RechargeDenomination extends StatelessWidget {
  final double amt;
  final String currencySymbol;
  final String? desc;

  const RechargeDenomination({
    super.key,
    required this.amt,
    required this.currencySymbol,
    this.desc
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 50,
        maxHeight: 140.0,
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 6, right: 6),
      decoration: BoxDecoration(
        borderRadius: prudRadAll,
        color: prudColorTheme.primary,
        border: Border.all(
          color: prudColorTheme.bgA,
          width: 3,
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                currencySymbol,
                style: tabData.tBStyle.copyWith(
                  fontSize: 16,
                  color: prudColorTheme.bgC
                ),
              ),
              Text(
                "${amt.toInt()}",
                style: TextStyle(
                  fontSize: 25.0,
                  color: prudColorTheme.bgA,
                ),
              )
            ],
          ),
          if(desc != null) SizedBox(
            width: 100,
            child: Translate(
              text: "$desc",
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
    );
  }
}
