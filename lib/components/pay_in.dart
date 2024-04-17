import 'package:flutter/material.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:uuid/uuid.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import '../constants.dart';
import '../singletons/i_cloud.dart';

class PayIn extends StatefulWidget {
  final double amount;
  final Function(bool, String) onPaymentMade;
  final Function onCancel;

  const PayIn({
    super.key,
    required this.amount,
    required this.onPaymentMade,
    required this.onCancel,aq
  });

  @override
  PayInState createState() => PayInState();
}

class PayInState extends State<PayIn> {
  Flutterwave? flutterwave;
  bool loading = false;

  handlePaymentInitialization() async {
    const uuid = Uuid();
    String ranRef = uuid.v1();
    String wave = Constants.wavePublicKey;
    final Customer customer = Customer(
      name: "PrudApp",
      phoneNumber: "+2349135049783",
      email: "pay@prudapp.com"
    );
    if(mounted){
      flutterwave = Flutterwave(
          context: context,
          publicKey: wave,
          currency: "EUR",
          redirectUrl: "$apiEndPoint/payments/pay/wave_in",
          txRef: ranRef,
          amount: "${widget.amount}",
          customer: customer,
          paymentOptions: "ussd, card, barter, payattitude",
          customization: Customization(
            title: "PrudApp Pay",
            description: "Making Payments Blissful",
            logo: "https://firebasestorage.googleapis.com/v0/b/prudapp.appspot.com/o/images%2Fprud_api_server%2Fprudapp_icon.png?alt=media&token=177a8f5e-a0ca-45fa-8324-7f1c9782dd14"
          ),
          isTestMode: paymentIsInTestMode,
      );
    }
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async {
      try{
        handlePaymentInitialization();
        if(mounted) setState(() => loading = true);
        final ChargeResponse? response = await flutterwave?.charge();
        if(response != null && response.transactionId != null && response.txRef != null){
          debugPrint("Transaction Response: $response");
          debugPrint("TransactionID: ${response.transactionId}");
          bool verified = await checkPaymentStatus(
            response.transactionId!, widget.amount,
            response.txRef!,
          );
          debugPrint("Verified Payment: $verified");
          widget.onPaymentMade(verified, response.transactionId!);
        }
        if(mounted) setState(() => loading = false);
      }catch(ex){
        widget.onCancel();
        debugPrint("PayIn InitState: $ex");
      }
    });
  }

  Future<bool> checkPaymentStatus(String transId, double amount, String txRef) async {
    bool verified = false;
    verified = await currencyMath.verifyPayment(transId, amount, 'EUR', txRef);
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
    return loading? LoadingComponent(
      height: screen.height - 100,
      isShimmer: false,
    ) : const WorkInProgress();
  }
}