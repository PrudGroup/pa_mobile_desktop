import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/pin_verifier.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';
import '../models/wallet.dart';

class PayFromWallet extends StatefulWidget {
  final double amount;
  final String currencyCode;
  final double amountInNaira;
  final WalletType walletType;
  final String forDesc;
  final Function(WalletTransactionResult) onPaymentCompleted;
  final Function() onCanceled;

  const PayFromWallet({
    super.key,
    required this.currencyCode,
    required this.walletType,
    required this.forDesc,
    required this.amountInNaira,
    required this.amount,
    required this.onPaymentCompleted,
    required this.onCanceled,
  });

  @override
  PayFromWalletState createState() => PayFromWalletState();
}

class PayFromWalletState extends State<PayFromWallet> {
  bool paymentMade = false;
  bool balanceIsSufficient = false;
  bool hasCheckedWallet = false;
  bool loading = false;
  double walletBalance = 0;
  double amountInWalletSelectedCurrency = 0;
  bool continueTransaction = false;
  bool pinVerified = false;
  bool unableToGetWallet = false;


  Future<void> checkBalance() async {
    await tryAsync("checkBalance", () async {
      debugPrint("Wallet not gotten yet A");
      if(myStorage.user != null && myStorage.user!.id != null && influencerNotifier.influencerWalletCurrencyCode != null){
        if(mounted) {
          setState(() {
            loading = true;
            unableToGetWallet = false;
          });
        }
        dynamic wallet;
        debugPrint("Wallet not gotten yet");
        switch(widget.walletType){
          case WalletType.influencer: {
            wallet = await influencerNotifier.getWallet(myStorage.user!.id!);
            debugPrint("Wallet gotten: $wallet");
          }
          case WalletType.bus: {}
          case WalletType.studio: {}
          case WalletType.switzStore: {}
          case WalletType.shipper: {}
          default: {}
        }
        if(wallet != null && mounted){
          double amtInWalletSelectedCurrency = await currencyMath.convert(
            amount: widget.amount,
            quoteCode: influencerNotifier.influencerWalletCurrencyCode!,
            baseCode: widget.currencyCode,
          );
          debugPrint("amtInWallet: $amtInWalletSelectedCurrency");
          setState(() {
            walletBalance = wallet.balance;
            hasCheckedWallet = true;
            unableToGetWallet = false;
            balanceIsSufficient = wallet.checkIfSufficient(widget.amountInNaira);
            amountInWalletSelectedCurrency = amtInWalletSelectedCurrency;
            loading = false;
          });
        }else{
          if(mounted){
            setState(() {
              unableToGetWallet = true;
              loading = false;
            });
          }
        }
      }
    },error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  void continueTrans(){
    if(mounted) setState(() => continueTransaction = true);
  }

  Future<void> makePayment() async {
    await tryAsync("makePayment", () async {
      if(mounted) setState(() => loading = true);
      if(myStorage.user != null && myStorage.user!.id != null) {
        switch (widget.walletType) {
          case WalletType.influencer:
            {
              WalletAction action = WalletAction(
                amount: widget.amountInNaira,
                selectedCurrency: widget.currencyCode,
                amtInSelectedCurrency: widget.amount,
                channel: widget.forDesc,
                isCreditAction: false,
                ownerId: myStorage.user!.id!,
              );
              WalletTransactionResult debited = await influencerNotifier.creditOrDebitWallet(action);
              if(debited.tran != null && debited.succeeded){
                widget.onPaymentCompleted(debited);
              }else{
                if(mounted){
                  setState(() {
                    balanceIsSufficient = false;
                    paymentMade = false;
                    hasCheckedWallet = true;
                  });
                }
              }

            }
          case WalletType.shipper:
            return "";
          case WalletType.switzStore:
            return "";
          case WalletType.studio:
            return "";
          case WalletType.bus:
            return "";
          default:
            return "";
        }
      }else{
        widget.onCanceled();
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
      widget.onCanceled();
    });
  }

  @override
  void initState(){
    Future.delayed(Duration.zero, () async {
      if(mounted) setState(() => loading = true);
      debugPrint("Wallet not gotten yet B");
      await checkBalance();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: loading? const LoadingComponent(
        isShimmer: false,
        defaultSpinnerType: false,
        size: 30,
      )
          :
      (
        continueTransaction?
        Column(
          children: [
            spacer.height,
            if(!pinVerified) PinVerifier(
              onVerified: (bool status) async {
                if(mounted) setState(() => pinVerified = status);
                if(pinVerified) await makePayment();
              },
            ),
          ],
        )
            :
        (
            hasCheckedWallet && balanceIsSufficient?
            Column(
              children: [
                spacer.height,
                Translate(
                  text: "This transaction will debit your wallet, the sum of ${tabData.getCurrencySymbol(widget.currencyCode)}${currencyMath.roundDouble(widget.amount, 2)} "
                      "( ${tabData.getCurrencySymbol(influencerNotifier.influencerWalletCurrencyCode!)}${currencyMath.roundDouble(amountInWalletSelectedCurrency, 2)}, ${tabData.getCurrencySymbol('NGN')}${currencyMath.roundDouble(widget.amountInNaira,2)}) will be deducted. "
                      " Should this transaction continue?",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: prudColorTheme.textB,
                  ),
                  align: TextAlign.center,
                ),
                spacer.height,
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    prudWidgetStyle.getShortButton(
                        onPressed: () => Navigator.pop(context),
                        text: "Cancel",
                        isPill: false,
                        makeLight: true
                    ),
                    prudWidgetStyle.getShortButton(
                      onPressed: continueTrans,
                      text: "Continue",
                      isPill: false,
                    ),
                  ],
                )
              ],
            )
                :
            (
              unableToGetWallet?
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  spacer.height,
                  Translate(
                    text: "Wallet Inaccessible.",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: prudColorTheme.error,
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  Translate(
                    text: "Unable to reach Prud services. Check your networks.",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: prudColorTheme.textB,
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  prudWidgetStyle.getLongButton(
                      onPressed: checkBalance,
                      text: "Try Again"
                  ),
                ],
              )
              :
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  spacer.height,
                  Translate(
                    text: "Insufficient Fund.",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: prudColorTheme.error,
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  Translate(
                    text: "Your wallet balance is presently Insufficient.",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: prudColorTheme.textB,
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  prudWidgetStyle.getLongButton(
                      onPressed: () => Navigator.pop(context),
                      text: "Cancel Transaction"
                  ),
                ],
              )
            )
        )
      )
    );
  }
}
