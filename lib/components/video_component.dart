import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/video_loading.dart';
import 'package:prudapp/models/aff_link.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/tabs/views/add_report_or_claim.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class PrudVideoComponent extends StatefulWidget{
  final ChannelVideo? video;
  final VidChannel? channel;
  final String? thrillerId;
  final VideoThriller? thriller;
  final bool isOwner;
  final String? affLinkId;
  final bool autoplay;

  const PrudVideoComponent({
    super.key, this.video, required this.isOwner,
    this.thrillerId, this.affLinkId, this.thriller,
    this.autoplay = false, this.channel,
  });

  @override
  PrudVideoComponentState createState() => PrudVideoComponentState();
}

class PrudVideoComponentState extends State<PrudVideoComponent> {
  VideoThriller? thriller;
  ChannelVideo? video;
  bool loading = false;
  late FlickManager flickManager;
  bool allVidsReady = false;
  String authorizedUrl = "";
  VidChannel? channel;
  int totalViews = 0;
  String uploadedWhen = "";
  double rating = 0;
  bool sharing = false;

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
        if(video!.channel == null){
          if(mounted) setState(() => channel = video!.channel);
        }else{
          if(mounted) setState(() => loading = true);
          await tryAsync("getChannel", () async {
            if(mounted) setState(() => loading = true);
            VidChannel? cha = await prudStudioNotifier.getChannelById(video!.channelId);
            if(mounted) {
              setState(() {
                channel = cha;
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


  @override
  void dispose(){
    flickManager.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(widget.thriller == null){
        await getThriller();
        if(widget.video == null){
          await getVideo();
          await getChannel();
        }
      }
      flickManager = FlickManager(
        autoPlay: widget.autoplay,
        videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(thriller!.videoUrl)),
      );
      if(mounted){
        setState(() {
          thriller ??= widget.thriller;
          video ??= widget.video;
          authorizedUrl = iCloud.authorizeDownloadUrl(thriller!.videoUrl);
          totalViews = video!.nonMemberViews + video!.memberViews;
          uploadedWhen = myStorage.ago(dDate: video!.uploadedAt, isShort: false);
          rating = video!.getRating();
          allVidsReady = true;
        });
      }
    });
    super.initState();
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
                onTap: dontRecommendChannel,
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
  
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation){
        return Container(
          width: MediaQuery.of(context).size.width,
          height: orientation == Orientation.portrait? 250 : 300,
          decoration: BoxDecoration(
            color: prudColorTheme.bgA,
            border: Border(
              bottom: BorderSide(
                color: prudColorTheme.lineC, 
                width: 3,
              )
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: allVidsReady == true? Column(
              children: [
                SizedBox(
                  height: orientation == Orientation.portrait? 190 : 240,
                  child: widget.autoplay? FlickVideoPlayer(
                    flickManager: flickManager
                  ) : PrudNetworkImage(url: video!.videoThumbnail, authorizeUrl: true,),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: prudColorTheme.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GFAvatar(
                            backgroundImage: FastCachedImageProvider(
                              iCloud.authorizeDownloadUrl(channel!.logo),
                            ),
                          ),
                          spacer.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.maxFinite,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tabData.shortenStringWithPeriod(channel!.channelName, length: 25),
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.lineC,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(height: 5, child: Align(alignment: Alignment.center, child: Container(width: 2, height: 2, color: prudColorTheme.textC))),
                                  Translate(
                                    text: "${tabData.getFormattedNumber(totalViews)} Views",
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.lineC,
                                    ),
                                    align: TextAlign.left,
                                  ),
                                  SizedBox(height: 5, child: Align(alignment: Alignment.center, child: Container(width: 2, height: 2, color: prudColorTheme.textC))),
                                  Translate(
                                    text: uploadedWhen,
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.lineC,
                                    ),
                                    align: TextAlign.left,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GFRating(
                                    onChanged: (rate){},
                                    value: rating,
                                    color: prudColorTheme.textD,
                                    borderColor: prudColorTheme.textD,
                                    size: 8,
                                  ),
                                  SizedBox(height: 5, child: Align(alignment: Alignment.center, child: Container(width: 2, height: 2, color: prudColorTheme.textC))),
                                  Translate(
                                    text: "$rating | ${tabData.getRateInterpretation(rating)}",
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.textD,
                                    ),
                                    align: TextAlign.left,
                                  ),
                                  SizedBox(height: 5, child: Align(alignment: Alignment.center, child: Container(width: 2, height: 2, color: prudColorTheme.textC))),
                                  Translate(
                                    text: "${tabData.getFormattedNumber(thriller!.impressions)} Impressions",
                                    style: prudWidgetStyle.hintStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.textD,
                                    ),
                                    align: TextAlign.left,
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      if(!widget.isOwner) IconButton(
                        onPressed: showMenu, 
                        icon: Icon(Icons.more_vert_sharp, semanticLabel: "More Menu",),
                        iconSize: 30,
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
    );
  }
}