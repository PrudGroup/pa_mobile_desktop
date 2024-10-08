import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/utility_denomination.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../../components/loading_component.dart';
import '../../components/modals/utility_order_modal_sheet.dart';
import '../../components/translate_text.dart';
import '../../models/reloadly.dart';
import '../../models/theme.dart';
import '../../singletons/currency_math.dart';
import '../../singletons/influencer_notifier.dart';
import '../../singletons/tab_data.dart';
import '../../singletons/utility_notifier.dart';

class BillerDetails extends StatefulWidget{
  final Biller biller;
  final String buttonIcon;

  const BillerDetails({super.key, required this.biller, required this.buttonIcon});

  @override
  BillerDetailsState createState() => BillerDetailsState();
}

class BillerDetailsState extends State<BillerDetails> {
  String? deviceNo;
  double? selectedAmount;
  bool startingTrans = false;
  double localDiscount = 0.0;
  double interDiscount = 0.0;
  double referralCustomerPercentage = 0;
  double prudCustomerDiscountInPercentage = 0;
  double prudCusDiscount = 0;
  double refCusDiscount = 0;
  double totalInterToPay = 0;
  double totalLocalToPay = 0;
  double localFeeInLocalCurrency = 0;
  double interFeeInInterCurrency = 0;
  int selectedLocalIndex = 0;
  int selectedInterIndex = 0;
  int? selectedFixedAmountId;
  bool transactionIsLocal = false;
  double prudCharges = 0;
  double totalLocalCharges = 0;
  double totalInterCharges = 0;
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();

  double getTotalInNaira(bool isLocal){
    double amount = isLocal? totalLocalToPay : totalInterToPay;
    String cur = isLocal? widget.biller.localTransactionCurrencyCode! : widget.biller.internationalTransactionCurrencyCode!;
    if(cur == "NGN"){
      return amount;
    }else{
      if(cur != widget.biller.fx!.currencyCode){
        return amount;
      }else{
        return (( 1/widget.biller.fx!.rate!) * amount);
      }
    }
  }

  double getDiscountInNaira(bool isLocal){
    double amount = isLocal? localDiscount : interDiscount;
    String cur = isLocal? widget.biller.localTransactionCurrencyCode! : widget.biller.internationalTransactionCurrencyCode!;
    if(cur == "NGN"){
      return amount;
    }else{
      if(cur != widget.biller.fx!.currencyCode){
        return amount;
      }else{
        return (( 1/widget.biller.fx!.rate!) * amount);
      }
    }
  }

