import 'dart:async';
import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:prudapp/models/country.dart' as mc;
import 'package:prudapp/models/user.dart';
import 'package:prudapp/pages/register/login.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';


class Register extends StatefulWidget {

  final bool isAnotherUser;

  const Register({super.key, this.isAnotherUser = false});

  @override
  RegisteredState createState() => RegisteredState();
}

class RegisteredState extends State<Register> {

  bool loading = false;
  User newUser = User();
  bool showPassword = false;
  RegisterState? presentState;
  List<String> states =  mc.nigeriaStates;
  double? secondStepCurveHeight;


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


  void showCountryDialog(){
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.pinkAccent),
        bottomSheetHeight: 500, // Optional. Country list modal height
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        //Optional. Styles the search field.
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        try{
          setState(() => newUser.countryOfResidence = country.name);
        }catch(ex){
          debugPrint("Country Picker Error: $ex");

        }

      },
    );
  }

  void _signIn() => iCloud.goto(context, const Login());

  @override
  void initState() {
    super.initState();
    iCloud.addListener(() {
      if(presentState != iCloud.registerState) {
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
    try{
      User? user;
      Future.delayed(Duration.zero, (){
        var storedUser = myStorage.getFromStore(key: 'user');
        user = storedUser == null? User() : User.fromJson(jsonDecode(storedUser));
        if(mounted) {
          setState(() {
          presentState = iCloud.registerState;
          secondStepCurveHeight = 0.3;
          newUser.email = user?.email?? "";
          newUser.fullName = user?.fullName?? "";
          newUser.countryOfResidence = user?.countryOfResidence?? "Nigeria";
          newUser.phoneNo = user?.phoneNo?? "";
          newUser.pin = '0';
        });
        }
      });
    }catch(ex){
      debugPrint("SetState Issues $ex");
    }
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

  Future<void> saveUserLocally() async{
    if(isLoggedIn) {
      messenger.getToken().then((String? token) async{
        if(token != null){
          newUser.deviceRegToken = token;
        }
        await messenger.subscribeToTopic(newUser.countryOfResidence?? 'Nigeria');
        await messenger.subscribeToTopic('all');
      }).catchError((ex){
        iCloud.showSnackBar(
          "$ex",
          context,
          title: 'Messenger',
          type: 3
        );
      });
      if(newUser.pin != null) {
        newUser.pin = tabData.encryptString(newUser.pin!);
        debugPrint("New Pin: ${newUser.pin}");
        myStorage.addToStore(key: "pin", value: newUser.pin);
      }
      newUser.pin = '0';
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
    double width = screen.width;
    return PopScope(
      onPopInvoked: (bool poped) => poped,
      child: const Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox()
      ),
    );
  }
}
