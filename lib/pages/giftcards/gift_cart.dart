import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/components/gift_cart_item_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';

import '../../components/Translate.dart';
import '../../components/modals/gift_checkout_modal_sheet.dart';
import '../../models/theme.dart';
import '../../singletons/tab_data.dart';

class GiftCart extends StatefulWidget {
  const GiftCart({super.key});

  @override
  GiftCartState createState() => GiftCartState();
}

class GiftCartState extends State<GiftCart> {
  List<CartItem> selectedItems = giftCardNotifier.selectedItems;
  List<CartItem> cartItems = giftCardNotifier.cartItems;
  Widget noItemFound = tabData.getNotFoundWidget(
    title: "No Item",
    desc: "You cart is empty! Start shopping for gifts."
  );
  bool allSelected = giftCardNotifier.selectedItems.length == giftCardNotifier.cartItems.length;
  double totalDiscount = 0;
  double totalCharges = 0;
  double totalToPay = 0;
  double totalAfterDiscountRemoved = 0;
  Currency? selectedCurrency;
  bool loading = false;
  bool paying = false;
  bool cartCanListen = giftCardNotifier.cartCanListen;

  Future<void> calculateTotals() async {
    try{
      if(selectedCurrency != null){
        if(mounted) setState(() => loading = true);
        String? cur;
        double grandAmount = 0, charges = 0, afterDiscount = 0, discounts = 0;
        for(CartItem item in selectedItems){
          cur = item.senderCur;
          double chargesInSelectedCur = await currencyMath.convert(
            amount: item.charges, quoteCode: selectedCurrency!.code, baseCode: cur
          );
          double afterDiscountInSelectedCur = await currencyMath.convert(
            amount: item.amount, quoteCode: selectedCurrency!.code, baseCode: cur
          );
          double discountInSelectedCur = await currencyMath.convert(
            amount: item.totalDiscount, quoteCode: selectedCurrency!.code, baseCode: cur
          );
          double grandInSelectedCur = await currencyMath.convert(
            amount: item.grandTotal, quoteCode: selectedCurrency!.code, baseCode: cur
          );
          charges += chargesInSelectedCur;
          afterDiscount += afterDiscountInSelectedCur;
          discounts += discountInSelectedCur;
          grandAmount += grandInSelectedCur;
        }
        if(mounted){
          setState(() {
            totalDiscount = currencyMath.roundDouble(discounts, 2);
            totalCharges = currencyMath.roundDouble(charges,2);
            totalAfterDiscountRemoved = currencyMath.roundDouble(afterDiscount,2);
            totalToPay = currencyMath.roundDouble(grandAmount,2);
            loading = false;
          });
        }
      }
    }catch(ex){
      if(mounted) setState(() => loading = false);
      debugPrint("GiftCart calculateTotals Errors: $ex");
    }
  }

