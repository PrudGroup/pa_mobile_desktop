import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/multi_player/flick_multi_manager.dart';
import 'package:prudapp/components/prud_infinite_loader.dart';
import 'package:prudapp/components/video_component.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../models/theme.dart';

class ChannelVideos extends StatefulWidget {

  final VidChannel channel;
  final bool isOwner;
  const ChannelVideos({super.key, required this.channel, required this.isOwner});

  @override
  ChannelVideosState createState() => ChannelVideosState();
}

class ChannelVideosState extends State<ChannelVideos> {
  List<ChannelVideo> videos = [];
  bool loading = false;
  bool loaded = false;
  bool gettingMore = false;  
  Widget noVideos = tabData.getNotFoundWidget(
    title: "No Video!",
    desc: "This channel is yet to upload contents. Stay tuned.",
    isRow: true,
  );
  int offset = 0;
  double lastScrollPoint = 0;
  ScrollController sCtrl = ScrollController();
  late FlickMultiManager flickMultiManager;

  Future<List<ChannelVideo>?> getFromCloud(bool isInit) async {
    return await tryAsync("getFromCloud", () async {
      return prudStudioNotifier.getChannelVideos(
        channelId: widget.channel.id!,
        limit: 50,
        offset: isInit? null : offset
      );
    }, error: (){
      return null;
    });
  }

  Future<void> getMoreVideos() async {
    await tryAsync("getMoreVideos", () async {
      if(mounted) setState(() => gettingMore = true);
      List<ChannelVideo>? vids = await getFromCloud(false);
      if(vids != null && vids.isNotEmpty){
        if(mounted) {
          setState(() {
            videos.addAll(vids);
            offset += vids.length;
          });
          VisitedChannel vCha = VisitedChannel(
            channel: widget.channel, 
            lastVideoOffset: offset, 
            lastBroadcastOffset: widget.channel.broadcasts?.length?? 0, 
            lastVideoScrollPoint: lastScrollPoint, 
            lastBroadcastScrollPoint: 0
          );
          prudStudioNotifier.updateChannelVideoToVisitedChannels(vCha, videos);
        }
      }
      if(mounted) setState(() => gettingMore = false);
    }, error: (){
      if(mounted) setState(() => gettingMore = false);
    });
  }

  Future<void> getVideos() async {
    await tryAsync("getVideos", () async {
      VisitedChannel? vCha = prudStudioNotifier.getCachedVisitedChannel(widget.channel.id!);
      if(vCha != null && vCha.channel.videos != null){
        if(mounted) {
          setState((){
            videos = vCha!.channel.videos!;
            offset = vCha.lastVideoOffset;
            lastScrollPoint = vCha.lastVideoScrollPoint;
          });
          if(videos.isNotEmpty && lastScrollPoint > 0) sCtrl.animateTo(lastScrollPoint, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      }else{
        if(mounted) setState(() => loading = true);
        List<ChannelVideo>? vids = await getFromCloud(true);
        if(vids != null && vids.isNotEmpty){
          if(mounted) {
            setState(() {
              videos = vids;
              offset = vids.length;
            });
            vCha = VisitedChannel(
              channel: widget.channel, 
              lastVideoOffset: offset, 
              lastBroadcastOffset: widget.channel.broadcasts?.length?? 0, 
              lastVideoScrollPoint: 0, 
              lastBroadcastScrollPoint: 0
            );
            prudStudioNotifier.addChannelVideoToVisitedChannels(vCha, vids);
          }
        }
        if(mounted) setState(() => loading = false);
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  
  @override
  void initState() {
    flickMultiManager = FlickMultiManager();
    Future.delayed(Duration.zero, () async {
      await getVideos();
      if(mounted) setState(() => loaded = true);
    });
    super.initState();
    sCtrl.addListener(() async {
      if(mounted){
        setState(() => lastScrollPoint = sCtrl.offset);
        VisitedChannel vCha = VisitedChannel(
          channel: widget.channel, 
          lastVideoOffset: offset, 
          lastBroadcastOffset: widget.channel.broadcasts?.length?? 0, 
          lastVideoScrollPoint: lastScrollPoint, 
          lastBroadcastScrollPoint: 0
        );
        prudStudioNotifier.updateChannelVideoToVisitedChannels(vCha, videos);
      }
      if(sCtrl.position.pixels == sCtrl.position.maxScrollExtent && videos.isNotEmpty) await getMoreVideos();
    });
  }

  @override
  void dispose() {
    sCtrl.removeListener((){});
    sCtrl.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: loading? Center(
        child: LoadingComponent(
          isShimmer: false,
          size: 40,
          spinnerColor: prudColorTheme.iconC
        ),
      ) 
      : 
      (
        videos.isNotEmpty? Column(
          children: [
            Expanded(
              child: VisibilityDetector(
                key: ObjectKey(flickMultiManager),
                onVisibilityChanged: (visibility) {
                  if (visibility.visibleFraction == 0 && mounted) {
                    flickMultiManager.pause();
                  }
                },
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: sCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return PrudVideoComponent(
                      video: videos[index],
                      thriller: videos[index].thriller,
                      channel: widget.channel,
                      isOwner: widget.isOwner,
                      noBorderRadius: false,
                      flickMultiManager: flickMultiManager,
                    );
                  },
                ),
              ),
            ),
            if(gettingMore) PrudInfiniteLoader(text: "Clips"),
          ],
        ) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [if(loaded) noVideos],
        )
      ),
    );
  }
}
