import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:prudapp/components/channel_logo.dart';
import 'package:prudapp/components/multi_player/flick_multi_manager.dart';
import 'package:prudapp/components/multi_player/flick_multi_player.dart';
import 'package:prudapp/components/point_divider.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/video_loading.dart';
import 'package:prudapp/models/aff_link.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/tabs/views/add_report_or_claim.dart';
import 'package:prudapp/pages/prudVid/thriller_views/thriller_detail.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/prudio_client.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:share_plus/share_plus.dart';

class PrudVideoComponent extends StatefulWidget{
  final ChannelVideo? video;
  final VidChannel? channel;
  final String? thrillerId;
  final VideoThriller? thriller;
  final bool isOwner;
  final String? affLinkId;
  final FlickMultiManager flickMultiManager;
  final bool noBorderRadius;
  final bool isPortrait;

  const PrudVideoComponent({
    super.key, this.video, required this.isOwner,
    this.thrillerId, this.affLinkId, this.thriller,
    this.isPortrait = true,
    this.channel, required this.flickMultiManager, this.noBorderRadius = true,
  });

  @override
  PrudVideoComponentState createState() => PrudVideoComponentState();
}

class PrudVideoComponentState extends State<PrudVideoComponent> {
  VideoThriller? thriller;
  ChannelVideo? video;
  bool loading = false;
  bool allVidsReady = false;
  String authorizedUrl = "";
  VidChannel? channel;
  int totalViews = 0;
  String uploadedWhen = "";
  double rating = 0;
  bool sharing = false;
  bool channelIsLive = false;
  int totalMembers = 0;

