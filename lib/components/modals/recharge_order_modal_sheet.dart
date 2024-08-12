import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:prudapp/components/recharge_transaction_component.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/recharge_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../models/theme.dart';
import '../../models/wallet.dart';
import '../../singletons/currency_math.dart';
import '../../singletons/i_cloud.dart';
import '../pay_from_wallet.dart';
import '../translate_text.dart';
import '../loading_component.dart';
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
  RechargeTransactionDetails? details;
  bool hasPaid = false;
  double discount = 0;
  double referralComInPercentage = 0;
  double amountInSelectedCur = 0;

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
        bool saved = await addTransToCloud(unSavedTrans!);
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

  Future<bool> addTransToCloud(TopUpTransaction tran) async {
    bool saved = false;
    try {
      double grandTotalInNaira = totalAmountToPay;
      double discountInNaira = 0, totalCostInSenderCur = 0;
      if (
        widget.operator.fx != null &&
        widget.operator.fx!.rate != null &&
        widget.operator.commission != null &&
        widget.operator.commission! > 0
      ) {
        discountInNaira = discount / widget.operator.fx!.rate!;
      }
      totalCostInSenderCur = tran.requestedAmount! / widget.operator.fx!.rate!;
      double income = (grandTotalInNaira - tran.requestedAmount!) + discountInNaira;
      double appReferralCommission = income > 0 ? (income * installReferralCommission) : 0;
      double referComm = 0;
      if (referralComInPercentage > 0) {
        double referralSupposeGet = income * referralCommission;
        referComm = referralSupposeGet > 0 ? (referralSupposeGet *
            (referralComInPercentage / 100)) : 0;
      } else {
        referComm = 0;
      }
      if (myStorage.installReferralCode == null) appReferralCommission = 0;
      if (myStorage.giftReferral == null) referComm = 0;
      double profit = income - (referComm + appReferralCommission);
      RechargeTransactionDetails dDetails = RechargeTransactionDetails(
        income: income,
        installReferralCommission: appReferralCommission,
        installReferralId: appReferralCommission > 0 ? myStorage.installReferralCode : null,
        profitForPrudapp: profit,
        customerGot: discountInNaira,
        commissionFromReloadly: discountInNaira,
        referralsGot: appReferralCommission + referComm,
        referralCommission: referComm,
        transCurrency: tran.requestedAmountCurrencyCode,
        referralId: referComm > 0 ? myStorage.giftReferral : null,
        transDate: DateTime.parse(tran.transactionDate!),
        affId: myStorage.user?.id,
        transId: tran.transactionId,
        transactionPaid: grandTotalInNaira,
        transactionPaidInSelected: amountInSelectedCur,
        selectedCurrencyCode: tran.deliveredAmountCurrencyCode,
        transactionCost: tran.requestedAmount,
        transactionCostInSelected: totalCostInSenderCur,
        refunded: false,
        beneficiaryNo: widget.selectedPhone.phoneNumber,
        providerPhoto: widget.operator.logoUrls?[0],
        transactionType: widget.isAirtime ? "Airtime" : "Data Bundle",
      );
      saved = await rechargeNotifier.saveTransactionToCloud(dDetails);
      if (saved == true) {
        if(mounted) setState(() => details = dDetails);
        rechargeNotifier.addToTransactions(dDetails);
      }
    }catch(ex){
      debugPrint("addTransCloud: $ex");
    }
    return saved;
  }

  Future<void> paymentMade(String transID) async {
    WalletAction refundAction = WalletAction(
      amount: totalAmountToPay,
      affId: myStorage.user!.id!,
      selectedCurrency: "NGN",
      amtInSelectedCurrency: totalAmountToPay,
      channel: "REFUNDED: $paymentId : TopUp",
      isCreditAction: true
    );
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
          bool saved = await addTransToCloud(trans);
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
            if(paymentWasMade && paymentId != null && !itemWasBought){
              WalletTransactionResult resp = await influencerNotifier.creditOrDebitWallet(refundAction);
              if(resp.succeeded){
                rechargeNotifier.clearAllSavePaymentDetails();
              }
            }
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
              rechargeNotifier.dataProviders = [];
              rechargeNotifier.airtimeProviders = [];
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
            paymentWasMade = false;
          });
        }
      }else{
        await setUnfinishedData();
        if(paymentWasMade && paymentId != null && !itemWasBought){
          WalletTransactionResult resp = await influencerNotifier.creditOrDebitWallet(refundAction);
          if(resp.succeeded){
            rechargeNotifier.clearAllSavePaymentDetails();
          }
        }
        if(mounted){
          setState((){
            purchasing = false;
            errorMsg = "No Item Selected";
            loading = false;
            hasAttempted = true;
            itSucceeded = false;
            showPay = false;
            paymentWasMade = false;
          });
        }
      }
    }catch(ex){
      debugPrint("PaymentMade Error: $ex");
      await setUnfinishedData();
      if(paymentWasMade && paymentId != null && !itemWasBought){
        WalletTransactionResult resp = await influencerNotifier.creditOrDebitWallet(refundAction);
        if(resp.succeeded){
          rechargeNotifier.clearAllSavePaymentDetails();
        }
      }
      if(mounted) {
        setState(() {
          purchasing = false;
          errorMsg = "An Unknown Error Occurred. $ex";
          loading = false;
          hasAttempted = true;
          itSucceeded = false;
          showPay = false;
          paymentWasMade = false;
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
        bool isInternallyForeign = tabData.checkIfForeign(widget.operator.destinationCurrencyCode!);
        double charges = isLocal? widget.operator.fees!.local! : widget.operator.fees!.international!;
        debugPrint("Foreign: $isInternallyForeign");
        if(isInternallyForeign) charges+=(widget.selectedAmount * rechargeForeignCharge);
        double amount = 0;
        debugPrint("charges: $charges");
        double commission = isLocal? widget.operator.localDiscount! : widget.operator.internationalDiscount!;
        if(commission > 0){
          debugPrint("commission: $commission");
          double customerDiscount = ((commission/100) * widget.selectedAmount) * rechargeCustomerDiscountInPercentage;
          String? linkId = myStorage.getRechargeReferral();
          debugPrint("customerDiscount: $customerDiscount");
          if(linkId != null){
            double? discountFromReferralInPercentage = await influencerNotifier.getLinkReferralPercentage(linkId);
            if(discountFromReferralInPercentage != null && discountFromReferralInPercentage > 0){
              if(mounted) setState(() => referralComInPercentage = discountFromReferralInPercentage);
              double discountFromLink = customerDiscount * (discountFromReferralInPercentage/100);
              customerDiscount = customerDiscount + discountFromLink;
            }
            debugPrint("customerDiscount: $customerDiscount");
          }
          if(mounted) setState(() => discount = customerDiscount);
        }
        double amtInSelectedCur = (widget.selectedAmount - discount) + charges;
        debugPrint("amtInSelectedCur ${widget.operator.destinationCurrencyCode}: $amtInSelectedCur");
        if(mounted) setState(() => amountInSelectedCur = amtInSelectedCur);
        debugPrint("amountInSelectedCur ${widget.operator.destinationCurrencyCode}: $amountInSelectedCur");
        if(widget.operator.fx != null && widget.operator.fx!.rate != null){
          amount = amtInSelectedCur/widget.operator.fx!.rate!;
        }else{
          amount = await currencyMath.convert(
            amount: amtInSelectedCur,
            quoteCode: "NGN",
            baseCode: widget.operator.destinationCurrencyCode!
          );
        }
        debugPrint("ExchangeRate: ${widget.operator.fx!.rate}");
        if(mounted){
          setState(() {
            totalAmountToPay = amount;
            loading = true;
          });
          debugPrint("Amount To Pay: $totalAmountToPay");
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  if(loading || purchasing || savingTrans) const LoadingComponent(
                    isShimmer: false,
                    size: 30,
                    defaultSpinnerType: false,
                  ),
                  if((!loading && !purchasing && !savingTrans) && totalAmountToPay > 0 && weHaveEnoughBalance && !paymentWasMade && !hasAttempted && showPay) PayFromWallet(
                      currencyCode: "NGN",
                      walletType: WalletType.influencer,
                      forDesc: "TopUp Purchase",
                      amountInNaira: totalAmountToPay,
                      amount: totalAmountToPay,
                      onPaymentCompleted: (WalletTransactionResult status){
                        rechargeNotifier.updatePaymentStatus(
                            status.succeeded, status.tran!.transId, widget.isAirtime
                        );
                        if(mounted){
                          setState(() {
                            loading = true;
                            paymentWasMade = status.succeeded;
                            if(status.tran != null) paymentId = status.tran!.transId;
                          });
                          if(paymentId != null && paymentWasMade) {
                            Future.delayed(Duration.zero, () async {
                              await paymentMade(paymentId!);
                            });
                          }else{
                            if (mounted) {
                              setState(() {
                                errorMsg = "Unable to verify payment.";
                                loading = false;
                              });
                            }
                          }
                        }
                      },
                      onCanceled: (){
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
                  if((!loading && !purchasing && !savingTrans) && paymentWasMade && itemWasBought && transaction != null && tranWasSaved && unSavedTrans == null && errorMsg == null) Column(
                    children: [
                      prudWidgetStyle.getLongButton(
                          onPressed: () => Navigator.pop(context),
                          text: "Finished"
                      ),
                      spacer.height,
                    ],
                  ),
                  if((!loading && !purchasing && !savingTrans) && paymentWasMade && itemWasBought && transaction != null && details != null && tranWasSaved && unSavedTrans == null && errorMsg == null) RechargeTransactionComponent(
                    tranDetails: details!,
                    tran: transaction,
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
                  spacer.height,
                  PrudShowroom(items: showroom,),
                ],
              ),
            ),
          )
      ),
    );
  }
}
