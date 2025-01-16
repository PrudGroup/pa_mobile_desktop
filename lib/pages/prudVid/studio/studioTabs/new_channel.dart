import 'package:country_state_city/models/country.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/theme.dart';

import '../../../../components/country_picker.dart';
import '../../../../components/prud_container.dart';
import '../../../../components/prud_image_picker.dart';
import '../../../../components/prud_panel.dart';
import '../../../../components/translate_text.dart';
import '../../../../models/prud_vid.dart';
import '../../../../singletons/prud_studio_notifier.dart';
import '../../../../singletons/tab_data.dart';

enum CreateChannelSteps {
  policy,
  step1,
  step2,
  step3,
  step4,
  step5,
  step6,
  step7,
  success,
  failed
}

class NewChannel extends StatefulWidget {
  final Function(int) goToTab;
  const NewChannel({super.key, required this.goToTab});

  @override
  State<NewChannel> createState() => _NewChannelState();
}

class _NewChannelState extends State<NewChannel> {
  CreateChannelSteps presentStep = CreateChannelSteps.policy;
  bool loading = false;
  String? channelName;
  String? countryCode = "NG";
  String category = channelCategories[0];
  Currency? selectedCurrency;
  Studio? studio = prudStudioNotifier.studio;
  String? logoUrl;
  String? displayScreenImage;
  bool shouldReset = false;

