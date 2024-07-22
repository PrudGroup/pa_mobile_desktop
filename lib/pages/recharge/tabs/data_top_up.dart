import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../components/Translate.dart';
import '../../../components/loading_component.dart';
import '../../../components/prud_panel.dart';
import '../../../components/recharge_denomination.dart';
import '../../../components/recharge_operator_promos.dart';
import '../../../models/images.dart';
import '../../../models/reloadly.dart';
import '../../../models/theme.dart';
import '../../../singletons/i_cloud.dart';
import '../../../singletons/recharge_notifier.dart';
import '../../../singletons/tab_data.dart';
import '../recharge_history.dart';

class DataTopUp extends StatefulWidget {
  final String? affLinkId;
  final Function(int)? goToTab;
  const DataTopUp({super.key, this.affLinkId, this.goToTab});

  @override
  DataTopUpState createState() => DataTopUpState();
}

class DataTopUpState extends State<DataTopUp> {

  ScrollController scrollCtrl = ScrollController();
  TextEditingController phoneTextController = TextEditingController();
  PhoneNumber? phoneNo;
  String? justNum;
  bool gettingCountries = false;
  List<String> countries = [];
  List<String> currencies = [];
  bool getting = false;
  bool startingTrans = false;
  bool phoneIsValid = false;
  Country? selectedCountry;
  RechargeOperator? detectedOperator;
  double selectedAmount = 0;
  FocusNode focusN = FocusNode();
  List<Widget> carousels = [];


  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }

  Future<void> startTransaction() async {
    // remember to check operators' status
  }

  Future<void> selectAmount(double amt) async {
    if(mounted) setState(() => selectedAmount = amt);
    await startTransaction();
  }

  void getCountry(){
    showCountryPicker(
        context: context,
        countryFilter: countries,
        favorite: ["NG", "UK", "SA", "US"],
        onSelect: (Country country) async {
          try{
            if(mounted){
              setState(() {
                selectedCountry = country;
              });
              if(selectedCountry != null) await detectProvider();
            }
          }catch(ex){
            debugPrint("getCurrency Error: $ex");
          }
        }
    );
  }

  Future<void> initSettings() async {
    try{
      if(mounted) setState(() => gettingCountries = true);
      if(reloadlyRechargeToken == null) await rechargeNotifier.getRechargeToken();
      if(reloadlyRechargeToken != null && rechargeableCountries.isEmpty) await rechargeNotifier.getRechargeableCountries();
      if(rechargeableCountries.isNotEmpty){
        for(ReloadlyCountry cty in rechargeableCountries){
          if(cty.isoName != null) countries.add(cty.isoName!);
          if(cty.currencyCode != null) currencies.add(cty.currencyCode!);
        }
        rechargeNotifier.saveRechargeableCountriesToCache();
      }
      if(mounted) setState(() => gettingCountries = false);
    }catch(ex){
      debugPrint("Airtime initSettings Error: $ex");
      if(mounted) setState(() => gettingCountries = false);
    }
  }

  Future<void> detectProvider() async {
    try{
      focusN.unfocus();
      if(mounted) setState(() => getting = true);
      if(phoneNo != null && justNum != null && phoneIsValid){
        String? country = phoneNo!.isoCode;
        if(country != null || selectedCountry != null){
          String ctyCode = country ?? selectedCountry!.countryCode;
          RechargeOperator? operator = await rechargeNotifier.detectOperator(ctyCode, justNum!, isAirtime: false);
          debugPrint("Operator: $operator");
          if(mounted){
            setState(() {
              detectedOperator = operator;
              carousels = detectedOperator!.logoUrls!.map((dynamic str){
                return Image.network(
                  str,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress){
                    if (loadingProgress == null) return child;
                    return Center(
                      child: LoadingComponent(
                        isShimmer: false,
                        size: 40,
                        spinnerColor: prudColorTheme.lineC,
                      ),
                    );
                  },
                  errorBuilder: (context, wid, chunk){
                    return const LoadingComponent(
                      isShimmer: false,
                      size: 20,
                    );
                  },
                );
              }).toList();
              if(detectedOperator != null && detectedOperator!.logoUrls != null && detectedOperator!.logoUrls!.isNotEmpty) {
                carousels = detectedOperator!.logoUrls!.map((dynamic str){
                  return Image.network(
                    str,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress){
                      if (loadingProgress == null) return child;
                      return Center(
                        child: LoadingComponent(
                          isShimmer: false,
                          size: 40,
                          spinnerColor: prudColorTheme.lineC,
                        ),
                      );
                    },
                    errorBuilder: (context, wid, chunk){
                      return const LoadingComponent(
                        isShimmer: false,
                        size: 20,
                      );
                    },
                  );
                }).toList();
              }
              if(detectedOperator!.minAmount != null) selectedAmount = detectedOperator!.minAmount!;
              debugPrint("Operator: ${detectedOperator?.toJson()}");
              getting = false;
            });
          }
        }else{
          getCountry();
        }
      }
      if(mounted) setState(() => getting = false);
    }catch(ex){
      if(mounted) setState(() => getting = false);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await initSettings();

    });
    super.initState();
    rechargeNotifier.addListener((){

    });
  }

  @override
  void dispose() {
    phoneTextController.dispose();
    scrollCtrl.dispose();
    rechargeNotifier.removeListener((){});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Data Top-up",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: [
          IconButton(
              onPressed: () => iCloud.goto(context, const RechargeHistory()),
              icon: const Icon(FontAwesome5Solid.history)
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            spacer.height,
            PrudPanel(
              title: 'Phone Details',
              bgColor: prudColorTheme.bgC,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                      color: prudColorTheme.lineC,
                      borderRadius: const BorderRadius.all(Radius.circular(5.0))
                  ),
                  child: Row(
                    children:  [
                      Expanded(
                        child: InternationalPhoneNumberInput(
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          textFieldController: phoneTextController,
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          ),
                          textStyle: prudWidgetStyle.typedTextStyle,
                          inputDecoration: prudWidgetStyle.inputDeco.copyWith(hintText: "Phone Number"),
                          maxLength: 20,
                          focusNode: focusN,
                          onInputValidated: (bool value){
                            if(mounted) setState(() => phoneIsValid = value);
                          },
                          onInputChanged: (PhoneNumber phoneNumber){
                            if(mounted){
                              setState(() {
                                phoneNo = phoneNumber;
                                justNum = phoneNumber.phoneNumber;
                              });
                            }
                          },
                        ),
                      ),
                      spacer.width,
                      getting || gettingCountries? LoadingComponent(
                        isShimmer: false,
                        defaultSpinnerType: true,
                        spinnerColor: prudColorTheme.primary,
                        size: 25,
                      ) : prudWidgetStyle.getIconButton(
                        onPressed: detectProvider,
                        icon: Icons.add_chart_sharp,
                        isIcon: true,
                        makeLight: phoneNo != null? false : true,
                      )
                    ],
                  ),
                ),
              ),
            ),
            spacer.height,
            if(detectedOperator != null) Column(
              children: [
                detectedOperator!.name != null && detectedOperator!.promotions != null && detectedOperator!.promotions!.isNotEmpty?
                RechargeOperatorPromos(
                    promos: detectedOperator!.promotions!,
                    operatorName: detectedOperator!.name!,
                    carousels: carousels
                )
                    :
                Row(
                  children: [
                    Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                            color: prudColorTheme.lineC,
                            width: 2.0
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: carousels.isNotEmpty?
                        GFCarousel(
                            height: 100.0,
                            autoPlay: true,
                            aspectRatio: double.maxFinite,
                            viewportFraction: 1.0,
                            enlargeMainPage: true,
                            enableInfiniteScroll: true,
                            pauseAutoPlayOnTouch: const Duration(seconds: 10),
                            autoPlayInterval: const Duration(seconds: 3),
                            items: carousels
                        )
                            :
                        Center(
                          child: Image.asset(prudImages.airtime, fit: BoxFit.contain,),
                        ),
                      ),
                    ),
                    spacer.width,
                    Column(
                      children: [
                        Text(
                          "${detectedOperator!.name}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 25,
                            color: prudColorTheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${detectedOperator?.country?.name} | ${detectedOperator?.country?.isoName}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              color: prudColorTheme.textB,
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          ),

                        ),
                        Text(
                          "Status: ${detectedOperator?.status}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              color: prudColorTheme.iconB,
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                spacer.height,
                if(detectedOperator!.denominationType != null && detectedOperator!.denominationType!.toLowerCase() != "fixed") PrudPanel(
                  title: "Amount",
                  titleColor: prudColorTheme.textB,
                  bgColor: prudColorTheme.bgC,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      children: [
                        Translate(
                          text: "Be sure it's not less "
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
                                              "${detectedOperator!.destinationCurrencySymbol}",
                                              style: tabData.tBStyle.copyWith(
                                                  fontSize: 15.0,
                                                  color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "${tabData.getFormattedNumber(detectedOperator!.minAmount)}",
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
                                initialValue: "$selectedAmount",
                                name: 'deno',
                                style: tabData.npStyle,
                                keyboardType: TextInputType.number,
                                decoration: getDeco("How Much"),
                                onChanged: (dynamic value){
                                  try{
                                    if(mounted) {
                                      setState(() => selectedAmount = double.parse(value?.trim()));
                                    }
                                  }catch(ex){
                                    debugPrint("Error: $ex");
                                  }
                                },
                                valueTransformer: (text) => num.tryParse(text!),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.min(detectedOperator!.minAmount?? 1),
                                  FormBuilderValidators.max(detectedOperator!.maxAmount?? 100),
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
                                              "${detectedOperator?.destinationCurrencySymbol}",
                                              style: tabData.tBStyle.copyWith(
                                                  fontSize: 15.0,
                                                  color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "${tabData.getFormattedNumber(detectedOperator!.maxAmount)}",
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
                                onPressed: startTransaction,
                                isIcon: false,
                                image: prudImages.airtime,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if(detectedOperator!.denominationType != null && detectedOperator!.localMinAmount != null && detectedOperator!.localMaxAmount != null) PrudPanel(
                  title: "Local Amount",
                  titleColor: prudColorTheme.textB,
                  bgColor: prudColorTheme.bgC,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      children: [
                        Translate(
                          text: "Be sure it's not less "
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
                                              "${detectedOperator!.destinationCurrencySymbol}",
                                              style: tabData.tBStyle.copyWith(
                                                  fontSize: 15.0,
                                                  color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "${tabData.getFormattedNumber(detectedOperator!.localMinAmount)}",
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
                                initialValue: "$selectedAmount",
                                name: 'deno',
                                style: tabData.npStyle,
                                keyboardType: TextInputType.number,
                                decoration: getDeco("How Much"),
                                onChanged: (dynamic value){
                                  try{
                                    if(mounted) {
                                      setState(() => selectedAmount = double.parse(value?.trim()));
                                    }
                                  }catch(ex){
                                    debugPrint("Error: $ex");
                                  }
                                },
                                valueTransformer: (text) => num.tryParse(text!),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.min(detectedOperator!.localMinAmount?? 1),
                                  FormBuilderValidators.max(detectedOperator!.localMaxAmount?? 100),
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
                                              "${detectedOperator?.destinationCurrencySymbol}",
                                              style: tabData.tBStyle.copyWith(
                                                  fontSize: 15.0,
                                                  color: prudColorTheme.textA
                                              ),
                                            ),
                                            Text(
                                              "${tabData.getFormattedNumber(detectedOperator!.localMaxAmount)}",
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
                                onPressed: startTransaction,
                                isIcon: false,
                                image: prudImages.airtime,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if(detectedOperator!.denominationType != null && detectedOperator!.denominationType!.toLowerCase() == "fixed" && detectedOperator!.fixedAmounts!.isNotEmpty) PrudPanel(
                  title: "Fixed Amount",
                  titleColor: prudColorTheme.textB,
                  bgColor: prudColorTheme.bgC,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: SizedBox(
                      height: 150,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: detectedOperator!.fixedAmounts!.length,
                          itemBuilder: (context, index){
                            double amt = detectedOperator!.fixedAmounts![index];
                            String desc = detectedOperator!.fixedAmountsDescriptions![index];
                            return InkWell(
                              onTap: () => selectAmount(amt),
                              child: RechargeDenomination(
                                amt: amt,
                                desc: desc,
                                currencySymbol: detectedOperator!.destinationCurrencySymbol!,
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                ),
                spacer.height,
                if(detectedOperator!.suggestedAmounts != null && detectedOperator!.suggestedAmounts!.isNotEmpty) PrudPanel(
                  title: "Suggested Amounts",
                  titleColor: prudColorTheme.textB,
                  bgColor: prudColorTheme.bgC,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: SizedBox(
                      height: 150,
                      child: ListView.builder(
                          itemCount: detectedOperator!.suggestedAmounts!.length,
                          itemBuilder: (context, index){
                            double amt = detectedOperator!.suggestedAmounts![index];
                            return InkWell(
                              onTap: () => selectAmount(amt),
                              child: RechargeDenomination(
                                amt: amt,
                                currencySymbol: detectedOperator!.destinationCurrencySymbol!,
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                ),
                spacer.height,
                if(detectedOperator!.mostPopularAmount != null) PrudPanel(
                  title: "Most Popular Amounts",
                  titleColor: prudColorTheme.textB,
                  bgColor: prudColorTheme.bgC,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: SizedBox(
                      height: 150,
                      child: ListView(
                        children: [
                          spacer.width,
                          RechargeDenomination(
                            amt: detectedOperator!.mostPopularAmount!,
                            currencySymbol: detectedOperator!.destinationCurrencySymbol!,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                spacer.height,
                if(detectedOperator!.localFixedAmounts != null && detectedOperator!.localFixedAmounts!.isNotEmpty && detectedOperator!.localFixedAmountsDescriptions != null) PrudPanel(
                  title: "Local Fixed Amounts",
                  titleColor: prudColorTheme.textB,
                  bgColor: prudColorTheme.bgC,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: SizedBox(
                      height: 150,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: detectedOperator!.localFixedAmounts!.length,
                          itemBuilder: (context, index){
                            double amt = detectedOperator!.localFixedAmounts![index];
                            String desc = detectedOperator!.localFixedAmountsDescriptions![index];
                            return InkWell(
                              onTap: () => selectAmount(amt),
                              child: RechargeDenomination(
                                amt: amt,
                                desc: desc,
                                currencySymbol: detectedOperator!.destinationCurrencySymbol!,
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                ),
                spacer.height,
              ],
            ),


          ],
        ),
      ),
    );
  }
}
