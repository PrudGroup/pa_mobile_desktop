import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/models/prud_vid.dart';

class ChannelLives extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;
  
  const ChannelLives({super.key, required this.channel, required this.isOwner});

  @override
  ChannelLivesState createState() => ChannelLivesState();
}

class ChannelLivesState extends State<ChannelLives> {
  
  @override
  Widget build(BuildContext context) {
    return WorkInProgress();
  }
}