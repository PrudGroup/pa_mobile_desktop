import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:prudapp/string_api.dart';
import 'package:textfield_tags/textfield_tags.dart';
    
class VideoMusic extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoMusic({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoMusicState createState() => VideoMusicState();
}

class VideoMusicState extends State<VideoMusic> {
  final tagCtrl = StringTagController();
  Map<String, dynamic>? result;
  List<String> forbiddenTags = ["sex", "fuck", "pussy", "violence", "viral", "shorts", "youtube"];
  List<String> guards = ["Adult", "All", "PG", "18+", "16+", "13+", "8+", "Infants"];
  List<String>? tags = prudStudioNotifier.newVideo.musicDetail?.tags;
  String? producerName = prudStudioNotifier.newVideo.musicDetail?.executiveProducerName;
  String parentalGuard = prudStudioNotifier.newVideo.musicDetail?.parentalGuard?? "Adult";
  int productionMonth = prudStudioNotifier.newVideo.musicDetail?.productionMonth?? 0;
  int productionYear = prudStudioNotifier.newVideo.musicDetail?.productionYear?? 2025;
  String? albumTitle = prudStudioNotifier.newVideo.musicDetail?.albumTitle?? "";
  String? trackTitle = prudStudioNotifier.newVideo.musicDetail?.trackTitle?? "";
  double totalCost = prudStudioNotifier.newVideo.musicDetail?.totalCostOfProduction?? 0;
  String musicLabel = prudStudioNotifier.newVideo.musicDetail?.musicLabel?? "";
  TextEditingController txtCtrl = TextEditingController();
  bool saving = false;
  bool hasSavedDetail = false;


  bool validate(){
    return albumTitle != null && trackTitle != null && producerName != null &&
    productionMonth > 0 && productionYear > 1900 &&
    forbiddenTags.every((tag) =>!tags!.contains(tag)) &&
    guards.contains(parentalGuard) && musicLabel.isNotEmpty;
  }


  Future<void> saveDetail() async {
    if(!validate()) return;
    if(mounted) setState(() => saving = true);
    VideoMusicDetail? detail = await tryAsync("saveDetail", () async {
      VideoMusicDetail vmd = VideoMusicDetail(
        albumTitle: albumTitle!, trackTitle: trackTitle!, musicLabel: musicLabel, 
        parentalGuard: parentalGuard, productionMonth: productionMonth,
        productionYear: productionYear, executiveProducerName: producerName!,
        totalCostOfProduction: totalCost, tags: tags, 
      );
      VideoMusicDetail? det = await prudStudioNotifier.createMusicDetail(vmd);
      return det;
    });
    if(mounted) {
      setState(() {
        if(detail != null) {
          result = {"detail": detail};
          hasSavedDetail = true;
        }
        saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Translate(text: hasSavedDetail? "Details Saved." : "Unable To Save Detail"),
        backgroundColor: hasSavedDetail? null : prudColorTheme.primary,
      ));
    }
  }


  @override
  void initState() {
    if(mounted) {
      setState(() { 
        result = {"detail": null};
      });
    }
    super.initState();
  }


  @override
  void dispose() {
    tagCtrl.dispose();
    txtCtrl.dispose();
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
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Music Details",
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
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Album Title",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: albumTitle,
                    name: 'albumTitle',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Album Title",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted) {
                        setState(() { 
                          albumTitle = value?.trim();
                        });
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
              title: "Guard Category",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilder(
                    child: FormBuilderChoiceChips(
                      decoration: getDeco("Guard Audience"),
                      backgroundColor: prudColorTheme.bgA,
                      disabledColor: prudColorTheme.bgD,
                      spacing: spacer.width.width!,
                      shape: prudWidgetStyle.choiceChipShape,
                      selectedColor: prudColorTheme.primary,
                      onChanged: (String? selected){
                        tryOnly("GuardSelector", (){
                          if(mounted && selected != null){
                            setState(() { 
                              parentalGuard = selected;
                            });
                          }
                        });
                      },
                      name: "guard",
                      initialValue: parentalGuard,
                      options: guards.map((String ele) {
                        return FormBuilderChipOption(
                          value: ele,
                          child: Translate(
                            text: ele,
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                color: ele == parentalGuard?
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
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Track Title",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: trackTitle,
                    name: 'trackTitle',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Track title",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted) {
                        setState(() { 
                          trackTitle = value?.trim();
                        });
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
            Translate(
              text: "Add tags to this music so viewers can easily locate this content during searches. Each tag can be separated by a space",
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
              title: "Music Tags",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  TextFieldTags<String>(
                    textfieldTagsController: tagCtrl,
                    initialTags: tags,
                    textSeparators: const [' '],
                    validator: (String tag){
                      if (tag.toLowerCase().containsAny(forbiddenTags)){
                        return '${forbiddenTags.join(", ")} not allowed';
                      }
                      return null;
                    },
                    inputFieldBuilder: (context, inputFieldValues){
                      return FormBuilderTextField(
                        controller: inputFieldValues.textEditingController,
                        focusNode: inputFieldValues.focusNode,
                        name: 'musicTags',
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
                              tags = valueDesc.trim().split(" ");
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
              text: "What is the name of the Music company/label who produced this music?",
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
              title: "Music Company/Label",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: musicLabel,
                    name: 'musicLabel',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Music Label",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted && value != null) {
                        setState(() { 
                          musicLabel = value.trim();
                        });
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
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Executive Producer's Name",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: producerName,
                    name: 'producer',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Producer",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted) {
                        setState(() { 
                          producerName = value?.trim();
                        });
                      }
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              )
            ),
            spacer.height,
            PrudPanel(
              title: "Production Date",
              hasPadding: true,
              bgColor: prudColorTheme.bgC,
              titleSize: 13,
              child: Column(
                children: [
                  spacer.height,
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          initialValue: "$productionMonth",
                          name: 'month',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.number,
                          decoration: getDeco(
                            "Month",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) {
                              setState(() { 
                                productionMonth = int.parse(value.trim());
                              });
                            }
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.min(1),
                            FormBuilderValidators.max(12),
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      ),
                      spacer.width,
                      Expanded(
                        child: FormBuilderTextField(
                          initialValue: "$productionYear",
                          name: 'year',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.number,
                          decoration: getDeco(
                            "Year",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) {
                              setState(() { 
                                productionYear = int.parse(value.trim());
                              });
                            }
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(4),
                            FormBuilderValidators.maxLength(4),
                            FormBuilderValidators.hasNumericChars(atLeast: 4),
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  spacer.height,
                ],
              ),
            ),
            spacer.height,
            Translate(
              text: "How much did the entire production cost. We are not talking about the budget but the exact amount that was spent.",
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
              title: "Production Cost",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: "$totalCost",
                    name: 'cost',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.number,
                    decoration: getDeco(
                      "Cost Of Production",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted && value != null) {
                        setState(() { 
                          totalCost = currencyMath.roundDouble(double.parse(value.trim()), 2);
                        });
                      }
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(1),
                      FormBuilderValidators.float(),
                      FormBuilderValidators.hasNumericChars(),
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              )
            ),
            mediumSpacer.height,
            if(!hasSavedDetail) (saving? LoadingComponent(
              isShimmer: false,
              defaultSpinnerType: false,
              size: 15,
              spinnerColor: prudColorTheme.primary,
            ) : prudWidgetStyle.getLongButton(
              onPressed: saveDetail, 
              shape: 1,
              text: "Save Music Detail"
            )),
            if(hasSavedDetail) spacer.height,
            if(hasSavedDetail) Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 10,
            ),
            if(hasSavedDetail) Row(
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