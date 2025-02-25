import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class VideoScheduled extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoScheduled({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoScheduledState createState() => VideoScheduledState();
}

class VideoScheduledState extends State<VideoScheduled> {
  DateTime scheduledFor = prudStudioNotifier.newVideo.scheduledFor?? DateTime.now();
  Map<String, dynamic>? result;
  String? timezone;

  @override
  void initState(){
    if(mounted){
      setState((){
        timezone = prudStudioNotifier.newVideo.timezone?? scheduledFor.timeZoneName;
        result = {
          "scheduledFor": scheduledFor,
          "timezone": timezone,
        };
      });
    }
    super.initState();
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
          text: "Premier Details",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            spacer.height,
            Translate(
              text: "When do you want this content to be published. The content will be premiered until the publishing date and time.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 15,
                color: prudColorTheme.textB,
                fontWeight: FontWeight.w500
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Scheduled Date",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderDateTimePicker(
                    initialValue: scheduledFor,
                    name: 'scheduledFor',
                    autofocus: true,
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Scheduled For",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (DateTime? value){
                      if(mounted && value != null) {
                        setState(() { 
                          scheduledFor = value;
                          timezone = scheduledFor.timeZoneName;
                          result = {
                            "scheduledFor": scheduledFor,
                            "timezone": timezone
                          };
                        });
                      }
                    },
                    valueTransformer: (date) => date!.toIso8601String(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              )
            ),
            spacer.height,
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                prudWidgetStyle.getShortButton(
                  onPressed: widget.onPrevious, 
                  text: "Previous",
                  makeLight: true,
                  isPill: false
                ),
                prudWidgetStyle.getShortButton(
                  onPressed: () => widget.onCompleted(result), 
                  text: "Next",
                  makeLight: false,
                  isPill: false
                ),
              ],
            ),
            xLargeSpacer.height,
          ],
        ),
      ),
    );
  }
}