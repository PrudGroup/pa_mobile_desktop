import 'package:flutter/material.dart';
    
class VideoSnippets extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoSnippets({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoSnippetsState createState() => VideoSnippetsState();
}

class VideoSnippetsState extends State<VideoSnippets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}