import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../../models/theme.dart';
import '../loading_component.dart';
import '../pay_in.dart';

class GiftCheckoutModalSheet extends StatefulWidget {
  final double amount;
  final String currencyCode;

  const GiftCheckoutModalSheet({super.key, required this.amount, required this.currencyCode});

  @override
  GiftCheckoutModalSheetState createState() => GiftCheckoutModalSheetState();
}

class GiftCheckoutModalSheetState extends State<GiftCheckoutModalSheet> {
  bool loading = true;
  bool hasAttempted = false;
  bool itSucceeded = false;
  double totalAmountToPay = 0;
  String? errorMsg;
  bool weHaveEnoughBalance = false;
  bool purchasing = false;
  List<GiftTransaction> giftTransactions = [];

  Future<void> paymentMade(bool verified, String transID) async {
    try{
      if(verified && giftCardNotifier.selectedItems.isNotEmpty){
        if(mounted) setState(() => purchasing = true);
        int totalSent = 0, totalFailed = 0;
        List<GiftTransaction> successful = [];
        for(CartItem gift in giftCardNotifier.selectedItems){
          GiftOrder newOrder = GiftOrder(
            productId: gift.product.productId!,
            quantity: gift.quantity,
            senderName: myStorage.user!.fullName!,
            unitPrice: gift.benSelectedDeno,
            preOrder: false,
            recipientEmail: gift.beneficiary!.email,
            recipientPhoneDetails: PhoneDetails(
              countryCode: gift.beneficiary!.countryCode,
              phoneNumber: gift.beneficiary!.parseablePhoneNo
            )
          );
          GiftTransaction? trans = await giftCardNotifier.makeOrder(newOrder);
          if(trans != null && trans.status != "REFUNDED" && trans.status != "FAILED"){
            totalSent++;
            successful.add(trans);
            giftCardNotifier.removeItemFromSelectedItems(gift);
            await giftCardNotifier.addTransToCloud(trans, gift);
          }else{
            totalFailed++;
          }
        }

      }else{

      }
    }catch(ex){
      debugPrint("PaymentMade Error: $ex");
      if(mounted) setState(() => purchasing = false);
    }
  }

  Future<void> setFigures() async {
    try{
      double amount = await currencyMath.convert(
        amount: widget.amount,
        quoteCode: "NGN",
        baseCode: widget.currencyCode
      );
      if(mounted){
        setState(() {
          totalAmountToPay = amount;
          loading = true;
        });
      }
      if(totalAmountToPay > 0){
        bool isOk = await giftCardNotifier.isBalanceSufficient(
          totalAmountToPay, "NGN",
        );
        if(isOk){
          if(mounted) {
            setState(() {
              weHaveEnoughBalance = true;
              loading = false;
            });
          }
        }else{
          if(mounted){
            setState(() {
              errorMsg = "Unable To Complete Transaction. Try Again Later";
              loading = false;
            });
          }
        }
      }else{
        if(mounted){
          setState(() {
            errorMsg = "Transaction Amount too low. Increase and Try Again Later";
            loading = false;
          });
        }
      }
    }catch(ex){
      debugPrint("initState Error: $ex");
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await setFigures();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Container(
      height: screen.height * 0.75,
      decoration: BoxDecoration(
        color: prudColorTheme.bgC,
        borderRadius: prudRad
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: Column(
          children: [
            Column(
              children: [
                spacer.height,
                if (loading)
                  LoadingComponent(
                    shimmerType: 1,
                    height: screen.height - 100,
                  ),
                if(totalAmountToPay > 0 && weHaveEnoughBalance) PayIn(
                    amount: totalAmountToPay,
                    onPaymentMade:(bool verified, String transID) {
                      Future.delayed(Duration.zero, () async {
                        await paymentMade(verified, transID);
                      });
                    },
                    onCancel: () {
                      if (mounted) {
                        setState(() {
                          errorMsg = "Payment Canceled";
                          loading = false;
                          hasAttempted = false;
                          itSucceeded = false;
                        });
                      }
                    }),
                largeSpacer.height,
              ],
            ),
            if(hasAttempted && itSucceeded)Column(
              children: [
                spacer.height,
              ],
            ),
          ],
        )
      ),
    );
  }
}
