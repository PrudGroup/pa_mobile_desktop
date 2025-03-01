import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/movie_cast_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_movie_cast_view.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:prudapp/string_api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:textfield_tags/textfield_tags.dart';
    
class VideoMovie extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoMovie({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoMovieState createState() => VideoMovieState();
}

class VideoMovieState extends State<VideoMovie> {
  final tagCtrl = StringTagController();
  final tagCtrl1 = StringTagController();
  Map<String, dynamic>? result;
  List<String> forbiddenTags = ["sex", "fuck", "pussy", "violence", "viral", "shorts", "youtube"];
  List<String> guards = ["Adult", "All", "PG", "18+", "16+", "13+", "8+", "Infants"];
  List<String> mTypes = ["Animation", "Live Action"];
   List<String> mSubTypes = ["Drama", "Action", "Epic", "Sci-Fi", "Horror", "Comedy", "Thriller", "Romance"];
  List<String>? tags = prudStudioNotifier.newVideo.movieDetail?.tags;
  String? producerName = prudStudioNotifier.newVideo.movieDetail?.executiveProducerName;
  String parentalGuard = prudStudioNotifier.newVideo.movieDetail?.parentalGuard?? "Adult";
  int productionMonth = prudStudioNotifier.newVideo.movieDetail?.productionMonth?? 0;
  int productionYear = prudStudioNotifier.newVideo.movieDetail?.productionYear?? 2025;
  String? title = prudStudioNotifier.newVideo.movieDetail?.movieTitle;
  String? subtitle = prudStudioNotifier.newVideo.movieDetail?.movieSubtitle;
  String? morePlot = prudStudioNotifier.newVideo.movieDetail?.morePlot;
  bool isSeries = prudStudioNotifier.newVideo.movieDetail?.isSeries?? false;
  int? season = prudStudioNotifier.newVideo.movieDetail?.season;
  int? episode = prudStudioNotifier.newVideo.movieDetail?.episode;
  List<String> companies = prudStudioNotifier.newVideo.movieDetail?.productionCompanyNames?? [];
  int totalCasts = prudStudioNotifier.newVideo.movieDetail?.totalCast?? 0;
  double totalCost = prudStudioNotifier.newVideo.movieDetail?.totalCostOfProduction?? 0;
  List<VideoMovieCast> casts = prudStudioNotifier.newVideo.movieDetail?.casts?? [];
  String movieType = prudStudioNotifier.newVideo.movieDetail?.movieType?? "Animation";
  String movieSubType = prudStudioNotifier.newVideo.movieDetail?.movieSubType?? "Drama";
  List<String> categories = ["Series", "Single"];
  FocusNode fNode = FocusNode();
  final GlobalKey _key1 = GlobalKey();
  TextEditingController txtCtrl = TextEditingController();
  final int maxWords = 200;
  final int minWords = 20;
  int presentWords = tabData.countWordsInString(prudStudioNotifier.newVideo.movieDetail?.morePlot?? "");
  bool saving = false;
  bool savingCast = false;
  bool hasSavedDetail = false;
  bool showAddCast = false;
  Widget noCasts = tabData.getNotFoundWidget(
    title: "No Cast Added", desc: "You must add the movie cast to a movie detail. Click below to add.", isRow: true,
  );

  void showCastAddView(){
    if(mounted) setState(() => showAddCast = true);
  }

  void onCastAdded(VideoMovieCast dCast){
    if(mounted) {
      setState((){
        casts.add(dCast);
        showAddCast = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Translate(text: "Cast Added"),
      ));
    }
  }

  void deleteCast(int index){
    Alert(
      context: context, style: myStorage.alertStyle,
      type: AlertType.warning, title: "Delete Cast",
      desc: "You are about to delete (${casts[index].fullname}) from the casts.",
      buttons: [
        DialogButton(
          onPressed: (){
            if(mounted) setState(() => casts.removeAt(index));
            Navigator.pop(context);
          },
          color: prudColorTheme.primary,
          radius: BorderRadius.zero,
          child: const Translate(
            text: "Delete",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: prudColorTheme.primary,
          radius: BorderRadius.zero,
          child: const Translate(
            text: "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }

  bool validate(){
    return title != null && subtitle != null && producerName != null &&
    productionMonth > 0 && productionYear > 1900 &&
    forbiddenTags.every((tag) =>!tags!.contains(tag)) &&
    guards.contains(parentalGuard) && mTypes.contains(movieType) &&
    mSubTypes.contains(movieSubType) && companies.isNotEmpty &&
    presentWords >= minWords && presentWords <= maxWords;
  }

  Future<void> saveDetail() async {
    if(!validate()) return;
    if(mounted) setState(() => saving = true);
    VideoMovieDetail? detail = await tryAsync("saveDetail", () async {
      VideoMovieDetail vmd = VideoMovieDetail(
        casts: casts, movieTitle: title!, movieSubtitle: subtitle!,
        morePlot: morePlot!, isSeries: isSeries, season: season,
        parentalGuard: parentalGuard, productionMonth: productionMonth,
        productionYear: productionYear, executiveProducerName: producerName!,
        totalCast: casts.length, totalCostOfProduction: totalCost,
        movieType: movieType, movieSubType: movieSubType, productionCompanyNames: companies,
        tags: tags, episode: episode,
      );
      VideoMovieDetail? det = await prudStudioNotifier.createMovieDetail(vmd);
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
    tagCtrl1.dispose();
    txtCtrl.dispose();
    fNode.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    String cate = isSeries ? "Series" : "Single";
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
          text: "Movie Details",
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
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Movie Category",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilder(
                    child: FormBuilderChoiceChips(
                      decoration: getDeco("Category"),
                      backgroundColor: prudColorTheme.bgA,
                      disabledColor: prudColorTheme.bgD,
                      spacing: spacer.width.width!,
                      shape: prudWidgetStyle.choiceChipShape,
                      selectedColor: prudColorTheme.primary,
                      onChanged: (String? selected){
                        tryOnly("CategorySelector", (){
                          if(mounted && selected != null){
                            setState(() { 
                              isSeries = selected == "Series";
                            });
                          }
                        });
                      },
                      name: "category",
                      initialValue: cate,
                      options: categories.map((String ele) {
                        return FormBuilderChipOption(
                          value: ele,
                          child: Translate(
                            text: ele,
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                color: ele == cate?
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
              title: "Title",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: title,
                    name: 'title',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Movie Title",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted) {
                        setState(() { 
                          title = value?.trim();
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
              title: "Subtitle",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: title,
                    name: 'subtitle',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Movie Subtitle",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted) {
                        setState(() { 
                          subtitle = value?.trim();
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
              text: "Add tags to this movie so viewers can easily locate this content during searches. Each tag can be separated by a space",
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
              title: "Movie Tags",
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
                        name: 'Movie Tags',
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
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Movie Type",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilder(
                    child: FormBuilderChoiceChips(
                      decoration: getDeco("Type"),
                      backgroundColor: prudColorTheme.bgA,
                      disabledColor: prudColorTheme.bgD,
                      spacing: spacer.width.width!,
                      shape: prudWidgetStyle.choiceChipShape,
                      selectedColor: prudColorTheme.primary,
                      onChanged: (String? selected){
                        tryOnly("TypeSelector", (){
                          if(mounted && selected != null){
                            setState(() { 
                              movieType = selected;
                            });
                          }
                        });
                      },
                      name: "category",
                      initialValue: movieType,
                      options: mTypes.map((String ele) {
                        return FormBuilderChipOption(
                          value: ele,
                          child: Translate(
                            text: ele,
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                color: ele == movieType?
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
              title: "Movie Sub Type",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilder(
                    child: FormBuilderChoiceChips(
                      decoration: getDeco("SubType"),
                      backgroundColor: prudColorTheme.bgA,
                      disabledColor: prudColorTheme.bgD,
                      spacing: spacer.width.width!,
                      shape: prudWidgetStyle.choiceChipShape,
                      selectedColor: prudColorTheme.primary,
                      onChanged: (String? selected){
                        tryOnly("SubTypeSelector", (){
                          if(mounted && selected != null){
                            setState(() { 
                              movieSubType = selected;
                            });
                          }
                        });
                      },
                      name: "subtype",
                      initialValue: movieSubType,
                      options: mSubTypes.map((String ele) {
                        return FormBuilderChipOption(
                          value: ele,
                          child: Translate(
                            text: ele,
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                color: ele == movieSubType?
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
              text: "What are the names of the companies who produced the movie? Each company can be separated by a comma",
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
              title: "Production Companies",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  TextFieldTags<String>(
                    textfieldTagsController: tagCtrl1,
                    initialTags: companies,
                    textSeparators: const [','],
                    inputFieldBuilder: (context, inputFieldValues){
                      return FormBuilderTextField(
                        controller: inputFieldValues.textEditingController,
                        focusNode: inputFieldValues.focusNode,
                        name: 'Companies',
                        enableInteractiveSelection: true,
                        onTap: (){
                          inputFieldValues.focusNode.requestFocus();
                        },
                        style: tabData.npStyle,
                        keyboardType: TextInputType.text,
                        decoration: getDeco(
                          "Company Names",
                          onlyBottomBorder: true,
                          borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? valueDesc){
                          if(mounted && valueDesc != null) {
                            setState(() {
                              companies = valueDesc.trim().split(",");
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
                      if(isSeries) spacer.width,
                      if(isSeries) Expanded(
                        child: FormBuilderTextField(
                          initialValue: "$season",
                          name: 'season',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.number,
                          decoration: getDeco(
                            "Season",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) {
                              setState(() { 
                                season = int.parse(value.trim());
                              });
                            }
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(1),
                            FormBuilderValidators.hasNumericChars(atLeast: 4),
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      ),
                      if(isSeries) spacer.width,
                      if(isSeries) Expanded(
                        child: FormBuilderTextField(
                          initialValue: "$episode",
                          name: 'episode',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.number,
                          decoration: getDeco(
                            "episode",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) {
                              setState(() { 
                                episode = int.parse(value.trim());
                              });
                            }
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(1),
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
            spacer.height,
            Translate(
              text: "In not less than 10 words and not more than 200 words, describe the movie plot and what"
                  " your viewers will gain from watching the movie. This could be your selling point to viewers.",
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
              title: "Movie Plot",
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
                      name: 'plot',
                      minLines: 8,
                      maxLines: 15,
                      focusNode: fNode,
                      enableInteractiveSelection: true,
                      onTap: (){
                        fNode.requestFocus();
                      },
                      autofocus: true,
                      style: tabData.npStyle,
                      keyboardType: TextInputType.multiline,
                      decoration: getDeco(
                        "Movie Plot",
                        onlyBottomBorder: true,
                        borderColor: prudColorTheme.lineC
                      ),
                      onChanged: (String? valueDesc){
                        if(mounted && valueDesc != null) {
                          setState(() {
                            morePlot = valueDesc.trim();
                            presentWords = tabData.countWordsInString(morePlot!);
                          });
                        }
                      },
                      valueTransformer: (text) => num.tryParse(text!),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minWordsCount(20),
                        FormBuilderValidators.maxWordsCount(200),
                      ]),
                    ),
                  ),
                  spacer.height,
                ],
              )
            ),
            mediumSpacer.height,
            PrudPanel(
              title: "Movie Cast",
              hasPadding: false,
              titleSize: 13,
              bgColor: prudColorTheme.bgC,
              child: Column(
                children: [
                  spacer.height,
                  casts.isNotEmpty? SizedBox(
                    height: casts.isNotEmpty? 160 : 100, 
                    child: ListView.builder(
                      itemCount: casts.length,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) => InkWell(
                        onLongPress: () => deleteCast(index),
                        child: MovieCastComponent(
                          isClickable: false,
                          cast: casts[index]
                        ),
                      ), 
                    )
                  ) : noCasts,
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
                        onPressed: showCastAddView, 
                        isPill: false,
                        isSmall: true,
                        text: casts.isEmpty? "Add Cast" : "Add More Cast",
                      )
                    ],
                  ),
                  Divider(
                    color: prudColorTheme.lineC,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                    height: 10,
                  ),
                  if(showAddCast) AddMovieCastView(
                    onCastAdded: onCastAdded,
                  ),
                ],
              ),
            ),
            spacer.height,
            if(!hasSavedDetail && casts.length > 3) (saving? LoadingComponent(
              isShimmer: false,
              defaultSpinnerType: false,
              size: 15,
              spinnerColor: prudColorTheme.primary,
            ) : prudWidgetStyle.getLongButton(
              onPressed: saveDetail, 
              shape: 1,
              text: "Save Movie Detail"
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