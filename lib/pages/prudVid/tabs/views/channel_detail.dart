import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_view.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class ChannelDetail extends StatefulWidget {
  final String? cid;

  const ChannelDetail({super.key, this.cid});

  @override
  ChannelDetailState createState() => ChannelDetailState();
}

class ChannelDetailState extends State<ChannelDetail> {
  VidChannel? channel;
  Future<void> getChannel() async {
    await tryAsync("getChannel", () async {
      // TODO: getChannel
    });
  }

  @override
  Widget build(BuildContext context) {
    return channel != null? ChannelView(channel: channel!, isOwner: false) : SizedBox();
  }
}