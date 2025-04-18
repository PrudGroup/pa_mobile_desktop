import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/selectable_creator_component.dart';
import 'package:prudapp/components/vid_channel_component.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/models/user.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

class ViewStudioCreators extends StatefulWidget {

    const ViewStudioCreators({super.key});

    @override
    ViewStudioCreatorsState createState() => ViewStudioCreatorsState();
}

class ViewStudioCreatorsState extends State<ViewStudioCreators> {
  VidChannel? selectedChannel;
  int selectedChannelIndex = 0;
  Widget notFound = tabData.getNotFoundWidget(
    title: "No Creator",
    desc: "This channel is yet to have creators.",
    isRow: true
  );
  bool loading = false;
  List<CreatorDetail> creatorsAndDetails = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if (prudStudioNotifier.myChannels.isNotEmpty) {
        selectChannel(prudStudioNotifier.myChannels[0], 0);
      }
      await getCreators();
    });
    super.initState();
  }

  Future<void> selectChannel(VidChannel channel, int index) async {
    if (mounted) {
      setState(() {
        selectedChannel = channel;
        selectedChannelIndex = index;
        creatorsAndDetails = [];
        loading = true;
      });
    }
    if (prudStudioNotifier.channelCreators.isNotEmpty) {
      int found = prudStudioNotifier.channelCreators
          .indexWhere((ele) => ele.channel.id == selectedChannel!.id);
      if (found == -1) {
        await getCreators();
      }
    } else {
      await getCreators();
    }
    if (mounted) {
      CachedChannelCreator? details;
      tryOnly("filter", () {
        details = prudStudioNotifier.channelCreators
            .firstWhere((ele) => ele.channel.id == selectedChannel!.id);
      });
      setState(() {
        if (details != null) {
          creatorsAndDetails = details!.creators;
        }else{
          creatorsAndDetails = [];
        }
        loading = false;
      });
    }
  }

  Future<void> getCreators() async {
    await tryAsync("getCreators", () async {
      List<ContentCreator> creators =
          await prudStudioNotifier.getChannelCreators(selectedChannel!.id!);
      if (creators.isNotEmpty && mounted) {
        List<CreatorDetail> details = [];
        for (ContentCreator ctr in creators) {
          User? detail = await influencerNotifier.getInfluencerById(ctr.affId);
          if (detail != null){
            details.add(CreatorDetail(creator: ctr, detail: detail));
          }
        }
        if (details.isNotEmpty) {
          CachedChannelCreator ccc = CachedChannelCreator(
              channel: selectedChannel!, creators: details);
          prudStudioNotifier.addToCachedChannelCreators(ccc);
        }
      }
    }, error: () {
      if (mounted) setState(() => loading = false);
    });
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
            if (prudStudioNotifier.myChannels.isNotEmpty)
              PrudContainer(
                hasTitle: true,
                hasPadding: true,
                title: "Channels And Creators",
                titleBorderColor: prudColorTheme.bgC,
                titleAlignment: MainAxisAlignment.end,
                child: Column(
                  children: [
                    mediumSpacer.height,
                    PrudPanel(
                      title: "Channels",
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
                              itemBuilder: (context, index) {
                                VidChannel cha = prudStudioNotifier.myChannels[index];
                                return InkWell(
                                  onTap: () async => await selectChannel(cha, index),
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
                    PrudPanel(
                      title: "Channel Creators",
                      titleColor: prudColorTheme.iconB,
                      hasPadding: false,
                      bgColor: prudColorTheme.bgA,
                      child: Column(
                        children: [
                          mediumSpacer.height,
                          creatorsAndDetails.isNotEmpty? 
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              scrollDirection: Axis.horizontal,
                              itemCount: creatorsAndDetails.length,
                              itemBuilder: (context, index) {
                                CreatorDetail cha = creatorsAndDetails[index];
                                return SelectableCreatorComponent(
                                  borderColor: prudColorTheme.bgD,
                                  creator: cha,
                                );
                              }
                            ),
                          )
                          : loading? 
                          LoadingComponent(
                            isShimmer: false,
                            size: 20,
                            defaultSpinnerType: false,
                            spinnerColor: prudColorTheme.lineC,
                          ) : notFound,
                          spacer.height
                        ],
                      ),
                    ),
                    spacer.height,
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