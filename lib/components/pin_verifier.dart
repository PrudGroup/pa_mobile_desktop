import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/models/wallet.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

class PinVerifier extends StatefulWidget {
  final WalletType walletType;
  final Function(bool) onVerified;

  const PinVerifier({super.key,required this.walletType, required this.onVerified});

  @override
  PinVerifierState createState() => PinVerifierState();
}

class PinVerifierState extends State<PinVerifier> {
  bool pinBlocked = false;
  int trials = 0;
  bool verified = false;
  DateTime? lastTrialedAt;
  TextEditingController txtCtrl = TextEditingController();


  void setFigures(){
    if(mounted){
      txtCtrl.text = "";
      setState(() {
        switch(widget.walletType){
          case WalletType.influencer: {
            influencerNotifier.checkPinBlockage();
            pinBlocked = influencerNotifier.pinBlocked;
            trials = influencerNotifier.pinTrial;
            verified = influencerNotifier.pinWasVerified;
            lastTrialedAt = influencerNotifier.lastPinTrialAt;
          }
          case WalletType.shipper: {}
          case WalletType.switzStore: {}
          case WalletType.hotel: {}
          default: {}
        }
      });
    }
  }

  String getTrialText() {
    if(trials == 0){
      return "You only have 3 trials. Type your pin.";
    }else if(trials > 0 && trials <= 2){
      return "You have ${3 - trials} more trials left.";
    }else if(trials == 3){
      return "This is your last trial after which your pin will be blocked.";
    }else{
      return "Pin Blocked. You have to wait for 3 hours";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String?> verifyPin(String typedPin) async {
    return await tryAsync("verifyPin", () async {
      switch(widget.walletType){
        case WalletType.influencer: {
          bool res = await influencerNotifier.verifyPin(typedPin);
          setFigures();
          return res? null : "Failed";
        }
        case WalletType.shipper: return "";
        case WalletType.switzStore: return "";
        case WalletType.hotel: return "";
        case WalletType.bus: return "";
        default: return "";
      }
    });
  }

  @override
  void initState() {
    setFigures();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        spacer.height,
        if(pinBlocked || trials > 3) Column(
          children: [
            if(lastTrialedAt != null) Translate(
              text: "Your Pin Has been blocked at ${DateFormat('dd-MM-yyyy hh:mm a').format(lastTrialedAt!)} "
                  " and that is about ${myStorage.ago(dDate: lastTrialedAt!, isShort: false)}. You will be automatically unblocked after 3 hours.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: prudColorTheme.primary
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            prudWidgetStyle.getLongButton(
              onPressed: () => Navigator.pop(context),
              text: "End Transaction",
              shape: 1,
            )
          ],
        ),
        if(!pinBlocked && trials <= 3) Column(
          children: [
            Translate(
              text: getTrialText(),
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: prudColorTheme.success
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            Pinput(
              obscureText: true,
              autofocus: true,
              controller: txtCtrl,
              pinputAutovalidateMode: PinputAutovalidateMode.disabled,
              showCursor: true,
              onCompleted: (pin) async {
                await verifyPin(pin);
                widget.onVerified(verified);
              },
            )
          ],
        ),
      ],
    );
  }
}
