import 'package:flutter/material.dart';
    
class VideoPublishType extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoPublishType({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoPublishTypeState createState() => VideoPublishTypeState();
}

class VideoPublishTypeState extends State<VideoPublishType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}