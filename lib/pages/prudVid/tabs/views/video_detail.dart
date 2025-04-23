import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';
    
class VideoDetail extends StatefulWidget {
  final ChannelVideo? video;
  final String? videoId;
  final String? affLinkId;
  final VidChannel? channel;
  final DownloadedVideo? localVid;

  const VideoDetail({
    super.key, this.video, this.videoId, this.affLinkId,
    this.channel, this.localVid
  });

  @override
  VideoDetailState createState() => VideoDetailState();
}

class VideoDetailState extends State<VideoDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(),
    );
  }
}