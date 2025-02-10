import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/models/prud_vid.dart';

class ChannelMemberships extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;
  
  const ChannelMemberships({super.key, required this.channel, required this.isOwner});

  @override
  ChannelMembershipsState createState() => ChannelMembershipsState();
}

class ChannelMembershipsState extends State<ChannelMemberships> {
  
  @override
  Widget build(BuildContext context) {
    return WorkInProgress();
  }
}