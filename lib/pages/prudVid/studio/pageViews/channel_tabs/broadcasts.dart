import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/models/prud_vid.dart';

class ChannelBroadcasts extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;
  
  const ChannelBroadcasts({super.key, required this.channel, required this.isOwner});

  @override
  ChannelBroadcastsState createState() => ChannelBroadcastsState();
}

class ChannelBroadcastsState extends State<ChannelBroadcasts> {
  
  @override
  Widget build(BuildContext context) {
    return WorkInProgress();
  }
}