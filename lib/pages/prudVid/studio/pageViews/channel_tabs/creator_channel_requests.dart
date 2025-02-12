import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/models/prud_vid.dart';
    
class CreatorChannelRequests extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;
  
  const CreatorChannelRequests({super.key, required this.channel, required this.isOwner});

  @override
  CreatorChannelRequestsState createState() => CreatorChannelRequestsState();
}

class CreatorChannelRequestsState extends State<CreatorChannelRequests> {
  
  @override
  Widget build(BuildContext context) {
    return WorkInProgress();
  }
}