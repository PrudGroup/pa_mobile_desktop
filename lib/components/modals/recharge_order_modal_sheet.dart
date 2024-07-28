import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:prudapp/components/recharge_transaction_component.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/recharge_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../models/theme.dart';
import '../../singletons/currency_math.dart';
import '../../singletons/i_cloud.dart';
import '../Translate.dart';
import '../loading_component.dart';
import '../pay_in.dart';
import '../prud_showroom.dart';

class RechargeOrderModalSheet extends StatefulWidget {
  final RechargeOperator operator;
  final double selectedAmount;
  final PhoneNumber selectedPhone;
  final bool isAirtime;
  final bool isLocal;

  const RechargeOrderModalSheet({
    super.key,
    required this.operator,
    required this.selectedAmount,
    required this.selectedPhone,
    this.isAirtime = true,
    this.isLocal = false,
  });

  @override
  RechargeOrderModalSheetState createState() => RechargeOrderModalSheetState();
}

class RechargeOrderModalSheetState extends State<RechargeOrderModalSheet> {
  bool loading = true;
  bool hasAttempted = false;
  bool itSucceeded = false;
  double totalAmountToPay = 0;
  String? errorMsg;
  bool weHaveEnoughBalance = false;
  bool purchasing = false;
  bool savingTrans = false;
  bool paymentWasMade = false;
  bool itemWasBought = false;
  bool tranWasSaved = false;
  String? paymentId;
  bool showPay = false;
  List<Widget> showroom = [];
  TopUpTransaction? transaction;
  TopUpTransaction? unSavedTrans;
  TopUpOrder? unboughtOrder;
  List<RechargeTransactionDetails> details = rechargeNotifier.transactions;
  bool hasPaid = false;

  // remember to add phoneNumberToCache
  // remember commissions even referral's decides what to give

  Future<void> saveUnsavedTrans() async {
    try{
      if(mounted) {
        setState(() {
          savingTrans = true;
          errorMsg = null;
        });
      }
      if(unSavedTrans != null){
        bool saved = await rechargeNotifier.addTransToCloud(unSavedTrans!, widget.isAirtime);
        if(mounted && saved) {
          setState(() {
            tranWasSaved = true;
            transaction = unSavedTrans;
            unSavedTrans = null;
          });
        }
      }
      if(mounted) setState(() => savingTrans = false);
    }catch(ex){
      if(mounted) setState(() => savingTrans = false);
      debugPrint("saveTrans: $ex");
    }
  }

