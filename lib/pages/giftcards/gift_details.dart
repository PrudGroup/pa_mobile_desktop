import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/add_beneficiary.dart';
import 'package:prudapp/components/gift_cart_icon.dart';
import 'package:prudapp/components/gift_denomination.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_data_viewer.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import '../../components/Translate.dart';
import '../../models/theme.dart';
import '../../singletons/tab_data.dart';

class GiftDetails extends StatefulWidget {
  final GiftProduct gift;
  const GiftDetails({super.key, required this.gift});

  @override
  GiftDetailsState createState() => GiftDetailsState();
}

class GiftDetailsState extends State<GiftDetails> {
  dynamic brandLogo;
  late GiftProduct gift;
  Denomination? denSelected = giftCardNotifier.selectedDenMap;
  bool gettingFx = false;
  double senderFeeInSenderCur = 0;
  double smsFeeInSenderCur = 0;
  double selectedDeno = 0;
  double selectedDenoCost = 0;
  double selectedDenoCostWithDiscount = 0;
  bool gettingDenoCost = false;
  double totalDiscount = 0;
  bool hasSelectedBen = beneficiaryNotifier.selectedBeneficiaries.isNotEmpty;
  ScrollController scrollCtrl = ScrollController();
  bool adding = false;

  void refresh() async {
    await beneficiaryNotifier.removeAll();
    if(mounted) {
      setState(() {
        denSelected = null;
        selectedDeno = 0;
        selectedDenoCost = 0;
        selectedDenoCostWithDiscount = 0;
        denSelected = null;
        totalDiscount = 0;
        adding = false;
        giftCardNotifier.selectedDenMap = null;
      });
    }
  }

  double getTotalCharges() => senderFeeInSenderCur + smsFeeInSenderCur;

  Future<double> convertSenderCostToSenderCur(double cost) async {
    return await currencyMath.convert(
      amount: cost,
      quoteCode: giftCardNotifier.lastGiftSearch!.senderCurrency.code,
      baseCode: "NGN"
    );
  }

  double getTotalDiscount(double senderCost){
    if(gift.denominationType!.toLowerCase() == "fixed"){
      double discount = gift.discountPercentage != null && gift.discountPercentage! > 0? ((gift.discountPercentage! * giftCustomerDiscountInPercentage)/100) : 0;
      return currencyMath.roundDouble(senderCost * discount,2);
    }else{
      return totalDiscount;
    }
  }

  double getSelectedDeno(){
    if(gift.denominationType!.toLowerCase() == "fixed"){
      return double.parse(denSelected!.recipient);
    }else{
      return selectedDeno;
    }
  }

  double getDiscountedAmount(double cost){
    if(gift.denominationType!.toLowerCase() == "fixed"){
      return currencyMath.roundDouble(cost - getTotalDiscount(cost), 2);
    }else{
      return selectedDenoCostWithDiscount;
    }
  }

  double getGrandTotal(double cost){
    if(gift.denominationType!.toLowerCase() == "fixed"){
      return currencyMath.roundDouble(getDiscountedAmount(cost) + getTotalCharges(), 2);
    }else{
      return selectedDenoCostWithDiscount;
    }
  }

  void addToCart() async {
    try{
      List<CartItem> items = [];
      if(mounted) setState(() => adding = true);
      List<Beneficiary> benes = beneficiaryNotifier.selectedBeneficiaries;
      if(benes.isNotEmpty){
        double senderCost = 0;
        if(gift.denominationType!.toLowerCase() == "fixed"){
          senderCost = await convertSenderCostToSenderCur(denSelected!.sender);
        }else{
          senderCost = selectedDenoCost;
        }
        double discountedAmount = getDiscountedAmount(senderCost);
        double totalFees = getTotalCharges();
        double grandAmt = getGrandTotal(senderCost);
        double totalDis = getTotalDiscount(senderCost);
        double selectedDen = getSelectedDeno();
        for(Beneficiary bene in benes){
          CartItem newCartItem = CartItem(
            amount: discountedAmount,
            charges: totalFees,
            createdOn: DateTime.now(),
            grandTotal: grandAmt,
            lastUpdated: DateTime.now(),
            product: gift,
            quantity: 1,
            productPhoto: gift.logoUrls != null && gift.logoUrls!.isNotEmpty? gift.logoUrls![0]: null,
            totalDiscount: totalDis,
            senderCur: giftCardNotifier.lastGiftSearch!.senderCurrency.code,
            benCur: gift.recipientCurrencyCode!,
            benSelectedDeno: selectedDen,
            beneficiary: bene,
          );
          items.add(newCartItem);
          // await giftCardNotifier.addItemToCart(newCartItem);
        }
        if(items.isNotEmpty) {
          await giftCardNotifier.addItemsToCart(items);
        }
        refresh();
        if(mounted) iCloud.showSnackBar("Items Added to Cart!", context, title: "Cool");
        iCloud.scrollTop(scrollCtrl);
      }
    }catch(ex){
      if(mounted) setState(() => adding = false);
      debugPrint("addToCart Error: $ex");
    }
  }

