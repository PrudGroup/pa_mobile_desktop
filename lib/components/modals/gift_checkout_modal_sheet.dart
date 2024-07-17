import 'package:flutter/material.dart';
import 'package:prudapp/components/gift_transaction_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_showroom.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../../models/theme.dart';
import '../../singletons/i_cloud.dart';
import '../Translate.dart';
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
  bool savingTrans = false;
  bool paymentWasMade = false;
  bool itemsWasBought = false;
  bool transWereSaved = false;
  String? paymentId;
  bool showPay = false;
  List<Widget> showroom = [];
  List<GiftTransaction> unsavedTransactions = [];
  List<CartItem> unsavedGifts = [];
  List<CartItem> failedGifts = [];
  List<GiftTransaction> giftTransactions = [];
  List<GiftTransactionDetails> details = giftCardNotifier.transactions;
  bool hasPaid = giftCardNotifier.selectedItemsPaid;

  Future<void> saveUnsavedTrans() async {
    try{
      if(mounted) {
        setState(() {
          savingTrans = true;
          errorMsg = null;
        });
      }
      if(unsavedTransactions.isNotEmpty && unsavedGifts.isNotEmpty){
        List<GiftTransaction> uTransactions = [];
        List<CartItem> uGifts = [];
        for(var i = 0; i < unsavedTransactions.length; i++){
          var trans = unsavedTransactions[i];
          var gift = unsavedGifts[i];
          bool saved = await giftCardNotifier.addTransToCloud(trans, gift);
          if(mounted && saved) {
            setState(() {
              transWereSaved = true;
              giftTransactions.add(trans);
            });
          }else{
            uTransactions.add(trans);
            uGifts.add(gift);
          }
        }
        if(mounted){
          setState(() {
            unsavedTransactions = uTransactions;
            unsavedGifts = uGifts;
          });
        }
      }
      if(mounted) setState(() => savingTrans = false);
      giftCardNotifier.updateCartListener(true);
    }catch(ex){
      if(mounted) setState(() => savingTrans = false);
      debugPrint("saveTrans: $ex");
    }
  }

  Future<void> setUnfinishedData() async{
    if(paymentWasMade && paymentId != null){
      await giftCardNotifier.updateItemsArePaidFor(paymentWasMade, paymentId!);
      if(unsavedTransactions.isNotEmpty) await giftCardNotifier.addItemsToUnsavedTrans(unsavedTransactions);
      if(unsavedGifts.isNotEmpty) await giftCardNotifier.addItemsToUnsavedGifts(unsavedGifts);
      if(failedGifts.isNotEmpty) await giftCardNotifier.addItemsToFailedItems(failedGifts);
    }
  }

  Future<void> paymentMade(String transID) async {
    try{
      if(mounted) {
        setState(() {
          errorMsg = null;
          paymentWasMade = true;
          paymentId = transID;
        });
      }
      await setUnfinishedData();
      if(giftCardNotifier.selectedItems.isNotEmpty){
        if(mounted) setState(() => purchasing = true);
        List<GiftTransaction> successfulTrans = [];
        List<CartItem> successfulItems = [];
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
            if(mounted) setState(() => itemsWasBought = true);
            successfulTrans.add(trans);
            successfulItems.add(gift);
            bool saved = await giftCardNotifier.addTransToCloud(trans, gift);
            if(mounted && saved) {
              setState(() => transWereSaved = true);
            }else{
              setState(() {
                unsavedTransactions.add(trans);
                unsavedGifts.add(gift);
              });
              await setUnfinishedData();
            }
          }else{
            if(mounted) {
              setState(() => failedGifts.add(gift));
              await setUnfinishedData();
            }
          }
        }
        if(mounted){
          int failed = giftCardNotifier.selectedItems.length - successfulTrans.length;
          if(failed > 0) iCloud.showSnackBar("$failed items failed", context,);
          if(successfulTrans.isNotEmpty && paymentWasMade && itemsWasBought && transWereSaved) {
            for(var success in successfulItems){
              await giftCardNotifier.removeItemFromCart(success);
              giftCardNotifier.removeItemFromSelectedItems(success);
            }
            if(mounted){
              setState(() {
                giftTransactions = successfulTrans;
                loading = false;
                hasAttempted = true;
                itSucceeded = true;
                showPay = false;
              });
              giftCardNotifier.updateCartListener(true);
            }
          }else{
            await setUnfinishedData();
          }
          setState(() {
            purchasing = false;
            errorMsg = null;
            loading = false;
            hasAttempted = true;
            itSucceeded = false;
            showPay = false;
          });
        }
      }else{
        await setUnfinishedData();
        if(mounted){
          setState((){
            purchasing = false;
            errorMsg = "No Item Selected";
            loading = false;
            hasAttempted = true;
            itSucceeded = false;
            showPay = false;
          });
        }
      }
    }catch(ex){
      debugPrint("PaymentMade Error: $ex");
      await setUnfinishedData();
      if(mounted) {
        setState(() {
          purchasing = false;
          errorMsg = "An Unknown Error Occurred. $ex";
          loading = false;
          hasAttempted = true;
          itSucceeded = false;
          showPay = false;
        });
      }
    }
  }

  Future<void> setFigures() async {
    try{
      if(paymentWasMade){
        if(mounted){
          if(giftCardNotifier.failedItems.isNotEmpty) failedGifts = giftCardNotifier.failedItems;
          if(giftCardNotifier.failedItems.isNotEmpty) unsavedGifts = giftCardNotifier.unsavedGifts;
          if(giftCardNotifier.selectedItemPaymentId != null) paymentId = giftCardNotifier.selectedItemPaymentId;
          if(giftCardNotifier.unsavedTrans.isNotEmpty) unsavedTransactions = giftCardNotifier.unsavedTrans;
        }
      }else{
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
                showPay = true;
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
      }
    }catch(ex){
      if(mounted){
        setState(() {
          errorMsg = "Network Issues! Check your internet and t again.";
          loading = false;
        });
      }
      debugPrint("setFigures Error: $ex");
    }
  }

  @override
  void initState() {
    giftCardNotifier.updateCartListener(false);
    Future.delayed(Duration.zero, () async {
      if(mounted) {
        debugPrint("paid: ${giftCardNotifier.selectedItemsPaid}");
        debugPrint("unsavedTrans: ${giftCardNotifier.unsavedTrans.isNotEmpty}");
        debugPrint("unsavedGifts: ${giftCardNotifier.unsavedGifts.isNotEmpty}");
        setState(() {
          showroom = iCloud.getShowroom(context,showroomItems: 4);
          paymentWasMade = giftCardNotifier.selectedItemsPaid;
        });
      }
      await setFigures();
      giftCardNotifier.transactions = [];
    });
    super.initState();
    giftCardNotifier.addListener((){
      if(mounted){
        details = giftCardNotifier.transactions;
      }
    });
  }

  GiftTransaction? getTransactionById(int transId){
    try{
      return giftTransactions.firstWhere((tran) => tran.transactionId == transId);
    }catch(ex){
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double height = screen.height * 0.75;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: prudColorTheme.bgC,
        borderRadius: prudRad
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: SizedBox(
          height: double.maxFinite,
          child: Column(
            children: [
              if(loading || purchasing || savingTrans) const LoadingComponent(
                isShimmer: false,
                size: 30,
                defaultSpinnerType: false,
              ),
              if((!loading && !purchasing && !savingTrans) && totalAmountToPay > 0 && weHaveEnoughBalance && !paymentWasMade && !hasAttempted && showPay) Expanded(
                child:  PayIn(
                  amount: totalAmountToPay,
                  currencyCode: 'NGN',
                  onPaymentMade:(bool verified, String transID) {
                    if (mounted) setState(() => loading = true);
                    if (verified) {
                      Future.delayed(Duration.zero, () async {
                        await paymentMade(transID);
                      });
                    } else {
                      if (mounted) {
                        setState(() {
                          errorMsg = "Unable to verify payment.";
                          loading = false;
                        });
                      }
                    }
                  },
                  onCancel: () {
                      if (mounted) {
                        setState(() {
                          errorMsg = "Payment Canceled";
                          loading = false;
                          hasAttempted = true;
                          itSucceeded = false;
                          showPay = false;
                          paymentWasMade = false;
                          itemsWasBought = false;
                          transWereSaved = false;
                          giftTransactions = [];
                        });
                      }
                    }
                ),
              ),
              if((!loading && !purchasing && !savingTrans) && paymentWasMade && itemsWasBought && giftTransactions.isNotEmpty && transWereSaved && unsavedTransactions.isEmpty && errorMsg == null) Column(
                children: [
                  prudWidgetStyle.getLongButton(
                    onPressed: () => Navigator.pop(context),
                    text: "Finished"
                  ),
                  spacer.height,
                ],
              ),
              if((!loading && !purchasing && !savingTrans) && paymentWasMade && itemsWasBought && giftTransactions.isNotEmpty && transWereSaved && unsavedTransactions.isEmpty && errorMsg == null) Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
                  physics: const BouncingScrollPhysics(),
                  itemCount: giftCardNotifier.transactions.length,
                  itemBuilder: (context, index){
                    GiftTransactionDetails detail = giftCardNotifier.transactions[index];
                    return GiftTransactionComponent(
                      tranDetails: detail,
                      tran: getTransactionById(detail.transId!),
                    );
                  },
                )
              ),
              if(!loading && !purchasing && !savingTrans) Column(
                children: [
                  if(paymentWasMade && paymentId != null && !itemsWasBought) Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        spacer.height,
                        Translate(
                          text: "Payment was successful but your gift transaction seems to have failed. You must try again.",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        prudWidgetStyle.getLongButton(
                          onPressed: () async => paymentMade(paymentId!),
                          text: "Try Purchasing"
                        ),
                        spacer.height,
                      ],
                    ),
                  ),
                  if(unsavedTransactions.isEmpty && paymentWasMade && itemsWasBought && giftCardNotifier.selectedItems.isNotEmpty) Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        spacer.height,
                        Translate(
                          text: "Some gift transaction seems to have failed. Your selected gifts need go through.",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        prudWidgetStyle.getLongButton(
                          onPressed: () async => paymentMade(paymentId!),
                          text: "Get Remaining Gifts"
                        ),
                        spacer.height,
                      ],
                    ),
                  ),
                  if(unsavedTransactions.isNotEmpty) Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        spacer.height,
                        Translate(
                          text: "Oops!. Some gifts transactions could not be saved. Check your network and try again.",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        prudWidgetStyle.getLongButton(
                            onPressed: saveUnsavedTrans,
                            text: "Save Gifts Transactions"
                        ),
                        spacer.height,
                      ],
                    ),
                  ),
                  if(errorMsg != null && unsavedTransactions.isEmpty) Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Translate(
                      text: "$errorMsg",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: prudColorTheme.primary
                      ),
                      align: TextAlign.center,
                    ),
                  ),
                ],
              ),
              if(loading || purchasing || savingTrans || (giftTransactions.isEmpty && !showPay)) Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: PrudShowroom(items: showroom,),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
