import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/home/home.dart';
import 'package:prudapp/pages/register/password_reset.dart';

import '../../models/user.dart';
import '../../singletons/i_cloud.dart';
import '../../singletons/shared_local_storage.dart';
import '../../singletons/tab_data.dart';

class Login extends StatefulWidget {


  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {

  bool loading = false;
  User existingUser = User();
  double? secondStepCurveHeight;
  String? email;
  String? password;
  bool showPassword = false;
  String? pin;
  bool sendingCode = false;

  String errorMsg = "Network Issues!";

  Future<void> _signIn() async{
    try{
      if(mounted) setState(() => loading = true);
      await messenger.getToken().then((String? token) async{
        if(token != null){
          if(email != null && password != null && pin != null){
            String url = "$prudApiUrl/affiliates/auth/login";
            Response res = await prudDio.get(url, queryParameters: {
              "email": email,
              "password": password,
              "device_token": token,
              "is_renew": true,
            });
            if (res.statusCode == 200) {
              debugPrint("Result: ${res.data}");
              if(res.data != null && res.data["user"] != null){
                User user = User.fromJson(res.data["user"]);
                user.password = password;
                user.deviceRegToken = token;
                iCloud.affAuthToken = 'PrudApp ${res.data["authToken"]}';
                prudDio.options.headers.addAll({
                  "Authorization": iCloud.affAuthToken,
                });
                if(user.id != null) {
                  await myStorage.addToStore(key: 'isNew', value: false);
                  await myStorage.addToStore(key: "user", value: jsonEncode(user));
                  await myStorage.addToStore(key: "referralCode", value: user.referralCode);
                  await myStorage.addToStore(key: "pin", value: pin);
                  myStorage.user = user;
                  if(mounted) {
                    iCloud.showSnackBar(
                      "Authenticated",  context,
                      title: "Authentication", type: 2
                    );
                  }
                }
                if(mounted) iCloud.goto(context, MyHomePage(title: "Prudapp",));
              }else{
                if(mounted) {
                  iCloud.showSnackBar(
                      "Unable To Retrieve User Details.",  context,
                      title: "Authentication", type: 1
                  );
                }
              }
            } else {
              if(mounted) {
                iCloud.showSnackBar(
                    "PrudService: Access Denied",  context,
                    title: "Authentication", type: 3
                );
              }
            }
          }else {
            if(mounted) {
              iCloud.showSnackBar(
                  "Pin/Email/Password needed.",  context,
                  title: "Authentication", type: 3
              );
            }
          }
          if(mounted) setState(() => loading = false);
        }else{
          if(mounted) {
            setState(() => loading = false);
            iCloud.showSnackBar(
              "Device token inaccessible!",
              context,
              title: 'Token',
              type: 3
            );
          }
        }
      }).catchError((ex){
        debugPrint("Firebase: $ex");
        if(mounted) {
          iCloud.showSnackBar("$ex", context, title: 'Messenger', type: 3);
          setState(() => loading = false);
        }
      });
    }catch(ex){
      debugPrint("Renew SignIn Error: $ex");
      if(mounted) {
        iCloud.showSnackBar(
          "PrudService Unauthorised",  context,
          title: "Authentication", type: 3
        );
      }
      if(mounted) setState(() => loading = false);
    }
  }

  Future<void> _forgotPassword() async{
    await tryAsync("_forgotPassword", () async {
      if(email != null){
        if(mounted) setState(() => sendingCode = true);
        String codeUrl = "$prudApiUrl/affiliates/send/code";
        String? code = await iCloud.sendCodeToEmail(codeUrl, email!);
        if(code != null && code.isNotEmpty){
          if(mounted) iCloud.goto(context, PasswordReset(email: email!, code: code));
        }else{
          if(mounted) iCloud.showSnackBar("Email Not Found.", context, title: 'Email Failed');
        }
        if(mounted) setState(() => sendingCode = false);
      }else{
        iCloud.showSnackBar("Email Missing.", context, title: 'Email Needed');
      }
    }, error: (){
      if(mounted) setState(() => sendingCode = false);
    });
  }

  @override
  void initState() {
    super.initState();
    try{
      Future.delayed(Duration.zero, () {
        String? storedUser = myStorage.getFromStore(key: "user");
        if(mounted && storedUser != null) {
          User user = User.fromJson(jsonDecode(storedUser));
          setState(() {
            existingUser.password = user.password;
          });
        }
      });
    }catch(ex){
      debugPrint("SetState Issues $ex");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double containerBorder = 15.0;
    double containerHeight = (screen.height * 0.65) - containerBorder;
    double sideSize = 40.0;
    BorderRadiusGeometry rad = BorderRadius.circular(sideSize);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool poped, dynamic res) async => poped,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              height: screen.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(prudImages.plainScreen,),
                  fit: BoxFit.cover,
                )
              ),
            ),
            Container(
              height: containerHeight,
              padding: EdgeInsets.all(containerBorder),
              margin: EdgeInsets.only(
                top: screen.height - (containerHeight + sideSize),
                left: sideSize,
                right: sideSize,
                bottom: sideSize,
              ),
              decoration: BoxDecoration(
                color: prudColorTheme.bgC.withValues(alpha: 0.3),
                borderRadius: rad,
              ),
              child: Container(
                height: containerHeight - (containerBorder * 2),
                decoration: BoxDecoration(
                  color: prudColorTheme.bgC,
                  borderRadius: rad,
                ),
                child: ClipRRect(
                  borderRadius: rad,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        spacer.height,
                        Image.asset(prudImages.logo, width: 170,),
                        Divider(
                          height: 1.0,
                          thickness: 2.0,
                          color: prudColorTheme.bgA,
                        ),
                        spacer.height,
                        FormBuilder(
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              Translate(
                                text: "A four digit pin is required for all transactions on Prudapp. Type what you "
                                    "can easily remember.",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: prudColorTheme.textB
                                ),
                                align: TextAlign.center,
                              ),
                              FormBuilderTextField(
                                initialValue: "",
                                name: 'pin',
                                style: tabData.npStyle,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                obscuringCharacter: "*",
                                decoration: getDeco("Transaction Pin"),
                                onChanged: (String? value){
                                  if(mounted) {
                                    setState(() {
                                      pin = value?.trim();
                                    });
                                  }
                                },
                                valueTransformer: (text) => num.tryParse(text!),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.integer(),
                                  FormBuilderValidators.minLength(4),
                                  FormBuilderValidators.maxLength(4)
                                ]),
                              ),
                              spacer.height,
                              FormBuilderTextField(
                                initialValue: "",
                                name: 'email',
                                style: tabData.npStyle,
                                keyboardType: TextInputType.emailAddress,
                                decoration: getDeco("Email"),
                                onChanged: (String? value){
                                  if(mounted) {
                                    setState(() {
                                      email = value?.trim();
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
                              FormBuilderTextField(
                                initialValue: "",
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
                                    if(mounted) {
                                      setState(() {
                                        password = value?.trim();
                                      });
                                    }
                                  }catch(ex){
                                    debugPrint("Password Error: $ex");
                                  }
                                },
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.match(
                                      RegExp("^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%&*])[A-Za-z0-9!@#\$%_&*]{8,20}\$"),
                                      errorText: "Invalid Password."
                                  ),
                                ]),
                              ),
                              spacer.height,
                              sendingCode? LoadingComponent(
                                isShimmer: false,
                                defaultSpinnerType: false,
                                spinnerColor: prudColorTheme.iconB,
                                size: 25,
                              ) : getTextButton(
                                  title: "Forgot Password",
                                  color: prudColorTheme.iconB,
                                  onPressed: _forgotPassword
                              ),
                              spacer.height,
                              spacer.height,
                              loading? SpinKitFadingCircle(
                                color: prudColorTheme.primary,
                                size: 30
                              ): prudWidgetStyle.getLongButton(
                                  onPressed: _signIn,
                                  text: "Sign In"
                              ),
                              spacer.height,
                              mediumSpacer.height,
                            ],
                          )
                        ),
                        xLargeSpacer.height,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
