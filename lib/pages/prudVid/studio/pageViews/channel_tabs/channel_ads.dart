import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/models/prud_vid.dart';
    
class ChannelAds extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;
  
  const ChannelAds({super.key, required this.channel, required this.isOwner});

  @override
  ChannelAdsState createState() => ChannelAdsState();
}

class ChannelAdsState extends State<ChannelAds> {
  @override
  Widget build(BuildContext context) {
    return WorkInProgress();
  }
}