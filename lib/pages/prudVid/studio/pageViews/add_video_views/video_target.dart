import 'package:flutter/material.dart';
    
class VideoTarget extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoTarget({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoTargetState createState() => VideoTargetState();
}

class VideoTargetState extends State<VideoTarget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}