  Future<void> makePayment() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: prudColorTheme.bgA,
      elevation: 5,
      isScrollControlled: true,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: prudRad,
      ),
      builder: (context){
        return GiftCheckoutModalSheet(
          amount: totalToPay,
          currencyCode: selectedCurrency!.code,
        );
      }
    ).whenComplete(() async {
      if(giftCardNotifier.selectedItems.isNotEmpty && giftCardNotifier.selectedItemsPaid) {
        await makePayment();
      } else{
        await giftCardNotifier.clearAllSavePaymentDetails();
        if(mounted) Navigator.pop(context);
      }
    });
  }

  void selectCurrency() {
    showCurrencyPicker(
      context: context,
      favorite: ["NGN", "GBP", "USD", "EUR", "CAD"],
      onSelect: (Currency cur) async {
        try{
          if(mounted){
            setState(() {
              selectedCurrency = cur;
            });
            await calculateTotals();
          }
        }catch(ex){
          debugPrint("Gift Cart selectCurrency Error: $ex");
        }
      }
    );
  }

  Future<void> refresh() async {
    if(mounted){
      setState(() {
        selectedItems = giftCardNotifier.failedItems.isNotEmpty? giftCardNotifier.failedItems : giftCardNotifier.selectedItems;
        cartItems = giftCardNotifier.cartItems;
        allSelected = cartItems.length == selectedItems.length;
        if(selectedItems.isNotEmpty) selectedCurrency = tabData.getCurrency(selectedItems[0].senderCur);
      });
    }
    await calculateTotals();
  }

  @override
  void initState() {
    try{
      Future.delayed(Duration.zero, () async {
        if(cartCanListen) await refresh();
      });
    }catch(ex){
      debugPrint("Error: $ex");
    }
    giftCardNotifier.addListener(() async {
      try{
        if(mounted) setState(() => cartCanListen = giftCardNotifier.cartCanListen);
        if(cartCanListen) await refresh();
      }catch(ex){
        debugPrint("Error: $ex");
      }
    });
    super.initState();
  }

  Future<void> selectAllCheckboxClicked(bool status) async {
    try{
      if(status == true){
        giftCardNotifier.selectAllItems();
      }else{
        giftCardNotifier.unselectAllItems();
      }
      if(mounted) setState(() => allSelected = status);
      await refresh();
    }catch(ex){
      debugPrint("CheckboxClicked Error: $ex");
    }
  }

  @override
  void dispose() {
    giftCardNotifier.removeListener((){});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Gift Cart",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: [
          if(cartItems.isNotEmpty) Container(
            width: 100,
            margin: const EdgeInsets.only(bottom: 0),
            child: FormBuilderCheckbox(
              enabled: true,
              initialValue: allSelected,
              selected: allSelected,
              activeColor: prudColorTheme.bgA,
              checkColor: prudColorTheme.secondary,
              name: "select_all",
              title: Translate(
                text: "All",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                  fontSize: 14,
                  color: prudColorTheme.bgA,
                ),
              ),
              onChanged: (bool? value) {
                if(value != null) selectAllCheckboxClicked(value);
              },
            ),
          ),
          if(selectedItems.isNotEmpty) IconButton(
            onPressed: selectCurrency,
            icon: const Icon(Icons.currency_exchange),
            color: prudColorTheme.bgA,
            iconSize: 20,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isNotEmpty?
            ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: cartItems.length,
              itemBuilder: (context, index){
                return GiftCartItemComponent(item: cartItems[index], index: index,);
              }
            )
                :
            noItemFound
          ),
          Container(
            width: screen.width,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              minHeight: 100,
            ),
            color: prudColorTheme.primary,
            child: Column(
              children: [
                spacer.height,
                if(selectedItems.isEmpty) Translate(
                  text: "You need to select the items you want checked-out to see summation.",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 12,
                    color: prudColorTheme.lineB,
                    fontWeight: FontWeight.w500
                  ),
                ),
                loading?
                  Center(
                    child: LoadingComponent(
                      isShimmer: false,
                      size: 50,
                      spinnerColor: prudColorTheme.bgB,
                    ),
                  )
                    :
                  (
                   selectedCurrency != null?
                   Column(
                     children: [
                       if(selectedItems.isNotEmpty) Translate(
                         text: "Summation is done in the currency attached to the first item in your cart. You can decide to change it.",
                         style: prudWidgetStyle.tabTextStyle.copyWith(
                             fontSize: 12,
                             color: prudColorTheme.lineB,
                             fontWeight: FontWeight.w500
                         ),
                       ),
                       spacer.height,
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Translate(
                             text: "Total Discount:",
                             style: prudWidgetStyle.tabTextStyle.copyWith(
                                 fontSize: 16,
                                 color: prudColorTheme.bgA,
                                 fontWeight: FontWeight.w600
                             ),
                           ),
                           Row(
                             children: [
                               Text(
                                 selectedCurrency!.symbol,
                                 style: tabData.tBStyle.copyWith(
                                     fontSize: 14,
                                     color: prudColorTheme.lineB
                                 ),
                               ),
                               Text(
                                 "$totalDiscount",
                                 style: TextStyle(
                                   fontSize: 18,
                                   color: prudColorTheme.iconD,
                                 ),
                                 textAlign: TextAlign.right,
                               ),
                             ],
                           ),
                         ],
                       ),
                       spacer.height,
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Translate(
                             text: "Cost After Discount:",
                             style: prudWidgetStyle.tabTextStyle.copyWith(
                                 fontSize: 16,
                                 color: prudColorTheme.bgA,
                                 fontWeight: FontWeight.w600
                             ),
                           ),
                           Row(
                             children: [
                               Text(
                                 selectedCurrency!.symbol,
                                 style: tabData.tBStyle.copyWith(
                                     fontSize: 14,
                                     color: prudColorTheme.lineB
                                 ),
                               ),
                               Text(
                                 "$totalAfterDiscountRemoved",
                                 style: TextStyle(
                                   fontSize: 18,
                                   color: prudColorTheme.iconD,
                                 ),
                                 textAlign: TextAlign.right,
                               ),
                             ],
                           ),
                         ],
                       ),
                       spacer.height,
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Translate(
                             text: "Total Charges: ",
                             style: prudWidgetStyle.tabTextStyle.copyWith(
                                 fontSize: 16,
                                 color: prudColorTheme.bgA,
                                 fontWeight: FontWeight.w600
                             ),
                           ),
                           Row(
                             children: [
                               Text(
                                 selectedCurrency!.symbol,
                                 style: tabData.tBStyle.copyWith(
                                     fontSize: 14,
                                     color: prudColorTheme.lineB
                                 ),
                               ),
                               Text(
                                 "$totalCharges",
                                 style: TextStyle(
                                   fontSize: 18,
                                   color: prudColorTheme.iconD,
                                 ),
                                 textAlign: TextAlign.right,
                               ),
                             ],
                           ),
                         ],
                       ),
                       Flex(
                         direction: Axis.horizontal,
                         mainAxisAlignment: MainAxisAlignment.end,
                         children: [
                           SizedBox(
                             width: screen.width/4,
                             child: Divider(
                               height: 10,
                               indent: 5.0,
                               endIndent: 0.0,
                               thickness: 2.0,
                               color: prudColorTheme.iconD,
                             ),
                           )
                         ],
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Translate(
                             text: "Grand Total: ",
                             style: prudWidgetStyle.tabTextStyle.copyWith(
                               fontSize: 16,
                               color: prudColorTheme.bgA,
                               fontWeight: FontWeight.w600
                             ),
                           ),
                           Row(
                             children: [
                               Text(
                                 selectedCurrency!.symbol,
                                 style: tabData.tBStyle.copyWith(
                                   fontSize: 14,
                                   color: prudColorTheme.lineB
                                 ),
                               ),
                               Text(
                                 "$totalToPay",
                                 style: TextStyle(
                                   fontSize: 18,
                                   color: prudColorTheme.iconD,
                                 ),
                                 textAlign: TextAlign.right,
                               ),
                             ],
                           ),
                         ],
                       ),
                       spacer.height,
                       Flex(
                         direction: Axis.horizontal,
                         mainAxisAlignment: MainAxisAlignment.end,
                         children: [
                           if(!paying) prudWidgetStyle.getShortButton(
                             onPressed: makePayment,
                             text: "Make Payment",
                             isSmall: false,
                             makeLight: true,
                           ),
                           if(paying) LoadingComponent(
                             isShimmer: false,
                             spinnerColor: prudColorTheme.lineC,
                             size: 40,
                           ),
                         ],
                       ),
                       spacer.height,
                     ],
                   )
                   :
                   const SizedBox()
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
