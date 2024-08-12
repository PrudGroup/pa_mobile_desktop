import 'package:flutter/material.dart';
import 'package:prudapp/components/pay_from_wallet.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/utility_transaction_component.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/models/wallet.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:prudapp/singletons/utility_notifier.dart';

import '../../models/theme.dart';
import '../../singletons/currency_math.dart';
import '../../singletons/i_cloud.dart';
import '../../singletons/influencer_notifier.dart';
import '../../singletons/shared_local_storage.dart';
import '../loading_component.dart';
import '../prud_showroom.dart';

class UtilityOrderModalSheet extends StatefulWidget {
  final UtilityOrder order;
  final double amountToPay;
  final double customerDiscount;
  final String currencyCode;
  final double amountInNaira;
  final double referralCustomerDiscountPercentage;
  final double customerDiscountInNaira;

  const UtilityOrderModalSheet({
    super.key, required this.order,
    required this.amountToPay,
    required this.customerDiscount,
    required this.currencyCode,
    required this.amountInNaira,
    required this.referralCustomerDiscountPercentage,
    required this.customerDiscountInNaira
  });

  @override
  UtilityOrderModalSheetState createState() => UtilityOrderModalSheetState();
}

class UtilityOrderModalSheetState extends State<UtilityOrderModalSheet> {
  bool loading = true;
  List<Widget> showroom = [];
  bool showPayment = true;
  bool utilityPaymentMade = false;
  bool paymentAttempted = false;
  String? utilityPaymentId;
  bool hasBoughtTrans = false;
  UtilityTransaction? trans;
  UtilityTransactionDetails? transDetails;
  UtilityTransactionDetails? unsavedUtilityTransDetails;
  UtilityTransaction? unsavedUtilityTrans;
  bool hasBoughtTransButNotSaved = false;
  UtilityOrderResult? orderResult;
  bool transactionCompleted = false;

