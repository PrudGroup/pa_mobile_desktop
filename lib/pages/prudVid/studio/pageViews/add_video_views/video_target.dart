import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:prudapp/string_api.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:prudapp/singletons/i_cloud.dart';
    
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
  late double _distanceToField;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }
  
  @override
  void initState() {
    if(mounted) {
      debugPrint("VideoTags: $videoTags");
      debugPrint("ThrillerTags: $thrillerTags");
      setState(() { 
        videoTags??= prudStudioNotifier.newVideo.title?.split(" ");
        thrillerTags??= videoTags;
        result = {"target": target, "videoTags": videoTags, "thrillerTags": thrillerTags};
        prudStudioNotifier.newVideo.targetAudience = target;
      });
      prudStudioNotifier.saveNewVideoData();
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
          onPressed: () => iCloud.goBack(context),
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
                    child: FormBuilderChoiceChips(
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
                              prudStudioNotifier.newVideo.targetAudience = target;
                            });
                            prudStudioNotifier.saveNewVideoData();
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
                        return 'Tag not allowed';
                      } else if (tagCtrl.getTags!.contains(tag)) {
                        return 'You\'ve already entered that';
                      }
                      return null;
                    },
                    inputFieldBuilder: (context, inputFieldValues){
                      return TextField(
                        controller: inputFieldValues.textEditingController,
                        focusNode: inputFieldValues.focusNode,
                        onTap: () => tagCtrl.getFocusNode?.requestFocus(),
                        style: tabData.npStyle,
                        maxLines: 15,
                        minLines: 6,
                        keyboardType: TextInputType.text,
                        decoration: getDeco("Tags", onlyBottomBorder: true, borderColor: prudColorTheme.lineC).copyWith(
                          helperText: 'Enter Tag...',
                          helperStyle: TextStyle(color: prudColorTheme.textD,),
                          hintText: inputFieldValues.tags.isNotEmpty? '' : "Enter tag...",
                          errorText: inputFieldValues.error,
                          prefixIconConstraints: BoxConstraints(maxWidth: _distanceToField * 0.8),
                          prefixIcon: inputFieldValues.tags.isNotEmpty? SingleChildScrollView(
                            controller: inputFieldValues.tagScrollController,
                            scrollDirection: Axis.vertical,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                              child: Wrap(
                                runSpacing: 4.0,
                                spacing: 4.0,
                                children: inputFieldValues.tags.map((String tag) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: prudColorTheme.lineC,
                                    ),
                                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          child: Text('#$tag', style: TextStyle(color: prudColorTheme.textB),),
                                          onTap: () {debugPrint("selected Tag: #$tag");},
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: Icon(Icons.cancel, size: 15.0, color: prudColorTheme.buttonA,),
                                          onTap: () => inputFieldValues.onTagRemoved(tag),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                              ),
                            ),
                          ) : null,
                        ),
                        onChanged: (String? valueDesc){
                          if(mounted && valueDesc != null) {
                            inputFieldValues.onTagChanged(valueDesc);
                            setState(() {
                              videoTags = inputFieldValues.tags;
                              result?["videoTags"] = videoTags;
                              prudStudioNotifier.newVideo.tags = videoTags;
                            });
                            prudStudioNotifier.saveNewVideoData();
                          }
                        },
                        onSubmitted: inputFieldValues.onTagSubmitted,
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
                        return 'tag not allowed';
                      } else if (tagCtrl1.getTags!.contains(tag)) {
                        return 'You\'ve already entered that';
                      }
                      return null;
                    },
                    inputFieldBuilder: (context, inputFieldValues){
                      return TextField(
                        controller: inputFieldValues.textEditingController,
                        focusNode: inputFieldValues.focusNode,
                        onTap: () => tagCtrl1.getFocusNode?.requestFocus(),
                        style: tabData.npStyle,
                        minLines: 6,
                        maxLines: 10,
                        keyboardType: TextInputType.text,
                        decoration: getDeco("Thriller Tags", onlyBottomBorder: true, borderColor: prudColorTheme.lineC).copyWith(
                          helperText: 'Enter Thriller...',
                          helperStyle: TextStyle(color: prudColorTheme.textD,),
                          hintText: inputFieldValues.tags.isNotEmpty? '' : "Enter tag...",
                          errorText: inputFieldValues.error,
                          prefixIconConstraints: BoxConstraints(maxWidth: _distanceToField * 0.8),
                          prefixIcon: inputFieldValues.tags.isNotEmpty? SingleChildScrollView(
                            controller: inputFieldValues.tagScrollController,
                            scrollDirection: Axis.vertical,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                              child: Wrap(
                                runSpacing: 4.0,
                                spacing: 4.0,
                                children: inputFieldValues.tags.map((String tag) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: prudColorTheme.lineC,
                                    ),
                                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          child: Text('#$tag', style: TextStyle(color: prudColorTheme.textB),),
                                          onTap: () {debugPrint("selected Tag: #$tag");},
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: Icon(Icons.cancel, size: 15.0, color: prudColorTheme.buttonA,),
                                          onTap: () => inputFieldValues.onTagRemoved(tag),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                              ),
                            ),
                          ) : null,
                        ),
                        onChanged: (String? valueDesc){
                          if(mounted && valueDesc != null) {
                            inputFieldValues.onTagChanged(valueDesc);
                            setState(() {
                              thrillerTags = inputFieldValues.tags;
                              result?["thrillerTags"] = thrillerTags;
                              prudStudioNotifier.newVideo.thriller!.tags = thrillerTags;
                            });
                            prudStudioNotifier.saveNewVideoData();
                          }
                        },
                        onSubmitted: inputFieldValues.onTagSubmitted,
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