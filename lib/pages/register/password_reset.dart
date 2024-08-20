import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pinput/pinput.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import '../../components/translate_text.dart';
import '../../models/images.dart';
import '../../models/theme.dart';
import '../../singletons/tab_data.dart';

class PasswordReset extends StatefulWidget {
  final String email;
  final String code;
  const PasswordReset({super.key, required this.email, required this.code});

  @override
  PasswordResetState createState() => PasswordResetState();
}

class PasswordResetState extends State<PasswordReset> {
  bool loading = false;
  bool verified = false;
  bool showPassword = false;
  String password = "";
  String confirm = "";
  bool confirmed = false;

  Future<void> changePassword() async {
    await tryAsync("changePassword", () async {
      if(mounted) setState(() => loading = true);
      bool res = await iCloud.resetPassword(widget.email, password);
      if(res == true){
        if(mounted) {
          iCloud.showSnackBar("Password Successfully Reset. Kindly Sign In.", context, title: "Password", type: 2);
          Navigator.pop(context);
        }
      }else{
        if(mounted) iCloud.showSnackBar("Unable To reset password", context);
      }
      if(mounted) setState(() => loading = false);
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
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
                color: prudColorTheme.bgC.withOpacity(0.3),
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
                                if(!verified) Column(
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
                                    Pinput(
                                      obscureText: true,
                                      autofocus: true,
                                      pinputAutovalidateMode: PinputAutovalidateMode.disabled,
                                      showCursor: true,
                                      onCompleted: (pin) {
                                        if(mounted) {
                                          setState(() {
                                            verified = pin == widget.code;
                                          });
                                        }
                                      },
                                    ),
                                    spacer.height,
                                  ],
                                ),
                                if(verified) Column(
                                  children: [
                                    Translate(
                                      text: "Type your new password. It must contain a Lowercase, Uppercase, Special Character, number, and must be at least 8 characters.",
                                      style: prudWidgetStyle.tabTextStyle.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: prudColorTheme.textB
                                      ),
                                      align: TextAlign.center,
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
                                          if(mounted && value != null) {
                                            setState(() {
                                              password = value.trim();
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
                                    FormBuilderTextField(
                                      initialValue: "",
                                      name: "confirm",
                                      style: tabData.npStyle,
                                      obscureText: showPassword==false? true : false,
                                      maxLines: 1,
                                      maxLength: 20,
                                      keyboardType: TextInputType.text,
                                      obscuringCharacter: '*',
                                      decoration: getDeco("Confirm",
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
                                          if(mounted && value != null) {
                                            setState(() {
                                              confirm = value.trim();
                                              confirmed = password == confirm;
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
                                        FormBuilderValidators.equal(password)
                                      ]),
                                    ),
                                    spacer.height,
                                    spacer.height,
                                    loading? SpinKitFadingCircle(
                                      color: prudColorTheme.primary,
                                      size: 30
                                    ): (
                                      confirmed?
                                      prudWidgetStyle.getLongButton(
                                          onPressed: changePassword,
                                          text: "Sign In"
                                      ) : const SizedBox()
                                    ),
                                  ],
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
