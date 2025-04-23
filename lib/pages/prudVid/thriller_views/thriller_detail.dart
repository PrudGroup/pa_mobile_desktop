import 'dart:isolate';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:prudapp/components/broadcast_component.dart';
import 'package:prudapp/components/channel_logo.dart';
import 'package:prudapp/components/comments_detail_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/modals/deduction_modal_sheet.dart';
import 'package:prudapp/components/multi_player/flick_multi_manager.dart';
import 'package:prudapp/components/point_divider.dart';
import 'package:prudapp/components/price_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_data_viewer.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/prud_video_player.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/video_component.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/aff_link.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_view.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_local_library.dart';
import 'package:prudapp/pages/prudVid/tabs/views/add_report_or_claim.dart';
import 'package:prudapp/pages/prudVid/tabs/views/video_detail.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/prudio_client.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_platform/universal_platform.dart';
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
  Set<String> selectedSegment = {"like"};
  String uploadedWhen = "";
  double rating = 0;
  bool sharing = false;
  bool joining = false;
  bool leaving = false;
  bool subscribing = false;
  bool unsubscribing = false;
  bool hasJoined = false;
  bool hasSubscribed = false;
  bool showMore = false;
  List<dynamic> relatedVideoAndBroadcasts = prudStudioNotifier.thrillerDetailSuggestions;
  bool loadingSuggestions = false;
  final receivePort = ReceivePort();
  final itemPort = ReceivePort();
  final joinedPort = ReceivePort();
  final subscribedPort = ReceivePort();
  Widget noSuggestions = tabData.getNotFoundWidget(
    title: "No Suggestions",
    desc: "We are unable to suggest any clips nor posts at this time.",
    isRow: true,
  );
  FlickMultiManager flickMultiManager = FlickMultiManager();
  int offset = 0;
  List<ChannelMembership> channelsMembered = prudStudioNotifier.affJoined;
  List<ChannelSubscriber> channelsSubscribed = prudStudioNotifier.affSubscribed;
  bool checkingIfSubscribed = false;
  bool checkingIfMembered = false;
  int totalMembers = 0;
  bool showComment = true;
  bool channelIsLive = false;
  int lastScrollPoint = prudStudioNotifier.thrillerDetailLastItemScroll;
  final ItemScrollController sCtrl = ItemScrollController();
  final ScrollOffsetController sOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  int totalComments = 0;
  int totalMembersComment = 0;
  ReceivePort totalCPort = ReceivePort();
  ReceivePort totalMCPort = ReceivePort();
  ReceivePort lastCPort = ReceivePort();
  VideoThrillerComment? lastComment;
  final GlobalKey _videoContainerKey = GlobalKey();
  final GlobalKey _flickKey = GlobalKey();
  double vHeight = 100;

  void display(){
    displayComment(showComment? false : true);
  }

  getSizeAndPosition() {
    vHeight = _videoContainerKey.currentContext?.size?.height?? 0;
    if(UniversalPlatform.isAndroid == false && UniversalPlatform.isIOS == false){
      vHeight = _flickKey.currentContext?.size?.height?? 0;
    }
    setState(() {});
  }

  displayComment(bool isMembersOnly){
    showModalBottomSheet(
      context: context,
      backgroundColor: prudColorTheme.bgF,
      elevation: 0,
      isDismissible: false,
      barrierColor: prudColorTheme.bgF,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return CommentsDetailComponent(
          membersOnly: isMembersOnly,
          id: thriller!.id!,
          commentType: CommentType.thrillerComment,
          parentObjHeight: vHeight,
        );
      },
    );
  }

  Future<void> getToTalComments() async {
    
  }

  Future<void> getToTalMemberComments() async {
    
  }

  Future<void> getLastComment() async {
    
  }

  Future<void> getSuggestedVideos() async {
    if(relatedVideoAndBroadcasts.isNotEmpty){
      if(lastScrollPoint > 0){
        sCtrl.scrollTo(index: lastScrollPoint, duration: Duration(seconds: 2), curve: Curves.easeInOutCubic);
      }
      return;
    }
    tryAsync("getSuggestedVideos", () async {
      if(mounted) setState(() => loadingSuggestions = true);
      if(iCloud.affAuthToken != null && video != null && myStorage.user != null){
        PrudCredential cred = PrudCredential(key: prudApiKey, token: iCloud.affAuthToken!);
        VideoSuggestionServiceArg suggestionArgs = VideoSuggestionServiceArg(
          sendPort: receivePort.sendPort,
          cred: cred,
          unwantedBroadcasts: prudVidNotifier.notInterestedBroadcasts,
          unwantedChannels: prudVidNotifier.dontRecommend,
          unwantedVideos: prudVidNotifier.notInterestedVideos,
          broadcastSearchText: video!.title,
          promotedType: VideoSearchType.promotedCountry,
          videoCateria: VideoSearchServiceArg(
            sendPort: receivePort.sendPort, 
            cred: cred, 
            searchType: VideoSearchType.categoryTitleTags,
            country: myStorage.user!.country,
            category: video!.videoType,
            searchText: video!.title
          ),
        );
        await Isolate.spawn(getVideoAndBroadcastSuggestions, suggestionArgs, onError: receivePort.sendPort, onExit: receivePort.sendPort);

        receivePort.listen((resp){
          if(resp != null && resp is List && resp.isNotEmpty){
            List<dynamic> related = [];
            related = resp.map((item) {
              if(item["message"] != null){
                // its a broadcast
                return ChannelBroadcast.fromJson(item);
              }else{
                // its a video
                return ChannelVideo.fromJson(item);
              }
            }).toList();
            prudStudioNotifier.updateThrillerDetailSuggestions(related);
            if(mounted) setState(() => relatedVideoAndBroadcasts = related);
          }
          if(mounted) setState(() => loadingSuggestions = false);
        });
      }
    }, error: (){
      if(mounted) setState(() => loadingSuggestions = false);
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

    prudSocket.on("thriller_like_dislike", (json){
      if(json != null && json["id"] == thriller!.id){
        if(mounted){
          setState(() {
            thriller!.likes = json["likes"];
            thriller!.dislikes = json["dislikes"];
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

  void like(){
    tryOnly("like", (){
      prudVidNotifier.addToLikeOrDislikeActions(
        ActionType.thriller,
        LikeDislikeAction(
          itemId: thriller!.id!, liked: 1
        ),
        context,
      );
    });
  }

  void dislike(){
    tryOnly("like", (){
      prudVidNotifier.addToLikeOrDislikeActions(
        ActionType.thriller,
        LikeDislikeAction(
          itemId: thriller!.id!, liked: 0
        ),
        context,
      );
    });
  }

  void segmentChanged(Set<String> value) {
    if (mounted) {
      setState(() {
        selectedSegment = value;
        if (value.contains("like")) {
          like();
        } else {
          dislike();
        }
      });
    }
  }

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

  Future<void> checkIfSubscribed() async {
    tryOnly("checkIfSubscribed", () async {
      if (mounted) setState(() => checkingIfSubscribed = true);
      if (channelsSubscribed.isNotEmpty && channel != null) {
        ListItemSearchArg searchArgs = ListItemSearchArg(
          sendPort: subscribedPort.sendPort,
          searchList: channelsSubscribed,
          searchItem: channel!.id
        );
        await Isolate.spawn(listItemSearch, searchArgs, onError: subscribedPort.sendPort, onExit: subscribedPort.sendPort);
        subscribedPort.listen((resp) {
          if (mounted) {
            setState(() {
              checkingIfSubscribed = false;
              hasSubscribed = resp > -1;
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            checkingIfSubscribed = false;
            hasSubscribed = false;
          });
        }
      }
    }, error: () {
      if (mounted) setState(() => checkingIfSubscribed = false);
    });
  }

  Future<void> checkIfMembered() async {
    tryOnly("checkIfMembered", () async {
      if (mounted) setState(() => checkingIfMembered = true);
      if (channelsMembered.isNotEmpty && channel != null) {
        ListItemSearchArg searchArgs = ListItemSearchArg(
          sendPort: joinedPort.sendPort,
          searchList: channelsMembered,
          searchItem: channel!.id
        );
        await Isolate.spawn(listItemSearch, searchArgs, onError: joinedPort.sendPort, onExit: joinedPort.sendPort);
        joinedPort.listen((resp) {
          if (mounted) {
            setState(() {
              checkingIfMembered = false;
              hasJoined = resp > -1;
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            checkingIfMembered = false;
            hasJoined = false;
          });
        }
      }
    }, error: () {
      if (mounted) setState(() => checkingIfMembered = false);
    });
  }

  Future<void> subscribe() async {
    await tryAsync("subscribe", () async {
      if (mounted) setState(() => subscribing = true);
      ChannelSubscriber? sub = await prudStudioNotifier.subscribeToChannel(channel!.id!);
      if (mounted && sub != null && channel != null) {
        prudStudioNotifier.addSubscribedToCache(sub);
        setState(() {
          subscribing = false;
          hasSubscribed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Subscribed"),
        ));
      }
    }, error: () {
      if (mounted) {
        setState(() => subscribing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Subscribe"),
          backgroundColor: prudColorTheme.primary,
        ));
      }
    });
  }

  Future<void> unsubscribe() async {
    await tryAsync("unsubscribe", () async {
      if (mounted) setState(() => unsubscribing = true);
      bool sub = await prudStudioNotifier.unsubscribeFromAChannel(channel!.id!);
      if (mounted && sub == true && channel != null) {
        await prudStudioNotifier.removeSubscribedFromCache(ChannelSubscriber(
          affId: myStorage.user!.id!, channelId: channel!.id!
        ));
        setState(() {
          unsubscribing = false;
          hasSubscribed = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unsubscribed"),
          ));
        }
      }else{
        if (mounted) {
          setState(() => unsubscribing = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Unsubscribe"),
            backgroundColor: prudColorTheme.primary,
          ));
        }
      }
    }, error: () {
      if (mounted) {
        setState(() => unsubscribing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Unsubscribe"),
          backgroundColor: prudColorTheme.primary,
        ));
      }
    });
  }

  Future<void> leave() async {
    await tryAsync("leave", () async {
      if (mounted) setState(() => leaving = true);
      bool sub = await prudStudioNotifier.leaveAChannel(channel!.id!);
      if (mounted && sub == true && channel != null) {
        await prudStudioNotifier.removeJoinedFromCache(ChannelMembership(
          affId: myStorage.user!.id!, channelId: channel!.id!
        ));
        setState(() {
          leaving = false;
          hasJoined = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Left"),
          ));
        }
      }else{
        if (mounted) {
          setState(() => leaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Leave"),
            backgroundColor: prudColorTheme.primary,
          ));
        }
      }
    }, error: () {
      if (mounted) {
        setState(() => leaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Leave"),
          backgroundColor: prudColorTheme.primary,
        ));
      }
    });
  }

  Future<void> join() async {
    await tryAsync("join", () async {
      if (mounted) setState(() => joining = true);
      ChannelMembership? sub = await prudStudioNotifier.joinAChannel(channel!.id!);
      if (mounted && sub != null && channel != null) {
        await prudStudioNotifier.addJoinedToCache(sub);
        setState(() {
          joining = false;
          hasJoined = true;
        });
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Joined"),
          ));
        }
      }else{
        if (mounted) {
          setState(() => joining = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Insufficient Fund/Network Issue"),
            backgroundColor: prudColorTheme.primary,
          ));
        }
      }
    }, error: () {
      if (mounted) {
        setState(() => joining = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Join."),
          backgroundColor: prudColorTheme.primary,
        ));
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

  void openVideoView(){
    bool existsInLocalLibrary = prudVidNotifier.checkIfVideoExistLocally(video!.id!);
    if(existsInLocalLibrary){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "This Video Exist in your Library."),
        ));
        iCloud.goto(context, const VidLocalLibrary());
      }
    }else{
      if(hasJoined){
        iCloud.goto(context, VideoDetail(video: video!,));
      }else{
        if(prudVidNotifier.checkIfVideoHasBeenBought(video!.id!)){
          iCloud.goto(context, VideoDetail(video: video!,));
        }else{
          showModalBottomSheet(
            context: context,
            backgroundColor: prudColorTheme.bgF,
            elevation: 0,
            barrierColor: prudColorTheme.bgE,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (BuildContext context) {
              return DeductionModalSheet(
                affLink: widget.referralLinkId,
                onlyDownload: false,
                channel: channel!,
                video:  video!,
                isMember: hasJoined,
              );
            },
          );
        }
      }
    }
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
  }


  @override
  void dispose(){
    flickManager.dispose();
    receivePort.close();
    itemPort.close();
    joinedPort.close();
    subscribedPort.close();
    Isolate.current.kill();
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
        Future.wait([
          getSuggestedVideos(), getToTalComments(), getToTalMemberComments(),
          checkIfMembered(), checkIfSubscribed(), getLastComment(),
        ]);
      }
      if(mounted){
        setState(() {
          thriller ??= widget.thriller;
          video ??= widget.video;
          authorizedUrl = iCloud.authorizeDownloadUrl(thriller!.videoUrl);
          totalViews = video!.nonMemberViews + video!.memberViews;
          uploadedWhen = myStorage.ago(dDate: video!.uploadedAt, isShort: false);
          rating = video!.getRating();
          if(UniversalPlatform.isAndroid == false && UniversalPlatform.isIOS == false){
            flickManager = FlickManager(
              onVideoEnd: () => prudStudioNotifier.addToWatchedThrillers(thriller!.id!),
              autoPlay: true,
              videoPlayerController: VideoPlayerController.networkUrl(
                Uri.parse(authorizedUrl),
                videoPlayerOptions: VideoPlayerOptions(
                  allowBackgroundPlayback: true,
                  mixWithOthers: false,
                )
              ),
            );
          }
          allVidsReady = true;
        });
      }
    });
    super.initState();
    Future.delayed(Duration.zero, (){
      if(mounted) WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
    });
    itemPositionsListener.itemPositions.addListener((){
      if(mounted) setState(() => uploadedWhen = myStorage.ago(dDate: video!.uploadedAt, isShort: false));
      var positions = itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        int lastVisibleIndex = positions
          .where((ItemPosition position) => position.itemLeadingEdge < 1)
          .reduce((ItemPosition max, ItemPosition position) =>
            position.itemLeadingEdge > max.itemLeadingEdge? position : max)
          .index;

        if(mounted){
          setState(() => lastScrollPoint = lastVisibleIndex);
          if(relatedVideoAndBroadcasts.isNotEmpty && iCloud.affAuthToken != null){
            dynamic visibleItem = relatedVideoAndBroadcasts[lastVisibleIndex];
            PrudCredential cred = PrudCredential(key: prudApiKey, token: iCloud.affAuthToken!);
            ServiceArg arg = ServiceArg(
              cred: cred,
              itemId: visibleItem.id,
              sendPort: itemPort.sendPort
            );
            Isolate.spawn(
              visibleItem is ChannelVideo? incrementVideoImpressionService : incrementBroadcastImpressionService, 
              arg, onError: itemPort.sendPort, onExit: itemPort.sendPort
            );
          }
        }
      }
    });
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
      backgroundColor: prudColorTheme.bgF,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        backgroundColor: prudColorTheme.bgF,
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
              text: "PrudVid",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 16,
                color: prudColorTheme.bgD
              ),
            ),
          ],
        ),
        actions: [
          if(channel != null && video != null) PriceComponent(
            currency: channel!.channelCurrency,
            price: currencyMath.roundDouble(video!.costPerNonMemberView, 2)
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) => SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Column(
                children: [
                  if(UniversalPlatform.isAndroid || UniversalPlatform.isIOS) PrudVideoPlayer(
                    key: _videoContainerKey,
                    vid: thriller!.videoUrl,
                    thumbnail: video!.videoThumbnail,
                    isPortrait: orientation == Orientation.portrait,
                    channelName: channel!.channelName,
                    vidTitle: video!.title,
                    loop: true,
                    finishedWidget: InkWell(
                      onTap: openVideoView,
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: prudColorTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 4.0, color: prudColorTheme.bgA),
                        ),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.solidCirclePlay, color: prudColorTheme.bgC, size: 40,),
                            spacer.width,
                            Column(
                              children: [
                                Translate(
                                  text: "Watch It Now",
                                  style: prudWidgetStyle.btnTextStyle.copyWith(
                                    color: prudColorTheme.bgA,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  align: TextAlign.left,
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
                                      size: 12,
                                    ),
                                    PointDivider(),
                                    Translate(
                                      text: "${tabData.getCurrencySymbol(channel!.channelCurrency)}${currencyMath.roundDouble(video!.costPerNonMemberView, 2)}",
                                      style: prudWidgetStyle.tabTextStyle.copyWith(
                                        color: prudColorTheme.success,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      align: TextAlign.left,
                                    ),
                                    PointDivider(),
                                    Translate(
                                      text: "${tabData.getFormattedNumber(totalViews)} Views}",
                                      style: prudWidgetStyle.tabTextStyle.copyWith(
                                        color: prudColorTheme.bgD,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      align: TextAlign.left,
                                    ),
                                  ],
                                )
                              ]
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                  if(flickManager != null && UniversalPlatform.isAndroid == false && UniversalPlatform.isIOS == false) VisibilityDetector(
                    key: ObjectKey(flickManager),
                    onVisibilityChanged: (visibility) {
                      if (visibility.visibleFraction == 0 && mounted) {
                        flickManager.flickControlManager?.autoPause();
                      } else if (visibility.visibleFraction == 1) {
                        flickManager.flickControlManager?.autoResume();
                      }
                    },
                    child: FlickVideoPlayer(
                      key: _flickKey,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
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
                            PointDivider(),
                            Translate(
                              text: uploadedWhen,
                              style: prudWidgetStyle.hintStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.lineC,
                              ),
                              align: TextAlign.left,
                            ),
                            PointDivider(),
                            Text(
                              "#${thriller?.tags?.elementAt(0)}",
                              style: prudWidgetStyle.hintStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.lineC,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            PointDivider(),
                            Text(
                              "#${thriller?.tags?.elementAt(1)}",
                              style: prudWidgetStyle.hintStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.lineC,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            PointDivider(),
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
                          ],
                        ),
                        if(showMore) Column(
                          children: [
                            PrudPanel(
                              bgColor: prudColorTheme.bgF,
                              title: "Thriller",
                              titleColor: prudColorTheme.bgD,
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                children: [
                                  PrudDataViewer(
                                    field: "Likes",
                                    value: tabData.getFormattedNumber(thriller!.likes),
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                  ),
                                  PrudDataViewer(
                                    field: "Dislikes",
                                    value: tabData.getFormattedNumber(thriller!.dislikes),
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                  ),
                                  PrudDataViewer(
                                    field: "Shared",
                                    value: tabData.getFormattedNumber(thriller!.shared),
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                  ),
                                  PrudDataViewer(
                                    field: "Thriller",
                                    value: tabData.getFormattedNumber(thriller!.impressions),
                                    makeTransparent: true,
                                    subValue: "Impressions",
                                    size: PrudSize.smaller,
                                  ),
                                ],
                              ),
                            ),
                            spacer.height,
                            PrudPanel(
                              bgColor: prudColorTheme.bgF,
                              title: "Video Clip",
                              titleColor: prudColorTheme.bgD,
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                children: [
                                  InkWell(
                                    onTap: openVideoView,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(prudImages.prudVid, width: 50,),
                                        Translate(
                                          text: "Watch Now", 
                                          align: TextAlign.center,
                                          style: prudWidgetStyle.tabTextStyle.copyWith(
                                            fontSize: 14,
                                            color: prudColorTheme.bgA,
                                            fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PrudDataViewer(
                                    field: "Clip Cost",
                                    value: "${tabData.getCurrencySymbol(channel!.channelCurrency)}${currencyMath.roundDouble(video!.costPerNonMemberView, 2)}",
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                    subValue: "Per View",
                                  ),
                                  PrudDataViewer(
                                    field: "Monthly",
                                    value: "${tabData.getCurrencySymbol(channel!.channelCurrency)}${currencyMath.roundDouble(channel!.monthlyMembershipCost, 2)}",
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                    subValue: "Membership",
                                  ),
                                  PrudDataViewer(
                                    field: "Member Views",
                                    value: tabData.getFormattedNumber(video!.memberViews),
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                  ),
                                  PrudDataViewer(
                                    field: "Views",
                                    value: tabData.getFormattedNumber(video!.nonMemberViews),
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                    subValue: "Non-Members",
                                  ),
                                  PrudDataViewer(
                                    field: "Views",
                                    value: tabData.getFormattedNumber(video!.nonMemberViews),
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                    subValue: "Non-Members",
                                  ),
                                  PrudDataViewer(
                                    field: "Total Views",
                                    value: tabData.getFormattedNumber(video!.nonMemberViews + video!.memberViews),
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                  ),
                                  PrudDataViewer(
                                    field: "Dislikes",
                                    value: tabData.getFormattedNumber(video!.dislikes),
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                  ),
                                  PrudDataViewer(
                                    field: "Downloads",
                                    value: tabData.getFormattedNumber(video!.downloads),
                                    makeTransparent: true,
                                    size: PrudSize.smaller,
                                  ),
                                ],
                              ),
                            ),
                            spacer.height,
                            PrudPanel(
                              bgColor: prudColorTheme.bgF,
                              title: "Description",
                              titleColor: prudColorTheme.bgD,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: SizedBox(
                                child: Translate(
                                  text: video!.description,
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: prudColorTheme.bgC,
                                  ),
                                  align: TextAlign.center,
                                ),
                              ),
                            ),
                            spacer.height,
                          ]
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      spacer.height,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if(channel != null) ChannelLogo(
                                    channel: channel!, isLive: channelIsLive,
                                    context: context, isOwner: widget.isOwner,
                                  ),
                                  spacer.width,
                                  Column(
                                    children: [
                                      Wrap(
                                        children: [
                                          Text(
                                            channel!.channelName,
                                            style: prudWidgetStyle.hintStyle.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: prudColorTheme.lineC,
                                            ),
                                            textAlign: TextAlign.left,
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
                                            size: 12,
                                          ),
                                          PointDivider(),
                                          Translate(
                                            text: "$rating | ${tabData.getRateInterpretation(rating)}",
                                            style: prudWidgetStyle.hintStyle.copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: prudColorTheme.iconC,
                                            ),
                                            align: TextAlign.left,
                                          ),
                                          PointDivider(),
                                          Translate(
                                            text: "${tabData.getFormattedNumber(totalMembers)} Members",
                                            style: prudWidgetStyle.hintStyle.copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: prudColorTheme.iconC,
                                            ),
                                            align: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ]
                                  )

                                ],
                              ),
                            ),
                            if(!hasJoined) prudWidgetStyle.getShortButton(
                              onPressed: join, 
                              text: "Join",
                              isSmall: true
                            ),
                            if(hasJoined) prudWidgetStyle.getShortButton(
                              onPressed: leave, 
                              text: "Leave",
                              isSmall: true
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          scrollDirection: Axis.horizontal,
                          children: [
                            SegmentedButton(
                              showSelectedIcon: false,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                                  WidgetState.error: prudColorTheme.textB.withValues(alpha: 0.5),
                                  WidgetState.hovered: prudColorTheme.textB.withValues(alpha: 0.7),
                                  WidgetState.focused: prudColorTheme.textB.withValues(alpha: 0.7),
                                  WidgetState.disabled: prudColorTheme.bgF,
                                  WidgetState.selected: prudColorTheme.textB,
                                  WidgetState.pressed: prudColorTheme.textB,
                                }),
                                foregroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                                  WidgetState.error: prudColorTheme.bgF.withValues(alpha: 0.5),
                                  WidgetState.hovered: prudColorTheme.bgA,
                                  WidgetState.focused: prudColorTheme.bgA,
                                  WidgetState.disabled: prudColorTheme.bgA,
                                  WidgetState.selected: prudColorTheme.bgA,
                                  WidgetState.pressed: prudColorTheme.bgA,
                                }),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                                side: WidgetStateProperty.all(BorderSide(
                                  color: prudColorTheme.textB.withValues(alpha: 0.6),
                                  width: 2,
                                )),
                              ),
                              selected: selectedSegment,
                              onSelectionChanged: segmentChanged,
                              segments: [
                                ButtonSegment(
                                  value: "like",
                                  tooltip: "like",
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Translate(
                                        text: "${tabData.getFormattedNumber(thriller!.likes)}",
                                        style: prudWidgetStyle.typedTextStyle.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: prudColorTheme.bgC,
                                        ),
                                      ),
                                      ImageIcon(AssetImage(prudImages.like), color: prudColorTheme.bgF, size: 14,),
                                    ],
                                  ),
                                ),
                                ButtonSegment(
                                  value: "dislike",
                                  tooltip: "dislike",
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Translate(
                                        text: "${tabData.getFormattedNumber(thriller!.dislikes)}",
                                        style: prudWidgetStyle.typedTextStyle.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: prudColorTheme.bgC,
                                        ),
                                      ),
                                      ImageIcon(AssetImage(prudImages.dislike), color: prudColorTheme.bgF, size: 14,),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            spacer.height,
                            prudWidgetStyle.getShortIconButton(
                              onPressed: openVideoView, 
                              text: "Watch",
                              isSmall: true,
                              bgColor: prudColorTheme.textA,
                              hasIcon: true,
                              icon: FaIcon(FontAwesomeIcons.eye, color: prudColorTheme.bgF, size: 13,),
                            ),
                            if(!hasJoined) spacer.width,
                            if(!hasJoined) prudWidgetStyle.getShortIconButton(
                              onPressed: join, 
                              text: "Join",
                              isSmall: true,
                              bgColor: prudColorTheme.textA,
                              hasIcon: true,
                              showLoader: joining,
                              icon: FaIcon(FontAwesomeIcons.personWalkingLuggage, color: prudColorTheme.bgF, size: 13,),
                            ),
                            if(hasJoined) spacer.width,
                            if(hasJoined) prudWidgetStyle.getShortIconButton(
                              onPressed: leave, 
                              text: "Leave",
                              isSmall: true,
                              bgColor: prudColorTheme.textA,
                              hasIcon: true,
                              showLoader: leaving,
                              icon: FaIcon(FontAwesomeIcons.personThroughWindow, color: prudColorTheme.bgF, size: 13,),
                            ),
                            spacer.width,
                            prudWidgetStyle.getShortIconButton(
                              onPressed: share, 
                              text: "Share",
                              isSmall: true,
                              bgColor: prudColorTheme.textA,
                              hasIcon: true,
                              showLoader: sharing,
                              icon: FaIcon(FontAwesomeIcons.share, color: prudColorTheme.bgF, size: 13,),
                            ),
                            if(!hasSubscribed && !hasJoined) spacer.width,
                            if(!hasSubscribed && !hasJoined) prudWidgetStyle.getShortIconButton(
                              onPressed: subscribe, 
                              text: "Subscribe",
                              isSmall: true,
                              bgColor: prudColorTheme.textA,
                              hasIcon: true,
                              showLoader: subscribing,
                              icon: Icon(Icons.alarm_add_outlined, color: prudColorTheme.bgF, size: 13,),
                            ),
                            if(hasSubscribed) spacer.width,
                            if(hasSubscribed) prudWidgetStyle.getShortIconButton(
                              onPressed: unsubscribe, 
                              text: "Unsubscribe",
                              isSmall: true,
                              bgColor: prudColorTheme.textA,
                              hasIcon: true,
                              showLoader: unsubscribing,
                              icon: Icon(Icons.alarm_off_outlined, color: prudColorTheme.bgF, size: 13,),
                            ),
                          ],
                        ),
                      ),
                      spacer.height,
                    ]
                  ),
                  if(totalComments > 0) InkWell(
                    onTap: display,
                    child: PrudContainer(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Translate(
                                text: showComment? "Comments $totalComments" : "Members Comments $totalMembersComment",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: prudColorTheme.bgD,
                                ),
                                align: TextAlign.left,
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  PointDivider(
                                    size: 10,
                                    pointColor: showComment? prudColorTheme.bgA : prudColorTheme.lineC,
                                  ),
                                  PointDivider(
                                    size: 10,
                                    pointColor: showComment? prudColorTheme.lineC : prudColorTheme.bgA,
                                  )
                                ],
                              )
                            ],
                          ),
                          lastComment != null && lastComment!.affiliate != null? GFCarousel(
                            autoPlay: true,
                            aspectRatio: double.maxFinite,
                            viewportFraction: 1.0,
                            enlargeMainPage: true,
                            enableInfiniteScroll: true,
                            onPageChanged: (int displayedIndex){
                              if(mounted) setState(() => showComment = displayedIndex == 0? true : false);
                            },
                            pauseAutoPlayOnTouch: const Duration(seconds: 15),
                            autoPlayInterval: const Duration(seconds: 10),
                            items: [
                              SizedBox(
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    lastComment!.affiliate!.getAvatar(shape: 1, size: 30.0),
                                    SizedBox(
                                      child: Translate(
                                        text: tabData.shortenStringWithPeriod(lastComment!.comment, length: 100),
                                        style: prudWidgetStyle.tabTextStyle.copyWith(
                                          fontSize: 12.0,
                                          color: prudColorTheme.textB,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  Icon(FontAwesomeIcons.comments, size: 30, color: prudColorTheme.lineC,),
                                  Translate(
                                    text: "You can see all the comments made by only members of this channel.",
                                    style: prudWidgetStyle.tabTextStyle.copyWith(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: prudColorTheme.textB,
                                    ),
                                  ),
                                ],
                              )
                            ]
                          ) : SizedBox(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: loadingSuggestions? 
                Center(
                  child: LoadingComponent(
                    isShimmer: false,
                    size: 30,
                    spinnerColor: prudColorTheme.lineC,
                  ),
                ) 
                : 
                (
                  relatedVideoAndBroadcasts.isEmpty? 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [noSuggestions],
                  ) 
                  : 
                  VisibilityDetector(
                    key: ObjectKey(flickMultiManager),
                    onVisibilityChanged: (visibility) {
                      if (visibility.visibleFraction == 0 && mounted) {
                        flickMultiManager.pause();
                      }
                    },
                    child: ScrollablePositionedList.builder(
                      physics: BouncingScrollPhysics(),
                      itemScrollController: sCtrl,
                      itemPositionsListener: itemPositionsListener,
                      scrollOffsetController: sOffsetController,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      itemCount: relatedVideoAndBroadcasts.length,
                      itemBuilder: (context, index) {
                        dynamic item = relatedVideoAndBroadcasts[index];
                        if(item is ChannelVideo){
                          return PrudVideoComponent(
                            video: item,
                            isOwner: false,
                            noBorderRadius: true,
                            flickMultiManager: flickMultiManager,
                            isPortrait: orientation == Orientation.portrait,
                          );
                        }else{
                          return BroadcastComponent(
                            broadcast: item,
                            isChannel: true,
                            isOwner: false,
                            isPortrait: orientation == Orientation.portrait,
                          );
                        }
                      }
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}