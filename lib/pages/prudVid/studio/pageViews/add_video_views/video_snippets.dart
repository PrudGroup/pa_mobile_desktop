import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/video_snippet_card.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class VideoSnippets extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoSnippets({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoSnippetsState createState() => VideoSnippetsState();
}

class VideoSnippetsState extends State<VideoSnippets> {
  List<VideoSnippet> snippets = prudStudioNotifier.newVideo.snippets?? [];
  Map<String, dynamic>? result;
  bool showSnippetAdd = false;
  String? title;
  String? description;
  String? start;
  String? end;
  String videoId = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(mounted){
        setState((){
          result = {"snippets": snippets};
        });
      }
    });
    super.initState();
  }

  void save() {
    final newSnippet = VideoSnippet(
      videoId: videoId, 
      description: description!, 
      title: title!, 
      startAt: start!, 
      endAt: end!
    );
    if(mounted) {
      setState(() { 
        snippets.add(newSnippet);
        result = {"snippets": snippets};
        showSnippetAdd = false;
      });
      clear();
    }
  }

  void delete(int index){
    if(mounted){
      setState(() { 
        snippets.removeAt(index);
        result = {"snippets": snippets};
      });
    }
  }

  void clear(){
    if(mounted){
      setState(() {
        title = null;
        description = null;
        start = null;
        end = null;
      });
    }
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
          text: "Video Snippets",
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
              text: "Create snippets for this video so that viewers can easily navigate to different parts of the video. "
              " To delete a snippet, give a longpress on the snippet.",
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
              hasPadding: false,
              title: "Video Snippets",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  if(snippets.isNotEmpty) SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      physics: CarouselScrollPhysics(),
                      itemCount: snippets.length,
                      itemBuilder: (context, index){
                        return InkWell(
                          onLongPress: () => delete(index),
                          child: VideoSnippetCard(
                            videoSnippet: snippets[index],
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(
                    color: prudColorTheme.lineC,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                    height: 10,
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      prudWidgetStyle.getShortButton(
                        onPressed: () {
                          if(mounted) setState(() => showSnippetAdd = !showSnippetAdd);
                        }, 
                        text: snippets.isEmpty? "Add Snippet":"Add More",
                      )
                    ],
                  ),
                  spacer.height,
                  if(showSnippetAdd) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: PrudPanel(
                      title: "New Snippet",
                      titleColor: prudColorTheme.textB,
                      bgColor: prudColorTheme.bgA,
                      titleSize: 14,
                      child: FormBuilder(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              name: 'title',
                              initialValue: title,
                              enableInteractiveSelection: true,
                              autofocus: true,
                              style: tabData.npStyle,
                              keyboardType: TextInputType.text,
                              decoration: getDeco(
                                "Title",
                                onlyBottomBorder: true,
                                borderColor: prudColorTheme.lineC
                              ),
                              onChanged: (String? value){
                                if(mounted) setState(() => title = value);
                              },
                              valueTransformer: (text) => num.tryParse(text!),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(3),
                                FormBuilderValidators.maxLength(30),
                              ]),
                            ),
                            spacer.height,
                            FormBuilderTextField(
                              name: 'description',
                              initialValue: description,
                              enableInteractiveSelection: true,
                              style: tabData.npStyle,
                              keyboardType: TextInputType.text,
                              decoration: getDeco(
                                "Description",
                                onlyBottomBorder: true,
                                borderColor: prudColorTheme.lineC
                              ),
                              onChanged: (String? value){
                                if(mounted) setState(() => description = value);
                              },
                              valueTransformer: (text) => num.tryParse(text!),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(3),
                                FormBuilderValidators.maxLength(30),
                              ]),
                            ),
                            spacer.height,
                            Row(
                              children: [
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'start',
                                    initialValue: description,
                                    enableInteractiveSelection: true,
                                    style: tabData.npStyle,
                                    keyboardType: TextInputType.datetime,
                                    decoration: getDeco(
                                      "Start At",
                                      onlyBottomBorder: true,
                                      borderColor: prudColorTheme.lineC
                                    ),
                                    onChanged: (String? value){
                                      if(mounted && value != null) setState(() => start = tabData.parseDurationFromDouble(double.parse(value)).toString());
                                    },
                                    valueTransformer: (text) => num.tryParse(text!),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required()
                                    ]),
                                  ),
                                ),
                                spacer.width,
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'End',
                                    initialValue: description,
                                    enableInteractiveSelection: true,
                                    style: tabData.npStyle,
                                    keyboardType: TextInputType.text,
                                    decoration: getDeco(
                                      "End At",
                                      onlyBottomBorder: true,
                                      borderColor: prudColorTheme.lineC
                                    ),
                                    onChanged: (String? value){
                                      if(mounted && value != null) setState(() => end = tabData.parseDurationFromDouble(double.parse(value)).toString());
                                    },
                                    valueTransformer: (text) => num.tryParse(text!),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                    ]),
                                  ),
                                )
                              ]
                            ),
                            spacer.height,
                            Divider(
                              color: prudColorTheme.lineC,
                              thickness: 1,
                              indent: 10,
                              endIndent: 10,
                              height: 10,
                            ),
                            if(description != null && title != null && start != null && end != null) Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                prudWidgetStyle.getShortButton(
                                  onPressed: save, 
                                  text: "Save",
                                  isSmall: true,
                                  isPill: false,
                                ),
                              ],
                            ),
                            spacer.height,
                          ],
                        ),
                      ),
                    ),
                  ),
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
                  onPressed: () => widget.onCompleted(true), 
                  text: "No Snippet",
                  makeLight: false,
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