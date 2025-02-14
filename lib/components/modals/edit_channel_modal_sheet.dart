import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../models/theme.dart';

class EditChannelModalSheet extends StatefulWidget {
  final double height;
  final String editType;
  final BorderRadiusGeometry radius;
  final VidChannel channel;
  


  const EditChannelModalSheet({
    super.key,
    required this.editType,
    required this.radius,
    required this.height,
    required this.channel,
  });

  @override
  EditChannelModalSheetState createState() => EditChannelModalSheetState();
}

class EditChannelModalSheetState extends State<EditChannelModalSheet> {

  TextEditingController txtCtrl = TextEditingController();
  double memberCost = 0;
  double membershipCostInEuro = 0;
  double streamingCost = 0;
  double streamingCostInEuro = 0;
  bool validated = false;
  bool saving = false;
  double viewShare = 0;
  double membershipShare = 0;
  String description = "";
  final int maxWords = 100;
  final int minWords = 30;
  int presentWords = 0;
  final GlobalKey _key1 = GlobalKey();
  final GlobalKey _key2 = GlobalKey();
  final GlobalKey _key3 = GlobalKey();
  final GlobalKey _key4 = GlobalKey();
  final GlobalKey _key5 = GlobalKey();
  FocusNode fNode1 = FocusNode();
  FocusNode fNode2 = FocusNode();
  FocusNode fNode3 = FocusNode();
  FocusNode fNode4 = FocusNode();
  FocusNode fNode5 = FocusNode();
  TextEditingController txtCtrl2 = TextEditingController();

  Future<bool> validateMemberCost() async {
    if(memberCost > 0){
      if(widget.channel.channelCurrency.toUpperCase() == "EUR"){
        membershipCostInEuro = memberCost;
        return memberCost >= 1.0 && memberCost <= 5.0;
      }else{
        double amount = await currencyMath.convert(
          amount: memberCost,
          quoteCode: "EUR",
          baseCode: widget.channel.channelCurrency
        );
        membershipCostInEuro = currencyMath.roundDouble(amount, 2);
        return amount >= 1.0 && amount <= 5.0;
      }
    }else{
      return false;
    }
  }

  bool validateShares() => viewShare >= 40.0 && membershipShare >= 40.0;

  bool validateDescription() => description.isNotEmpty && presentWords >= minWords && presentWords <= maxWords;

  Future<bool> validateStreamingCost(double cost) async {
    if(cost > 0){
      if(widget.channel.channelCurrency.toUpperCase() == "EUR"){
        streamingCostInEuro = cost;
        return cost >= 4.0 && cost <= 10.0;
      }else{
        double amount = await currencyMath.convert(
          amount: cost,
          quoteCode: "EUR",
          baseCode: widget.channel.channelCurrency
        );
        streamingCostInEuro = currencyMath.roundDouble(amount, 2);
        return amount >= 4.0 && amount <= 10.0;
      }
    }else{
      return false;
    }
  }

  Future<void> saveMembershipCost() async {
    ChannelUpdate newUpdate = ChannelUpdate(
      monthlyMembershipCost: memberCost,
      monthlyMembershipCostInEuro: membershipCostInEuro
    );
    await save(newUpdate);
  }

  Future<void> saveShares() async {
    ChannelUpdate newUpdate = ChannelUpdate(
      contentPercentageSharePerView: viewShare,
      membershipPercentageSharePerMonth: membershipShare
    );
    await save(newUpdate);
  }

  Future<void> saveDescription() async {
    ChannelUpdate newUpdate = ChannelUpdate(
      description: description,
    );
    await save(newUpdate);
  }

   Future<void> saveStreamingCost() async {
    ChannelUpdate newUpdate = ChannelUpdate(
      monthlyStreamingCost: streamingCost,
      monthlyStreamingCostInEuro: streamingCostInEuro,
    );
    await save(newUpdate);
  }

