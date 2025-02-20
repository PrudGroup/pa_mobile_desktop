import 'package:flutter/material.dart';
    
class VideoTitles extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoTitles({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoTitlesState createState() => VideoTitlesState();
}

class VideoTitlesState extends State<VideoTitles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}