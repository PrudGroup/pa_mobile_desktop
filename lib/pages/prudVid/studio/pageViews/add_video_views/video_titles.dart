import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:prudapp/singletons/i_cloud.dart';
    
class VideoTitles extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoTitles({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoTitlesState createState() => VideoTitlesState();
}

class VideoTitlesState extends State<VideoTitles> {
  final GlobalKey _key1 = GlobalKey();
  final GlobalKey _key2 = GlobalKey();
  TextEditingController txtCtrl = TextEditingController();
  String? title = prudStudioNotifier.newVideo.title;
  String? description = prudStudioNotifier.newVideo.description;
  Map<String, dynamic>? result;
  FocusNode fNode = FocusNode();
  final int maxWords = 100;
  final int minWords = 30;
  int presentWords = tabData.countWordsInString(prudStudioNotifier.newVideo.description?? "");
  
  @override
  void initState(){
    if(mounted){
      setState(() {
        result = {
          "title": prudStudioNotifier.newVideo.title,
          "description": prudStudioNotifier.newVideo.description,
        };
      });
      txtCtrl.text = description?? '';
    }
    super.initState();
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    fNode.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
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
          text: "Video Info",
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
              text: "Lets get other important details for this video.",
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
              title: "Title",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: title,
                    name: 'title',
                    key: _key2,
                    autofocus: true,
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Video Title",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted) {
                        setState(() { 
                          title = value?.trim();
                          result = {
                            "title": title,
                            "description": description,
                          };
                          prudStudioNotifier.newVideo.title = title;
                        });
                        prudStudioNotifier.saveNewVideoData();
                      }
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(30),
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              )
            ),
            spacer.height,
            spacer.height,
            Translate(
              text: "In not less than 30 words and not more than 100 words, describe this video content and what"
                  " your viewers will gain from watching this video. This could be your selling point to viewers.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                color: prudColorTheme.textA,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Description",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("$presentWords/$maxWords"),
                  ),
                  FormBuilder(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: FormBuilderTextField(
                      controller: txtCtrl,
                      key: _key1,
                      name: 'description',
                      minLines: 8,
                      maxLines: 12,
                      focusNode: fNode,
                      enableInteractiveSelection: true,
                      onTap: (){
                        fNode.requestFocus();
                      },
                      autofocus: true,
                      style: tabData.npStyle,
                      keyboardType: TextInputType.text,
                      decoration: getDeco(
                        "About Video",
                        onlyBottomBorder: true,
                        borderColor: prudColorTheme.lineC
                      ),
                      onChanged: (String? valueDesc){
                        if(mounted && valueDesc != null) {
                          setState(() {
                            description = valueDesc.trim();
                            presentWords = tabData.countWordsInString(description!);
                            result = {
                              "title": title,
                              "description": description,
                            };
                            prudStudioNotifier.newVideo.description = description;
                          });
                          prudStudioNotifier.saveNewVideoData();
                        }
                      },
                      valueTransformer: (text) => num.tryParse(text!),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minWordsCount(30),
                        FormBuilderValidators.maxWordsCount(100),
                      ]),
                    ),
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
                if(presentWords >= 30 && presentWords <= 100) prudWidgetStyle.getShortButton(
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