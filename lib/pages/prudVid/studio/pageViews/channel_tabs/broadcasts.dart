import 'package:flutter/material.dart';
import 'package:prudapp/components/broadcast_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_infinite_loader.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_broadcast.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

class ChannelBroadcasts extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;
  
  const ChannelBroadcasts({super.key, required this.channel, required this.isOwner});

  @override
  ChannelBroadcastsState createState() => ChannelBroadcastsState();
}

class ChannelBroadcastsState extends State<ChannelBroadcasts> {
  List<ChannelBroadcast> broadcasts = [];
  Widget noBroadcast = tabData.getNotFoundWidget(
    title: "No broadcast!",
    isRow: true,
    desc: "You are yet to make a public announcement/broadcast."
  );
  bool loading = false;
  bool loadingMore = false;
  int offset = 0;
  double lastScrollPoint = 0;
  ScrollController sCtrl = ScrollController();

  void openAddNew(){
    if(mounted) iCloud.goto(context, AddBroadcast(channel: widget.channel,));
  }

  Future<void> getMoreChannelBroadcast() async {
    await tryAsync("getMoreChannelBroadcast", () async {
      if(mounted) setState(() => loadingMore = true);
      List<ChannelBroadcast>? foundBroadcasts = await prudStudioNotifier.getChannelBroadcasts(
        channelId: widget.channel.id!, limit: 100, offset: offset
      );
      if(mounted) {
        setState((){
          if(foundBroadcasts != null && foundBroadcasts.isNotEmpty) broadcasts.addAll(foundBroadcasts);
          offset = broadcasts.length;                            
        });
        VisitedChannel vCha = VisitedChannel(
            channel: widget.channel, 
            lastVideoOffset: widget.channel.videos?.length?? 0, 
            lastBroadcastOffset: offset, 
            lastVideoScrollPoint: 0, 
            lastBroadcastScrollPoint: lastScrollPoint
          );
          prudStudioNotifier.updateChannelBroadcastToVisitedChannels(vCha, broadcasts);
      }
      if(mounted) setState(() => loadingMore = false);
    }, error: (){
      if(mounted) setState(() => loadingMore = false);
    });
  }

  Future<void> getChannelBroadcast() async {
    await tryAsync("getChannelBroadcast", () async {
      VisitedChannel? vCha = prudStudioNotifier.getCachedVisitedChannel(widget.channel.id!);
      if(vCha != null && vCha.channel.broadcasts != null){
        if(mounted) {
          setState((){
            broadcasts = vCha!.channel.broadcasts!;
            offset = vCha.lastBroadcastOffset;
            lastScrollPoint = vCha.lastBroadcastScrollPoint;
          });
          if(broadcasts.isNotEmpty && lastScrollPoint > 0) sCtrl.animateTo(lastScrollPoint, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      }else{
        if(mounted) setState(() => loading = true);
        List<ChannelBroadcast>? foundBroadcasts = await prudStudioNotifier.getChannelBroadcasts(
          channelId: widget.channel.id!, limit: 100, 
        );
        if(mounted) {
          setState((){
            if(foundBroadcasts != null && foundBroadcasts.isNotEmpty) broadcasts = foundBroadcasts;
            offset = broadcasts.length;                            
            loading = false;
          });
          vCha = VisitedChannel(
            channel: widget.channel, 
            lastVideoOffset: 0, 
            lastBroadcastOffset: offset, 
            lastVideoScrollPoint: 0, 
            lastBroadcastScrollPoint: 0
          );
          prudStudioNotifier.addChannelBroadcastToVisitedChannels(vCha, broadcasts);
        }
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getChannelBroadcast();
    });
    super.initState();
    sCtrl.addListener(() async {
      if(mounted){
        setState(() => lastScrollPoint = sCtrl.offset);
        VisitedChannel vCha = VisitedChannel(
          channel: widget.channel, 
          lastVideoOffset: 0, 
          lastBroadcastOffset: offset, 
          lastVideoScrollPoint: 0, 
          lastBroadcastScrollPoint: lastScrollPoint
        );
        prudStudioNotifier.updateChannelBroadcastToVisitedChannels(vCha, broadcasts);
      }
      if(sCtrl.position.pixels == sCtrl.position.maxScrollExtent && broadcasts.isNotEmpty) await getMoreChannelBroadcast();
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
    return Stack(
      children: [
        SizedBox(
          height: screen.height,
          child: loading? Center(
            child: LoadingComponent(
              isShimmer: false,
              size: 40,
              spinnerColor: prudColorTheme.iconC
            ),
          ) 
          :
          broadcasts.isEmpty? Center(child: noBroadcast,) : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) => BroadcastComponent(
                    broadcast: broadcasts[index],
                    isChannel: true,
                    isOwner: widget.isOwner,
                  ),
                ),
              ),
              if(loadingMore && broadcasts.isNotEmpty) PrudInfiniteLoader(text: "Broadcasts"),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: FloatingActionButton.small(
              onPressed: openAddNew,
              backgroundColor: prudColorTheme.primary,
              foregroundColor: prudColorTheme.bgA,
              tooltip: "Add New Broadcast",
              child: ImageIcon(
                AssetImage(prudImages.announceMsg),
                size: 15,
                color: prudColorTheme.bgA,
              ),
            ),
          ),
        )
      ],
    );
  }
}