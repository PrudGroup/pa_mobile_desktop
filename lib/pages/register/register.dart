import 'dart:async';
import 'dart:convert';

import 'package:country_state_city/models/city.dart';
import 'package:country_state_city/models/country.dart' as mc;
import 'package:country_state_city/models/state.dart' as ms;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:prudapp/components/country_picker.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/state_picker.dart';
import 'package:prudapp/models/user.dart';
import 'package:prudapp/pages/register/login.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../components/translate.dart';
import '../../models/images.dart';
import '../../models/theme.dart';
import 'package:country_state_city/country_state_city.dart' as csc;


class Register extends StatefulWidget {

  final bool isAnotherUser;

  const Register({super.key, this.isAnotherUser = false});

  @override
  RegisteredState createState() => RegisteredState();
}

class RegisteredState extends State<Register> {
  ScrollController scrollCtrl = ScrollController();
  bool loading = false;
  User newUser = User();
  bool showPassword = false;
  RegisterState? presentState;
  List<ms.State> states =  [];
  List<City> cities =  [];
  List<String> towns = [];
  List<String> strCountries = [];
  List<mc.Country> countries = [];
  Color primary = prudColorTheme.primary;
  Color primaryShade = prudColorTheme.primary.withOpacity(0.5);
  bool signingIn = false;
  bool isRegistering = true;
  String errorMsg = "Network Issues!";
  final _formKey = GlobalKey<FormBuilderState>();
  final _formKey1 = GlobalKey<FormBuilderState>();
  PhoneNumber pNumber = PhoneNumber(isoCode: "NG", phoneNumber: '', dialCode: '+234');
  TextEditingController phoneTextController = TextEditingController();
  bool phoneVerified = false;
  String smsCode = "";
  int? smsSendToken;
  bool loadingStates = false;
  bool loadingCities = false;

  void validateStep1() {
    if (_formKey.currentState!.validate()) {
      iCloud.changeRegisterState(state: RegisterState.third);
      myStorage.addToStore(key: 'user', value: jsonEncode(newUser));
      iCloud.scrollTop(scrollCtrl);
    }
  }

  void showCityDialog(){}

  void showTownDialog(){}

  void _signIn() => iCloud.goto(context, const Login());

  @override
  void initState() {
    super.initState();
    try{
      User? user;
      Future.delayed(Duration.zero, () async {
        if(mounted) setState(() => loading = true);
        var storedUser = myStorage.getFromStore(key: 'user');
        user = storedUser == null? User() : User.fromJson(jsonDecode(storedUser));
        iCloud.getRegisterStateFromStore();
        List<mc.Country> dCountries = await csc.getAllCountries();
        if(mounted && dCountries.isNotEmpty) {
          for(mc.Country cty in dCountries){
            strCountries.add(cty.isoCode);
          }
          setState(() {
            loadingCities = true;
            loadingStates = true;
          });
          List<ms.State> dStates = await csc.getStatesOfCountry('NG');
          List<City> dCities = await csc.getCountryCities('NG');
          PhoneNumber? phe = await PhoneNumber.getRegionInfoFromPhoneNumber(user?.phoneNo?? '');
          debugPrint("phone: ${phe.dialCode}: ${phe.isoCode}: ${phe.phoneNumber}: ${phe.props}");
          setState(() {
              loadingCities = false;
              loadingStates = false;
              countries = dCountries ;
              presentState = iCloud.registerState;
              newUser.email = user?.email?? '';
              newUser.fullName = user?.fullName?? '';
              newUser.country = user?.country;
              newUser.phoneNo = user?.phoneNo?? '';
              newUser.password = user?.password?? '';
              newUser.state = user?.state;
              newUser.city = user?.city;
              newUser.town = user?.town;
              if(newUser.phoneNo != null) {
                pNumber = phe;
                // phoneTextController.text = newUser.phoneNo!;
              }
              states = dStates;
              cities = dCities;
          });
        }
        if(mounted) setState(() => loading = false);
      });
    }catch(ex){
      debugPrint("SetState Issues $ex");
    }
    iCloud.addListener(() {
      if(presentState != iCloud.registerState && mounted) {
        try{
          Future.delayed(Duration.zero, (){
            setState(() => presentState = iCloud.registerState);
          });
        }catch(ex){
          debugPrint("SetState Issues $ex");
        }
      }
      try{
      }catch(ex){
        debugPrint("SetState Issues $ex");
      }
    });
  }

