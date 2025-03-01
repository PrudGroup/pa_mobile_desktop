import 'package:country_state_city/models/country.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../components/country_picker.dart';
import '../../../../components/prud_container.dart';
import '../../../../components/prud_image_picker.dart';
import '../../../../components/prud_panel.dart';
import '../../../../components/translate_text.dart';
import '../../../../models/prud_vid.dart';
import '../../../../singletons/currency_math.dart';
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
  step8,
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
  CreateChannelSteps presentStep = prudStudioNotifier.newChannelData.step;
  bool loading = false;
  Studio? studio = prudStudioNotifier.studio;
  bool shouldReset = false;
  TextEditingController txtCtrl = TextEditingController();
  TextEditingController txtCtrl1 = TextEditingController();
  TextEditingController txtCtrl2 = TextEditingController();
  final GlobalKey _key1 = GlobalKey();
  final GlobalKey _key2 = GlobalKey();
  final GlobalKey _key3 = GlobalKey();
  final GlobalKey _key4 = GlobalKey();
  FocusNode fNode = FocusNode();
  final int maxWords = 100;
  final int minWords = 30;
  int presentWords = tabData.countWordsInString(prudStudioNotifier.newChannelData.description?? "");


  void clearInput(){
    prudStudioNotifier.newChannelData = NewChannelData(
      ageTargets: SfRangeValues(18, 30),
      category: channelCategories[0],
      selectedCurrency: tabData.getCurrency("EUR"),
    );
    prudStudioNotifier.saveNewChannelData();
    setState(() {
      shouldReset = true;
      loading = false;
      shouldReset = false;
    });
    txtCtrl.text = "0";
    txtCtrl1.text = "0";
    txtCtrl2.text = "";
  }

  @override
  void initState() {
    super.initState();
    if(mounted){
      txtCtrl.text = "${prudStudioNotifier.newChannelData.memberCost}";
      txtCtrl1.text = "${prudStudioNotifier.newChannelData.streamServiceCost}";
      txtCtrl2.text = "${prudStudioNotifier.newChannelData.description}";
    }
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    txtCtrl1.dispose();
    txtCtrl2.dispose();
    fNode.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  void getCurrency(){
    showCurrencyPicker(
      context: context,
      favorite: ["NGN", "GBP", "USD", "EUR", "CAD"],
      onSelect: (Currency cur){
        try{
          if(mounted) {
            setState(() {
              prudStudioNotifier.newChannelData.selectedCurrency = cur;
            });
          }
        }catch(ex){
          debugPrint("getCurrency Error: $ex");
        }
      }
    );
  }

  Future<bool> createChannel() async {
    return await tryAsync("createChannel", () async {
      bool created = false;
      if(mounted) setState(() => loading = true);
      prudStudioNotifier.newChannelData.studioId = studio!.id;
      VidChannel newChannel = prudStudioNotifier.newChannelData.toVidChannel()!;
      VidChannel? result = await prudStudioNotifier.createVidChannel(newChannel);
      created = result != null;
      if(created) {
        if(result.id != null) await messenger.subscribeToTopic(result.id!);
        prudStudioNotifier.updateMyChannel(result);
      }
      if(mounted) setState(() => loading = false);
      return created;
    }, error: (){
      if(mounted) setState(() => loading = false);
      return false;
    });
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

  void createAnother() {
    clearInput();
    if(mounted) setState(() => presentStep = CreateChannelSteps.step1);
  }

  void addVideo() {
    clearInput();
    widget.goToTab(2);
  }

  Future<bool> validateStep(CreateChannelSteps step) async {
    switch(presentStep){
      case CreateChannelSteps.step1: return prudStudioNotifier.newChannelData.category!.isNotEmpty && prudStudioNotifier.newChannelData.selectedCurrency != null;
      case CreateChannelSteps.step2: {
        if(mounted) setState(() => loading = true);
        if(prudStudioNotifier.newChannelData.memberCost > 0){
          if(prudStudioNotifier.newChannelData.selectedCurrency!.code.toUpperCase() == "EUR"){
            prudStudioNotifier.newChannelData.membershipCostInEuro = prudStudioNotifier.newChannelData.memberCost;
            if(mounted) setState(() => loading = false);
            return prudStudioNotifier.newChannelData.memberCost >= 1.0 && prudStudioNotifier.newChannelData.memberCost <= 5.0;
          }else{
            double amount = await currencyMath.convert(
                amount: prudStudioNotifier.newChannelData.memberCost,
                quoteCode: "EUR",
                baseCode: prudStudioNotifier.newChannelData.selectedCurrency!.code
            );
            prudStudioNotifier.newChannelData.membershipCostInEuro = currencyMath.roundDouble(amount, 2);
            if(mounted) setState(() => loading = false);
            return amount >= 1.0 && amount <= 5.0;
          }
        }else{
          if(mounted) setState(() => loading = false);
          return false;
        }
      }
      case CreateChannelSteps.step3: return prudStudioNotifier.newChannelData.countryCode != null && prudStudioNotifier.newChannelData.channelName != null;
      case CreateChannelSteps.step4: {
        if(mounted) setState(() => loading = true);
        if(prudStudioNotifier.newChannelData.streamServiceCost > 0){
          if(prudStudioNotifier.newChannelData.selectedCurrency!.code.toUpperCase() == "EUR"){
            prudStudioNotifier.newChannelData.streamServiceCostInEuro = prudStudioNotifier.newChannelData.streamServiceCost;
            if(mounted) setState(() => loading = false);
            return prudStudioNotifier.newChannelData.streamServiceCost >= 4.0 && prudStudioNotifier.newChannelData.streamServiceCost <= 10.0;
          }else{
            double amount = await currencyMath.convert(
                amount: prudStudioNotifier.newChannelData.streamServiceCost,
                quoteCode: "EUR",
                baseCode: prudStudioNotifier.newChannelData.selectedCurrency!.code
            );
            prudStudioNotifier.newChannelData.streamServiceCostInEuro = currencyMath.roundDouble(amount, 2);
            if(mounted) setState(() => loading = false);
            return amount >= 4.0 && amount <= 10.0;
          }
        }else{
          if(mounted) setState(() => loading = false);
          return false;
        }
      }
      case CreateChannelSteps.step5: return prudStudioNotifier.newChannelData.sharePerView >= 40.0 && prudStudioNotifier.newChannelData.sharePerMember >= 40.0;
      case CreateChannelSteps.step6: return prudStudioNotifier.newChannelData.logoUrl != null && prudStudioNotifier.newChannelData.displayScreenImage != null;
      case CreateChannelSteps.step7: return prudStudioNotifier.newChannelData.ageTargets!.start > 1.0 && prudStudioNotifier.newChannelData.ageTargets!.end <= 50;
      case CreateChannelSteps.step8: {
        if(prudStudioNotifier.newChannelData.description != null){
          return presentWords >= minWords && presentWords <= maxWords;
        }else{
          return false;
        }
      }
      default: return false;
    }
  }

  Future<void> next() async {
    switch(presentStep){
      case CreateChannelSteps.policy: if(mounted) setState(() => presentStep = CreateChannelSteps.step1);
      case CreateChannelSteps.step1: {
        bool validated = await validateStep(CreateChannelSteps.step1);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step2);
      }
      case CreateChannelSteps.step2: {
        bool validated = await validateStep(CreateChannelSteps.step2);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step3);
      }
      case CreateChannelSteps.step3: {
        bool validated = await validateStep(CreateChannelSteps.step3);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step4);
      }
      case CreateChannelSteps.step4: {
        bool validated = await validateStep(CreateChannelSteps.step4);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step5);
      }
      case CreateChannelSteps.step5: {
        bool validated = await validateStep(CreateChannelSteps.step5);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step6);
      }
      case CreateChannelSteps.step6: {
        bool validated = await validateStep(CreateChannelSteps.step6);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step7);
      }
      case CreateChannelSteps.step7: {
        bool validated = await validateStep(CreateChannelSteps.step7);
        if(mounted && validated) setState(() => presentStep = CreateChannelSteps.step8);
      }
      case CreateChannelSteps.step8: {
        bool validated = await validateStep(CreateChannelSteps.step8);
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
        clearInput();
        widget.goToTab(2);
      }
      default: if(mounted) setState(() => presentStep = CreateChannelSteps.step7);
    }
    if(mounted) setState(() => prudStudioNotifier.newChannelData.step = presentStep);
    if(presentStep != CreateChannelSteps.success) prudStudioNotifier.saveNewChannelData();
    FocusManager.instance.primaryFocus?.unfocus();
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
      case CreateChannelSteps.step8: if(mounted) setState(() => presentStep = CreateChannelSteps.step7);
      case CreateChannelSteps.failed: if(mounted) setState(() => presentStep = CreateChannelSteps.step8);
      default: {}
    }
    if(mounted) setState(() => prudStudioNotifier.newChannelData.step = presentStep);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Size screen = MediaQuery.of(context).size;
    return SizedBox(
      // height: screen.height,
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
                  size: 15,
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
                      color: prudColorTheme.textA,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
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
                        text: "Select a category for your channel. This will mean that every video you upload "
                            "to this channel must be of this category type. If you upload a video with contents "
                            "of another type, your channel will be suspended for a month. So decide what niche your "
                            "channel will be.",
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          color: prudColorTheme.textA,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
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
                                child: FormBuilderChoiceChips(
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
                                          prudStudioNotifier.newChannelData.category = selected;
                                        });
                                      }
                                    });
                                  },
                                  name: "category",
                                  initialValue: prudStudioNotifier.newChannelData.category,
                                  options: channelCategories.map((String ele) {
                                    return FormBuilderChipOption(
                                      value: ele,
                                      child: Translate(
                                        text: ele,
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                            color: ele == prudStudioNotifier.newChannelData.category?
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
                                            if(prudStudioNotifier.newChannelData.selectedCurrency != null) Text(
                                              "${prudStudioNotifier.newChannelData.selectedCurrency!.flag}",
                                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                                  fontSize: 18.0
                                              ),
                                            ),
                                            spacer.width,
                                            Translate(
                                              text: prudStudioNotifier.newChannelData.selectedCurrency != null? prudStudioNotifier.newChannelData.selectedCurrency!.name : "Select Currency",
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
                      xLargeSpacer.height,
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
                            text: "How much would you charge for monthly membership subscription on "
                                "this channel? You must make sure that the amount is not less than 1(EURO) and not greater "
                                "than 5(Euro) in the currency of your channel.",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              color: prudColorTheme.textA,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            align: TextAlign.center,
                          ),
                          spacer.height,
                          PrudContainer(
                              hasTitle: true,
                              hasPadding: true,
                              title: "Membership Cost(${prudStudioNotifier.newChannelData.selectedCurrency!.code})",
                              titleBorderColor: prudColorTheme.bgC,
                              titleAlignment: MainAxisAlignment.end,
                              child: Column(
                                children: [
                                  mediumSpacer.height,
                                  FormBuilder(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    child: FormBuilderTextField(
                                      controller: txtCtrl,
                                      key: _key1,
                                      autofocus: true,
                                      name: 'membershipCost',
                                      style: tabData.npStyle,
                                      keyboardType: TextInputType.number,
                                      decoration: getDeco(
                                          "How Much",
                                          onlyBottomBorder: true,
                                          borderColor: prudColorTheme.lineC
                                      ),
                                      onChanged: (String? value){
                                        tryOnly("onChange", (){
                                          if(mounted && value != null && value.isNotEmpty) setState(() => prudStudioNotifier.newChannelData.memberCost = currencyMath.roundDouble(double.parse(value.trim()), 2));
                                        });
                                      },
                                      valueTransformer: (text) => num.tryParse(text!),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                      ]),
                                    ),
                                  ),
                                  spacer.height,
                                ],
                              )
                          ),
                          xLargeSpacer.height,
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
                                text: "What name would you like to call your channel. Make it exciting yet represents your brand. "
                                    "Please note that name must not contain prudapp, prudVid, prudLearn, prudStreams, prudStudio, prudMusic, prudMovies, prudComedy",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.textA,
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
                                      initialValue: prudStudioNotifier.newChannelData.channelName?? '',
                                      name: 'channelName',
                                      key: _key4,
                                      autofocus: true,
                                      style: tabData.npStyle,
                                      keyboardType: TextInputType.text,
                                      decoration: getDeco(
                                          "Channel Name",
                                          onlyBottomBorder: true,
                                          borderColor: prudColorTheme.lineC
                                      ),
                                      onChanged: (String? value){
                                        if(mounted && value != null) setState(() => prudStudioNotifier.newChannelData.channelName = value.trim());
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
                                  color: prudColorTheme.textA,
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
                                        selected: prudStudioNotifier.newChannelData.countryCode?? "NG",
                                        onChange: (Country ctry) async {
                                          if(mounted) setState(() => prudStudioNotifier.newChannelData.countryCode = ctry.isoCode);
                                        },
                                      ),
                                      spacer.height,
                                    ],
                                  )
                              ),
                              xLargeSpacer.height,
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
                                    text: "How much would you charge for monthly streaming subscription on "
                                        "this channel? You must make sure that the amount is not less than 4(EURO) and not greater "
                                        "than 10(Euro) in the currency of your channel.",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                      color: prudColorTheme.textA,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    align: TextAlign.center,
                                  ),
                                  spacer.height,
                                  PrudContainer(
                                      hasTitle: true,
                                      hasPadding: true,
                                      title: "Streaming Cost(${prudStudioNotifier.newChannelData.selectedCurrency!.code})",
                                      titleBorderColor: prudColorTheme.bgC,
                                      titleAlignment: MainAxisAlignment.end,
                                      child: Column(
                                        children: [
                                          mediumSpacer.height,
                                          FormBuilder(
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            child: FormBuilderTextField(
                                              onChanged: (String? value){
                                                debugPrint("before: $value ");
                                                tryOnly("onChange", (){
                                                  if(mounted && value != null && value.isNotEmpty) setState(() => prudStudioNotifier.newChannelData.streamServiceCost = currencyMath.roundDouble(double.parse(value.trim()), 2));
                                                });
                                                debugPrint("streamed: $value | ${prudStudioNotifier.newChannelData.streamServiceCost}");
                                              },
                                              autofocus: true,
                                              name: 'streamServiceCost',
                                              controller: txtCtrl1,
                                              key: _key2,
                                              style: tabData.npStyle,
                                              keyboardType: TextInputType.number,
                                              decoration: getDeco(
                                                  "How Much",
                                                  onlyBottomBorder: true,
                                                  borderColor: prudColorTheme.lineC
                                              ),
                                              valueTransformer: (text) => num.tryParse(text!),
                                              validator: FormBuilderValidators.compose([
                                                FormBuilderValidators.required(),
                                              ]),
                                            ),
                                          ),
                                          spacer.height,
                                        ],
                                      )
                                  ),
                                  xLargeSpacer.height,
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
                                      Translate(
                                        text: "Your channel can contract as many content creators as you desire. "
                                            "These content creators will be responsible for creating contents for your "
                                            "channel. You are responsible for them. Many content creators may contact you for "
                                            "an opportunity, you will need to vet their skills before adding them to your channel. "
                                            "This will also mean, they share from the funds generated by your channel. What percentage are "
                                            "of your channel fund are you willing to share per view with content creators. Must be from 40 and above.",
                                        style: prudWidgetStyle.tabTextStyle.copyWith(
                                          color: prudColorTheme.textA,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        align: TextAlign.center,
                                      ),
                                      spacer.height,
                                      PrudContainer(
                                        hasTitle: true,
                                        hasPadding: true,
                                        title: "Share Per View",
                                        titleBorderColor: prudColorTheme.bgC,
                                        titleAlignment: MainAxisAlignment.end,
                                        child: Column(
                                          children: [
                                            mediumSpacer.height,
                                            SfSlider(
                                              min: 40.0,
                                              max: 100.0,
                                              value: prudStudioNotifier.newChannelData.sharePerView,
                                              interval: 10,
                                              showTicks: true,
                                              showLabels: true,
                                              enableTooltip: true,
                                              minorTicksPerInterval: 1,
                                              onChanged: (dynamic value){
                                                setState(() {
                                                  prudStudioNotifier.newChannelData.sharePerView = value;
                                                });
                                              },
                                            ),
                                            spacer.height,
                                          ],
                                        )
                                      ),
                                      spacer.height,
                                      Translate(
                                        text: "Your content creators also share every fund your channel generates from "
                                            "monthly membership subscriptions. This means that all the creators you have on a channel "
                                            "will all share a particular percentage. All could share 40% of your total membership revenue each month. what are "
                                            "you willing to share?",
                                        style: prudWidgetStyle.tabTextStyle.copyWith(
                                          color: prudColorTheme.textA,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        align: TextAlign.center,
                                      ),
                                      spacer.height,
                                      PrudContainer(
                                        hasTitle: true,
                                        hasPadding: true,
                                        title: "Share Per Membership",
                                        titleBorderColor: prudColorTheme.bgC,
                                        titleAlignment: MainAxisAlignment.end,
                                        child: Column(
                                          children: [
                                            mediumSpacer.height,
                                            SfSlider(
                                              min: 40.0,
                                              max: 100.0,
                                              value: prudStudioNotifier.newChannelData.sharePerMember,
                                              interval: 10,
                                              showTicks: true,
                                              showLabels: true,
                                              enableTooltip: true,
                                              minorTicksPerInterval: 1,
                                              onChanged: (dynamic value){
                                                setState(() {
                                                  prudStudioNotifier.newChannelData.sharePerMember = value;
                                                });
                                              },
                                            ),
                                            spacer.height,
                                          ],
                                        )
                                      ),
                                      xLargeSpacer.height,
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
                                          Translate(
                                            text: "Upload your channel logo. The logo must represent your brand",
                                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                              color: prudColorTheme.textA,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            align: TextAlign.center,
                                          ),
                                          if(studio != null && prudStudioNotifier.newChannelData.channelName != null) PrudImagePicker(
                                            destination: "studio/${studio!.id}/images",
                                            existingUrl: prudStudioNotifier.newChannelData.logoUrl,
                                            saveToCloud: true,
                                            reset: shouldReset,
                                            onSaveToCloud: (String? url){
                                              tryOnly("Picker onSaveToCloud", (){
                                                debugPrint("PhotoUrl: $url");
                                                if(mounted && url != null) setState(() => prudStudioNotifier.newChannelData.logoUrl = url);
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
                                              color: prudColorTheme.textA,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            align: TextAlign.center,
                                          ),
                                          if(studio != null && prudStudioNotifier.newChannelData.channelName != null) PrudImagePicker(
                                            destination: "studio/${studio!.id}/images",
                                            saveToCloud: true,
                                            existingUrl: prudStudioNotifier.newChannelData.displayScreenImage,
                                            reset: shouldReset,
                                            onSaveToCloud: (String? url){
                                              tryOnly("Picker onSaveToCloud", (){
                                                if(mounted && url != null) setState(() => prudStudioNotifier.newChannelData.displayScreenImage = url);
                                              });
                                            },
                                            onError: (err){
                                              debugPrint("Picker Error: $err");
                                            },
                                          ),
                                          xLargeSpacer.height,
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
                                              Translate(
                                                text: "Your contents on this channel needs age restrictions. Kindly provide the age range.",
                                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                                  color: prudColorTheme.textA,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                align: TextAlign.center,
                                              ),
                                              spacer.height,
                                              PrudContainer(
                                                  hasTitle: true,
                                                  hasPadding: true,
                                                  title: "Age Targets",
                                                  titleBorderColor: prudColorTheme.bgC,
                                                  titleAlignment: MainAxisAlignment.end,
                                                  child: Column(
                                                    children: [
                                                      mediumSpacer.height,
                                                      SfRangeSlider(
                                                        min: 1,
                                                        max: 50,
                                                        values: prudStudioNotifier.newChannelData.ageTargets!,
                                                        interval: 5,
                                                        showTicks: true,
                                                        showLabels: true,
                                                        enableTooltip: true,
                                                        minorTicksPerInterval: 1,
                                                        onChanged: (SfRangeValues values){
                                                          if(mounted) setState(() => prudStudioNotifier.newChannelData.ageTargets = values);
                                                        },
                                                      ),
                                                      spacer.height,
                                                    ],
                                                  )
                                              ),
                                              xLargeSpacer.height,
                                            ],
                                          )
                                              :
                                          (
                                              presentStep == CreateChannelSteps.step8?
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  spacer.height,
                                                  Translate(
                                                    text: "In not less than 30 words and not more than 100 words, describe your channel and what"
                                                        " your content on this channel will focus on. This could be your selling point to viewers.",
                                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                                      color: prudColorTheme.textA,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                    align: TextAlign.center,
                                                  ),
                                                  spacer.height,
                                                  PrudContainer(
                                                    hasTitle: true,
                                                    hasPadding: true,
                                                    title: "Description",
                                                    titleBorderColor: prudColorTheme.bgC,
                                                    titleAlignment: MainAxisAlignment.end,
                                                    child: Column(
                                                      children: [
                                                        mediumSpacer.height,
                                                        Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text("$presentWords/$maxWords"),
                                                        ),
                                                        FormBuilder(
                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                          child: FormBuilderTextField(
                                                            controller: txtCtrl2,
                                                            key: _key3,
                                                            name: 'description',
                                                            minLines: 8,
                                                            maxLines: 12,
                                                            focusNode: fNode,
                                                            enableInteractiveSelection: true,
                                                            onTap: (){
                                                              fNode.requestFocus();
                                                            },
                                                            autofocus: true,
                                                            style: tabData.npStyle,
                                                            keyboardType: TextInputType.text,
                                                            decoration: getDeco(
                                                              "About Channel",
                                                              onlyBottomBorder: true,
                                                              borderColor: prudColorTheme.lineC
                                                            ),
                                                            onChanged: (String? valueDesc){
                                                              if(mounted && valueDesc != null) {
                                                                setState(() {
                                                                  prudStudioNotifier.newChannelData.description = valueDesc.trim();
                                                                  presentWords = tabData.countWordsInString(prudStudioNotifier.newChannelData.description!);
                                                                });
                                                              }
                                                            },
                                                            valueTransformer: (text) => num.tryParse(text!),
                                                            validator: FormBuilderValidators.compose([
                                                              FormBuilderValidators.required(),
                                                              FormBuilderValidators.minWordsCount(30),
                                                              FormBuilderValidators.maxWordsCount(100),
                                                            ]),
                                                          ),
                                                        ),
                                                        spacer.height,
                                                      ],
                                                    )
                                                  ),
                                                  xLargeSpacer.height,
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
                                                      Translate(
                                                        text: "You have successfully created a channel in your studio. What will "
                                                            "you like to do next.",
                                                        style: prudWidgetStyle.tabTextStyle.copyWith(
                                                          color: prudColorTheme.textA,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                        align: TextAlign.center,
                                                      ),
                                                      spacer.height,
                                                      Flex(
                                                          direction: Axis.horizontal,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            prudWidgetStyle.getShortButton(
                                                                onPressed: createAnother,
                                                                text: "Create Another Channel",
                                                                isPill: false,
                                                                makeLight: true
                                                            ),
                                                            prudWidgetStyle.getShortButton(
                                                              onPressed: addVideo,
                                                              text: "Add A Video",
                                                              isPill: false,
                                                            )
                                                          ]
                                                      ),
                                                      xLargeSpacer.height,
                                                    ],
                                                  )
                                                      :
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      spacer.height,
                                                      Translate(
                                                        text: "Oops! We are unable to create this channel. Kindly check your networks and try again.",
                                                        style: prudWidgetStyle.tabTextStyle.copyWith(
                                                          color: prudColorTheme.error,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                        align: TextAlign.center,
                                                      ),
                                                      xLargeSpacer.height,
                                                    ],
                                                  )
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