  Future<void> checkSelectedDeno() async {
    try{
      if(selectedDeno < (gift.minRecipientDenomination?? 0)){
        selectedDeno = gift.minRecipientDenomination?? 0;
      }else if(selectedDeno > (gift.maxRecipientDenomination?? 0)){
        selectedDeno = gift.maxRecipientDenomination?? 0;
      }
      await getSelectedDenCost();
    }catch(ex){
      debugPrint("Error: $ex");
    }
  }

  Future<void> getSelectedDenCost() async {
    if (mounted) setState(() => gettingDenoCost = true);
    if (selectedDeno >= gift.minRecipientDenomination! &&
        selectedDeno <= gift.maxRecipientDenomination! &&
        gift.recipientCurrencyCode != null &&
        giftCardNotifier.lastGiftSearch != null) {
      FxRate? senderCost = await giftCardNotifier.getFxRate(
          gift.recipientCurrencyCode!,
          selectedDeno
      );
      if (mounted && senderCost != null) {
        double inSenderCur = await convertSenderCostToSenderCur(senderCost.senderAmount!);
        double discot = gift.discountPercentage != null && gift.discountPercentage! > 0? ((gift.discountPercentage! * giftCustomerDiscountInPercentage)/100) : 0;
        double discount = inSenderCur * discot;
        setState(() {
          gettingDenoCost = false;
          totalDiscount = currencyMath.roundDouble(discount, 2);
          selectedDenoCost = currencyMath.roundDouble(inSenderCur, 2);
          selectedDenoCostWithDiscount = currencyMath.roundDouble(inSenderCur - discount, 2);
        });
      }
    }
  }

  Future<void> getSenderFxRates() async {
    if(mounted) setState(() => gettingFx = true);
    if(gift.senderFee != null && giftCardNotifier.lastGiftSearch != null){
      double senderFee = await currencyMath.convert(
        amount: gift.senderFee!,
        quoteCode: giftCardNotifier.lastGiftSearch!.senderCurrency.code,
        baseCode: "NGN"
      );
      double smsFee = await currencyMath.convert(
        amount: reloadlySmsFee,
        quoteCode: giftCardNotifier.lastGiftSearch!.senderCurrency.code,
        baseCode: "NGN"
      );
      if(mounted){
        setState(() {
          senderFeeInSenderCur = senderFee;
          smsFeeInSenderCur = smsFee;
          gettingFx = false;
        });
      }
    }
  }

