import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_showroom.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/currency_math.dart';
import '../singletons/i_cloud.dart';
import 'translate_text.dart';

class PayIn extends StatefulWidget {
  final double amount;
  final String? currencyCode;
  final Function(bool, String) onPaymentMade;
  final Function onCancel;
  final String? countryCode;
  final bool usePaystack;

  const PayIn({
    super.key,
    required this.amount,
    required this.onPaymentMade,
    required this.onCancel,
    this.usePaystack = false,
    this.currencyCode,
    this.countryCode
  });

  @override
  PayInState createState() => PayInState();
}

class PayInState extends State<PayIn> {
  bool loading = false;
  List<Widget> showroom = [];
  String? paymentId;
  bool paymentMade = false;
  String? transRef;
  dynamic getCashierStatusResult;


  Future<void> verifyPayment() async {
    try{
      if(mounted) setState(() => loading = true);
      if(paymentId != null && paymentMade && transRef != null){
        bool verified = await checkPaymentStatus(
          paymentId!, widget.amount,
          transRef!,currency: widget.currencyCode?? "EUR"
        );
        if(verified && mounted){
          widget.onPaymentMade(verified, paymentId!);
          setState(() {
            paymentId = null;
            transRef = null;
            paymentMade = false;
          });
        }
        debugPrint("Verified Payment: $verified");
      }
      if(mounted) setState(() => loading = false);
    }catch(ex) {
      if(mounted) setState(() => loading = false);
      debugPrint("verifyPayment Error: $ex");
    }
  }

  @override
  void initState(){
    if(mounted) {
      setState(() {
        showroom = iCloud.getShowroom(context,showroomItems: 4);
      });
    }
    super.initState();
    Future.delayed(Duration.zero, () async {
      try{

      }catch(ex){
        if(mounted) setState(() => loading = false);
        widget.onCancel();
        debugPrint("PayIn InitState: $ex");
      }
    });
  }

  Future<bool> checkPaymentStatus(String transId, double amount, String txRef,
      {String currency = 'EUR'}) async {
    bool verified = false;
    verified = await currencyMath.verifyPayment(transId, amount, currency, txRef);
    /*try{
      String payUrl = "$apiEndPoint/payments/pay/verify/$transId";
      Response res = await prudDio.get(payUrl, queryParameters: {
        'currency': 'EUR',
        'amount': amount,
        'tx_ref': txRef,
      });
      if (res.statusCode == 200) {
        debugPrint("Result: $res");
        verified = res.data;
      } else {
        verified = false;
      }
    }catch(ex){
      debugPrint("CheckPaymentStatus: $ex");
    }*/
    return verified;
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            if(loading) const LoadingComponent(
              defaultSpinnerType: false,
              size: 30,
              isShimmer: false,
            ),
            if(!loading && paymentMade) Column(
              children: [
                spacer.height,
                Translate(
                  text: "Unable To Verify Payment. Kindly Check Your Network.",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: prudColorTheme.secondary,
                  ),
                  align: TextAlign.center,
                ),
                spacer.height,
                prudWidgetStyle.getLongButton(
                  onPressed: verifyPayment,
                  text: "Verify Payment"
                ),
                spacer.height,
              ],
            ),
            if(!loading && !paymentMade) Column(
              children: [
                spacer.height,
                Translate(
                  text: "Unable To Proceed With Payment. Kindly Check Your Network.",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: prudColorTheme.secondary,
                  ),
                  align: TextAlign.center,
                ),
                spacer.height,
                prudWidgetStyle.getLongButton(
                  onPressed: () => iCloud.goBack(context),
                  text: "Go Back"
                ),
                spacer.height,
              ],
            ),
            PrudShowroom(items: showroom,)
          ],
        ),
      ),
    );
  }
}