  void register() async {
    try{
      if (_formKey1.currentState!.validate()) {
        setState(() => loading = true);

        setState(() => loading = false);
        iCloud.changeRegisterState(state: phoneVerified? RegisterState.success : RegisterState.third);
      }
      setState(() => loading = false);
    }catch(ex){
      debugPrint("Register Error: $ex");
      setState(() => loading = false);
      iCloud.showSnackBar("$ex", context, title: "Register", type: 3);
    }

  }

  void _goBack(){
    switch(presentState){
      case RegisterState.second: iCloud.changeRegisterState(state: RegisterState.first);
      case RegisterState.third: iCloud.changeRegisterState(state: RegisterState.second);
      case RegisterState.success: iCloud.changeRegisterState(state: RegisterState.third);
      case RegisterState.failed: iCloud.changeRegisterState(state: RegisterState.third);
      default: iCloud.changeRegisterState(state: RegisterState.first);
    }
  }

  Future<void> saveUserLocally() async{
    if(isLoggedIn) {
      messenger.getToken().then((String? token) async{
        if(token != null){
          newUser.deviceRegToken = token;
        }
        await messenger.subscribeToTopic(newUser.country?? 'Nigeria');
        await messenger.subscribeToTopic('all');
      }).catchError((ex){
        iCloud.showSnackBar(
          "$ex",
          context,
          title: 'Messenger',
          type: 3
        );
      });
      if(newUser.password != null) {
        newUser.password = tabData.encryptString(newUser.password!);
        debugPrint("New Password: ${newUser.password}");
        myStorage.addToStore(key: "password", value: newUser.password);
      }
      newUser.password = '';
      myStorage.addToStore(key: "user", value: jsonEncode(newUser));
    }
  }

