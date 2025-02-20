import 'package:flutter/material.dart';
    
class VideoScheduled extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoScheduled({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoScheduledState createState() => VideoScheduledState();
}

class VideoScheduledState extends State<VideoScheduled> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}