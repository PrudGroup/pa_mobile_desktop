import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../components/translate_text.dart';
import '../../../models/theme.dart';
import '../../../singletons/tab_data.dart';

class NewBeneficiary extends StatefulWidget {
  final Function(int) goToTab;
  const NewBeneficiary({super.key, required this.goToTab});

  @override
  NewBeneficiaryState createState() => NewBeneficiaryState();
}

class NewBeneficiaryState extends State<NewBeneficiary> {
  Beneficiary? newBen = Beneficiary(
    currencyCode: "",
    countryCode: "",
    fullName: "",
    gender: "Female",
    phoneNo: "",
    email: "",
    avatar: "",
    photo: null,
    parseablePhoneNo: "",
  );
  Currency? selectedBenCurrency;
  Country? selectedBenCountry;
  String useFace = "avatar";
  String selectedAvatar = "";
  final ImagePicker picker = ImagePicker();
  bool picking = false;
  bool adding = false;
  String? msg;
  FocusNode focus = FocusNode();
  ScrollController scrollCtrl = ScrollController();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController phoneTextController = TextEditingController();

  void selectAvatar(String avatar){
    if(mounted){
      setState(() {
        selectedAvatar = avatar;
        newBen!.avatar = avatar;
      });
    }
  }


  void clear({bool nextExisting = false}){
    if(mounted){
      setState(() {
        newBen = Beneficiary(
          currencyCode: "",
          countryCode: "",
          fullName: "",
          gender: "Female",
          phoneNo: "",
          email: "",
          avatar: "",
          photo: null,
          parseablePhoneNo: ""
        );
        msg = null;
        selectedBenCurrency = null;
        selectedBenCountry = null;
        useFace = "avatar";
        selectedAvatar = "";
      });
      nameCtrl.text = "";
      emailCtrl.text = "";
      focus.requestFocus();
      phoneTextController.text = "";
      Alert(
        context: context,
        style: myStorage.alertStyle,
        type: AlertType.success,
        title: "Beneficiary",
        desc: "Beneficiary Added",
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            color: prudColorTheme.primary,
            radius: BorderRadius.zero,
            child: const Text(
              "Okay",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ).show();
      iCloud.scrollTop(scrollCtrl);
      if(nextExisting) widget.goToTab(1);
    }
  }

  Future<void> saveBeneficiary({bool nextExisting = false}) async {
    if(newBen!.photo != null || newBen!.avatar != ""){
      if(newBen!.countryCode.isNotEmpty && newBen!.currencyCode.isNotEmpty){
        if(newBen!.gender.isNotEmpty && newBen!.phoneNo.isNotEmpty){
          if(newBen!.email.isNotEmpty && newBen!.fullName.isNotEmpty){
            try{
              if(mounted) setState(() => adding = true);
              if(nextExisting){
                await beneficiaryNotifier.addBeneficiary(newBen!, isSelected: false);
                await beneficiaryNotifier.addBeneficiary(newBen!);
              }else{
                await beneficiaryNotifier.addBeneficiary(newBen!, isSelected: false);
              }
              clear(nextExisting: nextExisting);
            }catch(ex){
              if(mounted) setState(() => adding = false);
              debugPrint("NewBeneficiary_saveBeneficiary: $ex");
            }
          }else{if(mounted) setState(() => msg = "Email/Fullname Is Missing");}
        }else{if(mounted) setState(() => msg = "Gender/PhoneNo Is Missing");}
      }else{
        if(mounted) setState(() => msg = "Country/Currency Is Missing!");
      }
    }else{
      if(mounted) setState(() => msg = "Photo/Avatar Is Missing!");
    }
    if(mounted && msg != null) {
      setState(() => adding = false);
      iCloud.showSnackBar(
          msg!, context
      );
    }
  }

  Future<void> saveAndAdd() async {
    await saveBeneficiary();
  }

  Future<void> saveAndSeeExisting() async {
    await saveBeneficiary(nextExisting: true);
  }

  Future<void> pickImage() async {
    try{
      if(mounted) setState(() => picking = true);
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if(image != null && mounted) {
        Uint8List photo = await image.readAsBytes();
        setState(() {
          newBen!.photo = photo;
          picking = false;
        });
      }
    }catch(ex){
      if(mounted) setState(() => picking = false);
      debugPrint("Picker Error: $ex");
    }
  }

  void getCountry(){
    showCountryPicker(
      context: context,
      favorite: ["NG", "UK", "GN", "US"],
      onSelect: (Country country){
        try{
          if(mounted){
            setState(() {
              selectedBenCountry = country;
              if(selectedBenCountry != null) newBen!.countryCode = selectedBenCountry!.countryCode;
            });
          }
        }catch(ex){
          debugPrint("getCurrency Error: $ex");
        }
      }
    );
  }

  void getCurrency(){
    showCurrencyPicker(
      context: context,
      favorite: ["NGN", "GBP", "USD", "EUR", "CAD"],
      onSelect: (Currency cur){
        try{
          if(mounted) {
            setState(() {
              selectedBenCurrency = cur;
              if(selectedBenCurrency != null) newBen!.currencyCode = selectedBenCurrency!.code;
            });
          }
        }catch(ex){
          debugPrint("getCurrency Error: $ex");
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          spacer.height,
          Translate(
            text: "You can decide to select from your existing beneficiaries or add new ones.",
            align: TextAlign.center,
            style: prudWidgetStyle.tabTextStyle.copyWith(
              color: prudColorTheme.textB,
              fontWeight: FontWeight.w500,
            ),
          ),
          spacer.height,
          PrudPanel(
            title: "Beneficiary Personal Info",
            titleColor: prudColorTheme.textB,
            bgColor: prudColorTheme.bgC,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 15),
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'fullName',
                    controller: nameCtrl,
                    autofocus: true,
                    focusNode: focus,
                    style: tabData.npStyle,
                    keyboardType: TextInputType.name,
                    decoration: getDeco("FullName"),
                    onChanged: (dynamic value){
                      if(mounted && value != null) {
                        setState(() {
                          newBen?.fullName = value?.trim();
                        });
                      }
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(80)
                    ]),
                  ),
                  spacer.height,
                  FormBuilderTextField(
                    name: 'email',
                    controller: emailCtrl,
                    style: tabData.npStyle,
                    keyboardType: TextInputType.emailAddress,
                    decoration: getDeco("Email"),
                    onChanged: (String? value){
                      if(mounted && value != null) {
                        setState(() {
                          newBen!.email = value.trim();
                        });
                      }
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email()
                    ]),
                  ),
                  spacer.height,
                  FormBuilder(
                    child: FormBuilderChoiceChip(
                      decoration: getDeco("Gender"),
                      backgroundColor: prudColorTheme.bgA,
                      disabledColor: prudColorTheme.bgD,
                      spacing: spacer.width.width!,
                      shape: prudWidgetStyle.choiceChipShape,
                      selectedColor: prudColorTheme.primary,
                      onChanged: (String? selected){
                        try{
                          if(mounted && selected != null){
                            setState(() {
                              newBen!.gender = selected;
                            });
                          }
                        }catch(ex){
                          debugPrint("Error: $ex");
                        }
                      },
                      name: "gender",
                      initialValue: newBen!.gender,
                      options: ["Female", "Male"].map((String ele) {
                        return FormBuilderChipOption(
                          value: ele,
                          child: Translate(
                            text: ele,
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                color: ele == newBen!.gender?
                                prudColorTheme.bgA : prudColorTheme.primary
                            ),
                            align: TextAlign.center,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                child: InternationalPhoneNumberInput(
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  textFieldController: phoneTextController,
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  textStyle: prudWidgetStyle.typedTextStyle,
                  inputDecoration: prudWidgetStyle.inputDeco.copyWith(hintText: "Phone Number"),
                  maxLength: 20,
                  onInputChanged: (PhoneNumber phoneNumber){
                    newBen?.phoneNo = phoneNumber.phoneNumber!;
                    newBen!.parseablePhoneNo = phoneNumber.parseNumber();
                  },
                ),
              ),
            ),
          ),
          spacer.height,
          PrudPanel(
            title: 'Location & Currency',
            bgColor: prudColorTheme.bgC,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: [
                  InkWell(
                    onTap: getCountry,
                    child: PrudPanel(
                      title: "Country",
                      titleColor: prudColorTheme.iconB,
                      bgColor: prudColorTheme.bgC,
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                            child: Row(
                              children: [
                                if(selectedBenCountry != null) Text(
                                  selectedBenCountry!.flagEmoji,
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontSize: 20.0
                                  ),
                                ),
                                spacer.width,
                                Translate(
                                  text: selectedBenCountry != null? selectedBenCountry!.displayName : "Select Country",
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
                  InkWell(
                    onTap: getCurrency,
                    child: PrudPanel(
                      title: "Currency",
                      titleColor: prudColorTheme.iconB,
                      bgColor: prudColorTheme.bgC,
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                            child: Row(
                              children: [
                                if(selectedBenCurrency != null) Text(
                                  "${selectedBenCurrency!.flag}",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontSize: 18.0
                                  ),
                                ),
                                spacer.width,
                                Translate(
                                  text: selectedBenCurrency != null? selectedBenCurrency!.name : "Select Currency",
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
                ],
              ),
            ),
          ),
          spacer.height,
          PrudPanel(
            title: "Beneficiary's Facial Identity",
            bgColor: prudColorTheme.bgC,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: [
                  FormBuilder(
                    child: FormBuilderChoiceChip(
                      decoration: getDeco("Face"),
                      backgroundColor: prudColorTheme.bgA,
                      disabledColor: prudColorTheme.bgD,
                      spacing: spacer.width.width!,
                      shape: prudWidgetStyle.choiceChipShape,
                      selectedColor: prudColorTheme.primary,
                      onChanged: (String? selected){
                        try{
                          if(mounted && selected != null){
                            setState(() {
                              useFace = selected.toLowerCase();
                              if(useFace == "avatar"){
                                newBen!.isAvatar = true;
                              }else{
                                newBen!.isAvatar = false;
                              }
                            });
                          }
                        }catch(ex){
                          debugPrint("Error: $ex");
                        }
                      },
                      name: "use_avatar",
                      initialValue: tabData.toTitleCase(useFace),
                      options: ["Avatar", "Photo"].map((String e) {
                        return FormBuilderChipOption(
                          value: e,
                          child: Translate(
                            text: e,
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                              color: e.toLowerCase() == useFace?
                              prudColorTheme.bgA : prudColorTheme.primary
                            ),
                            align: TextAlign.center,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  spacer.height,
                  if(useFace == "avatar") PrudContainer(
                    hasTitle: true,
                    title: "Select Avatar",
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: SizedBox(
                        height: 80,
                        child: ListView(
                          padding: const EdgeInsets.only(top: 10),
                          scrollDirection: Axis.horizontal,
                          children: [
                            InkWell(
                              onTap: () => selectAvatar(prudImages.avatar_1),
                              child: GFAvatar(
                                backgroundImage: AssetImage(prudImages.avatar_1),
                                size: selectedAvatar == prudImages.avatar_1? GFSize.LARGE : GFSize.MEDIUM,
                              ),
                            ),
                            spacer.width,
                            InkWell(
                              onTap: () => selectAvatar(prudImages.avatar_2),
                              child: GFAvatar(
                                backgroundImage: AssetImage(prudImages.avatar_2),
                                size: selectedAvatar == prudImages.avatar_2? GFSize.LARGE : GFSize.MEDIUM,
                              ),
                            ),
                            spacer.width,
                            InkWell(
                              onTap: () => selectAvatar(prudImages.avatar_3),
                              child: GFAvatar(
                                backgroundImage: AssetImage(prudImages.avatar_3),
                                size: selectedAvatar == prudImages.avatar_3? GFSize.LARGE : GFSize.MEDIUM,
                              ),
                            ),
                            spacer.width,
                            InkWell(
                              onTap: () => selectAvatar(prudImages.avatar_4),
                              child: GFAvatar(
                                backgroundImage: AssetImage(prudImages.avatar_4),
                                size: selectedAvatar == prudImages.avatar_4? GFSize.LARGE : GFSize.MEDIUM,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ),
                  if(useFace != "avatar") PrudContainer(
                    hasTitle: true,
                    title: "Select Photo",
                    child: Center(
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(newBen!.photo != null) GFAvatar(
                            backgroundImage: MemoryImage(newBen!.photo),
                            size: GFSize.LARGE,
                          ),
                          picking? LoadingComponent(
                            size: 40,
                            isShimmer: false,
                            spinnerColor: prudColorTheme.primary,
                          ) : prudWidgetStyle.getShortButton(
                            text: "Pick From Gallery",
                            onPressed: pickImage
                          )
                        ],
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
          spacer.height,
          if(newBen!.avatar != "" || newBen!.photo != null) FittedBox(
            fit: BoxFit.fitWidth,
            child: adding? const LoadingComponent(isShimmer: false, size: 40,) : Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                prudWidgetStyle.getShortButton(
                  onPressed: saveAndAdd,
                  text: "Save & Add More"
                ),
                spacer.width,
                prudWidgetStyle.getShortButton(
                  onPressed: saveAndSeeExisting,
                  text: "Save & See Existing"
                )
              ],
            ),
          ),
          spacer.height,
          if(msg != null) Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Translate(
              text: "$msg",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                color: prudColorTheme.error,
                fontSize: 16,
              ),
              align: TextAlign.center,
            ),
          ),
          xLargeSpacer.height,
        ],
      ),
    );
  }
}