  void clearInput(){
    setState(() {
      shouldReset = true;
      displayScreenImage = null;
      logoUrl = null;
      selectedCurrency = null;
      category = channelCategories[0];
      countryCode = "NG";
      channelName = null;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void getCurrency(){
    showCurrencyPicker(
      context: context,
      favorite: ["NGN", "GBP", "USD", "EUR", "CAD"],
      onSelect: (Currency cur){
        try{
          if(mounted) {
            setState(() {
              selectedCurrency = cur;
            });
          }
        }catch(ex){
          debugPrint("getCurrency Error: $ex");
        }
      }
    );
  }

  Future<bool> createChannel() async {
    return false;
  }

  Color getPreviousButtonColor() {
    if(presentStep == CreateChannelSteps.policy || presentStep == CreateChannelSteps.success) return prudColorTheme.bgD;
    return prudColorTheme.iconA;
  }

  Color getNextButtonColor() {
    if(presentStep == CreateChannelSteps.failed) return prudColorTheme.bgD;
    return prudColorTheme.iconA;
  }

  String getNextButtonTitle() {
    if(presentStep == CreateChannelSteps.failed) return "Try Again";
    return "Next";
  }

  String getPreviousButtonTitle() {
    if(presentStep == CreateChannelSteps.policy) return "Cancel";
    return "Previous";
  }

  bool validateStep(CreateChannelSteps step){
    switch(presentStep){
      case CreateChannelSteps.step1: return countryCode != null && channelName != null;
      case CreateChannelSteps.step2: return category.isNotEmpty && selectedCurrency != null;
      case CreateChannelSteps.step3: return logoUrl != null && displayScreenImage != null;
      case CreateChannelSteps.step4: return false;
      case CreateChannelSteps.step5: return false;
      case CreateChannelSteps.step6: return false;
      case CreateChannelSteps.step7: return false;
      default: return false;
    }
  }

  Future<void> next() async {
    switch(presentStep){
      case CreateChannelSteps.policy: if(mounted) setState(() => presentStep = CreateChannelSteps.step1);
      case CreateChannelSteps.step1: {
        bool validated = validateStep(CreateChannelSteps.step1);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step2);
      }
      case CreateChannelSteps.step2: {
        bool validated = validateStep(CreateChannelSteps.step2);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step3);
      }
      case CreateChannelSteps.step3: {
        bool validated = validateStep(CreateChannelSteps.step3);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step4);
      }
      case CreateChannelSteps.step4: {
        bool validated = validateStep(CreateChannelSteps.step4);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step5);
      }
      case CreateChannelSteps.step5: {
        bool validated = validateStep(CreateChannelSteps.step5);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step6);
      }
      case CreateChannelSteps.step6: {
        bool validated = validateStep(CreateChannelSteps.step6);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step7);
      }
      case CreateChannelSteps.step7: {
        bool validated = validateStep(CreateChannelSteps.step7);
        if(validated) {
          bool created = await createChannel();
          if(mounted && created) {
            setState(() => presentStep = CreateChannelSteps.success);
          }else{
            setState(() => presentStep = CreateChannelSteps.failed);
          }
        }
      }
      case CreateChannelSteps.success: {
        widget.goToTab(2);
      }
      default: if(mounted) setState(() => presentStep = CreateChannelSteps.step7);
    }
  }

  Future<void> previous() async {
    switch(presentStep){
      case CreateChannelSteps.step1: if(mounted) setState(() => presentStep = CreateChannelSteps.policy);
      case CreateChannelSteps.step2: if(mounted) setState(() => presentStep = CreateChannelSteps.step1);
      case CreateChannelSteps.step3: if(mounted) setState(() => presentStep = CreateChannelSteps.step2);
      case CreateChannelSteps.step4: if(mounted) setState(() => presentStep = CreateChannelSteps.step3);
      case CreateChannelSteps.step5: if(mounted) setState(() => presentStep = CreateChannelSteps.step4);
      case CreateChannelSteps.step6: if(mounted) setState(() => presentStep = CreateChannelSteps.step5);
      case CreateChannelSteps.step7: if(mounted) setState(() => presentStep = CreateChannelSteps.step6);
      case CreateChannelSteps.failed: if(mounted) setState(() => presentStep = CreateChannelSteps.step7);
      default: {}
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getTextButton(
                  title: getPreviousButtonTitle(),
                  onPressed: previous,
                  color: getPreviousButtonColor()
                ),
                loading? LoadingComponent(
                  isShimmer: false,
                  defaultSpinnerType: false,
                  size: 20,
                  spinnerColor: getNextButtonColor(),
                ) : getTextButton(
                  title: getNextButtonTitle(),
                  onPressed: next,
                  color: getNextButtonColor()
                )
              ],
            ),
          ),
          Divider(
            indent: 0,
            endIndent: 0,
            height: 1,
            thickness: 2,
            color: prudColorTheme.bgD,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: BouncingScrollPhysics(),
              child: presentStep == CreateChannelSteps.policy?
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spacer.height,
                  Translate(
                    text: "Creating a channel continues exciting experiences on Prudapp. "
                        " Be sure to read our policies that guards owning a Channel on Prudapp. Creating "
                        "one automatically binds you to that agreement. Let's continue the excitements!",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.textB,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  Translate(
                    text: "Do you know that you could make much money monthly by owning and running channel(s) "
                        "on Prudapp? In fact you could start making money off your channel contents almost "
                        "immediately you add high quality contents. Start by creating a channel.",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.primary,
                      fontSize: 16,
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                ],
              )
                  :
              (
                  presentStep == CreateChannelSteps.step1?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      spacer.height,
                      Translate(
                        text: "What name would you like to call your channel. Make it exciting yet represents your brand.",
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          color: prudColorTheme.textB,
                          fontSize: 14,
                        ),
                        align: TextAlign.center,
                      ),
                      spacer.height,
                      PrudContainer(
                          hasTitle: true,
                          hasPadding: true,
                          title: "Channel Name",
                          titleBorderColor: prudColorTheme.bgC,
                          titleAlignment: MainAxisAlignment.end,
                          child: Column(
                            children: [
                              mediumSpacer.height,
                              FormBuilderTextField(
                                initialValue: channelName?? '',
                                name: 'channelName',
                                autofocus: true,
                                style: tabData.npStyle,
                                keyboardType: TextInputType.text,
                                decoration: getDeco(
                                    "Channel Name",
                                    onlyBottomBorder: true,
                                    borderColor: prudColorTheme.lineC
                                ),
                                onChanged: (String? value){
                                  if(mounted && value != null) setState(() => channelName = value.trim());
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
                      Translate(
                        text: "Which country is your primary target for your content. This is "
                            "not to imply that your content will only be used by only people from "
                            "selected country but they are prioritized.",
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          color: prudColorTheme.textB,
                          fontSize: 14,
                        ),
                        align: TextAlign.center,
                      ),
                      spacer.height,
                      PrudContainer(
                        hasTitle: true,
                        hasPadding: true,
                        title: "Country",
                        titleBorderColor: prudColorTheme.bgC,
                        titleAlignment: MainAxisAlignment.end,
                        child: Column(
                          children: [
                            mediumSpacer.height,
                            CountryPicker(
                              bgColor: prudColorTheme.bgA,
                              selected: countryCode?? "NG",
                              onChange: (Country ctry) async {
                                if(mounted) setState(() => countryCode = ctry.isoCode);
                              },
                            ),
                            spacer.height,
                          ],
                        )
                      ),
                      spacer.height,
                    ],
                  )
                      :
                  (
                      presentStep == CreateChannelSteps.step2?
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          spacer.height,
                          Translate(
                            text: "Select a category for your channel. This will mean that every video you upload "
                                "to this channel must be of this category type. If you upload a video with contents "
                                "of another type, your channel will be suspended for a month. So decide what niche your "
                                "channel will be.",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              color: prudColorTheme.textB,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            align: TextAlign.center,
                          ),
                          spacer.height,
                          PrudContainer(
                            hasTitle: true,
                            hasPadding: true,
                            title: "Category",
                            titleBorderColor: prudColorTheme.bgC,
                            titleAlignment: MainAxisAlignment.end,
                            child: Column(
                              children: [
                                mediumSpacer.height,
                                FormBuilder(
                                  child: FormBuilderChoiceChip(
                                    decoration: getDeco("Category"),
                                    backgroundColor: prudColorTheme.bgA,
                                    disabledColor: prudColorTheme.bgD,
                                    spacing: spacer.width.width!,
                                    shape: prudWidgetStyle.choiceChipShape,
                                    selectedColor: prudColorTheme.primary,
                                    onChanged: (String? selected){
                                      tryOnly("CategorySelector", (){
                                        if(mounted && selected != null){
                                          setState(() {
                                            category = selected;
                                          });
                                        }
                                      });
                                    },
                                    name: "category",
                                    initialValue: category,
                                    options: channelCategories.map((String ele) {
                                      return FormBuilderChipOption(
                                        value: ele,
                                        child: Translate(
                                          text: ele,
                                          style: prudWidgetStyle.btnTextStyle.copyWith(
                                              color: ele == category?
                                              prudColorTheme.bgA : prudColorTheme.primary
                                          ),
                                          align: TextAlign.center,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                spacer.height,
                              ],
                            )
                          ),
                          spacer.height,
                          spacer.height,
                          PrudContainer(
                            hasTitle: true,
                            hasPadding: true,
                            title: "Currency",
                            titleBorderColor: prudColorTheme.bgC,
                            titleAlignment: MainAxisAlignment.end,
                            child: Column(
                              children: [
                                mediumSpacer.height,
                                InkWell(
                                  onTap: getCurrency,
                                  child: PrudPanel(
                                    title: "Currency",
                                    titleColor: prudColorTheme.iconB,
                                    bgColor: prudColorTheme.bgA,
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        FittedBox(
                                          child: Row(
                                            children: [
                                              if(selectedCurrency != null) Text(
                                                "${selectedCurrency!.flag}",
                                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                                    fontSize: 18.0
                                                ),
                                              ),
                                              spacer.width,
                                              Translate(
                                                text: selectedCurrency != null? selectedCurrency!.name : "Select Currency",
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
                                  ),
                                ),
                                spacer.height,
                              ],
                            )
                          ),
                          spacer.height,
                        ],
                      )
                          :
                      (
                          presentStep == CreateChannelSteps.step3?
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              spacer.height,
                              Translate(
                                text: "Upload your channel logo. The logo must represent your brand",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.textB,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                align: TextAlign.center,
                              ),
                              if(studio != null && channelName != null) PrudImagePicker(
                                destination: "studio/${studio!.id}/channels/$channelName/images",
                                saveToCloud: true,
                                reset: shouldReset,
                                onSaveToCloud: (String? url){
                                  tryOnly("Picker onSaveToCloud", (){
                                    debugPrint("PhotoUrl: $url");
                                    if(mounted && url != null) setState(() => logoUrl = url);
                                  });
                                },
                                onError: (err){
                                  debugPrint("Picker Error: $err");
                                },
                              ),
                              spacer.height,
                              Translate(
                                text: "What Photo will you use for your channel background. Be sure that the "
                                    "photo has landscape dimensions. The width has to be higher than the height. "
                                    "We recommend 2000x1000 dimensions.",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.textB,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                align: TextAlign.center,
                              ),
                              if(studio != null && channelName != null) PrudImagePicker(
                                destination: "studio/${studio!.id}/channels/$channelName/images",
                                saveToCloud: true,
                                reset: shouldReset,
                                onSaveToCloud: (String? url){
                                  tryOnly("Picker onSaveToCloud", (){
                                    if(mounted && url != null) setState(() => displayScreenImage = url);
                                  });
                                },
                                onError: (err){
                                  debugPrint("Picker Error: $err");
                                },
                              ),
                            ],
                          )
                              :
                          (
                              presentStep == CreateChannelSteps.step4?
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  spacer.height,
                                  Translate(
                                    text: "Your contents on this channel needs age restrictions. Kindly provide the age range.",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                      color: prudColorTheme.textB,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    align: TextAlign.center,
                                  ),
                                  spacer.height,

                                ],
                              )
                                  :
                              (
                                  presentStep == CreateChannelSteps.step5?
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      spacer.height,
                                    ],
                                  )
                                      :
                                  (
                                      presentStep == CreateChannelSteps.step6?
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          spacer.height,
                                        ],
                                      )
                                          :
                                      (
                                          presentStep == CreateChannelSteps.step7?
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              spacer.height,
                                            ],
                                          )
                                              :
                                          (
                                              presentStep == CreateChannelSteps.success?
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  spacer.height,
                                                ],
                                              )
                                                  :
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  spacer.height,
                                                ],
                                              )
                                          )
                                      )
                                  )
                              )
                          )
                      )
                  )
              ),
            )
          )
        ],
      ),
    );
  }
}