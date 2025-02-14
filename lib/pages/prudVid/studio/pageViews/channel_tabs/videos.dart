import 'package:flutter/material.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_infinite_loader.dart';
import 'package:prudapp/components/video_component.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

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
  bool gettingMore = false;   
  Widget noVideos = tabData.getNotFoundWidget(
    title: "No Video!",
    desc: "This channel is yet to upload contents. Stay tuned.",
    isRow: true,
  );
  int offset = 0;
  double lastScrollPoint = 0;
  ScrollController sCtrl = ScrollController();

  Future<List<ChannelVideo>?> getFromCloud(bool isInit) async {
    return await tryAsync("getVideos", () async {
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
    if(mounted) setState(() => gettingMore = true);
    List<ChannelVideo>? vids = await getFromCloud(false);
    if(vids != null && vids.isNotEmpty){
      if(mounted) {
        setState(() {
          videos.addAll(vids);
          offset += vids.length;
        });
        prudStudioNotifier.lastOffsetChannelVideos = offset;
        prudStudioNotifier.selectedChannelId = widget.channel.id;
        prudStudioNotifier.selectedChannelVideos = vids;
      }
    }
    if(mounted) setState(() => gettingMore = false);
  }

  Future<void> getVideos() async {
    if(prudStudioNotifier.selectedChannelId == widget.channel.id && prudStudioNotifier.selectedChannelVideos.isNotEmpty){
      if(mounted) {
        setState((){
          videos = prudStudioNotifier.selectedChannelVideos;
          offset = prudStudioNotifier.lastOffsetChannelVideos;
          lastScrollPoint = prudStudioNotifier.lastScrollPointChannelVideos;
        });
        sCtrl.animateTo(lastScrollPoint, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
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
          prudStudioNotifier.lastOffsetChannelVideos = offset;
          prudStudioNotifier.selectedChannelId = widget.channel.id;
          prudStudioNotifier.selectedChannelVideos = vids;
        }
      }
      if(mounted) setState(() => loading = false);
    }
  }

  
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getVideos();
    });
    super.initState();
    sCtrl.addListener(() async {
      if(mounted){
        lastScrollPoint = sCtrl.offset;
        prudStudioNotifier.lastScrollPointChannelVideos = lastScrollPoint;
      }
      if(sCtrl.position.pixels == sCtrl.position.maxScrollExtent) await getMoreVideos();
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
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                controller: sCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return PrudVideoComponent(
                    video: videos[index],
                    isOwner: widget.isOwner,
                  );
                },
              ),
            ),
            if(gettingMore) PrudInfiniteLoader(text: "Video Clips"),
          ],
        ) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [noVideos],
        )
      ),
    );
  }
}