  Future<void> save(ChannelUpdate newUpdate) async{
    await tryAsync("saveMembershipCost", () async {
      if(mounted) setState(() => saving = true);
      VidChannel? updated = await prudStudioNotifier.updateChannelInCloud(widget.channel.id!, newUpdate);
      if(updated != null){
        prudStudioNotifier.updateAChannelInMyChannels(updated);
        prudStudioNotifier.channelChangesOccurred(updated);
        if(mounted) {
          setState(() => saving = false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Changes Saved.",),
          ));
        }
      }else{
        if(mounted) {
          setState(() => saving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Failed to save changes.",),
            backgroundColor: prudColorTheme.primary,
          ));
        }
      }
    }, error: (){
      if(mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Failed to save changes.",),
          backgroundColor: prudColorTheme.primary,
        ));
      }
    });
  }


  @override
  void initState() {
    if(mounted){
      setState(() {
        viewShare = widget.channel.contentPercentageSharePerView;
        membershipShare = widget.channel.membershipPercentageSharePerMonth;
        description = widget.channel.description;
        presentWords = tabData.countWordsInString(widget.channel.description);
        streamingCost = widget.channel.monthlyStreamingCost;
      });
    }
    super.initState();
    txtCtrl.text = widget.channel.monthlyMembershipCost.toString();
    txtCtrl2.text = description;
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    txtCtrl2.dispose();
    fNode1.dispose();
    fNode2.dispose();
    fNode3.dispose();
    fNode4.dispose();
    fNode5.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry rad = widget.radius;
    double height = widget.height * 0.8;
    double minHeight = widget.height * 0.4;
    return ClipRRect(
      borderRadius: rad,
      child: Container(
        // height: height,
        constraints: BoxConstraints(maxHeight: height, minHeight: minHeight),
        decoration: BoxDecoration(
          borderRadius: rad,
          color: prudColorTheme.bgC
        ),
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              spacer.height,
              if(widget.editType == "membership_cost") Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spacer.height,
                  Translate(
                    text: "How much would you charge for monthly membership subscription on "
                        "this channel? You must make sure that the amount is not less than 1(EURO) and not greater "
                        "than 5(Euro) in the currency of your channel.",
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
                    title: "Membership Cost(${widget.channel.channelCurrency})",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        FormBuilder(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: FormBuilderTextField(
                            controller: txtCtrl,
                            autofocus: true,
                            name: 'membershipCost',
                            style: tabData.npStyle,
                            key: _key1,
                            focusNode: fNode1,
                            onTap: (){
                              fNode1.requestFocus();
                            },
                            keyboardType: TextInputType.number,
                            decoration: getDeco(
                              "How Much",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                            ),
                            onChanged: (String? value) async {
                              await tryAsync("onChange", () async {
                                if(mounted && value != null && value.isNotEmpty) setState(() => memberCost = currencyMath.roundDouble(double.parse(value.trim()), 2));
                                bool cleared = await validateMemberCost();
                                if(mounted) setState(() => validated = cleared);
                              });
                            },
                            valueTransformer: (text) => num.tryParse(text!),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),
                        ),
                        spacer.height,
                      ],
                    )
                  ),
                  spacer.height,
                  saving? LoadingComponent(
                    isShimmer: false,
                    defaultSpinnerType: false,
                    size: 15,
                    spinnerColor: prudColorTheme.primary,
                  ) : (
                    validated? prudWidgetStyle.getLongButton(
                      onPressed: saveMembershipCost, 
                      text: "Save Changes"
                    ) : SizedBox()
                  ),
                ],
              ),
              if(widget.editType == "creator_membership_share") FormBuilder(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                children: [
                  spacer.height,
                  Translate(
                    text: "Your channel can contract as many content creators as you desire. "
                        "This will also mean that they share from the funds generated by your channel. What percentage are "
                        "of your channel funds are you willing to share per view/membership with content creators. Must be from 40 and above.",
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
                    title: "Creator Percentage Share",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        FormBuilderTextField(
                          initialValue: "$membershipShare",
                          name: 'membershipShare',
                          autofocus: true,
                          key: _key2,
                          focusNode: fNode2,
                          onTap: (){
                            fNode2.requestFocus();
                          },
                          style: tabData.npStyle,
                          keyboardType: TextInputType.number,
                          decoration: getDeco(
                            "Membership Share",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) {
                              setState(() {
                                membershipShare = double.parse(value.trim());
                                validated = validateShares();
                              });
                            }
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.min(40),
                            FormBuilderValidators.max(80),
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: "$viewShare",
                          name: 'viewShare',
                          key: _key3,
                          focusNode: fNode3,
                          onTap: (){
                            fNode3.requestFocus();
                          },
                          autofocus: true,
                          style: tabData.npStyle,
                          keyboardType: TextInputType.number,
                          decoration: getDeco(
                            "View Share",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) {
                              setState(() {
                                viewShare = double.parse(value.trim());
                                validated = validateShares();
                              });
                            }
                          },
                          valueTransformer: (text) => num.tryParse(text!),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.min(40),
                            FormBuilderValidators.max(80),
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  spacer.height,
                  saving? LoadingComponent(
                    isShimmer: false,
                    defaultSpinnerType: false,
                    size: 15,
                    spinnerColor: prudColorTheme.primary,
                  ) : (validated? prudWidgetStyle.getLongButton(
                    onPressed: saveShares, 
                    text: "Save Changes"
                  ) : SizedBox()),
                ],
              )
              ),
              if(widget.editType == "streaming_cost") Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spacer.height,
                  Translate(
                    text: "How much would you charge for monthly streaming subscription on "
                        "this channel? You must make sure that the amount is not less than 4(EURO) and not greater "
                        "than 10(Euro) in the currency of your channel.",
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
                    title: "Streaming Cost(${prudStudioNotifier.newChannelData.selectedCurrency!.code})",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        FormBuilder(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: FormBuilderTextField(
                            onChanged: (String? value) async {
                              await tryAsync("onChange", () async {
                                if(mounted && value != null && value.isNotEmpty) {
                                  double cost = currencyMath.roundDouble(double.parse(value.trim()), 2);
                                  bool cleared = await validateStreamingCost(cost);
                                  setState(() {
                                    streamingCost = cost;
                                    validated = cleared;
                                  });
                                }
                              });
                            },
                            autofocus: true,
                            name: 'streamingCost',
                            initialValue: "$streamingCost",
                            style: tabData.npStyle,
                            focusNode: fNode4,
                            key: _key4,
                            onTap: (){
                              fNode4.requestFocus();
                            },
                            keyboardType: TextInputType.number,
                            decoration: getDeco(
                              "How Much",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                            ),
                            valueTransformer: (text) => num.tryParse(text!),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),
                        ),
                        spacer.height,
                      ],
                    ),
                  ),
                  spacer.height,
                  saving? LoadingComponent(
                    isShimmer: false,
                    defaultSpinnerType: false,
                    size: 15,
                    spinnerColor: prudColorTheme.primary,
                  ) : (validated? prudWidgetStyle.getLongButton(
                    onPressed: saveStreamingCost, 
                    text: "Save Changes"
                  ) : SizedBox()),
                ],
              ),
              if(widget.editType == "description") FormBuilder(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    spacer.height,
                    Translate(
                      text: "In not less than 30 words and not more than 100 words, describe your channel and what"
                          " your content on this channel will focus on. This could be your selling point to viewers.",
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
                              controller: txtCtrl2,
                              name: 'description',
                              minLines: 8,
                              key: _key5,
                              maxLines: 12,
                              focusNode: fNode5,
                              enableInteractiveSelection: true,
                              onTap: (){
                                fNode5.requestFocus();
                              },
                              autofocus: true,
                              style: tabData.npStyle,
                              keyboardType: TextInputType.text,
                              decoration: getDeco(
                                "About Channel",
                                onlyBottomBorder: true,
                                borderColor: prudColorTheme.lineC
                              ),
                              onChanged: (String? valueDesc){
                                if(mounted && valueDesc != null) {
                                  setState(() {
                                    description = valueDesc.trim();
                                    presentWords = tabData.countWordsInString(description);
                                    validated = validateDescription();
                                  });
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
                    saving? LoadingComponent(
                      isShimmer: false,
                      defaultSpinnerType: false,
                      size: 15,
                      spinnerColor: prudColorTheme.primary,
                    ) : (validated? prudWidgetStyle.getLongButton(
                      onPressed: saveDescription, 
                      text: "Save Changes"
                    ) : SizedBox()),
                  ],
                ),
              ),
              xLargeSpacer.height,
              xLargeSpacer.height,
            ],
          ),
        )
      ),
    );
  }
}
