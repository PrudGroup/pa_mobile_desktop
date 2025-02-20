import 'package:flutter/material.dart';
    
class VideoMusic extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoMusic({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoMusicState createState() => VideoMusicState();
}

class VideoMusicState extends State<VideoMusic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}