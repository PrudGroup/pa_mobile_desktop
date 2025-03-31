import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/aff_link.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_view.dart';
import 'package:prudapp/pages/prudVid/tabs/views/add_report_or_claim.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
    
class ThrillerDetail extends StatefulWidget {
  final VideoThriller? thriller;
  final ChannelVideo? video;
  final String? thrillerId;
  final String? referralLinkId;
  final bool isOwner;
  
  const ThrillerDetail({super.key, this.thriller, this.video, this.thrillerId, this.referralLinkId, this.isOwner = false});

  @override
  ThrillerDetailState createState() => ThrillerDetailState();
}

class ThrillerDetailState extends State<ThrillerDetail> {
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
  bool showMore = false;

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
      if(mounted){
        setState(() {
          thriller ??= widget.thriller;
          video ??= widget.video;
          authorizedUrl = iCloud.authorizeDownloadUrl(thriller!.videoUrl);
          totalViews = video!.nonMemberViews + video!.memberViews;
          uploadedWhen = myStorage.ago(dDate: video!.uploadedAt, isShort: false);
          rating = video!.getRating();
          flickManager = FlickManager(
            autoPlay: true,
            videoPlayerController: VideoPlayerController.networkUrl(
              Uri.parse(authorizedUrl),
              videoPlayerOptions: VideoPlayerOptions(
                allowBackgroundPlayback: true,
                mixWithOthers: false,
              )
            ),
          );
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

  void viewChannel(){
    if(channel != null && mounted){
      iCloud.goto(context, ChannelView(
        channel: channel!,
        isOwner: widget.isOwner,
      ));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        backgroundColor: prudColorTheme.bgE,
        leading: IconButton(
          icon: Icon(Icons.arrow_drop_down, color: prudColorTheme.bgA,),
          onPressed: () => iCloud.goBack(context),
          splashRadius: 20,
        ),
        title: Row(
          children: [
            Image.asset(
              prudImages.prudIcon,
              width: 30,
            ),
            spacer.width,
            Translate(
              text: "Thriller Player",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 16,
                color: prudColorTheme.bgA
              ),
            ),
          ],
        ),
        actions: const [
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            VisibilityDetector(
              key: ObjectKey(flickManager),
              onVisibilityChanged: (visibility) {
                if (visibility.visibleFraction == 0 && mounted) {
                  flickManager.flickControlManager?.autoPause();
                } else if (visibility.visibleFraction == 1) {
                  flickManager.flickControlManager?.autoResume();
                }
              },
              child: FlickVideoPlayer(
                flickManager: flickManager,
                flickVideoWithControls: FlickVideoWithControls(
                  closedCaptionTextStyle: TextStyle(fontSize: 8),
                  controls: FlickPortraitControls(),
                ),
                flickVideoWithControlsFullscreen: FlickVideoWithControls(
                  controls: FlickLandscapeControls(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(
                    child: Text(
                      video!.title,
                      style: prudWidgetStyle.typedTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: prudColorTheme.bgA,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      SizedBox(height: 5, child: Align(alignment: Alignment.center, child: Container(width: 2, height: 2, color: prudColorTheme.textC))),
                      Text(
                        "#${thriller?.tags?.elementAt(0)}",
                        style: prudWidgetStyle.hintStyle.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: prudColorTheme.lineC,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 5, child: Align(alignment: Alignment.center, child: Container(width: 2, height: 2, color: prudColorTheme.textC))),
                      InkWell(
                        onTap: () {
                          if(mounted) setState(() => showMore = !showMore);
                        },
                        child: Text(
                          showMore? "...Less" : "...More",
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: prudColorTheme.bgA,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      if(showMore) Column(
                        children: [
                          
                        ]
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}