  Future<void> saveTransDetails(UtilityTransaction trn, UtilityTransactionDetails utd) async {
    await tryAsync("saveTransDetails", () async {
      if(mounted) setState(() => loading = true);
      bool saved = await utilityNotifier.saveTransactionToCloud(utd);
      if(saved){
        if(mounted){
          utilityNotifier.clearAllSavePaymentDetails();
          setState(() {
            trans = trn;
            transDetails = utd;
            unsavedUtilityTrans = null;
            unsavedUtilityTransDetails = null;
            hasBoughtTransButNotSaved = false;
            transactionCompleted = true;
            loading = false;
          });
        }
      }else{
        if(mounted){
          utilityNotifier.updateUnsavedTrans(trn);
          utilityNotifier.updateUnsavedUtilityDetails(utd);
          setState(() {
            unsavedUtilityTrans = trn;
            unsavedUtilityTransDetails = utd;
            loading = false;
          });
        }
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  Future<void> saveToCloud(UtilityOrderResult res) async {
    await tryAsync("UtilityOrderModalSheet.saveToCloud", () async {
      if(mounted) setState(() => hasBoughtTrans = true);
      UtilityTransaction? trn = await utilityNotifier.getTransactionById(res.id!);
      if(trn != null && trn.transaction != null){
        debugPrint("Transaction: ${trn.transaction}");
        double expIncome = widget.amountInNaira - trn.transaction!.amount!;
        double income = expIncome > 0? expIncome : 0;
        double costInSelectedCur = await currencyMath.convert(
          amount: trn.transaction!.amount!,
          quoteCode: "NGN",
          baseCode: trn.transaction!.amountCurrencyCode!
        );
        double prudProfit = 0, referralsGot = 0, installCommission = 0, referralCommission = 0, commissionsPerAff = 0;
        String? installReferral = myStorage.installReferralCode, linkReferral = myStorage.rechargeReferral;
        if(income > 0){
          commissionsPerAff = income * utilityCustomerDiscountInPercentage;
          if(installReferral != null){
            installCommission = commissionsPerAff;
          }
          if(linkReferral != null){
            referralCommission = commissionsPerAff - (commissionsPerAff * (widget.referralCustomerDiscountPercentage/100));
          }
          referralsGot = referralCommission + installCommission;
          prudProfit = income - referralsGot;
        }
        UtilityTransactionDetails utd = UtilityTransactionDetails(
          transId: res.id,
          transDate: DateTime.parse(res.submittedAt!),
          affId: myStorage.user!.id,
          customerGot: widget.customerDiscountInNaira,
          income: income,
          transactionCost: trn.transaction!.amount!,
          transactionCostInSelected: costInSelectedCur,
          transactionPaid: widget.amountInNaira,
          transactionPaidInSelected: widget.amountToPay,
          transCurrency: "NGN",
          selectedCurrencyCode: widget.currencyCode,
          installReferralCommission: installCommission,
          installReferralId: installReferral,
          refunded: false,
          referralCommission: referralCommission,
          referralId: linkReferral,
          profitForPrudapp: prudProfit,
          referralsGot: referralsGot,
          commissionFromReloadly: trn.transaction!.discount?? 0,
        );
        await saveTransDetails(trn, utd);
      }else{
        if(mounted){
          setState(() {
            hasBoughtTransButNotSaved = true;
            loading = false;
          });
        }
      }
    }, error: () async {
      if(mounted) setState(() => loading = false);
    });
  }

  Future<void> makeTransaction() async {
    WalletAction refundAction = WalletAction(
      amount: widget.amountInNaira,
      affId: myStorage.user!.id!,
      selectedCurrency: widget.currencyCode,
      amtInSelectedCurrency: widget.amountToPay,
      channel: "REFUNDED: $utilityPaymentId : Utility",
      isCreditAction: true
    );
    await tryAsync("makeTransaction", () async {
      if(mounted) setState(() => loading = true);
      UtilityOrderResult? res = await utilityNotifier.makeOrder(widget.order);
      if(mounted) setState(() => orderResult = res);
      if(res != null && res.status != 'FAILED' && res.status != 'REFUNDED'){
        await saveToCloud(res);
      }else{
        if(mounted && res != null && (res.status == 'FAILED' || res.status == 'REFUNDED')){
          setState(() {
            hasBoughtTrans = false;
          });
          if(utilityPaymentMade && utilityPaymentId != null) {
            WalletTransactionResult resp = await influencerNotifier.creditOrDebitWallet(refundAction);
            if(resp.succeeded){
              utilityNotifier.clearAllSavePaymentDetails();
            }
          }
        }
      }
    }, error: () async {
      if(utilityPaymentMade && utilityPaymentId != null && !hasBoughtTrans){
        WalletTransactionResult resp = await influencerNotifier.creditOrDebitWallet(refundAction);
        if(resp.succeeded){
          utilityNotifier.clearAllSavePaymentDetails();
        }
      }
      if(mounted) setState(() => loading = false);
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(mounted) {
        setState(() {
          showroom = iCloud.getShowroom(context,showroomItems: 4);
          loading = false;
        });
      }
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
                if(loading) const LoadingComponent(
                  isShimmer: false,
                  size: 30,
                  defaultSpinnerType: false,
                ),
                if(!loading) Column(
                  children: [
                    if(showPayment && !utilityPaymentMade) PayFromWallet(
                        currencyCode: widget.currencyCode,
                        walletType: WalletType.influencer,
                        forDesc: "Utility Payment",
                        amountInNaira: widget.amountInNaira,
                        amount: widget.amountToPay,
                        onPaymentCompleted: (WalletTransactionResult status){
                          if(mounted){
                            setState(() {
                              utilityPaymentMade = status.succeeded;
                              if(status.tran != null) utilityPaymentId = status.tran!.transId;
                              paymentAttempted = true;
                            });
                            if(utilityPaymentId != null && utilityPaymentMade) {
                              utilityNotifier.updatePaymentStatus(utilityPaymentMade, utilityPaymentId!);
                              makeTransaction();
                            }
                          }
                        },
                        onCanceled: (){
                          if(mounted){
                            setState(() {
                              utilityPaymentMade = false;
                              paymentAttempted = true;
                              Navigator.pop(context);
                            });
                          }
                        }
                    ),
                    if(utilityPaymentMade && orderResult != null && hasBoughtTransButNotSaved) Column(
                      children: [
                        spacer.height,
                        Translate(
                          text: "Transaction not completed. Kindly check your internet and try again.",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.textB,
                            fontSize: 15
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        prudWidgetStyle.getLongButton(
                          onPressed: () => saveToCloud(orderResult!),
                          text: "Complete Transaction",
                          shape: 1,
                        )
                      ],
                    ),
                    if(unsavedUtilityTrans != null && unsavedUtilityTransDetails != null) Column(
                      children: [
                        spacer.height,
                        Translate(
                          text: "Transaction not completed. Kindly check your internet and try again.",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.textB,
                            fontSize: 15
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        prudWidgetStyle.getLongButton(
                          onPressed: () async => saveTransDetails(unsavedUtilityTrans!, unsavedUtilityTransDetails!),
                          text: "Complete Transaction",
                          shape: 1,
                        )
                      ],
                    ),
                    if(transactionCompleted && trans != null && transDetails != null) UtilityTransactionComponent(tranDetails: transDetails!, tran: trans!,)
                  ],
                ),
                spacer.height,
                PrudShowroom(items: showroom,),
              ],
            ),
          )
        )
      ),
    );
  }
}
