import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/vid_channel_component.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

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

  void refreshData(){
    if(mounted){
      setState(() {
        creatorId = null;
        selectedChannel = null;
        adding = false;
        selectedChannelIndex = 0;
      });
    }
  }


  Future<void> addCreator() async {
    await tryAsync("addCreator", () async {
      if(mounted) setState(() => adding = true);
      bool added = await prudStudioNotifier.addCreatorToChannel(creatorId!, selectedChannel!.id!);
      if(mounted && added){
        iCloud.showSnackBar("Added Successfully", context, type: 2);
        refreshData();
      }else{
        if(mounted) iCloud.showSnackBar("Unable To Add!", context, type: 1);
      }
      if(mounted) setState(() => adding = false);
    }, error: (){
      if(mounted) setState(() => adding = false);
    });
  }


  void selectChannel(VidChannel channel, int index){
    if(mounted){
      selectedChannel = channel;
      selectedChannelIndex = index;
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
                    initialValue: '',
                    name: 'creatorId',
                    autofocus: true,
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
                            padding: const EdgeInsets.all(5),
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
              title: "Send Creator Request",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
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
          ],
        ),
      ),
    );
  }

}