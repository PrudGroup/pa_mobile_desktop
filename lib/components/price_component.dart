import 'package:flutter/material.dart';
import 'package:prudapp/components/point_divider.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class PriceComponent extends StatelessWidget {
  final String currency;
  final double price;
  final Color? symbolColor;
  final Color? priceColor;
  final Color? decimalColor;
  final Color? currencyColor;
  final double? priceSize;
  final double? symbolSize;
  final double? decimalSize;
  final double? currencySize;

  const PriceComponent({ 
    super.key, 
    required this.currency, 
    required this.price, 
    this.symbolColor, this.priceColor, 
    this.decimalColor, this.currencyColor, 
    this.priceSize, this.symbolSize, 
    this.decimalSize, this.currencySize 
  });
  
  List<String> getPriceInArray(){
    return "$price".split(".");
  }
  
  @override
  Widget build(BuildContext context) {
    List<String> strPrice = getPriceInArray();
    String mainPrice = strPrice[0];
    String decimalPrice = strPrice[1]?? '00';
    
    return Row(
      children: [
        Text(
          "${tabData.getCurrencySymbol(currency)}",
          style: tabData.tBStyle.copyWith(
            color: symbolColor?? prudColorTheme.bgA,
            fontSize: symbolSize?? 15.0,
            fontWeight: FontWeight.w600
          ),
        ),
        Text(
          mainPrice,
          style: prudWidgetStyle.btnTextStyle.copyWith(
            color: priceColor?? prudColorTheme.buttonC,
            fontSize: priceSize?? 18.0,
            fontWeight: FontWeight.w700
          ),
        ),
        Stack(
          children: [
            Row(
              children: [
                PointDivider(pointColor: prudColorTheme.bgD),
                Text(
                  decimalPrice,
                  style: prudWidgetStyle.btnTextStyle.copyWith(
                    color: decimalColor?? prudColorTheme.bgD,
                    fontSize: decimalSize?? 13.0,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Text(
                decimalPrice,
                style: prudWidgetStyle.tabTextStyle.copyWith(
                  color: currencyColor?? prudColorTheme.buttonC,
                  fontSize: currencySize?? 13.0,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}