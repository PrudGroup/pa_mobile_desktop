import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_image_picker.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/prud_video_picker.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/vid_channel_component.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class PromoteStudioChannel extends StatefulWidget {
  const PromoteStudioChannel({super.key});

  @override
  State<PromoteStudioChannel> createState() => _PromoteStudioChannelState();
}

class _PromoteStudioChannelState extends State<PromoteStudioChannel> {
  List<VidChannel> myChannels = prudStudioNotifier.myChannels;
  List<VidChannel> promoted = [];
  List<VidChannel> promotable = [];
  VidChannel? selectedChannelToPromote;
  VidChannel? selectedChannelToStop;
  bool shouldReset = false;
  int selectedChannelToPromoteIndex = -1;
  int selectedChannelToStopIndex = -1;
  bool promoting = false;
  bool showPromote = true;
  Set<String> selectedSegment = {"promote"};
  String? fileUrl;
  String fileType = "Image";
  Widget noChannels = tabData.getNotFoundWidget(
    title: "No Channel!",
    isRow: true,
    desc: "You presently don't have a channel that can undergo this task.",
  );

  void clearInput() {
    if (mounted) {
      setState(() {
        shouldReset = true;
        fileUrl = null;
        promoting = false;
        selectedChannelToPromoteIndex = -1;
        selectedChannelToStopIndex = -1;
        selectedChannelToPromote = null;
        selectedChannelToStop = null;
      });
    }
  }

  void setValues() {
    List<VidChannel> proChas = myChannels.where((VidChannel ele) => ele.promoted == true).toList();
    List<VidChannel> unproChas = myChannels.where((VidChannel ele) => ele.promoted == false).toList();
    if (mounted) {
      setState(() {
        if (proChas.isNotEmpty) promoted = proChas;
        if (unproChas.isNotEmpty) promotable = unproChas;
      });
    }
  }

  void onDurationGotten(PrudVidDuration duration){
    debugPrint("Video Duration: ${duration.toJson()}");
  }

  void setVideoFile(String? url) {
    if (mounted && url != null) {
      setState(() => fileUrl = url);
    }
  }

  void setVideoProgress(SaveVideoResponse progress){
    debugPrint("Video Upload Progress: ${progress.toJson()}");
  }

  void segmentChanged(Set<String> value) {
    if (mounted) {
      setState(() {
        selectedSegment = value;
        if (value.contains("promote")) {
          showPromote = true;
        } else {
          showPromote = false;
        }
      });
    }
  }

  @override
  void initState() {
    setValues();
    super.initState();
    prudStudioNotifier.addListener(() {
      if (mounted) {
        setState(() {
          myChannels = prudStudioNotifier.myChannels;
        });
        setValues();
      }
    });
  }