  void watchLater() {
    tryOnly("watchLater", (){
      if(video != null && video!.id != null) prudVidNotifier.addToWatchLater(video!.id!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Translate(text: "Done")
      ));
    });
  }

  void addToPlaylist(){
    tryOnly("addToPlaylist", (){
      if(video != null && video!.id != null) prudVidNotifier.addToPlaylist(video!.id!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Translate(text: "Added")
      ));
    });
  }

  void listenToThrillerFromSocket(){
    prudSocket.on("live_changed", (json){
      if(json != null && json["id"] == channel!.id){
        if(mounted){
          setState(() {
            channel!.presentlyLive = json["isLive"];
            channelIsLive = json["isLive"];
          });
        }
      }
    });

    prudSocket.on("video_views_changed", (json){
      if(json != null && json["id"] == video!.id){
        if(mounted){
          setState(() {
            video!.memberViews = json["memberViews"];
            video!.nonMemberViews = json["nonMemberViews"];
          });
        }
      }
    });

    prudSocket.on("channel_members_changed", (json){
      if(json != null && json["id"] == channel!.id){
        if(mounted){
          setState(() {
            totalMembers = json["memberCount"];
          });
        }
      }
    });
  }

  Future<void> share() async {
    await tryAsync("share", () async {
      if(mounted) setState(() => sharing = true);
      String category = "thriller";
      String categoryId = thriller!.id!;
      String target = "$prudWeb/$category/$categoryId";
      AffLink? link = await influencerNotifier.createAffLinks(target, category, categoryId);
      if(link != null){
        String msg = "If you haven't watch this clip...sorry! Life has left you behind! Watch now and come back to life. ";
        final result = await Share.share("$msg ${link.fullShortUrl}", subject: video!.title);
        if (result.status == ShareResultStatus.success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Shared"),
          ));
        }
      }else{
        if(mounted){
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Share")
          ));
        }
      }
    });
  }

  void notInterested(){
    tryOnly("notInterested", (){
      if(video != null && video!.id != null) prudVidNotifier.addToNotInterested(video!.id!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Translate(text: "Noted")
      ));
    });
  }

  void dontRecommendChannel(){
    tryOnly("dontRecommendChannel", (){
      if(channel != null && channel!.id != null) prudVidNotifier.addToDontRecommend(channel!.id!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Translate(text: "Noted")
      ));
    });
  }

  void report(){
    tryOnly("report", (){
      Navigator.pop(context);
      if(video != null) iCloud.goto(context, AddReportOrClaim(video: video!,));
    });
  }

  Future<void> getThriller() async {
    await tryAsync("getThriller", () async {
      if(mounted) setState(() => loading = true);
      VideoThriller? dThrill = widget.thrillerId != null? await prudStudioNotifier.getThrillerById(thrillId: widget.thrillerId!) 
        : await prudStudioNotifier.getThrillerByVideoId(videoId: widget.video!.id!);
      if(mounted) {
        setState(() {
          thriller = dThrill;
          loading = false;
        });
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }


  Future<void> getVideo() async {
    if(thriller != null) {
      if(mounted) setState(() => loading = true);
      await tryAsync("getVideo", () async {
        if(mounted) setState(() => loading = true);
        ChannelVideo? vid = await prudStudioNotifier.getVideoById(thriller!.videoId);
        if(mounted) {
          setState(() {
            video = vid;
            loading = false;
          });
        }
      }, error: (){
        if(mounted) setState(() => loading = false);
      });
    }
  }


  Future<void> getChannel() async {
    if(widget.channel == null) {
      if(video != null){
        if(video!.channel != null){
          if(mounted) setState(() => channel = video!.channel);
        }else{
          await tryAsync("getChannel", () async {
            if(mounted) setState(() => loading = true);
            VidChannel? cha = await prudStudioNotifier.getChannelById(video!.channelId);
            if(mounted) {
              setState(() {
                channel = cha;
                if(cha != null) {
                  totalMembers = cha.totalMembers;
                  channelIsLive = cha.presentlyLive;
                }
                loading = false;
              });
            }
          }, error: (){
            if(mounted) setState(() => loading = false);
          });
        }
      }
    }else{
      if(mounted) setState(() => channel = widget.channel);
    }
  }


  void saveThrillerToCache(){
    if(channel != null && video != null && thriller != null){
      prudStudioNotifier.updateVideoThrillerToVisitedChannels(
        channel!.id!, thriller!
      );
    }
  }


  @override
  void dispose(){
    super.dispose();
  }
  
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(widget.thriller == null) {
        await getThriller();
      }else{
        if(mounted) setState(() => thriller ??= widget.thriller);
      }
      if(widget.video == null) {
        await getVideo();
      }else{
        if(mounted) setState(() => video ??= widget.video);
      }
      await getChannel();
      if(mounted){
        setState(() {
          if(thriller != null) authorizedUrl = iCloud.authorizeDownloadUrl(thriller!.videoUrl);
          debugPrint("channel_id: ${channel?.id}");
          if(video != null) {
            totalViews = video!.nonMemberViews + video!.memberViews;
            uploadedWhen = myStorage.ago(dDate: video!.uploadedAt, isShort: false);
            rating = video!.getRating();
          }
          allVidsReady = true;
        });
      }
    });
    super.initState();
    saveThrillerToCache();
    listenToThrillerFromSocket();
  }

  void showMenu(){
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: prudColorTheme.bgE,
      elevation: 5,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          width: double.maxFinite,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: prudColorTheme.bgF
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              InkWell(
                onTap: watchLater,
                child: Row(
                  children: [
                    Icon(
                      Icons.watch_later_outlined, 
                      size: 25,
                      color: prudColorTheme.lineC,
                      semanticLabel: "Watch later",
                    ),
                    mediumSpacer.width,
                    Translate(
                      text: "Watch Later",
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        color: prudColorTheme.lineC,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 1.5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      align: TextAlign.left,
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: addToPlaylist,
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_add_outlined, 
                      size: 25,
                      color: prudColorTheme.lineC,
                      semanticLabel: "Save To Current Playlist",
                    ),
                    mediumSpacer.width,
                    Translate(
                      text: "Save To Current Playlist",
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        color: prudColorTheme.lineC,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 1.5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      align: TextAlign.left,
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: share,
                child: Row(
                  children: [
                    Icon(
                      Icons.share_outlined, 
                      size: 25,
                      color: prudColorTheme.lineC,
                      semanticLabel: "Share & get paid",
                    ),
                    mediumSpacer.width,
                    Translate(
                      text: "Share & Get Paid",
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        color: prudColorTheme.lineC,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 1.5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      align: TextAlign.left,
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: notInterested,
                child: Row(
                  children: [
                    Icon(
                      Icons.remove_moderator_outlined, 
                      size: 25,
                      color: prudColorTheme.lineC,
                      semanticLabel: "Not Interested",
                    ),
                    mediumSpacer.width,
                    Translate(
                      text: "Not Interested",
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        color: prudColorTheme.lineC,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 1.5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      align: TextAlign.left,
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: dontRecommendChannel,
                child: Row(
                  children: [
                    Icon(
                      Icons.remove_from_queue_outlined, 
                      size: 25,
                      color: prudColorTheme.lineC,
                      semanticLabel: "Don't Recommend Channel",
                    ),
                    mediumSpacer.width,
                    Translate(
                      text: "Don't Recommend Channel",
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        color: prudColorTheme.lineC,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 1.5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      align: TextAlign.left,
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: report,
                child: Row(
                  children: [
                    Icon(
                      Icons.flag_outlined, 
                      size: 25,
                      color: prudColorTheme.lineC,
                      semanticLabel: "Report Channel",
                    ),
                    mediumSpacer.width,
                    Translate(
                      text: "Report/Claim",
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        color: prudColorTheme.lineC,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 1.5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      align: TextAlign.left,
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void viewThriller(){
    if(mounted) {
      iCloud.goto(context, ThrillerDetail(
        thriller: thriller,
        video: video,
        thrillerId: thriller?.id,
        referralLinkId: widget.affLinkId,
        isOwner: widget.isOwner,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius rad = widget.noBorderRadius? BorderRadius.zero : BorderRadius.circular(20.0);
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: widget.isPortrait? BoxConstraints(
        minHeight: 250,
      ) : BoxConstraints(
        maxWidth: 500,
      ),
      decoration: BoxDecoration(
        color: prudColorTheme.secondary,
        border: Border(
          bottom: BorderSide(
            color: prudColorTheme.lineC, 
            width: 3,
          )
        ),
        borderRadius: rad
      ),
      child: ClipRRect(
        borderRadius: rad,
        child: allVidsReady == true? Column(
          children: [
            InkWell(
              onTap: viewThriller,
              child: FlickMultiPlayer(
                url: authorizedUrl,
                flickMultiManager: widget.flickMultiManager,
                image: video!.videoThumbnail,
                thrillerId: thriller!.id!,
                watched: prudStudioNotifier.isThrillerWatched(thriller!.id!),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              color: prudColorTheme.bgF,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if(channel != null) ChannelLogo(
                          channel: channel!, isLive: channelIsLive,
                          context: context, isOwner: widget.isOwner,
                        ),
                        spacer.width,
                        if(video != null && channel != null && thriller != null) InkWell(
                          onTap: viewThriller,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                child: Translate(
                                  text: tabData.shortenStringWithPeriod(video!.title, length: 70),
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: prudColorTheme.bgA,
                                  ),
                                  align: TextAlign.left,
                                ),
                              ),
                              Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  Text(
                                    tabData.shortenStringWithPeriod(channel!.channelName, length: 25),
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.lineC,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  PointDivider(),
                                  Translate(
                                    text: "${tabData.getFormattedNumber(totalViews)} Views",
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.lineC,
                                    ),
                                    align: TextAlign.left,
                                  ),
                                  PointDivider(),
                                  Translate(
                                    text: uploadedWhen,
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.lineC,
                                    ),
                                    align: TextAlign.left,
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  GFRating(
                                    onChanged: (rate){},
                                    value: rating,
                                    color: prudColorTheme.buttonC,
                                    borderColor: prudColorTheme.buttonC,
                                    size: 10,
                                  ),
                                  PointDivider(),
                                  Translate(
                                    text: "$rating | ${tabData.getRateInterpretation(rating)}",
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.iconC,
                                    ),
                                    align: TextAlign.left,
                                  ),
                                  PointDivider(),
                                  Translate(
                                    text: "${tabData.getFormattedNumber(thriller!.impressions)} Impressions",
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.iconC,
                                    ),
                                    align: TextAlign.left,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if(!widget.isOwner) IconButton(
                    onPressed: showMenu, 
                    icon: Icon(Icons.more_vert_sharp, semanticLabel: "More Menu",),
                    iconSize: 25,
                    color: prudColorTheme.lineC,
                  )
                ],
              ),
            ),
          ],
        ) : Center(
          child: VideoLoading(),
        ),
      ),
    );
  }
}