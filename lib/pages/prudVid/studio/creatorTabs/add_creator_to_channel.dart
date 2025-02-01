import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/channel_search_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/vid_channel_component.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../pageViews/channel_view.dart';

class AddCreatorToChannel extends StatefulWidget{

  const AddCreatorToChannel({super.key, });

  @override
  AddCreatorToChannelState createState() => AddCreatorToChannelState();
}


class AddCreatorToChannelState extends State<AddCreatorToChannel>{

  bool adding = false;
  String? creatorId;
  VidChannel? selectedChannel;
  int selectedChannelIndex = 0;
  int selectedRequestChannelIndex = 0;
  int selectedSeekingChannelIndex = 0;
  List<VidChannel> searchResults = [];
  List<VidChannel> seekingSearchResults = [];
  TextEditingController txtCtrl = TextEditingController();
  Widget notFound = tabData.getNotFoundWidget(
    title: "Channels Not Found", desc: "Your search got no results. Change your keyword and try again.",
    isRow: true
  );
  Widget notSuggestFound = tabData.getNotFoundWidget(
    title: "No Suggestions", desc: "No channel(s) is/are presently seeking creators.", isRow: true
  );
  String? filterValue;
  String? searchTerm;
  int offset = 0;
  int seekingOffset = 0;
  bool loading = false;
  bool seeking = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getMoreSeekingSearchResults();
    });
    super.initState();
  }

  void refreshData(){
    if(mounted){
      setState(() {
        creatorId = null;
        selectedChannel = null;
        adding = false;
        selectedChannelIndex = 0;
      });
      txtCtrl.text = "";
    }
  }

  void setResult(List<VidChannel> result, List<VidChannel> seekingResult, String filterValue, String searchText){
    List<VidChannel> channels = [];
    if(result.isNotEmpty && mounted){
      channels.addAll(result);
      setState(() {
        searchResults = channels;
        searchTerm = searchText;
        filterValue = filterValue;
      });
    }
    if(seekingResult.isNotEmpty && mounted) setState(() => seekingSearchResults = seekingResult);
  }


  Future<void> addCreator() async {
    await tryAsync("addCreator", () async {
      if(mounted) setState(() => adding = true);
      bool added = await prudStudioNotifier.addCreatorToChannel(creatorId!, selectedChannel!.id!);
      if(mounted && added){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Translate(text: "Added Successfully"),
        ));
        refreshData();
      }else{
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Task failed", style: prudWidgetStyle.btnTextStyle.copyWith(
              color: prudColorTheme.bgA,
            ),),
            backgroundColor: prudColorTheme.primary,
          ));
        }
      }
      if(mounted) setState(() => adding = false);
    }, error: (){
      if(mounted) setState(() => adding = false);
    });
  }


  void selectChannel(VidChannel channel, int index){
    if(mounted){
      setState((){
        selectedChannel = channel;
        selectedChannelIndex = index;
      });
    }
  }


  Future<void> getMoreSearchResults() async {
    if(searchTerm != null && filterValue != null){
      await tryAsync("getMoreSearchResults", () async {
        if(mounted) setState(() => loading = true);
        List<VidChannel> results = await prudStudioNotifier.searchForChannels(
          filterValue!, searchTerm, 20, offset
        );
        if(results.isNotEmpty) {
          setState(() { 
            offset += results.length;
            searchResults.addAll(results);
            loading = false;
          });
        }else{
          if(mounted) setState(() => loading = false);
        }
      }, 
      error: (){
        if(mounted) setState(() => loading = false);
      });
    }
  }

  Future<void> getMoreSeekingSearchResults() async {
    String dFilterValue = filterValue?? "any";
    String dSearchTerm = searchTerm?? "any";
    await tryAsync("getMoreSeekingSearchResults", () async {
      if(mounted) setState(() => seeking = true);
      List<VidChannel> results = await prudStudioNotifier.searchForChannels(
        dFilterValue, dSearchTerm, 20, seekingOffset, onlySeeking: true
      );
      if(results.isNotEmpty) {
        setState(() { 
          seekingOffset += results.length;
          seekingSearchResults.addAll(results);
          seeking = false;
        });
      }else{
        if(mounted) setState(() => seeking = false);
      }
    }, 
    error: (){
      if(mounted) setState(() => seeking = false);
    });
  }

  void openChannel(VidChannel channel, int index){
    if(mounted){
      setState((){
        selectedRequestChannelIndex = index;
      });
      iCloud.goto(context, ChannelView(channel: channel, isOwner: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            if(prudStudioNotifier.myChannels.isNotEmpty) PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Add Creator To Channels",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    name: 'creatorId',
                    controller: txtCtrl,
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Creator's Id",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted && value != null) setState(() => creatorId = value.trim());
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(30),
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                  PrudPanel(
                    title: "Select Channel",
                    titleColor: prudColorTheme.iconB,
                    hasPadding: false,
                    bgColor: prudColorTheme.bgA,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            scrollDirection: Axis.horizontal,
                            itemCount: prudStudioNotifier.myChannels.length,
                            itemBuilder: (context, index){
                              VidChannel cha = prudStudioNotifier.myChannels[index];
                              return InkWell(
                                onTap: () => selectChannel(cha, index),
                                child: SelectableChannelComponent(
                                  borderColor: selectedChannelIndex == index? prudColorTheme.primary : prudColorTheme.bgD,
                                  channel: cha,
                                ),
                              );
                            }
                          ),
                        ),
                        spacer.height
                      ],
                    ),
                  ),
                  spacer.height,
                  creatorId != null && selectedChannel != null? (
                    adding? LoadingComponent(
                      isShimmer: false,
                      defaultSpinnerType: false,
                      size: 30,
                      spinnerColor: prudColorTheme.primary,
                    ) : prudWidgetStyle.getLongButton(
                      onPressed: addCreator, 
                      text: "Add Creator",
                      shape: 1,
                    )
                  ) : SizedBox()
                ],
              )
            ),
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Suggested Channels",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  seekingSearchResults.isNotEmpty? 
                  PrudPanel(
                    title: "Select Channel",
                    titleColor: prudColorTheme.iconB,
                    hasPadding: false,
                    bgColor: prudColorTheme.bgA,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            scrollDirection: Axis.horizontal,
                            itemCount: seekingSearchResults.length,
                            itemBuilder: (context, index) {
                              VidChannel cha = seekingSearchResults[index];
                              return InkWell(
                                onTap: () => openChannel(cha, index),
                                child: SelectableChannelComponent(
                                  borderColor: selectedSeekingChannelIndex == index? prudColorTheme.primary : prudColorTheme.bgD,
                                  channel: cha,
                                ),
                              );
                            }
                          ),
                        ),
                        spacer.height
                      ],
                    ),
                  ) 
                  : 
                  seeking? LoadingComponent(
                    isShimmer: false,
                    defaultSpinnerType: false,
                    spinnerColor: prudColorTheme.lineC,
                    size: 20,
                  ) : notSuggestFound,
                ],
              )
            ),
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Send Creator Request",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  ChannelSearchComponent(onResultReady: setResult),
                  spacer.height,
                  searchResults.isNotEmpty? PrudPanel(
                    title: "Select Channel",
                    titleColor: prudColorTheme.iconB,
                    hasPadding: false,
                    bgColor: prudColorTheme.bgA,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            scrollDirection: Axis.horizontal,
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              VidChannel cha = searchResults[index];
                              return InkWell(
                                onTap: () => openChannel(cha, index),
                                child: SelectableChannelComponent(
                                  borderColor: selectedRequestChannelIndex == index? prudColorTheme.primary : prudColorTheme.bgD,
                                  channel: cha,
                                ),
                              );
                            }
                          ),
                        ),
                        spacer.height
                      ],
                    ),
                  ) : notFound,
                ],
              )
            ),
            xLargeSpacer.height,
          ],
        ),
      ),
    );
  }

}