  Future<void> setUnfinishedData() async{
    if(paymentWasMade && paymentId != null){
      rechargeNotifier.updatePaymentStatus(paymentWasMade, paymentId!, widget.isAirtime);
      if(unSavedTrans != null) await rechargeNotifier.updateUnsavedTrans(unSavedTrans!, isAirtime: widget.isAirtime);
      if(unboughtOrder != null) await rechargeNotifier.updateUnBoughtOrder(unboughtOrder!, isAirtime: widget.isAirtime);
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
      if(totalAmountToPay > 0 && widget.operator.supportsLocalAmounts != null){
        if(mounted) setState(() => purchasing = true);
        TopUpOrder newOrder = TopUpOrder(
          operatorId: widget.operator.operatorId,
          useLocalAmount: widget.isLocal,
          recipientPhone: PhoneNo(
            countryCode: widget.selectedPhone.isoCode,
            number: int.parse(widget.selectedPhone.parseNumber()),
          ),
          amount: widget.isLocal? widget.selectedAmount : (widget.selectedAmount/widget.operator.fx!.rate!),
        );
        TopUpTransaction? trans = await rechargeNotifier.makeTopUpOrder(newOrder);
        if(trans != null && trans.status != "REFUNDED" && trans.status != "FAILED"){
          if(mounted) {
            setState(() {
              itemWasBought = true;
              transaction = trans;
            });
          }
          bool saved = await rechargeNotifier.addTransToCloud(trans, widget.isAirtime);
          if(mounted && saved) {
            setState(() => tranWasSaved = true);
          }else{
            setState(() {
              unSavedTrans = trans;
            });
            await setUnfinishedData();
          }
        }else{
          if(mounted) {
            setState(() => unboughtOrder = newOrder);
            await setUnfinishedData();
          }
        }
        if(mounted){
          if(paymentWasMade && itemWasBought && tranWasSaved) {
            if(mounted){
              setState(() {
                loading = false;
                hasAttempted = true;
                itSucceeded = true;
                showPay = false;
              });
              rechargeNotifier.addItemToPhoneNumber(widget.selectedPhone);
              rechargeNotifier.updateContinuedStatus(false);
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
          if(widget.isAirtime){
            unboughtOrder = rechargeNotifier.airUnBoughtOrder;
            unSavedTrans = rechargeNotifier.unsavedAirtimeTrans;
            paymentId = rechargeNotifier.dataPaymentId;
          }else{
            unboughtOrder = rechargeNotifier.dataUnBoughtOrder;
            unSavedTrans = rechargeNotifier.unsavedDataTrans;
            paymentId = rechargeNotifier.dataPaymentId;
          }
        }
      }else{
        bool isLocal = widget.isLocal;
        bool isInternallyForeign = tabData.checkIfLocal(widget.operator.destinationCurrencyCode!);
        double charges = isLocal? widget.operator.fees!.local! : widget.operator.fees!.international!;
        if(isInternallyForeign) charges+=(widget.selectedAmount * rechargeForeignCharge);
        double amount = 0;
        if(widget.operator.fx != null && widget.operator.fx!.rate != null){
          amount = (widget.selectedAmount + charges)/widget.operator.fx!.rate!;
        }else{
          amount = await currencyMath.convert(
            amount: widget.selectedAmount + charges,
            quoteCode: "NGN",
            baseCode: widget.operator.destinationCurrencyCode!
          );
        }
        if(mounted){
          setState(() {
            totalAmountToPay = amount;
            loading = true;
          });
        }
        if(totalAmountToPay > 0){
          bool isOk = await rechargeNotifier.isBalanceSufficient(
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
          errorMsg = "Network Issues! Check your internet and try again.";
          loading = false;
        });
      }
      debugPrint("setFigures Error: $ex");
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(mounted) {
        setState(() {
          showroom = iCloud.getShowroom(context,showroomItems: 4);
          paymentWasMade = widget.isAirtime? rechargeNotifier.airPaymentMade : rechargeNotifier.dataPaymentMade;
        });
      }
      await setFigures();
      rechargeNotifier.transactions = [];
    });
    super.initState();
    rechargeNotifier.addListener((){
      if(mounted){
        details = rechargeNotifier.transactions;
      }
    });
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
                      countryCode: "NG",
                      useOpay: false,
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
                            itemWasBought = false;
                            tranWasSaved = false;
                            transaction = null;
                          });
                        }
                      }
                  ),
                ),
                if((!loading && !purchasing && !savingTrans) && paymentWasMade && itemWasBought && transaction != null && tranWasSaved && unSavedTrans == null && errorMsg == null) Column(
                  children: [
                    prudWidgetStyle.getLongButton(
                        onPressed: () => Navigator.pop(context),
                        text: "Finished"
                    ),
                    spacer.height,
                  ],
                ),
                if((!loading && !purchasing && !savingTrans) && paymentWasMade && itemWasBought && transaction != null && tranWasSaved && unSavedTrans == null && errorMsg == null) Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
                      physics: const BouncingScrollPhysics(),
                      itemCount: rechargeNotifier.transactions.length,
                      itemBuilder: (context, index){
                        RechargeTransactionDetails detail = rechargeNotifier.transactions[index];
                        return RechargeTransactionComponent(
                          tranDetails: detail,
                          tran: transaction,
                        );
                      },
                    )
                ),
                if(!loading && !purchasing && !savingTrans) Column(
                  children: [
                    if(paymentWasMade && paymentId != null && !itemWasBought) Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        children: [
                          spacer.height,
                          Translate(
                            text: "Payment was successful but your recharge transaction seems to have failed. You must try again.",
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
                    if(unSavedTrans == null && paymentWasMade && itemWasBought && unboughtOrder != null) Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        children: [
                          spacer.height,
                          Translate(
                            text: "Your selected recharge did not go through.",
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
                              text: "Try Again"
                          ),
                          spacer.height,
                        ],
                      ),
                    ),
                    if(unSavedTrans != null) Padding(
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
                    if(errorMsg != null && unSavedTrans != null) Padding(
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
                if(loading || purchasing || savingTrans || (transaction != null && !showPay)) Expanded(
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
