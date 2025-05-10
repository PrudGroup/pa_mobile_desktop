import 'package:flutter/material.dart';
import 'package:prudapp/components/download_video_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/point_divider.dart';
import 'package:prudapp/components/prud_data_viewer.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/aff_link.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/tabs/views/video_detail.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/prudio_client.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class DeductionModalSheet extends StatefulWidget {
  final String? affLink;
  final VidChannel channel;
  final ChannelVideo video;
  final bool isMember;
  final bool onlyDownload;

  const DeductionModalSheet({
    super.key, this.affLink, this.onlyDownload = false,
    required this.channel, required this.video, this.isMember = false
  });

  @override
  DeductionModalSheetState createState() => DeductionModalSheetState();
}

class DeductionModalSheetState extends State<DeductionModalSheet> {
  double downloadCost = 0;
  bool loading = false;
  bool joining = false;
  bool downloading = false;
  bool showDownloadProcess = false;

  Future<void> view() async {
    prudSocket.on('view_paid', (data) async {
      if(data["result"] == true){
        await prudVidNotifier.addToVideosBought(VideoPaidFor(
          paidOn: DateTime.now(),
          videoId: widget.video.id!
        ));
        if(mounted){
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Translate(text: "Transaction Successful."),
            ));
          iCloud.goto(context, VideoDetail(video: widget.video,));
        }
      }else{
        if(mounted){
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Transaction Failed."),
          ));
        }
      }
    });
    if(prudIOConnectID != null && myStorage.user != null && myStorage.user!.id != null){
      if(mounted) setState(() => loading = true);
      String linkId = widget.affLink?? myStorage.getVideoReferral(widget.video.id!)?? myStorage.generalReferral?? "";
      AffLink? link = await influencerNotifier.getLinkByLinkId(linkId);
      double costInEuro = await currencyMath.convert(
        amount: widget.video.costPerNonMemberView, 
        quoteCode: "EUR", 
        baseCode: widget.channel.channelCurrency,
      );
      PayForVideoViewSchema newPay = PayForVideoViewSchema(
        vidId: widget.video.id!,
        viewerId: myStorage.user!.id!,
        costInEuro: costInEuro,
        socketUserId: prudIOConnectID!,
        dwCostInSelectedCurrency: widget.video.costPerNonMemberView,
        appReferral: influencerNotifier.appInstallAffId,
        videoReferral: link?.affId,
      );
      PayForVideoViewSchema? pay = await prudStudioNotifier.pay4View(newPay);
      if(pay == null && mounted){
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Complete Transaction."),
          ));
      }
    }else{
      if(mounted){
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Complete Transaction."),
          ));
      }
    }
  }

  Future<void> join() async {
    await tryAsync("join", () async {
      if (mounted) setState(() => joining = true);
      ChannelMembership? sub = await prudStudioNotifier.joinAChannel(widget.channel.id!);
      if (mounted && sub != null) {
        await prudStudioNotifier.addJoinedToCache(sub);
        setState(() {
          joining = false;
        });
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Joined"),
          ));
          iCloud.goto(context, VideoDetail(video: widget.video,));
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

  Future<void> download() async {
    prudSocket.on('download_paid', (data) async {
      if(data["result"] == true){
        if(mounted){
          setState(() {
            downloading = false;
            showDownloadProcess = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Transaction Successful."),
          ));
        }
      }else{
        if(mounted){
          setState(() {
            downloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Transaction Failed."),
          ));
        }
      }
    });
    if(prudIOConnectID != null && myStorage.user != null && myStorage.user!.id != null){
      if(mounted) setState(() => downloading = true);
      String linkId = widget.affLink?? myStorage.getVideoReferral(widget.video.id!)?? myStorage.generalReferral?? "";
      AffLink? link = await influencerNotifier.getLinkByLinkId(linkId);
      double costInEuro = await currencyMath.convert(
        amount: downloadCost, 
        quoteCode: "EUR", 
        baseCode: widget.channel.channelCurrency,
      );
      PayForVideoViewSchema newPay = PayForVideoViewSchema(
        vidId: widget.video.id!,
        viewerId: myStorage.user!.id!,
        costInEuro: costInEuro,
        socketUserId: prudIOConnectID!,
        dwCostInSelectedCurrency: downloadCost,
        appReferral: influencerNotifier.appInstallAffId,
        videoReferral: link?.affId,
      );
      PayForVideoViewSchema? pay = await prudStudioNotifier.pay4Download(newPay);
      if(pay == null && mounted){
        setState(() {
          downloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Complete Transaction."),
        ));
      }
    }else{
      if(mounted){
        setState(() {
          downloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Complete Transaction."),
          ));
      }
    }
  }

  @override
  void initState(){
    if(mounted){
      setState((){
        downloadCost = widget.video.costPerNonMemberView + (widget.video.costPerNonMemberView * (widget.onlyDownload? 0.5 : 1));
      });
    }
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return OrientationBuilder(builder: (ctext, orientation){
      return ClipRRect(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screen.height * 0.6,
            minHeight: screen.height * 0.4
          ),
          color: prudColorTheme.bgF,
          padding: const EdgeInsets.only(left: 5, right: 5, top: 15),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: showDownloadProcess? 
            Column(
              children: [
                spacer.height,
                DownloadVideoComponent(
                  video: widget.video,
                  screenOrientation: orientation,
                  channel: widget.channel,
                  details: DownloadedVideo(
                    chucksDownloaded: [], 
                    chucksRemaining: [],
                    filename: tabData.getFilenameFromUrl(widget.video.videoUrl), 
                    startedAt: DateTime.now(), 
                    mergedChunk: [], 
                    videoDuration: widget.video.videoDuration,
                    channelName: widget.channel.channelName,
                    videoTitle: widget.video.title,
                    videoId: widget.video.id!, 
                    placeholderUrl: widget.video.videoThumbnail, 
                    videoUrl: widget.video.videoUrl,
                    videoType: widget.video.videoType,
                    channelId: widget.video.channelId,
                  ),
                ),
                largeSpacer.height
              ],
            ) 
            : 
            Column(
              children: [
                spacer.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PrudDataViewer(
                      field: "Cost", 
                      value: "${tabData.getCurrencySymbol(widget.channel.channelCurrency)}${currencyMath.roundDouble(widget.video.costPerNonMemberView, 2)}",
                      valueIsMoney: true,
                      inverseColor: true,
                      subValue: "Viewing",
                    ),
                    PointDivider(pointColor: prudColorTheme.primary,),
                    PrudDataViewer(
                      field: "Cost", 
                      value: "${tabData.getCurrencySymbol(widget.channel.channelCurrency)}${currencyMath.roundDouble(widget.channel.monthlyMembershipCost, 2)}",
                      valueIsMoney: true,
                      inverseColor: true,
                      subValue: "Membership",
                    ),
                    PointDivider(pointColor: prudColorTheme.primary,),
                    PrudDataViewer(
                      field: "Watch Locally", 
                      value: "${tabData.getCurrencySymbol(widget.channel.channelCurrency)}${currencyMath.roundDouble(downloadCost, 2)}",
                      valueIsMoney: true,
                      inverseColor: true,
                      subValue: "Download And",
                    ),
                  ],
                ),
                spacer.height,
                Translate(
                  text: "You will be charged the above amount for viewing this clip. You have other options to "
                  "either choose to join membership and get to watch all the clips from this channel, or download it "
                  "so you can watch it for as long as this app is installed on your device. What will it be?",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: prudColorTheme.textB,
                  ),
                  align: TextAlign.center,
                ),
                spacer.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    loading? LoadingComponent(
                      isShimmer: false,
                      size: 25,
                      spinnerColor: prudColorTheme.primary,
                    ) : prudWidgetStyle.getShortButton(
                      onPressed: view, text: "View Now",
                      isSmall: true
                    ),

                    joining? LoadingComponent(
                      isShimmer: false,
                      size: 25,
                      spinnerColor: prudColorTheme.primary,
                    ) : prudWidgetStyle.getShortButton(
                      onPressed: join, text: "Join Now",
                      isSmall: true
                    ),
                    downloading? LoadingComponent(
                      isShimmer: false,
                      size: 25,
                      spinnerColor: prudColorTheme.primary,
                    ) : prudWidgetStyle.getShortButton(
                      onPressed: download, text: "Download Now",
                      isSmall: true
                    ),
                  ],
                ),
                largeSpacer.height,
              ],
            ),
          )
        ),
      );
    });
  }
}