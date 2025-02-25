import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:prudapp/string_api.dart';
import 'package:textfield_tags/textfield_tags.dart';
    
class VideoTarget extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoTarget({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoTargetState createState() => VideoTargetState();
}

class VideoTargetState extends State<VideoTarget> {
  final tagCtrl = StringTagController();
  final tagCtrl1 = StringTagController();
  Map<String, dynamic>? result;
  List<String> forbiddenTags = ["sex", "pussy", "violence", "viral", "shorts", "youtube"];
  List<String> targets = ["General", "Adult", "Youth", "Teenage", "Kids", ];
  String target = prudStudioNotifier.newVideo.targetAudience?? "General";
  List<String>? videoTags = prudStudioNotifier.newVideo.tags;
  List<String>? thrillerTags = prudStudioNotifier.newVideo.thriller?.tags;

  @override
  void initState() {
    if(mounted) {
      setState(() { 
        videoTags??= prudStudioNotifier.newVideo.title?.split(" ");
        thrillerTags??= videoTags;
        result = {"target": target, "videoTags": videoTags, "thrillerTags": thrillerTags};
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    tagCtrl.dispose();
    tagCtrl1.dispose();
    super.dispose();
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
          text: "Target & Tags",
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
              text: "Which audience is this content appropriate for?",
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
              title: "Target",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilder(
                    child: FormBuilderChoiceChip(
                      decoration: getDeco("Targetted Audience"),
                      backgroundColor: prudColorTheme.bgA,
                      disabledColor: prudColorTheme.bgD,
                      spacing: spacer.width.width!,
                      shape: prudWidgetStyle.choiceChipShape,
                      selectedColor: prudColorTheme.primary,
                      onChanged: (String? selected){
                        tryOnly("TargetSelector", (){
                          if(mounted && selected != null){
                            setState(() { 
                              target = selected;
                              result?["target"] = target;
                            });
                          }
                        });
                      },
                      name: "target",
                      initialValue: target,
                      options: targets.map((String ele) {
                        return FormBuilderChipOption(
                          value: ele,
                          child: Translate(
                            text: ele,
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                color: ele == target?
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
            Translate(
              text: "Add tags to this video so viewers can easily locatethis content during searches. Each tag can be separated by a space",
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
              title: "Video Tags",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  TextFieldTags<String>(
                    textfieldTagsController: tagCtrl,
                    initialTags: videoTags,
                    textSeparators: const [' '],
                    validator: (String tag){
                      if (tag.toLowerCase().containsAny(forbiddenTags)){
                        return 'Sex not allowed';
                      }
                      return null;
                    },
                    inputFieldBuilder: (context, inputFieldValues){
                      return FormBuilderTextField(
                        controller: inputFieldValues.textEditingController,
                        focusNode: inputFieldValues.focusNode,
                        name: 'Video Tags',
                        minLines: 8,
                        maxLines: 12,
                        enableInteractiveSelection: true,
                        onTap: (){
                          inputFieldValues.focusNode.requestFocus();
                        },
                        style: tabData.npStyle,
                        keyboardType: TextInputType.text,
                        decoration: getDeco(
                          "Tags",
                          onlyBottomBorder: true,
                          borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? valueDesc){
                          if(mounted && valueDesc != null) {
                            setState(() {
                              videoTags = valueDesc.trim().split(" ");
                              result?["videoTags"] = videoTags;
                            });
                          }
                        },
                      );
                    }
                  ),
                  spacer.height,
                ],
              )
            ),
            spacer.height,
            Translate(
              text: "Add tags to the thriller so viewers can easily locate the video during searches. Each tag can be separated by a space",
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
              title: "Thriller Tags",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  TextFieldTags<String>(
                    textfieldTagsController: tagCtrl1,
                    initialTags: thrillerTags,
                    textSeparators: const [' '],
                    validator: (String tag){
                      if (tag.toLowerCase().containsAny(forbiddenTags)){
                        return 'Sex not allowed';
                      }
                      return null;
                    },
                    inputFieldBuilder: (context, inputFieldValues){
                      return FormBuilderTextField(
                        controller: inputFieldValues.textEditingController,
                        focusNode: inputFieldValues.focusNode,
                        name: 'Thriller Tags',
                        minLines: 8,
                        maxLines: 12,
                        enableInteractiveSelection: true,
                        onTap: (){
                          inputFieldValues.focusNode.requestFocus();
                        },
                        style: tabData.npStyle,
                        keyboardType: TextInputType.text,
                        decoration: getDeco(
                          "Tags",
                          onlyBottomBorder: true,
                          borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? valueDesc){
                          if(mounted && valueDesc != null) {
                            setState(() {
                              thrillerTags = valueDesc.trim().split(" ");
                              result?["thrillerTags"] = thrillerTags;
                            });
                          }
                        },
                      );
                    }
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