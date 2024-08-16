import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/pages/travels/switz_travels.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../../../../../components/translate_text.dart';
import '../../../../../models/theme.dart';
import '../../../../../singletons/tab_data.dart';

class NewBusDashboard extends StatefulWidget {
  const NewBusDashboard({super.key});

  @override
  NewBusDashboardState createState() => NewBusDashboardState();
}

class NewBusDashboardState extends State<NewBusDashboard> {
  String brandName = "";
  String email = "";
  Country? selectedCountry;
  String slogan = "";
  String registrar = "";
  String regGovId = "";
  String referralCode = "";
  String logoLink = "";
  bool loading = false;
  bool sending = false;
  BusBrandOperator? operator;
  bool hasCreatedOperator = false;
  bool hasTriedAlready = false;
  String code = tabData.getRandomDigitString(6);
  String typedCode = "";

  Future<void> resendCode() async {
    await tryAsync("resendCode", () async {
      if(mounted) setState(() => sending = true);
      String? sentCode = await busNotifier.sendCode(email, code);
      if(sentCode == code && mounted){
        iCloud.showSnackBar("Code sent", context, title: "Sent");
      }
      if(mounted) setState(() => sending = false);
    }, error: (){
      if(mounted) setState(() => sending = false);
    });
  }


  Future<void> verifyEmail() async {
    await tryAsync("verifyEmail", () async {
      if(mounted) setState(() => loading = true);
      if(typedCode == code){
        bool updated = await busNotifier.updateEmailVerification(busNotifier.busBrandId!, email);
        if(updated){
          if(mounted) iCloud.goto(context, const SwitzTravels(tab: 2,));
        }else{
          if(mounted) {
            iCloud.showSnackBar("Email Not Verified", context);
          }
        }
      }else{
        iCloud.showSnackBar("Wrong code entered", context);
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }


  Future<void> retryCreation() async {
    await tryAsync("retryCreation", () async {
      if(mounted) setState(() => loading = true);
      BusBrandOperator newOpr = BusBrandOperator(
          affId: myStorage.user!.id!,
          status: "ACTIVE",
          brandId: busNotifier.busBrandId!,
          role: "SUPER"
      );
      BusBrandOperator? opr = await busNotifier.createNewOperator(newOpr);
      if(mounted) {
        if(opr != null){
          busNotifier.busOperatorId = opr.id;
          busNotifier.busBrandRole = opr.role;
          busNotifier.isActive = opr.status.toLowerCase() == "active";
          await busNotifier.saveDefaultSettings();
          await resendCode();
          if(mounted) {
            setState(() {
              operator = opr;
              hasCreatedOperator = true;
            });
          }
        }
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }


  Future<void> create() async {
    bool validated = validateForm();
    if(validated){
      await tryAsync("create", () async {
        if(mounted) {
          setState(() {
            loading = true;
          });
        }
        BusBrand busBrand = BusBrand(
          email: email,
          country: selectedCountry!.countryCode,
          brandName: brandName,
          govRegistrationId: regGovId,
          logo: logoLink,
          ownBy: myStorage.user!.id!,
          registrar: registrar,
          slogan: slogan
        );
        bool saved = await busNotifier.createNewBrand(busBrand);
        if(saved && mounted && busNotifier.busBrandId != null){
          await retryCreation();
          if(mounted) setState(() => hasTriedAlready = true);
        }else{
          if(mounted) {
            setState(() => loading = false);
            iCloud.showSnackBar("Unable To Create Dashboard", context, type: 3);
          }
        }
      }, error: (){
        if(mounted) setState(() => loading = false);
      });
    }else{
      iCloud.showSnackBar("Details Incomplete", context);
    }
  }

  bool validateForm(){
    return brandName.isNotEmpty && email.isNotEmpty && selectedCountry != null &&
      slogan.isNotEmpty && logoLink.isNotEmpty && registrar.isNotEmpty && regGovId.isNotEmpty &&
      myStorage.user != null && myStorage.user!.id != null;
  }

  void getCountry(){
    showCountryPicker(
      context: context,
      favorite: ["NG", "GA", "SA", "UK", "AU", "US"],
      onSelect: (Country country){
        if(mounted) setState(() => selectedCountry = country);
      }
    );
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
          text: "Create Brand Dashboard",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            if(!hasTriedAlready) Column(
              children: [
                spacer.height,
                PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Referral Code",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        Translate(
                          text: "Businesses that registers with referral codes usually get discounts on platform charges. ",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: referralCode,
                          name: 'referralCode',
                          autofocus: true,
                          style: tabData.npStyle,
                          keyboardType: TextInputType.text,
                          decoration: getDeco(
                              "Referral Code",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => referralCode = value);
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(3),
                            FormBuilderValidators.maxLength(30),
                          ]),
                        ),
                        spacer.height
                      ],
                    )
                ),
                spacer.height,
                PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Brand Name *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: brandName,
                          name: 'brandName',
                          autofocus: true,
                          style: tabData.npStyle,
                          keyboardType: TextInputType.text,
                          decoration: getDeco(
                              "Bus Transit Name",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => brandName = value);
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(3),
                            FormBuilderValidators.maxLength(100),
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        spacer.height
                      ],
                    )
                ),
                spacer.height,
                PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Brand Email *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: email,
                          name: 'email',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.emailAddress,
                          decoration: getDeco(
                              "Bus Transit Email",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => email = value);
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.email(),
                            FormBuilderValidators.required()
                          ]),
                        ),
                        spacer.height
                      ],
                    )
                ),
                spacer.height,
                PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Brand Country *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        InkWell(
                          onTap: getCountry,
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FittedBox(
                                child: Row(
                                  children: [
                                    if(selectedCountry != null) Text(
                                      selectedCountry!.flagEmoji,
                                      style: prudWidgetStyle.tabTextStyle.copyWith(
                                          fontSize: 20.0
                                      ),
                                    ),
                                    spacer.width,
                                    Translate(
                                      text: selectedCountry != null? selectedCountry!.displayName : "Select Country",
                                      style: prudWidgetStyle.tabTextStyle.copyWith(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_sharp,
                                size: 20,
                                color: prudColorTheme.lineB,
                              )
                            ],
                          ),
                        )
                      ],
                    )
                ),
                spacer.height,
                PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Brand Slogan *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: slogan,
                          name: 'slogan',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.text,
                          decoration: getDeco(
                              "Bus Transit Slogan",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => slogan = value);
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(3),
                            FormBuilderValidators.maxLength(50),
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        spacer.height
                      ],
                    )
                ),
                spacer.height,
                PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Government Registrar *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        Translate(
                          text: "As a transport company, you must be registered as one with the government of the country where you do business. Kindly tell "
                              "us the name of the government business registrar. ",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: registrar,
                          name: 'registrar',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.text,
                          decoration: getDeco(
                              "Government Registrar",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => registrar = value);
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(3),
                            FormBuilderValidators.maxLength(100),
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        spacer.height
                      ],
                    )
                ),
                spacer.height,
                PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Government RegNo *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        Translate(
                          text: "What is the registration number you got from your government business registrar that uniquely identifies your business. ",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: regGovId,
                          name: 'regGovId',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.text,
                          decoration: getDeco(
                              "Registration ID",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => regGovId = value);
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(3),
                            FormBuilderValidators.maxLength(30),
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        spacer.height,
                      ],
                    )
                ),
                spacer.height,
                PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Company Logo *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        Translate(
                          text: "You must have the logo of your company saved somewhere on the web. What's the link?",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: regGovId,
                          name: 'logo',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.text,
                          decoration: getDeco(
                              "Logo",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => logoLink = value);
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(3),
                          ]),
                        ),
                        spacer.height,
                      ],
                    )
                ),
                spacer.height,
                loading? LoadingComponent(
                  isShimmer: false,
                  size: 35,
                  spinnerColor: prudColorTheme.primary,
                )
                    :
                validateForm()? prudWidgetStyle.getLongButton(
                    onPressed: create,
                    text: "Create Dashboard"
                ) : const SizedBox(),
              ],
            ),
            spacer.height,
            if(hasTriedAlready && !hasCreatedOperator) PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Operator",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  Translate(
                    text: "We were unable to create access for you. Kindly try it again",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: prudColorTheme.textB
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  loading? LoadingComponent(
                    isShimmer: false,
                    size: 35,
                    spinnerColor: prudColorTheme.primary,
                  )
                      :
                  prudWidgetStyle.getLongButton(
                    onPressed: retryCreation,
                    text: "Create Access"
                  ),
                  spacer.height,
                ],
              )
            ),
            if(hasTriedAlready && hasCreatedOperator) PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Verify Email",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  Translate(
                    text: "A code has been sent to your email. Type in the code below and verify.",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: prudColorTheme.textB
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  FormBuilderTextField(
                    initialValue: typedCode,
                    name: 'code',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                        "Email Verification",
                        onlyBottomBorder: true,
                        borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted && value != null) setState(() => typedCode = value);
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(6),
                      FormBuilderValidators.maxLength(6),
                    ]),
                  ),
                  spacer.height,
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      getTextButton(
                        onPressed: resendCode,
                        title: "Resend code"
                      ),
                      loading? LoadingComponent(
                        isShimmer: false,
                        size: 35,
                        spinnerColor: prudColorTheme.primary,
                      )
                          :
                      prudWidgetStyle.getShortButton(
                        onPressed: verifyEmail,
                        text: "Verify"
                      ),
                    ],
                  ),
                  spacer.height,
                ],
              )
            ),
            largeSpacer.height,
            xLargeSpacer.height,
          ],
        ),
      ),
    );
  }
}