  @override
  void initState() {
    if(mounted){
      setState(() {
        gift = widget.gift;
        brandLogo = gift.logoUrls?[0];
        selectedDeno = gift.minRecipientDenomination?? 0;
      });
    }
    Future.delayed(Duration.zero, () async {
      await getSenderFxRates();
    });
    super.initState();
    giftCardNotifier.addListener((){
      if(denSelected?.recipient != giftCardNotifier.selectedDenMap?.recipient){
        if(mounted) setState(() => denSelected = giftCardNotifier.selectedDenMap);
      }
    });
    beneficiaryNotifier.addListener((){
      if(mounted){
        setState(() {
          hasSelectedBen = beneficiaryNotifier.selectedBeneficiaries.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    giftCardNotifier.removeListener((){});
    beneficiaryNotifier.removeListener((){});
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        controller: scrollCtrl,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 200,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(screen.width/2),
                  bottomLeft: Radius.circular(screen.width/2),
                ),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  onError: (obj, stack){
                    debugPrint("NetworkImage Error: $obj : $stack");
                  },
                  image: FastCachedImageProvider(
                    brandLogo,
                  )
                )
              ),
              child: Column(
                children: [
                  spacer.height,
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgB,),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 20,
                      ),
                      Row(
                        children: [
                          const GiftCartIcon(),
                          spacer.width,
                          IconButton(
                            onPressed: refresh,
                            icon: const Icon(Icons.refresh),
                            color: prudColorTheme.bgB,
                            splashColor: prudColorTheme.bgD,
                            splashRadius: 10.0,
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            spacer.height,
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: FittedBox(
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if(gift.country != null && gift.country!.isoName != null) Text(
                          "${tabData.getCountryFlag(gift.country!.isoName!)}",
                          style: prudWidgetStyle.hintStyle.copyWith(
                              fontSize: 25.0
                          ),
                        ),
                        spacer.width,
                        Text(
                          "${gift.productName}",
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: prudColorTheme.textA,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                    mediumSpacer.width,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${currencyMath.roundDouble(((gift.discountPercentage?? 0)*giftCustomerDiscountInPercentage), 2)}",
                              style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                  color: prudColorTheme.error
                              ),
                            ),
                            Text(
                              "%",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                  color: prudColorTheme.buttonA
                              ),
                            ),
                          ],
                        ),
                        Translate(
                          text: "DISCOUNT",
                          align: TextAlign.center,
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                            color: prudColorTheme.textB,
                            fontSize: 13,
                            fontWeight: FontWeight.w600
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            spacer.height,
            if(gift.senderFee != null && gift.senderFee! > 0) Padding(
              padding: const EdgeInsets.only(left: 10, right: 10,),
              child: PrudPanel(
                title: "You Will be charged",
                titleColor: prudColorTheme.textB,
                bgColor: prudColorTheme.bgC,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: gettingFx? const Center(
                    child: LoadingComponent(
                      size: 40,
                      isShimmer: false,
                    ),
                  ) : Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PrudDataViewer(valueIsMoney: true, field: "Sender Fee", value: "${giftCardNotifier.lastGiftSearch?.senderCurrency.symbol}$senderFeeInSenderCur"),
                      spacer.width,
                      PrudDataViewer(valueIsMoney: true, field: "SMS Fee", value: "${giftCardNotifier.lastGiftSearch?.senderCurrency.symbol}$smsFeeInSenderCur"),
                    ],
                  ),
                ),
              ),
            ),
            spacer.height,
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  if(gift.denominationType != null && gift.denominationType!.toLowerCase() == "fixed") PrudPanel(
                    title: "Select the GiftCard Capacity",
                    titleColor: prudColorTheme.textB,
                    bgColor: prudColorTheme.bgC,
                    hasPadding: false,
                    child: SizedBox(
                      height: 240,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: gift.fixedRecipientToSenderDenominationsMap!.keys.length,
                        itemBuilder: (context, index){
                          List<dynamic> keys = gift.fixedRecipientToSenderDenominationsMap!.keys.toList();
                          List<dynamic> values = gift.fixedRecipientToSenderDenominationsMap!.values.toList();
                          Denomination denMap = Denomination(
                            sender: values[index],
                            recipient: keys[index]
                          );
                          bool selected = denSelected != null && denSelected!.recipient == denMap.recipient;
                          return GiftDenomination(
                            denMap: denMap,
                            selected: selected,
                            discountInPercentage: (gift.discountPercentage?? 0)*giftCustomerDiscountInPercentage,
                            senderFee: gift.senderFee?? 0,
                            recipientCur: gift.recipientCurrencyCode!
                          );
                        }
                      ),
                    ),
                  ),
                  if(gift.denominationType != null && gift.denominationType!.toLowerCase() == "range") PrudPanel(
                    title: "Gift Card Amount",
                    titleColor: prudColorTheme.textB,
                    bgColor: prudColorTheme.bgC,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        children: [
                          Translate(
                            text: "How much do you want the card to carry? Be sure it's not less "
                                "than the minimum nor more than the maximum",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 13.0,
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
                                              Text(
                                                "${(tabData.getCurrency(gift.recipientCurrencyCode!))?.symbol}",
                                                style: tabData.tBStyle.copyWith(
                                                    fontSize: 15.0,
                                                    color: prudColorTheme.textA
                                                ),
                                              ),
                                              Text(
                                                "${gift.minRecipientDenomination}",
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
                                  initialValue: "$selectedDeno",
                                  name: 'deno',
                                  style: tabData.npStyle,
                                  keyboardType: TextInputType.number,
                                  decoration: getDeco("How Much"),
                                  onChanged: (dynamic value){
                                    try{
                                      if(mounted) {
                                        setState(() => selectedDeno = double.parse(value?.trim()));
                                      }
                                    }catch(ex){
                                      debugPrint("Error: $ex");
                                    }
                                  },
                                  valueTransformer: (text) => num.tryParse(text!),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.min(gift.minRecipientDenomination?? 0),
                                    FormBuilderValidators.max(gift.maxRecipientDenomination?? 0)
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
                                              Text(
                                                "${(tabData.getCurrency(gift.recipientCurrencyCode!))?.symbol}",
                                                style: tabData.tBStyle.copyWith(
                                                  fontSize: 15.0,
                                                  color: prudColorTheme.textA
                                                ),
                                              ),
                                              Text(
                                                "${gift.maxRecipientDenomination}",
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
                                child: gettingDenoCost? LoadingComponent(
                                  isShimmer: false,
                                  size: 40,
                                  spinnerColor: prudColorTheme.primary,
                                ) : prudWidgetStyle.getIconButton(
                                  onPressed: checkSelectedDeno,
                                  isIcon: true,
                                  icon: Icons.add_card_sharp
                                ),
                              )
                            ],
                          ),
                          if(selectedDenoCost > 0) Column(
                            children: [
                              Divider(
                                height: 15.0,
                                thickness: 1.0,
                                endIndent: 30,
                                indent: 30,
                                color: prudColorTheme.lineC,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                        "${(tabData.getCurrency(gift.recipientCurrencyCode!))?.symbol}",
                                              style: tabData.tBStyle.copyWith(
                                                fontSize: 18.0,
                                                color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "$selectedDeno",
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
                                                  fontSize: 25.0,
                                                  color: prudColorTheme.primary,
                                                  fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                        Translate(
                                          text: "Beneficiary Gets",
                                          style: prudWidgetStyle.tabTextStyle.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: prudColorTheme.textB
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${giftCardNotifier.lastGiftSearch?.senderCurrency.symbol}",
                                              style: tabData.tBStyle.copyWith(
                                                fontSize: 18.0,
                                                color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "$selectedDenoCost",
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
                                                fontSize: 25.0,
                                                color: prudColorTheme.primary,
                                                fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                        Stack(
                                          alignment: AlignmentDirectional.center,
                                          children: [
                                            Translate(
                                              text: "Sender Pays",
                                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: prudColorTheme.textB
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15),
                                              child: Translate(
                                                text: "(Discount & Charges Excluded)",
                                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w600,
                                                    color: prudColorTheme.danger
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if(selectedDenoCostWithDiscount > 0) Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${giftCardNotifier.lastGiftSearch?.senderCurrency.symbol}",
                                              style: tabData.tBStyle.copyWith(
                                                  fontSize: 18.0,
                                                  color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "$selectedDenoCostWithDiscount",
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
                                                fontSize: 25.0,
                                                color: prudColorTheme.primary,
                                                fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                        Stack(
                                          alignment: AlignmentDirectional.center,
                                          children: [
                                            Translate(
                                              text: "Sender Pays",
                                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: prudColorTheme.textB
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15),
                                              child: Translate(
                                                text: "(Charges Excluded)",
                                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w600,
                                                    color: prudColorTheme.danger
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ]
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  spacer.height,
                  if(selectedDenoCost != 0 || giftCardNotifier.selectedDenMap != null) const AddBeneficiary(),
                  spacer.height,
                  if(gift.redeemInstruction != null) PrudPanel(
                    title: "Redeem Instructions",
                    titleColor: prudColorTheme.textB,
                    bgColor: prudColorTheme.bgC,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 15),
                      child: Column(
                        children: [
                          if(gift.redeemInstruction!.concise != null) PrudContainer(
                            hasTitle: true,
                            title: "Concise Instructions",
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                              child: Translate(
                                text: "${gift.redeemInstruction?.concise}",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: prudColorTheme.success
                                ),
                                align: TextAlign.left,
                              ),
                            ),
                          ),
                          spacer.height,
                          if(gift.redeemInstruction!.verbose != null) PrudContainer(
                            hasTitle: true,
                            title: "Elaborated Instructions",
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                              child: Translate(
                                text: "${gift.redeemInstruction?.verbose}",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: prudColorTheme.primary
                                ),
                                align: TextAlign.left,
                              ),
                            ),
                          ),
                          spacer.height,
                        ],
                      ),
                    ),
                  ),
                  spacer.height,
                  if(hasSelectedBen && (selectedDeno > 0 || denSelected != null) && !adding) prudWidgetStyle.getLongButton(
                    onPressed: addToCart,
                    text:"Add To Cart"
                  ),
                  if(adding) LoadingComponent(
                    isShimmer: false,
                    size: 40,
                    spinnerColor: prudColorTheme.primary,
                  ),
                  spacer.height,
                ],
              ),
            ),
            mediumSpacer.height,
          ],
        ),
      ),
    );
  }
}
