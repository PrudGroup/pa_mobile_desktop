import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:prudapp/components/inner_menu.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/vid_channel_component.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_tabs/broadcasts.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_tabs/channel_ads.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_tabs/channel_info.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_tabs/channel_memberships.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_tabs/creator_channel_requests.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_tabs/lives.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_tabs/playlists.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_tabs/videos.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/settings_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../models/prud_vid.dart';

class ChannelView extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;

  const ChannelView({super.key, required this.channel, required this.isOwner});

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {
  List<InnerMenuItem> tabMenus = [];
  late VidChannel channel;
  bool loading = false;
  final GlobalKey<InnerMenuState> _key = GlobalKey();
  RatingSearchResult hasVotedB4 = RatingSearchResult(index: -1);
  bool isCreator = prudStudioNotifier.amACreator != null;

  void moveTo(int index) {
    if (_key.currentState != null) {
      _key.currentState!
          .changeWidget(_key.currentState!.widget.menus[index].menu, index);
    }
  }

  Future<void> rateNow(double rate) async {
    Map<String, dynamic> data = {};
    if (hasVotedB4.canVote) {
      if (hasVotedB4.index != -1 && hasVotedB4.ratedObject != null) {
        data = hasVotedB4.ratedObject!.toRateSchema(rate.toInt());
      } else {
        data = {
          "hasRated": false,
          "lastRate": 0,
          "currentRate": rate.toInt(),
        };
      }
      VidChannel? result = await tryAsync("rateNow", () async {
        if (mounted) setState(() => loading = true);
        return await prudStudioNotifier.voteAnObject(widget.channel.id!, VoteObjectType.channel, data);
      });
      if (result != null) {
        if (mounted) {
          DateTime now = DateTime.now();
          RatedObject ratedChannel = RatedObject(
            id: result.id!,
            vote: rate.toInt(),
            monthRated: now.month,
            yearRated: now.year,
          );
          await prudStudioNotifier.updateObjectRating(
            ratedChannel, hasVotedB4.index != -1, hasVotedB4.index
          );
          setState(() {
            channel = result;
            loading = false;
          });
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Translate(text: "Rated Successfully"),
            ));
          }
        }
      } else {
        if (mounted) {
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Action Failed"),
            backgroundColor: prudColorTheme.error,
          ));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "You can't Vote"),
          backgroundColor: prudColorTheme.error,
        ));
      }
    }
  }

  void setMenu(VidChannel cha){
    if (mounted) {
      setState(() {
        channel = cha;
        hasVotedB4 = prudStudioNotifier.checkIfVotedObject(widget.channel.id!);
        tabMenus = [
          InnerMenuItem(
            icon: Icons.info_sharp,
            title: "Info",
            menu: ChannelInfo(channel: channel, isOwner: widget.isOwner),
          ),
          InnerMenuItem(
            imageIcon: prudImages.movie,
            title: "Videos",
            menu: ChannelVideos(channel: channel, isOwner: widget.isOwner)
          ),
          InnerMenuItem(
            imageIcon: prudImages.playlist,
            title: "Playlist",
            menu: ChannelPlaylists(channel: channel, isOwner: widget.isOwner)
          ),
          InnerMenuItem(
              imageIcon: prudImages.videoMembership,
              title: "Membership",
              menu: ChannelMemberships(
                  channel: channel, isOwner: widget.isOwner)),
          InnerMenuItem(
              imageIcon: prudImages.announceMsg,
              title: "Broadcast",
              menu: ChannelBroadcasts(
                  channel: channel, isOwner: widget.isOwner)),
          InnerMenuItem(
              imageIcon: prudImages.live,
              title: "Live",
              menu: ChannelLives(
                  channel: channel, isOwner: widget.isOwner)),
          InnerMenuItem(
              imageIcon: prudImages.operators,
              title: "Requests",
              menu: CreatorChannelRequests(
                  channel: channel, isOwner: widget.isOwner)),
          InnerMenuItem(
              imageIcon: prudImages.announceMsgMega,
              title: "Ads & Analysis",
              menu: ChannelAds(
                  channel: channel, isOwner: widget.isOwner)),
        ];
      });
    }
  }

  Future<void> checkIfIsChannelCreator() async {
    if(prudStudioNotifier.amACreator != null){
      if(prudStudioNotifier.affiliatedChannels.isNotEmpty){
        if(mounted) {
          setState(() {
            isCreator = prudStudioNotifier.affiliatedChannels.any((ch) => ch.id == widget.channel.id);
          });
        }
      }else{
        await prudStudioNotifier.getAffiliatedChannels();
        if(prudStudioNotifier.affiliatedChannels.isNotEmpty){
          if(mounted) {
            setState(() {
              isCreator = prudStudioNotifier.affiliatedChannels.any((ch) => ch.id == widget.channel.id);
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    setMenu(widget.channel);
    localSettings.updateLastRoute(Uri(path: '/channels/${widget.channel.id}').toString());
    localSettings.updateLastRouteData({"isOwner": widget.isOwner, "channel": widget.channel.toJson()});
    super.initState();
    Future.delayed(Duration.zero, () async {
      await checkIfIsChannelCreator();
    });
    prudStudioNotifier.addListener(() {
      int index = prudStudioNotifier.myChannels.indexWhere((ch) => ch.id == channel.id);
      if (index != -1) setMenu(prudStudioNotifier.myChannels[index]);
      if (mounted) {
        setState(() {
          hasVotedB4 = prudStudioNotifier.checkIfVotedObject(channel.id!);
        });
      }
    });
  }

  @override
  void dispose() {
    localSettings.updateLastRoute(Uri(path: '/channels/${channel.id}').toString());
    localSettings.updateLastRouteData({"isOwner": widget.isOwner, "channel": channel.toJson()});
    prudStudioNotifier.removeListener(() {});
    super.dispose();
  }

  Future<void> openAddVideo() async {
    if(mounted && isCreator){
      if(prudStudioNotifier.newVideo.channelId == widget.channel.id){
        prudStudioNotifier.newVideo.channelId = widget.channel.id;
        await prudStudioNotifier.saveNewVideoData();
        if(mounted) iCloud.goto(context, AddVideo(channel: widget.channel, creatorId: prudStudioNotifier.amACreator!.id!,));
      }else{
        Alert(context: context, style: myStorage.alertStyle,
          type: AlertType.warning,title: "Unfinished Upload",
          desc: "You have an unfinished upload on another channel. Would you want to continue the upload or start a new upload on the current channel(${widget.channel.channelName}).",
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.pop(context);
                iCloud.goto(context, AddVideo(channel: widget.channel, creatorId: prudStudioNotifier.amACreator!.id!,));
              },
              color: prudColorTheme.buttonC,
              radius: BorderRadius.circular(20),
              child: const Translate(
                text:"Continue",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            DialogButton(
              onPressed: () async {
                if(mounted) Navigator.pop(context);
                prudStudioNotifier.newVideo = PendingNewVideo(
                  thriller: VideoThriller(
                    videoId: "", videoUrl: ""
                  ),
                  channelId: widget.channel.id,
                );
                await prudStudioNotifier.saveNewVideoData();
                if(mounted) iCloud.goto(context, AddVideo(channel: widget.channel, creatorId: prudStudioNotifier.amACreator!.id!,));
              },
              color: prudColorTheme.primary,
              radius: BorderRadius.circular(20),
              child: const Translate(
                text:"Restart",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double rating = channel.getRating();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: prudColorTheme.bgC,
      body: Column(
        children: [
          Stack(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 150,
                    child: PrudNetworkImage(
                      width: double.maxFinite,
                      url: channel.displayScreen,
                      authorizeUrl: true,
                      errorWidget: Center(child: Translate(text: "Unable To Display (Network Issue).")),
                    ),
                  ),
                  if(widget.isOwner && isCreator) Padding(
                    padding: const EdgeInsets.only(top: 100, bottom: 20, right: 10),
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton.filled(
                          onPressed: openAddVideo, 
                          iconSize: 25,
                          tooltip: "Add Video",
                          icon: Icon(Icons.add)
                        ),
                      ]
                    )
                  ),
                ]
              ),
              Row(
                spacing: 15,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80, left: 10),
                    child: SelectableChannelComponent(
                      channel: channel,
                      borderColor: prudColorTheme.bgC,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 120, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              loading
                                  ? LoadingComponent(
                                      isShimmer: false,
                                      defaultSpinnerType: false,
                                      size: 15,
                                      spinnerColor: prudColorTheme.warning,
                                    )
                                  : GFRating(
                                      onChanged: rateNow,
                                      value: rating,
                                      allowHalfRating: false,
                                      size: 30,
                                    ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Translate(
                                        text: tabData.getRateInterpretation(rating),
                                        style: prudWidgetStyle.btnTextStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: prudColorTheme.success
                                        ),
                                      ),
                                      Text(
                                        ".",
                                        style: prudWidgetStyle.typedTextStyle.copyWith(
                                          color: prudColorTheme.lineC,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 40
                                        ),
                                      ),
                                      Row(
                                        spacing: 2,
                                        children: [
                                          Text(
                                            tabData.getFormattedNumber(channel.voters),
                                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                              color: prudColorTheme.secondary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14
                                            ),
                                          ),
                                          Text(
                                            "Reviews",
                                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                              color: prudColorTheme.iconB,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )),
                            ],
                          ),
                          FittedBox(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  "$rating",
                                  style: prudWidgetStyle.hintStyle.copyWith(
                                    fontSize: 35,
                                    fontWeight: FontWeight.w700,
                                    color: prudColorTheme.secondary,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Text(
                                    tabData.toTitleCase(channel.category),
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: prudColorTheme.iconB,
                                    ),
                                  ),
                                )
                              ]
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Expanded(
            child: InnerMenu(
                key: _key,
                menus: tabMenus,
                type: 1,
                hasIcon: true,
                canSwipe: true),
          ),
        ],
      ),
    );
  }
}