  Future<void> selectChannel(
      VidChannel channel, int index, bool promote) async {
    if (mounted) {
      setState(() {
        if (promote) {
          selectedChannelToPromote = channel;
          selectedChannelToPromoteIndex = index;
        } else {
          selectedChannelToStop = channel;
          selectedChannelToStopIndex = index;
        }
      });
    }
    String wrd = promote ? 'Promote' : 'Unpromote';
    Alert(
      context: context,
      style: myStorage.alertStyle,
      type: AlertType.warning,
      title: "$wrd Channel",
      desc:
          "You are about to $wrd a channel(${channel.channelName}). Should this be done?",
      buttons: [
        DialogButton(
          onPressed: () async => await startProcess(channel, promote),
          color: prudColorTheme.primary,
          radius: BorderRadius.zero,
          child: promoting
              ? LoadingComponent(
                  isShimmer: false,
                  size: 15,
                  spinnerColor: prudColorTheme.bgC,
                )
              : Translate(
                  text: wrd,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: prudColorTheme.buttonC,
          radius: BorderRadius.zero,
          child: const Translate(
            text: "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }

  Future<void> startProcess(VidChannel channel, bool promote) async {
    if (mounted) setState(() => promoting = true);
    await tryAsync("startProcess", () async {
      bool succeeded = await prudStudioNotifier.promoteChannel(channel, promote, fileType, fileUrl);
      if (succeeded) {
        prudStudioNotifier.updateChannelPromoteStatus(channel, promote);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(
              text: "Succeeded",
              style: prudWidgetStyle.btnTextStyle.copyWith(
                color: prudColorTheme.bgA,
              ),
            ),
          ));
          clearInput();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(
              text: "Task failed",
              style: prudWidgetStyle.btnTextStyle.copyWith(
                color: prudColorTheme.bgA,
              ),
            ),
            backgroundColor: prudColorTheme.primary,
          ));
        }
      }
    }, error: () {
      if (mounted) {
        setState(() => promoting = false);
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: Column(
        children: [
          SegmentedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.error: Colors.blueAccent,
                WidgetState.hovered: prudColorTheme.bgC,
                WidgetState.focused: prudColorTheme.bgC,
                WidgetState.disabled: prudColorTheme.lineC,
                WidgetState.selected: prudColorTheme.primary,
                WidgetState.pressed: prudColorTheme.primary,
              }),
              foregroundColor:
                  WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.error: Colors.blueAccent,
                WidgetState.hovered: prudColorTheme.secondary,
                WidgetState.focused: prudColorTheme.secondary,
                WidgetState.disabled: prudColorTheme.secondary,
                WidgetState.selected: prudColorTheme.bgA,
                WidgetState.pressed: prudColorTheme.bgA,
              }),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
              side: WidgetStateProperty.all(BorderSide(
                color: prudColorTheme.textD,
                width: 2,
              )),
            ),
            selected: selectedSegment,
            selectedIcon: Icon(Icons.check),
            onSelectionChanged: segmentChanged,
            segments: [
              ButtonSegment(
                  value: "promote",
                  label: Translate(text: "Promote"),
                  icon: ImageIcon(AssetImage(prudImages.videoAd))),
              ButtonSegment(
                  value: "unpromote",
                  label: Translate(text: "Unpromote"),
                  icon: ImageIcon(AssetImage(prudImages.smartTv1))),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: BouncingScrollPhysics(),
              child: showPromote
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        spacer.height,
                        Translate(
                          text:
                              "Waooh! Do you know you can promote your channel without having to"
                              " pay for ads downtime? You can promote your channel and only pay when you"
                              " actually get conversions in terms of video viewing and membership. We"
                              " only charge 30% of what you make from promoting your channel. Promoted channels are"
                              " excluded from other charges. Promote your channel(s) today. If the file is a video, it must not be more than 3 minutes long.",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.textB,
                          ),
                          align: TextAlign.center,
                        ),
                        PrudContainer(
                            hasTitle: true,
                            hasPadding: true,
                            title: "Select Ads Type",
                            titleBorderColor: prudColorTheme.bgC,
                            titleAlignment: MainAxisAlignment.end,
                            child: Column(
                              children: [
                                mediumSpacer.height,
                                FormBuilderChoiceChip<String>(
                                  decoration: getDeco("Ads Type"),
                                  backgroundColor: prudColorTheme.bgA,
                                  disabledColor: prudColorTheme.bgD,
                                  spacing: spacer.width.width!,
                                  shape: prudWidgetStyle.choiceChipShape,
                                  selectedColor: prudColorTheme.primary,
                                  onChanged: (String? selected) async {
                                    await tryAsync("fileTypeSelector",
                                        () async {
                                      if (mounted && selected != null) {
                                        setState(() {
                                          fileType = selected;
                                        });
                                      }
                                    });
                                  },
                                  name: "fileType",
                                  initialValue: fileType,
                                  options: ["Image", "Video"].map((String ele) {
                                    return FormBuilderChipOption(
                                      value: ele,
                                      child: Translate(
                                        text: ele,
                                        style: prudWidgetStyle.btnTextStyle
                                            .copyWith(
                                                color: ele == fileType
                                                    ? prudColorTheme.bgA
                                                    : prudColorTheme.primary),
                                        align: TextAlign.center,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                spacer.height,
                              ],
                            ),
                          ),
                          if(prudStudioNotifier.studio != null && fileType != "Image") PrudVideoPicker(
                            onDurationGotten: onDurationGotten,
                            isShort: true,
                            onSaveToCloud: setVideoFile,
                            onProgressChanged: setVideoProgress,
                            destination: "studio/${prudStudioNotifier.studio!.id}/images/ads",
                            saveToCloud: true,
                            alreadyUploaded: fileUrl != null,
                          ),
                          if(prudStudioNotifier.studio != null && fileType == "Image") PrudImagePicker(
                            destination: "studio/${prudStudioNotifier.studio!.id}/images/ads",
                            saveToCloud: true,
                            reset: shouldReset,
                            onSaveToCloud: (String? url) {
                              tryOnly("Picker onSaveToCloud", () {
                                if (mounted && url != null) {
                                  setState(() => fileUrl = url);
                                }
                              });
                            },
                            onError: (err) {
                              debugPrint("Picker Error: $err");
                            },
                          ),
                        promotable.isNotEmpty && fileUrl != null
                            ? PrudContainer(
                                hasTitle: true,
                                hasPadding: true,
                                title: "Promote Channel",
                                titleBorderColor: prudColorTheme.bgC,
                                titleAlignment: MainAxisAlignment.end,
                                child: Column(
                                  children: [
                                    mediumSpacer.height,
                                    PrudPanel(
                                      title: "Select Channel To Promote",
                                      titleColor: prudColorTheme.iconB,
                                      hasPadding: false,
                                      bgColor: prudColorTheme.bgA,
                                      child: Column(
                                        children: [
                                          mediumSpacer.height,
                                          SizedBox(
                                            height: 120,
                                            child: ListView.builder(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: promotable.length,
                                                itemBuilder: (context, index) {
                                                  VidChannel cha =
                                                      promotable[index];
                                                  return InkWell(
                                                    onTap: () async =>
                                                        await selectChannel(
                                                            cha, index, true),
                                                    child:
                                                        SelectableChannelComponent(
                                                      borderColor:
                                                          selectedChannelToPromoteIndex == index
                                                              ? prudColorTheme
                                                                  .primary
                                                              : prudColorTheme
                                                                  .bgD,
                                                      channel: cha,
                                                    ),
                                                  );
                                                }),
                                          ),
                                          spacer.height
                                        ],
                                      ),
                                    ),
                                    spacer.height,
                                  ],
                                ),
                              )
                            : noChannels,
                        xLargeSpacer.height,
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        spacer.height,
                        Translate(
                          text:
                              "Stoping promotions on a channel is as easy as clicking below.",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.textB,
                          ),
                          align: TextAlign.center,
                        ),
                        promoted.isNotEmpty
                            ? PrudContainer(
                                hasTitle: true,
                                hasPadding: true,
                                title: "Stop Channel Promoting",
                                titleBorderColor: prudColorTheme.bgC,
                                titleAlignment: MainAxisAlignment.end,
                                child: Column(
                                  children: [
                                    mediumSpacer.height,
                                    PrudPanel(
                                      title: "Select Channel To Stop",
                                      titleColor: prudColorTheme.iconB,
                                      hasPadding: false,
                                      bgColor: prudColorTheme.bgA,
                                      child: Column(
                                        children: [
                                          mediumSpacer.height,
                                          SizedBox(
                                            height: 120,
                                            child: ListView.builder(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: promoted.length,
                                                itemBuilder: (context, index) {
                                                  VidChannel cha =
                                                      promoted[index];
                                                  return InkWell(
                                                    onTap: () async =>
                                                        await selectChannel(
                                                            cha, index, false),
                                                    child:
                                                        SelectableChannelComponent(
                                                      borderColor:
                                                          selectedChannelToStopIndex == index
                                                              ? prudColorTheme
                                                                  .primary
                                                              : prudColorTheme
                                                                  .bgD,
                                                      channel: cha,
                                                    ),
                                                  );
                                                }),
                                          ),
                                          spacer.height
                                        ],
                                      ),
                                    ),
                                    spacer.height,
                                  ],
                                ),
                              )
                            : noChannels,
                        xLargeSpacer.height,
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }
}
