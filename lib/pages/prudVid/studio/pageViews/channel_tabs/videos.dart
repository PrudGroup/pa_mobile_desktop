import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';

import '../../../../../components/translate_text.dart';
import '../../../../../components/work_in_progress.dart';
import '../../../../../models/theme.dart';

class ChannelVideos extends StatefulWidget {

  final VidChannel channel;
  final bool isOwner;
  const ChannelVideos({super.key, required this.channel, required this.isOwner});

  @override
  ChannelVideosState createState() => ChannelVideosState();
}

class ChannelVideosState extends State<ChannelVideos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Channel Videos",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: const WorkInProgress(),
    );
  }
}
