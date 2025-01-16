import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/shapes/custom_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../models/prud_vid.dart';
import '../singletons/tab_data.dart';

class CreateNewStudioComponent extends StatefulWidget {
  final Function(int) onTabChange;
  const CreateNewStudioComponent({super.key, required this.onTabChange});

  @override
  State<CreateNewStudioComponent> createState() => _CreateNewStudioComponentState();
}

class _CreateNewStudioComponentState extends State<CreateNewStudioComponent> {

  String? studioName;
  bool loading = false;
  TextEditingController txtCtrl = TextEditingController();
  bool showResult = false;
  Studio? addedStudio;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    super.dispose();
  }

  void _goToCreateChannel(){
    widget.onTabChange(1);
  }

  void _tryAgain(){
    if(mounted){
      setState(() {
        showResult = false;
        studioName = null;
        addedStudio = null;
        loading = false;
      });
    }
  }

  Future<void> _create() async {
    await tryAsync("_create", () async {
      if(studioName != null && myStorage.user != null && myStorage.user!.id != null){
        if(mounted) setState(() => loading = true);
        Studio newStudio = Studio(ownedBy: myStorage.user!.id!, studioName: studioName!);
        Studio? stud = await prudStudioNotifier.createStudio(newStudio);
        if(stud != null){
          if(mounted){
            setState(() {
              addedStudio = stud;
              showResult = true;
              loading = false;
            });
          }
        }else{
          if(mounted) {
            setState(() {
              showResult = true;
              loading = false;
            });
          }
        }
      }else{
        if(mounted) iCloud.showSnackBar("Name/User needed", context);
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: showResult? (
        addedStudio != null?
        CustomContainer(
          height: screen.height,
          width: screen.width,
          color: prudColorTheme.primary.withOpacity(0.7),
          frontColor: prudColorTheme.primary,
          arcHeight: 0.7,
          space: 0.04,
          equality: true,
          clock: false,
          bgImage: prudImages.intro3,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(30, 60, 30, 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                spacer.height,
                Translate(
                  text: "Yes! Your studio was created successfully. "
                      "Having Fun? Lets do the next thing on the list. "
                      "Add Channel(s)!",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.bgA,
                    fontWeight: FontWeight.w600,
                    fontSize: 15
                  ),
                  align: TextAlign.center,
                ),
                spacer.height,
                prudWidgetStyle.getLongButton(
                  onPressed: _goToCreateChannel,
                  makeLight: true,
                  text: "Create A Channel"
                ),
                spacer.height,
              ],
            ),
          )
        )
            :
        CustomContainer(
          height: screen.height,
          width: screen.width,
          color: prudColorTheme.primary.withOpacity(0.7),
          frontColor: prudColorTheme.primary,
          arcHeight: 0.7,
          space: 0.04,
          equality: true,
          clock: false,
          bgImage: prudImages.intro1,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(30, 60, 30, 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                spacer.height,
                Translate(
                  text: "Ops! Something went wrong! Perhaps, you need to check your network and try again.",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.bgA,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  align: TextAlign.center,
                ),
                spacer.height,
                prudWidgetStyle.getLongButton(
                  onPressed: _tryAgain,
                  text: "Try Again",
                  makeLight: true
                ),
                spacer.height,
              ],
            ),
          )
        )
      ) : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            spacer.height,
            Translate(
              text: "Creating a studio is the beginning of exciting experiences on Prudapp. "
                  " Be sure to read our policies that guards owning a Studio on Prudapp. Creating "
                  "one automatically binds you to that agreement. Let's start the excitements!",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                color: prudColorTheme.textB,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            Translate(
              text: "What name would you like to call your studio. With a studio, "
                  "you can have as many channels as needed depending on your target audience. So "
                  "what name! Think something exciting yet represents your brand.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                  color: prudColorTheme.primary,
                  fontSize: 13,
              ),
              align: TextAlign.center,
            ),
            FormBuilderTextField(
              controller: txtCtrl,
              name: 'studioName',
              autofocus: true,
              style: tabData.npStyle,
              keyboardType: TextInputType.text,
              decoration: getDeco(
                  "Studio Name",
                  onlyBottomBorder: true,
                  borderColor: prudColorTheme.lineC
              ),
              onChanged: (String? value){
                if(mounted && value != null) setState(() => studioName = value.trim());
              },
              valueTransformer: (text) => num.tryParse(text!),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.minLength(3),
                FormBuilderValidators.maxLength(30),
                FormBuilderValidators.required(),
              ]),
            ),
            spacer.height,
            loading? LoadingComponent(
              isShimmer: false,
              defaultSpinnerType: true,
              spinnerColor: prudColorTheme.primary,
              size: 30,
            )
                :
            prudWidgetStyle.getLongButton(
              onPressed: _create,
              text: "Create Studio",
              shape: 1
            ),
            largeSpacer.height,
          ],
        ),
      ),
    );
  }
}