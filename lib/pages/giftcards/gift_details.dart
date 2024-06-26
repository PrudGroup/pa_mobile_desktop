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

  void refresh(){

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
        giftCardNotifier.lastGiftSearch != null) {
      FxRate? senderCost = await giftCardNotifier.getFxRate(
          giftCardNotifier.lastGiftSearch!.beneficiaryCurrency.code,
          selectedDeno
      );
      if (mounted && senderCost != null) {
        double inSenderCur = await currencyMath.convert(
          amount: senderCost.senderAmount!,
          quoteCode: giftCardNotifier.lastGiftSearch!.senderCurrency.code,
          baseCode: "NGN"
        );
        double discount = inSenderCur * (gift.discountPercentage!/100);
        setState(() {
          gettingDenoCost = false;
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
  }

  @override
  void dispose() {
    giftCardNotifier.removeListener((){});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
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
                  image: NetworkImage(
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
                              "${gift.discountPercentage?? 0}",
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
                      PrudDataViewer(field: "Sender Fee", value: "${giftCardNotifier.lastGiftSearch?.senderCurrency.symbol}$senderFeeInSenderCur"),
                      spacer.width,
                      PrudDataViewer(field: "SMS Fee", value: "${giftCardNotifier.lastGiftSearch?.senderCurrency.symbol}$smsFeeInSenderCur"),
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
                            discountInPercentage: gift.discountPercentage?? 0,
                            senderFee: gift.senderFee?? 0,
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
                                child: FittedBox(
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
                                          child: Row(
                                            children: [
                                              Text(
                                                "${giftCardNotifier.lastGiftSearch?.beneficiaryCurrency.symbol}",
                                                style: prudWidgetStyle.btnTextStyle.copyWith(
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
                                      )
                                    ],
                                  ),
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
                                child: FittedBox(
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
                                          child: Row(
                                            children: [
                                              Text(
                                                "${giftCardNotifier.lastGiftSearch?.beneficiaryCurrency.symbol}",
                                                style: prudWidgetStyle.btnTextStyle.copyWith(
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
                                      )
                                    ],
                                  ),
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
                                              "${giftCardNotifier.lastGiftSearch?.senderCurrency.symbol}",
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
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
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
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
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          direction: Axis.vertical,
                                          spacing: -5.0,
                                          children: [
                                            Translate(
                                              text: "Sender Pays",
                                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: prudColorTheme.textB
                                              ),
                                            ),
                                            Translate(
                                              text: "(Discount & Charges Excluded)",
                                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w600,
                                                color: prudColorTheme.danger
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    if(selectedDenoCostWithDiscount > 0) Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${giftCardNotifier.lastGiftSearch?.senderCurrency.symbol}",
                                              style: prudWidgetStyle.btnTextStyle.copyWith(
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
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          direction: Axis.vertical,
                                          spacing: -5.0,
                                          children: [
                                            Translate(
                                              text: "Sender Pays",
                                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: prudColorTheme.textB
                                              ),
                                            ),
                                            Translate(
                                              text: "(Charges Excluded)",
                                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w600,
                                                  color: prudColorTheme.danger
                                              ),
                                            )
                                          ],
                                        )
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