  Future<void> startTransaction(bool isLocal) async {
    tryAsync("startTransaction", () async {
      // debugPrint("isInter: ${selectedAmount! < widget.biller.minInternationalTransactionAmount! || selectedAmount! > widget.biller.maxInternationalTransactionAmount!}");
      if(deviceNo == null || deviceNo == "") return;
      if(isLocal){
        if(selectedAmount! < widget.biller.minLocalTransactionAmount! || selectedAmount! > widget.biller.maxLocalTransactionAmount!) return;
      }else{
        if(selectedAmount! < widget.biller.minInternationalTransactionAmount! || selectedAmount! > widget.biller.maxInternationalTransactionAmount!) return;
      }
      if(mounted) {
        if(focusNode1.hasFocus) focusNode1.unfocus();
        if(focusNode2.hasFocus) focusNode2.unfocus();
        if(focusNode3.hasFocus) focusNode3.unfocus();
        setState(() => startingTrans = true);
      }
      calculateFigures(isLocal);
      utilityNotifier.updateSelectedServiceType(utilityNotifier.translateToService(widget.biller.serviceType!));
      utilityNotifier.updateSelectedUtilityType(utilityNotifier.translateToType(widget.biller.type!));
      utilityNotifier.updateLastBillerUsed(widget.biller, deviceNo!);
      await utilityNotifier.updateSelectedBiller(widget.biller);
      await utilityNotifier.updateSelectedDeviceNo(UtilityDevice(
        serviceType: widget.biller.serviceType!,
        type: widget.biller.type!,
        countryIsoCode: widget.biller.countryCode!,
        no: deviceNo!,
        billerId: widget.biller.id!,
      ));
      UtilityOrder order = UtilityOrder(
        amount: selectedAmount!,
        billerId: widget.biller.id!,
        amountId: null,
        subscriberAccountNumber: deviceNo!,
        useLocalAmount: isLocal,
        additionalInfo: UtilityAdditionalInfo(
          invoiceId: tabData.getRandomString(16),
        )
      );
      if(widget.biller.denominationType == "FIXED"){
        order.amountId = selectedFixedAmountId;
      }
      if(mounted) {
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
            return UtilityOrderModalSheet(
              order: order,
              amountToPay: isLocal? totalLocalToPay : totalInterToPay,
              customerDiscount: isLocal? localDiscount : interDiscount,
              currencyCode: isLocal? widget.biller.localTransactionCurrencyCode! : widget.biller.internationalTransactionCurrencyCode!,
              amountInNaira: getTotalInNaira(isLocal),
              customerDiscountInNaira: getDiscountInNaira(isLocal),
              referralCustomerDiscountPercentage: referralCustomerPercentage,
            );
          }
        ).whenComplete(() async {
          if(mounted) setState(() => startingTrans = false);
        });
      }
    }, error: (){
      if(mounted) setState(() => startingTrans = false);
    });
  }
  
  void selectFixedAmount(BillerFixedAmount amount, bool isLocal, int index){
    tryAsync("selectFixedAmount", () async {
      if(mounted){
        selectedAmount = amount.amount;
        if(amount.id != null) selectedFixedAmountId = amount.id!;
        if(isLocal) {
          selectedLocalIndex = index;
        }else{
          selectedInterIndex = index;
        }
      }
      calculateFigures(isLocal);
    });
  }

  void calculateFigures(bool isLocal) {
    tryAsync("calculateFigures", () {
      if(selectedAmount != null && selectedAmount! > 0){
        double prudCommission = 0;
        if(isLocal){
          if(widget.biller.localDiscountPercentage != null && widget.biller.localDiscountPercentage! > 0){
            prudCommission = widget.biller.localDiscountPercentage! * selectedAmount!;
            if(prudCommission > 0){
              double cusDis = prudCommission * (prudCustomerDiscountInPercentage/100);
              if(mounted) setState(() => prudCusDiscount = cusDis);
              if(cusDis > 0 && referralCustomerPercentage > 0){
                double refCusDis = cusDis * (referralCustomerPercentage/100);
                if(mounted) setState(() => refCusDiscount = refCusDis);
              }
            }
          }
          if(widget.biller.localTransactionFeeCurrencyCode != widget.biller.localTransactionCurrencyCode){
            if(widget.biller.fx != null && widget.biller.fx!.rate != null){
              if(widget.biller.fx!.currencyCode != widget.biller.localTransactionFeeCurrencyCode){
                if(mounted && widget.biller.localTransactionFee != null) setState(() => localFeeInLocalCurrency = widget.biller.localTransactionFee! * widget.biller.fx!.rate!);
              }
            }
          }else{
            if(mounted && widget.biller.localTransactionFee != null) setState(() => localFeeInLocalCurrency = widget.biller.localTransactionFee!);
          }
          if(mounted) {
            setState(() {
              prudCharges = selectedAmount! * prudUtilityChargeInPercentage;
              totalLocalCharges = prudCharges + (widget.biller.localTransactionFee?? 0);
              localDiscount = prudCusDiscount + refCusDiscount;
              totalLocalToPay = localFeeInLocalCurrency + prudCharges + (selectedAmount! - localDiscount);
              transactionIsLocal = true;
            });
          }
        }else{
          if(widget.biller.internationalDiscountPercentage != null && widget.biller.internationalDiscountPercentage! > 0){
            prudCommission = widget.biller.internationalDiscountPercentage! * selectedAmount!;
            if(prudCommission > 0){
              double cusDis = prudCommission * (prudCustomerDiscountInPercentage/100);
              if(mounted) setState(() => prudCusDiscount = cusDis);
              if(cusDis > 0 && referralCustomerPercentage > 0){
                double refCusDis = cusDis * (referralCustomerPercentage/100);
                if(mounted) setState(() => refCusDiscount = refCusDis);
              }
            }
          }
          if(widget.biller.internationalTransactionFeeCurrencyCode != widget.biller.internationalTransactionCurrencyCode){
            if(widget.biller.fx != null && widget.biller.fx!.rate != null){
              if(widget.biller.fx!.currencyCode != widget.biller.internationalTransactionFeeCurrencyCode){
                if(mounted && widget.biller.internationalTransactionFee != null) setState(() => interFeeInInterCurrency = widget.biller.internationalTransactionFee! * widget.biller.fx!.rate!);
              }
            }
          }else{
            if(mounted && widget.biller.internationalTransactionFee != null) setState(() => interFeeInInterCurrency = widget.biller.internationalTransactionFee!);
          }
          if(mounted) {
            setState(() {
              prudCharges = selectedAmount! * prudUtilityChargeInPercentage;
              totalInterCharges = prudCharges + (widget.biller.internationalTransactionFee?? 0);
              interDiscount = prudCusDiscount + refCusDiscount;
              totalInterToPay = interFeeInInterCurrency + prudCharges + (selectedAmount! - interDiscount);
              transactionIsLocal = false;
            });
          }
        }
      }
    });
  }

  Future<void> getReferralPercentage() async {
    tryAsync("getReferralPercentage", () async {
      if(myStorage.rechargeReferral != null){
        double? discountFromReferralInPercentage = await influencerNotifier.getLinkReferralPercentage(myStorage.rechargeReferral!);
        double prudDiscount = currencyMath.roundDouble((utilityCustomerDiscountInPercentage * 100), 1);
        if(mounted) {
          setState(() {
            referralCustomerPercentage = discountFromReferralInPercentage?? 0;
            prudCustomerDiscountInPercentage = prudDiscount;
          });
        }
      }
      if(mounted){
        setState(() {
          totalInterCharges = prudCharges + (widget.biller.internationalTransactionFee?? 0);
          totalLocalCharges = prudCharges + (widget.biller.localTransactionFee?? 0);
        });
      }
    });
  }

  @override
  void initState(){
    Future.delayed(Duration.zero, () async {
      if(mounted && utilityNotifier.selectedDeviceNumber != null){
        setState(() {
          deviceNo = utilityNotifier.selectedDeviceNumber!.no;
        });
      }
      await getReferralPercentage();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    Biller biller = widget.biller;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Row(
          children: [
            if(biller.countryCode != null) Text(
              tabData.getCountryFlag(biller.countryCode!),
            ),
            if(biller.countryCode != null) spacer.width,
            if(biller.name != null) Translate(
              text: tabData.shortenStringWithPeriod(biller.name!, length: 30),
              style: prudWidgetStyle.tabTextStyle.copyWith(
                  fontSize: 16,
                  color: prudColorTheme.bgA
              ),
            ),
          ],
        ),
        actions: const [
        ],
      ),
      body: SizedBox(
        height: screen.height,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              spacer.height,
              Row(
                children: [
                  if(biller.localAmountSupported == true) Expanded(
                    child: PrudPanel(
                      title: "Local Fee",
                      hasPadding: true,
                      bgColor: prudColorTheme.bgC,
                      child: Center(
                        child: FittedBox(
                          child: Row(
                            children: [
                              if(biller.localTransactionFeeCurrencyCode != null) Text(
                                "${tabData.getCurrencySymbol(biller.localTransactionFeeCurrencyCode!)}",
                                style: tabData.tBStyle.copyWith(
                                    fontSize: 15.0,
                                    color: prudColorTheme.textA
                                ),
                              ),
                              Text(
                                "${tabData.getFormattedNumber(totalLocalCharges)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                    fontSize: 20.0,
                                    color: prudColorTheme.primary,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              spacer.width,
                              Row(
                                children: [
                                  Text(
                                    "${biller.localTransactionFeePercentage}",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                      color: prudColorTheme.success,
                                      fontSize: 14
                                    ),
                                  ),
                                  Text(
                                    "%",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.textB,
                                        fontSize: 11
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  spacer.width,
                  Expanded(
                    child: PrudPanel(
                      title: "Global Fee",
                      hasPadding: true,
                      bgColor: prudColorTheme.bgC,
                      child: Center(
                        child: FittedBox(
                          child: Row(
                            children: [
                              if(biller.internationalTransactionFeeCurrencyCode != null) Text(
                                "${tabData.getCurrencySymbol(biller.internationalTransactionFeeCurrencyCode!)}",
                                style: tabData.tBStyle.copyWith(
                                    fontSize: 15.0,
                                    color: prudColorTheme.textA
                                ),
                              ),
                              Text(
                                "${tabData.getFormattedNumber(totalInterCharges)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                  fontSize: 20.0,
                                  color: prudColorTheme.primary,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              spacer.width,
                              Row(
                                children: [
                                  Text(
                                    "${biller.internationalTransactionFeePercentage}",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                      color: prudColorTheme.success,
                                      fontSize: 14
                                    ),
                                  ),
                                  Text(
                                    "%",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.textB,
                                        fontSize: 11
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if(biller.localAmountSupported == true) Expanded(
                    child: PrudPanel(
                      title: "Local Discount",
                      hasPadding: true,
                      bgColor: prudColorTheme.bgC,
                      child: Center(
                        child: FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(biller.localTransactionCurrencyCode != null) Text(
                                "${tabData.getCurrencySymbol(biller.internationalTransactionCurrencyCode!)}",
                                style: tabData.tBStyle.copyWith(
                                    fontSize: 15.0,
                                    color: prudColorTheme.textA
                                ),
                              ),
                              Text(
                                "${tabData.getFormattedNumber(localDiscount)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                    fontSize: 20.0,
                                    color: prudColorTheme.primary,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              spacer.width,
                              Row(
                                children: [
                                  Text(
                                    "$prudCustomerDiscountInPercentage",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.success,
                                        fontSize: 14
                                    ),
                                  ),
                                  Text(
                                    "%",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.textB,
                                        fontSize: 11
                                    ),
                                  )
                                ],
                              ),
                              spacer.width,
                              Stack(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$referralCustomerPercentage",
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                            color: prudColorTheme.success,
                                            fontSize: 14
                                        ),
                                      ),
                                      Text(
                                        "%",
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                            color: prudColorTheme.textB,
                                            fontSize: 11
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text(
                                      "Referral Link",
                                      style: prudWidgetStyle.btnTextStyle.copyWith(
                                          color: prudColorTheme.success,
                                          fontSize: 10
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  spacer.width,
                  Expanded(
                    child: PrudPanel(
                      title: "Global Discount",
                      hasPadding: true,
                      bgColor: prudColorTheme.bgC,
                      child: Center(
                        child: FittedBox(
                          child: Row(
                            children: [
                              if(biller.internationalTransactionCurrencyCode != null) Text(
                                "${tabData.getCurrencySymbol(biller.internationalTransactionCurrencyCode!)}",
                                style: tabData.tBStyle.copyWith(
                                    fontSize: 15.0,
                                    color: prudColorTheme.textA
                                ),
                              ),
                              Text(
                                "${tabData.getFormattedNumber(interDiscount)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                  fontSize: 20.0,
                                  color: prudColorTheme.primary,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              spacer.width,
                              Row(
                                children: [
                                  Text(
                                    "$prudCustomerDiscountInPercentage",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.success,
                                        fontSize: 14
                                    ),
                                  ),
                                  Text(
                                    "%",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.textB,
                                        fontSize: 11
                                    ),
                                  )
                                ],
                              ),
                              spacer.width,
                              Stack(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$referralCustomerPercentage",
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                            color: prudColorTheme.success,
                                            fontSize: 14
                                        ),
                                      ),
                                      Text(
                                        "%",
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                            color: prudColorTheme.textB,
                                            fontSize: 11
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text(
                                      "Referral Link",
                                      style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.success,
                                        fontSize: 10
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              spacer.height,
              PrudPanel(
                title: "Device Number",
                titleColor: prudColorTheme.secondary,
                bgColor: prudColorTheme.bgC,
                child: Column(
                  children: [
                    spacer.height,
                    Translate(
                      text: "What's your devices/meter number. Be sure to type it correctly and you won't have to type it again.",
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        color: prudColorTheme.textB,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      align: TextAlign.center,
                    ),
                    spacer.height,
                    FormBuilderTextField(
                      initialValue: deviceNo,
                      name: 'deviceNo',
                      focusNode: focusNode1,
                      autofocus: true,
                      style: tabData.npStyle,
                      keyboardType: TextInputType.text,
                      decoration: getDeco("Device No:", hasBorders: true, onlyBottomBorder: true),
                      onChanged: (dynamic value){
                        tryAsync("deviceNo form", (){
                          if(mounted && value != null) {
                            setState(() => deviceNo = value.trim());
                          }
                        });
                      },
                      valueTransformer: (text) => num.tryParse(text!),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.min(5),
                        FormBuilderValidators.max(40),
                      ]),
                    ),
                    spacer.height,
                  ],
                ),
              ),
              spacer.height,
              Row(
                children: [
                  if(biller.localAmountSupported == true) Expanded(
                    child: PrudPanel(
                      title: "Local: Total",
                      hasPadding: true,
                      bgColor: prudColorTheme.bgC,
                      child: Center(
                        child: FittedBox(
                          child: Row(
                            children: [
                              if(biller.localTransactionCurrencyCode != null) Text(
                                "${tabData.getCurrencySymbol(biller.localTransactionCurrencyCode!)}",
                                style: tabData.tBStyle.copyWith(
                                  fontSize: 15.0,
                                  color: prudColorTheme.textA
                                ),
                              ),
                              Text(
                                "${tabData.getFormattedNumber(totalLocalToPay)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                    fontSize: 20.0,
                                    color: prudColorTheme.primary,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              spacer.width,
                              Stack(
                                children: [
                                  Text(
                                    "$localDiscount",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.success,
                                        fontSize: 14
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text(
                                      "Discount",
                                      style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.textB,
                                        fontSize: 10
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  spacer.width,
                  Expanded(
                    child: PrudPanel(
                      title: "Global: Total",
                      hasPadding: true,
                      bgColor: prudColorTheme.bgC,
                      child: Center(
                        child: FittedBox(
                          child:  Row(
                            children: [
                              if(biller.internationalTransactionCurrencyCode != null) Text(
                                "${tabData.getCurrencySymbol(biller.internationalTransactionCurrencyCode!)}",
                                style: tabData.tBStyle.copyWith(
                                  fontSize: 15.0,
                                  color: prudColorTheme.textA
                                ),
                              ),
                              Text(
                                "${tabData.getFormattedNumber(totalInterToPay)}",
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                  fontSize: 20.0,
                                  color: prudColorTheme.primary,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              spacer.width,
                              Stack(
                                children: [
                                  Text(
                                    "$interDiscount",
                                    style: prudWidgetStyle.btnTextStyle.copyWith(
                                        color: prudColorTheme.success,
                                        fontSize: 14
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text(
                                      "Discount",
                                      style: prudWidgetStyle.btnTextStyle.copyWith(
                                          color: prudColorTheme.textB,
                                          fontSize: 10
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              spacer.height,
              if(biller.localAmountSupported == true && biller.minLocalTransactionAmount != null && biller.maxLocalTransactionAmount != null) Column(
                children: [
                  PrudPanel(
                    title: "Local Subscription Amount",
                    titleColor: prudColorTheme.secondary,
                    bgColor: prudColorTheme.bgC,
                    child: Column(
                      children: [
                        spacer.height,
                        Translate(
                          text: "Be sure it's not less "
                              "than the minimum nor more than the maximum",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Translate(
                                    text: "Minimum",
                                    style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: prudColorTheme.secondary,
                                    ),
                                    align: TextAlign.center,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: prudColorTheme.bgA,
                                      border: Border.all(
                                        color: prudColorTheme.bgD,
                                        width: 3.0
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Center(
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            if(biller.localTransactionCurrencyCode != null) Text(
                                              "${tabData.getCurrencySymbol(biller.localTransactionCurrencyCode!)}",
                                              style: tabData.tBStyle.copyWith(
                                                fontSize: 15.0,
                                                color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "${tabData.getFormattedNumber(biller.minLocalTransactionAmount)}",
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
                                                  fontSize: 20.0,
                                                  color: prudColorTheme.primary,
                                                  fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            spacer.width,
                            Expanded(
                              child: FormBuilderTextField(
                                initialValue: "",
                                name: 'deno',
                                focusNode: focusNode2,
                                style: tabData.npStyle,
                                keyboardType: TextInputType.number,
                                decoration: getDeco("Amount",  hasBorders: true, onlyBottomBorder: true),
                                onChanged: (dynamic value){
                                  tryAsync("local amount form", (){
                                    if(mounted && value != null) {
                                      setState(() {
                                        selectedAmount = double.parse(value?.trim());
                                      });
                                    }
                                    calculateFigures(true);
                                  });
                                },
                                valueTransformer: (text) => num.tryParse(text!),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.min(biller.minLocalTransactionAmount?? 1),
                                  FormBuilderValidators.max(biller.maxLocalTransactionAmount?? 100),
                                ]),
                              ),
                            ),
                            spacer.width,
                            SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Translate(
                                    text: "Maximum",
                                    style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: prudColorTheme.secondary,
                                    ),
                                    align: TextAlign.center,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: prudColorTheme.bgA,
                                      border: Border.all(
                                          color: prudColorTheme.bgD,
                                          width: 3.0
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Center(
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            if(biller.localTransactionCurrencyCode != null) Text(
                                              "${tabData.getCurrencySymbol(biller.localTransactionCurrencyCode!)}",
                                              style: tabData.tBStyle.copyWith(
                                                  fontSize: 15.0,
                                                  color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "${tabData.getFormattedNumber(biller.maxLocalTransactionAmount)}",
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
                                                  fontSize: 20.0,
                                                  color: prudColorTheme.primary,
                                                  fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            spacer.width,
                            SizedBox(
                              width: 50,
                              child: startingTrans? LoadingComponent(
                                isShimmer: false,
                                size: 40,
                                spinnerColor: prudColorTheme.primary,
                              ) : prudWidgetStyle.getIconButton(
                                onPressed: () async => await startTransaction(true),
                                isIcon: false,
                                image: widget.buttonIcon,
                              ),
                            )
                          ],
                        ),
                        spacer.height,
                      ],
                    ),
                  ),
                  spacer.height,
                ],
              ),
              if(biller.minInternationalTransactionAmount != null && biller.maxInternationalTransactionAmount != null) Column(
                children: [
                  PrudPanel(
                    title: "Global Subscription Amount",
                    titleColor: prudColorTheme.secondary,
                    bgColor: prudColorTheme.bgC,
                    child: Column(
                      children: [
                        spacer.height,
                        Translate(
                          text: "Be sure it's not less "
                              "than the minimum nor more than the maximum",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Translate(
                                    text: "Minimum",
                                    style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: prudColorTheme.secondary,
                                    ),
                                    align: TextAlign.center,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: prudColorTheme.bgA,
                                      border: Border.all(
                                          color: prudColorTheme.bgD,
                                          width: 3.0
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Center(
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            if(biller.internationalTransactionCurrencyCode != null) Text(
                                              "${tabData.getCurrencySymbol(biller.internationalTransactionCurrencyCode!)}",
                                              style: tabData.tBStyle.copyWith(
                                                fontSize: 15.0,
                                                color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "${tabData.getFormattedNumber(biller.minInternationalTransactionAmount)}",
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
                                                fontSize: 20.0,
                                                color: prudColorTheme.primary,
                                                fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            spacer.width,
                            Expanded(
                              child: FormBuilderTextField(
                                initialValue: "",
                                name: 'deno',
                                style: tabData.npStyle,
                                focusNode: focusNode3,
                                keyboardType: TextInputType.number,
                                decoration: getDeco("Amount", hasBorders: true, onlyBottomBorder: true),
                                onChanged: (dynamic value){
                                  tryAsync("inter amount form", (){
                                    if(mounted && value != null) {
                                      setState(() {
                                        selectedAmount = double.parse(value?.trim());
                                      });
                                    }
                                    calculateFigures(false);
                                  });
                                },
                                valueTransformer: (text) => num.tryParse(text!),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.min(biller.minInternationalTransactionAmount?? 1),
                                  FormBuilderValidators.max(biller.maxInternationalTransactionAmount?? 100),
                                ]),
                              ),
                            ),
                            spacer.width,
                            SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Translate(
                                    text: "Maximum",
                                    style: prudWidgetStyle.typedTextStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: prudColorTheme.secondary,
                                    ),
                                    align: TextAlign.center,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: prudColorTheme.bgA,
                                      border: Border.all(
                                          color: prudColorTheme.bgD,
                                          width: 3.0
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Center(
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            if(biller.internationalTransactionCurrencyCode != null) Text(
                                              "${tabData.getCurrencySymbol(biller.internationalTransactionCurrencyCode!)}",
                                              style: tabData.tBStyle.copyWith(
                                                fontSize: 15.0,
                                                color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "${tabData.getFormattedNumber(biller.maxInternationalTransactionAmount)}",
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
                                                fontSize: 20.0,
                                                color: prudColorTheme.primary,
                                                fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            spacer.width,
                            SizedBox(
                              width: 50,
                              child: startingTrans? LoadingComponent(
                                isShimmer: false,
                                size: 40,
                                spinnerColor: prudColorTheme.primary,
                              ) : prudWidgetStyle.getIconButton(
                                onPressed: () async => await startTransaction(false),
                                isIcon: false,
                                image: widget.buttonIcon,
                              ),
                            )
                          ],
                        ),
                        spacer.height,
                      ],
                    ),
                  ),
                  spacer.height,
                ],
              ),
              if(biller.denominationType != null && biller.denominationType!.toLowerCase() == "fixed") Column(
                children: [
                  if(biller.localAmountSupported == true && biller.localTransactionCurrencyCode != null && biller.localFixedAmounts != null && biller.localFixedAmounts!.isNotEmpty) Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          itemCount: biller.localFixedAmounts!.length,
                          itemBuilder: (context, index){
                            BillerFixedAmount amt = biller.localFixedAmounts![index];
                            return InkWell(
                              onTap: () => selectFixedAmount(amt, true, index),
                              child: UtilityDenomination(
                                fixedAmount: amt, 
                                selected: selectedLocalIndex == index,
                                currencyCode: biller.localTransactionCurrencyCode!
                              ),
                            );
                          }),
                      ),
                      spacer.height,
                    ],
                  ),
                  if(biller.internationalTransactionCurrencyCode != null && biller.internationalFixedAmounts != null && biller.internationalFixedAmounts!.isNotEmpty) Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          itemCount: biller.internationalFixedAmounts!.length,
                          itemBuilder: (context, index){
                            BillerFixedAmount amt = biller.internationalFixedAmounts![index];
                            return InkWell(
                              onTap: () => selectFixedAmount(amt, false, index),
                              child: UtilityDenomination(
                                fixedAmount: amt,
                                selected: selectedInterIndex == index,
                                currencyCode: biller.internationalTransactionCurrencyCode!
                              ),
                            );
                          }),
                      ),
                      spacer.height,
                    ],
                  ),
                  spacer.height,
                  startingTrans? LoadingComponent(
                    isShimmer: false,
                    size: 40,
                    spinnerColor: prudColorTheme.primary,
                  ) 
                    : 
                  selectedAmount != null && selectedAmount! > 0? prudWidgetStyle.getLongButton(
                    onPressed: () async => await startTransaction(transactionIsLocal), 
                    text: "Pay Now (${tabData.getCurrencySymbol(transactionIsLocal? biller.localTransactionCurrencyCode! : biller.internationalTransactionCurrencyCode!)}${transactionIsLocal? totalLocalToPay : totalInterToPay})"
                  ) : const SizedBox(),
                  
                ],
              ),
              xLargeSpacer.height,
              largeSpacer.height
            ],
          ),
        ),
      ),
    );
  }
}