  void _signUp(){
    setState(() => loading = true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return PopScope(
      onPopInvoked: (bool poped) => poped,
      child: Scaffold(
        backgroundColor: prudColorTheme.bgA,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Image(
              image: AssetImage(prudImages.bg),
              width: screen.width,
            ),
            Expanded(
              child: loading? const LoadingComponent(
                isShimmer: true,
                height: double.maxFinite,
                shimmerType: 3,
              )
                  :
              SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: presentState == RegisterState.first?
                Column(
                  children: [
                    spacer.height,
                    Translate(
                      text: "It's like the first time you are joining PrudApp. If this is your first time you can"
                          " click on the sign up. If you already joined then just click on sign-in",
                      align: TextAlign.center,
                      style: prudWidgetStyle.tabTextStyle.copyWith(
                        fontSize: 20.0,
                        color: prudColorTheme.textA,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    spacer.height,
                    spacer.height,
                    Flex(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      direction: Axis.horizontal,
                      children: <Widget>[
                        GFButton(
                          color: primary,
                          splashColor: primaryShade,
                          hoverColor: primaryShade,
                          shape: GFButtonShape.pills,
                          hoverElevation: 0.0,
                          elevation: 0.0,
                          onPressed: _signIn,
                          child: Center(
                            child: Translate(
                              text: "Sign In",
                              style: tabData.bStyle,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: GFButton(
                            onPressed: () => iCloud.changeRegisterState(state: RegisterState.second),
                            color: prudColorTheme.iconB,
                            splashColor: primaryShade,
                            hoverColor: primaryShade,
                            shape: GFButtonShape.pills,
                            elevation: 0.0,
                            hoverElevation: 0.0,
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            size: GFSize.LARGE,
                            type: GFButtonType.solid,
                            child: Center(
                              child: Translate(
                                text: "Sign Up",
                                style: tabData.bStyle,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                )
                    :
                (
                    presentState == RegisterState.second?
                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          spacer.height,
                          FormBuilderTextField(
                            initialValue: newUser.fullName,
                            name: 'fullName',
                            autofocus: true,
                            style: tabData.npStyle,
                            keyboardType: TextInputType.name,
                            decoration: getDeco("FullName"),
                            onChanged: (dynamic value){
                              setState(() {
                                newUser.fullName = value?.trim();
                              });
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
                            initialValue: newUser.email,
                            name: 'email',
                            style: tabData.npStyle,
                            keyboardType: TextInputType.emailAddress,
                            decoration: getDeco("Email"),
                            onChanged: (String? value){
                              setState(() {
                                newUser.email = value?.trim();
                              });
                            },
                            valueTransformer: (text) => num.tryParse(text!),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.email()
                            ]),
                          ),
                          spacer.height,
                          Translate(
                            text: "Create a password for your account. Must have at least one uppercase, lowercase, special character, and number. "
                                "All must be at least 8 character long.. You must keep it safe from any other person.",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 16,
                              color: prudColorTheme.textA,
                              fontWeight: FontWeight.w500
                            ),
                            align: TextAlign.center,
                          ),
                          FormBuilderTextField(
                            initialValue: newUser.password,
                            name: "password",
                            style: tabData.npStyle,
                            obscureText: showPassword==false? true : false,
                            maxLines: 1,
                            maxLength: 20,
                            keyboardType: TextInputType.text,
                            obscuringCharacter: '*',
                            decoration: getDeco("Password",
                              suffixIcon: showPassword==false?
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                color: Colors.black26,
                                onPressed: (){
                                  try{
                                    if(mounted) {
                                      setState(() {
                                        showPassword = true;
                                      });
                                    }
                                  } catch (ex){
                                    debugPrint("setState: SignUp: Pin: $ex");
                                  }
                                },
                              )
                                  :
                              IconButton(
                                icon: const Icon(Icons.visibility_off),
                                color: Colors.black26,
                                onPressed: (){
                                  try{
                                    if(mounted) {
                                      setState(() {
                                        showPassword = false;
                                      });
                                    }
                                  } catch (ex){
                                    debugPrint("setState: SignUp: Pin: $ex");
                                  }
                                },
                              ),
                            ),
                            onChanged: (String? value){
                              try{
                                setState(() {
                                  newUser.password = value?.trim();
                                });
                              }catch(ex){
                                debugPrint("Pin Pars Error: $ex");
                              }
                            },
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.match(
                                "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%&*])[A-Za-z0-9!@#\$%_&*]{8,20}\$",
                                errorText: "Invalid Password."
                              ),
                            ]),
                          ),
                          spacer.height,
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                                color: prudColorTheme.lineC,
                                borderRadius: const BorderRadius.all(Radius.circular(5.0))
                            ),
                            child: InternationalPhoneNumberInput(
                              autoValidateMode: AutovalidateMode.onUserInteraction,
                              // textFieldController: phoneTextController,
                              selectorConfig: const SelectorConfig(
                                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              ),
                              textStyle: prudWidgetStyle.typedTextStyle,
                              inputDecoration: prudWidgetStyle.inputDeco.copyWith(hintText: "Phone Number"),
                              initialValue: pNumber,
                              maxLength: 20,
                              onInputChanged: (PhoneNumber phoneNumber){
                                pNumber = phoneNumber;
                                newUser.phoneNo = pNumber.phoneNumber;
                              },
                            ),
                          ),
                          spacer.height,
                          Flex(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            direction: Axis.horizontal,
                            children: <Widget>[
                              GFButton(
                                color: primary,
                                splashColor: primaryShade,
                                hoverColor: primaryShade,
                                shape: GFButtonShape.pills,
                                hoverElevation: 0.0,
                                elevation: 0.0,
                                onPressed: _goBack,
                                child: Center(
                                  child: Translate(
                                    text: "Go Back",
                                    style: tabData.bStyle,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: GFButton(
                                  onPressed: validateStep1,
                                  color: newUser.password != "" && newUser.email != ""? prudColorTheme.iconB : primaryShade,
                                  splashColor: primaryShade,
                                  hoverColor: primaryShade,
                                  shape: GFButtonShape.pills,
                                  elevation: 0.0,
                                  hoverElevation: 0.0,
                                  padding: const EdgeInsets.only(left: 30, right: 30),
                                  size: GFSize.LARGE,
                                  type: GFButtonType.solid,
                                  child: Center(
                                    child: Translate(
                                      text: "Next",
                                      style: tabData.bStyle,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          xLargeSpacer.height
                        ],
                      ),
                    )
                        :
                    (
                        presentState == RegisterState.third?
                        FormBuilder(
                          key: _formKey1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              spacer.height,
                              CountryPicker(
                                countries: strCountries,
                                onChange: (mc.Country ctry) async {
                                  if(mounted) {
                                    setState(() {
                                      loadingCities = true;
                                      loadingStates = true;
                                    });
                                  }
                                  List<ms.State> dStates = await csc.getStatesOfCountry(ctry.isoCode);
                                  List<City> dCities = await csc.getCountryCities(ctry.isoCode);
                                  if(mounted){
                                    setState(() {
                                      loadingCities = false;
                                      loadingStates = false;
                                      newUser.country = ctry.name;
                                      states = dStates;
                                      cities = dCities;
                                    });
                                  }
                                },
                              ),
                              spacer.height,
                              if(states.isNotEmpty && !loadingStates) StatePicker(
                                states: states,
                                onChange: (ms.State st) async {
                                  List<City> dCities = await csc.getStateCities(st.countryCode, st.isoCode);
                                  if(mounted) {
                                    setState(() {
                                      newUser.state = st.name;
                                      cities = dCities;
                                    });
                                  }
                                  debugPrint("selected State: ${newUser.state}");
                                  debugPrint("selected city: ${cities[0].name}");
                                }
                              ),
                              spacer.height,
                              GFButton(
                                color: prudColorTheme.lineC,
                                splashColor: prudColorTheme.lineC.withOpacity(0.7),
                                hoverColor: prudTheme.disabledColor.withOpacity(0.7),
                                shape: GFButtonShape.pills,
                                hoverElevation: 0.0,
                                fullWidthButton: true,
                                elevation: 0.0,
                                size: GFSize.LARGE,
                                type: GFButtonType.outline,
                                child: Translate(
                                  text: "Select City: ${newUser.city}",
                                  style: tabData.bStyle.copyWith(color: Colors.black),
                                  align: TextAlign.left,
                                ),
                                onPressed: () => showCityDialog(),
                              ),
                              spacer.height,
                              GFButton(
                                color: prudColorTheme.lineC,
                                splashColor: prudColorTheme.lineC.withOpacity(0.7),
                                hoverColor: prudTheme.disabledColor.withOpacity(0.7),
                                shape: GFButtonShape.pills,
                                hoverElevation: 0.0,
                                fullWidthButton: true,
                                elevation: 0.0,
                                size: GFSize.LARGE,
                                type: GFButtonType.outline,
                                child: Translate(
                                  text: "Select Town: ${newUser.town}",
                                  style: tabData.bStyle.copyWith(color: Colors.black),
                                  align: TextAlign.left,
                                ),
                                onPressed: () => showTownDialog(),
                              ),
                              spacer.height,
                              Flex(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                direction: Axis.horizontal,
                                children: <Widget>[
                                  GFButton(
                                    color: primary,
                                    splashColor: primaryShade,
                                    hoverColor: primaryShade,
                                    shape: GFButtonShape.pills,
                                    hoverElevation: 0.0,
                                    elevation: 0.0,
                                    onPressed: _goBack,
                                    child: Center(
                                      child: Translate(
                                        text: "Previous",
                                        style: tabData.bStyle,
                                      ),
                                    ),
                                  ),
                                  loading? SpinKitFadingCircle(
                                    size: 35.0,
                                    color: primary,
                                  ) : Padding(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: GFButton(
                                      onPressed: register,
                                      color: newUser.country != "" && newUser.state != ""?
                                      prudColorTheme.iconB : primaryShade,
                                      splashColor: primaryShade,
                                      hoverColor: primaryShade,
                                      shape: GFButtonShape.pills,
                                      elevation: 0.0,
                                      hoverElevation: 0.0,
                                      padding: const EdgeInsets.only(left: 30, right: 30),
                                      size: GFSize.LARGE,
                                      type: GFButtonType.solid,
                                      child: Center(
                                        child: Translate(
                                          text: "Next",
                                          style: tabData.bStyle,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              xLargeSpacer.height
                            ],
                          ),
                        )
                            :
                        (
                            presentState == RegisterState.success?
                            Column(
                              children: [
                                spacer.height
                              ],
                            )
                                :
                            Column(
                              children: [
                                spacer.height
                              ],
                            )
                        )
                    )
                ),
              )
            )
          ],
        )
      ),
    );
  }
}
