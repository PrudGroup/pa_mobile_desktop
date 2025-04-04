import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';

import '../../../../../components/translate_text.dart';
import '../../../../../components/work_in_progress.dart';
import '../../../../../models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class ChannelPlaylists extends StatefulWidget {
  final VidChannel channel;
  final bool isOwner;
  
  const ChannelPlaylists({super.key, required this.channel, required this.isOwner});

  @override
  ChannelPlaylistsState createState() => ChannelPlaylistsState();
}

class ChannelPlaylistsState extends State<ChannelPlaylists> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: prudColorTheme.bgA,
          ),
          onPressed: () => iCloud.goBack(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Channel Playlist",
          style: prudWidgetStyle.tabTextStyle.copyWith(fontSize: 16, color: prudColorTheme.bgA),
        ),
        actions: const [],
      ),
      body: const WorkInProgress(),
    );
  }
}
